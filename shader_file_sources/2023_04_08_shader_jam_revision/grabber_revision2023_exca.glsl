#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
 
uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients 
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float fftS = 0.0;
float fftI = 0.0;

// Matrix rotations.
mat3 RotX(float a)
{
    return mat3(
        1.0, 0.0, 0.0, 
        0.0, cos(a), -sin(a), 
        0.0, sin(a), cos(a)
    );
}
mat3 RotY(float a)
{
    return mat3(
        cos(a), 0.0, sin(a), 
        0.0, 1.0, 0.0, 
        -sin(a), 0.0, cos(a)
    );
}
mat3 RotZ(float a)
{
    return mat3(
        cos(a), -sin(a), 0.0, 
        sin(a), cos(a), 0.0, 
        0.0, 0.0, 1.0
    );
}
mat3 Rot(float x,float y,float z)
{
    return RotX(x)*RotY(y)*RotZ(z);
}

vec3 repeat( vec3 p, vec3 q)
{
  return mod( p + 0.5 *q, q)- 0.5*q;
}

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross(vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  return normalize( uv.y * up + uv.x * right + fov * forward);
}

float rbox( vec3 p, vec3 b, float r)
{
  vec3 q = abs(p)-b;
  return length( max(q, 0.0)) + min(max(q.x, max(q.y, q.z)),0.0)-r;
}

float sphere( vec3 p, float r)
{
  return length(p)-r;
}

float ground( vec3 p, float h)
{
  return p.y  - h;
}

vec3 U(vec3 a, vec3 b)
{
  return a.x < b.x ? a : b;
}

vec2 gh( vec3 p)
{
  vec2 gx = p.xz;
  vec2 sined = vec2( sin(gx.x*0.4), cos(gx.y*0.3));
  sined += (Rot(0.0, 0.7,0.0)*vec3(sined*3.4+vec2(0.5+fftS,1.3),0.0)).xy*0.75;
  sined += (Rot(0.0, 1.7,0.0)*vec3(sined*7.3+vec2(2.5-40.0*sin(fftI*0.4-0.3),1.3),0.0)).xy*0.5;
  sined += (Rot(0.1, 0.7,3.0)*vec3(sined*16.5+vec2(4.5+sin(fftI)*4.0,3.3),0.0)).xy*0.2;
  return sined;
  
}

vec3 map( vec3 p)
{
  vec3 op = p * Rot(0.0,fftI*2.1, 0.0) + vec3(0.0, -0.75, 0.0);
  
  vec2 towerIndex = floor( op.xz/0.2); 
   op = repeat( op, vec3( 8.0, 0.0, 8.0));
  float s1 = sphere(op + vec3( 0.0, sin(fGlobalTime)*0.0-0.5, 0.0), length(op)*0.3+ 1.25+smoothstep(0.005, 0.075,fftS)*4.0);
  float b1 = rbox( 
    repeat(op, vec3( 0.4+fftS, 0.0, 0.4)), 
    vec3(0.1+fftS*30.0, 45.0 * fftS + 0.25 + sin(towerIndex.y+fftI)+cos(towerIndex.x+fftI), 0.1), 0.01);
  
  b1 = max(s1, b1);
  
  b1 = min(max(s1, ground(p, 0.5)), b1);
  
  
  float h = gh(p + vec3(fftI, -fftI, -fftI*3.3)).x;
  float g1 = ground(p, h*0.1);
  
  vec3 mat = U(
    vec3( b1, 2.0, 0.0),
    vec3( g1, 1.0, 0.0)
  );
  
  return mat;
}

vec3 march(vec3 cam, vec3 rd, out vec3 p, out float t)
{
  p = cam; t = 0.0;
  for(int i = 0; i < 100; i++)
  {
    p = cam + rd * t;
    vec3 r = map(p);
    t+=r.x;
    if(r.x < 0.01)
    {
      return r;
    }
    if(t > 50.0)
    {
      t = 50.0;
      return vec3(-1.0);
    }
  }
  return vec3(-1.0);
}

vec3 normal( vec3 p )
{
  vec2 e = vec2(0.01, 0.0);
  vec3 c = map( p);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  
  )-c.x);
}

float light(vec3 p, vec3 l, vec3 n)
{
  return max(0.0, dot(normalize(l-p), n));
}

vec3 col1 = vec3(1.0, 0.65, 0.2);
vec3 col2 = vec3(0.2, 0.65, 1.0);

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 c = vec3(0.0);
  
  fftS = texture(texFFTSmoothed, 0.25).r;
  fftI = texture(texFFTIntegrated, 0.25).r*1.75 + fGlobalTime*0.01;
  
  
  vec3 cam  = vec3( sin(sin(fftI)*0.001)*5.0, cos(fftI* 0.1)*3.0+5.2, cos(fftI*0.001)*3.0);
  vec3 light1 = vec3( sin(fGlobalTime), 2.0, 1.0);
  vec3 target = vec3(0,0.85,0);
  float fov = 0.9 + step( mod(fftI,2.0), 1.0)*2.0  -0.24* step( mod(fftI*0.5,2.0), 1.0);
  vec3 rd = getcam( cam, target, uv, fov);
  
  vec3 marchP = cam; float marchT = 0.0;
  vec3 result = march( cam, rd, marchP, marchT);
  
  if(result.y > 1.5)
  {
    // ball
    vec3 n =  normal(marchP);
    float l1 = light(marchP, light1, n);
    float gridI = mod( floor(marchP.x) + floor(marchP.z), 2.0 );
    c = vec3(1.0)  * l1 * mix( col1, col2, gridI);
  }
  else if(result.y > 0.5)
  {
    //ground
    vec3 n =  normal(marchP);
    float l1 = light(marchP, light1, n);
    float gridI = mod( floor(marchP.x) + floor(marchP.z), 2.0 );
    c = 0.25* mix(vec3(0.0, 0.4, 1.0), vec3(1.4,0.4, 1.0), -marchP.y*fftS*130.0)  * l1;
  }
  
  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  uv -= vec2(0.5, 0.25);
  uv *= 0.99;
  uv += vec2(0.5, 0.25);
  vec3 prev = texture(texPreviousFrame, uv).rgb;
  
  c += mix( c + prev*0.5, c+ prev*1.5, smoothstep(0.0, 0.04, fftS));
  
  float modt = mod( fftI, 4.0);
  if(modt < 1.0) c.rgb = c.grb;
  else if(modt < 2.0) c.rgb = c.brg;
  else if(modt < 3.0) c.rgb = c.rbg;
  
  
  //c = 1.0-c;//
  
	out_color = vec4(c, 1.0);
}
