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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float ffti = 0.0;
float ffts = 0.0;
float fft = 0.0;
float iTime = fGlobalTime;

float txt(vec2 p,float t)
{
     ivec2 i = ivec2(abs(p)*128.);
      return dot(sin(i),cos(i.yx*t))+(i.x&i.y)/128.;;
}

vec4 sessions(vec2 uv)
{
  uv = mod(uv, vec2(1.0));
  uv -= 0.5;
	
  float bpm=fGlobalTime;
    #define spl mod(fGlobalTime*140/60*4+.2,8)<4 ? texSessions:texSessionsShort
    vec3 col =vec3(0.);
    col.r= texture(spl,clamp(uv*vec2(1.,-1)+.5+texture(texFFTSmoothed,floor(bpm*10)*.1+txt(uv,1.)).r,0.,1.)).r;
    col.gb= texture(spl,clamp((uv*vec2(1.,-1)+.5)+texture(texFFTSmoothed,floor(bpm*10)*.1+txt(uv,2.)).r,0.,1.)).gb;
    return vec4(col, length(col.rgb));
}

vec2 rot2d( float a, vec2 p)
{
  return mat2( cos(a), -sin(a), sin(a), cos(a)) * p;
}

float smin( float a, float b, float k)
{
  float h = clamp( 0.5 + 0.5 * (b - a ) / k, 0.0, 1.0);
  float dist = mix(b,a,h) - k*h*(1.0-h);
  return dist;
}

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross( vec3( 0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  return normalize( forward*fov + uv.x * right + uv.y*up);
}

float sphere( vec3 p, float r)
{
  return length(p)-r;
}

float hexPrism( vec3 p, vec2 h )
{
  const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
  vec2 d = vec2(
       length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
       p.z-h.y );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float octahedron( vec3 p, float s)
{
  p = abs(p);
  return (p.x+p.y+p.z-s)*0.57735027;
}

float box(vec3 pos, vec3 size)
{
 	vec3 q = abs(pos)-size;
    return length(max(q,0.) + min(max(q.x, max(q.y, q.z)), 0.));
}
float ibox(vec3 pos, vec3 size)
{
 	vec3 q = size-abs(pos);
    return length(max(q,0.) + min(max(q.x, max(q.y, q.z)), 0.));
}


vec3 union( vec3 a, vec3 b){
  if(a.x < b.x) return a;
  return b;
}

vec3 map( vec3 p)
{
  float spSize = smoothstep(0.0, 0.1,ffts)* length(p*p*0.56 + sin(ffti))*smoothstep(0.0, 0.01,ffts)*50.0 + 0.1*abs( sin(p.x+iTime) * sin(p.y-0.4*iTime)* sin(p.z-0.8*iTime));
  
  float s1 = sphere( p, 0.25+spSize*0.3);
  float h1 = hexPrism(p, vec2( 0.5, 0.3+spSize));
  float o1 = octahedron(p, 0.3+spSize);
  
  float bt = mod(ffti*5.0, 3.0)/3.0;
  
  o1 = mix( smin( 
    mix( o1, h1, smoothstep(0.0, 0.05,ffts)),
    mix( s1, o1, smoothstep(0.0, 0.05,ffts)), 
    0.3
  ),smin( 
    mix( o1, s1, smoothstep(0.0, 0.05,ffts)),
    mix( h1, s1, smoothstep(0.0, 0.05,ffts)), 
    0.3
  ),bt);
  
  float b1 = ibox(p, vec3(4.0,4.0,4.0)*3.0 );
  
  vec3 S1 = vec3(o1, 1.0, 0.0);
  vec3 B1 = vec3(b1, 2.0, 0.0);
  vec3 OBJ = union(S1, B1);
  return OBJ;
}

vec3 march(vec3 cam, vec3 rd, out vec3 p, out float t)
{
  for(int i = 0; i < 100; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p);
    t+=r.x;
    if(r.x < 0.001)
    {
      return r;
    }
    if(t > 50.0){
      t = 50.0;
      return vec3(-1.0);
    }
  }
  return vec3(-1.0);
}

vec3 normal( vec3 p)
{
  vec3 c = map(p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  ) - c.x );
}
float light( vec3 p, vec3 l, vec3 n)
{
  return max(0.0, dot(n, normalize(l-p)));
}

vec3 col1 = vec3(1.0, 0.5, 0.0);
vec3 col2 = vec3(0.0, 0.5, 1.0);
vec3 col3 = vec3(0.25, 1.0, 0.25);

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ouv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  //FFT 
  ffti = texture(texFFTIntegrated, 0.2).r;
  ffts = texture(texFFTSmoothed, 0.2).r;
  fft = texture(texFFT, 0.2).r;
  
  
  // Marching
  vec3 c = vec3(0.0);
  
  // Cam
  float spSize = smoothstep(0.0, 0.1,ffts)* smoothstep(0.0, 0.01,ffts)*50.0;
  vec3 cam = vec3( 
    sin(ffti + mod(ffti*5.0,2.0))*3.0, 
    cos(ffti + mod(ffti*5.0,3.0))*3.0,
    sin(ffti*0.3 + mod(ffti*5.0,4.0))*3.0
  )*(1.0+0.5*spSize);
  vec3 target = vec3( 0,0,0);
  float fov = 1.0;
  fov += smoothstep( 0.0, 0.25, sin(ffti))*3.0 - 
         smoothstep( 0.25, 0.5, sin(ffti))*-2.0 -
         smoothstep( 0.75, 1.0, sin(ffti))*-0.4; 
         
        fov = 1.7;
  vec3 rd = getcam( cam, target, uv, fov);
  
  
  // Lights
  vec3 light1 = vec3( sin( iTime) * 4.0, 4.0, 0.0);
  vec3 light2 = vec3( sin( iTime*0.3) * 4.0, 4.0, cos(iTime*0.7) * 4.0);
  vec3 light3 = vec3( sin( iTime*0.987) * 4.0, sin(iTime*1.4)* 4.0, cos(iTime*0.23) * 4.0);
  
  vec3 marchP = cam;
  float marchT = 0.0;
  vec3 res = march( cam, rd, marchP, marchT);
  
  if(res.y > 1.5){
    // Cube
    vec3 n = normal(marchP);
    float l1 = light( marchP, light1, n);
    float l2 = light( marchP, light2, n);
    float l3 = light( marchP, light3, n);
    c = col1 * l1 + col2 * l2 + col3 * l3;
    c *= 1.0+ sessions(mod( 0.1*vec2( marchP.x+ marchP.y, marchP.z + marchP.x), vec2(1.0))).rgb;
  }
  else if(res.y > 0.5)
  {
    // Sphere
    vec3 n = normal(marchP);
    float l1 = light( marchP, light1, n);
    float l2 = light( marchP, light2, n);
    float l3 = light( marchP, light3, n);
    c = col1 * l1 + col2 * l2 + col3 * l3;
  }
  else
  {
    // Bg
  }
  
  // Feedback loop
  ouv -=0.5;
  ouv*0.9;
  ouv +=0.5;
  vec3 previous = texture(texPreviousFrame, ouv).rgb;
  
  c = mix(c*0.5, previous*0.99+c*0.25, smoothstep(0.0, 0.005,ffts)*0.75);
  
	out_color = vec4(c,1.0);
}















