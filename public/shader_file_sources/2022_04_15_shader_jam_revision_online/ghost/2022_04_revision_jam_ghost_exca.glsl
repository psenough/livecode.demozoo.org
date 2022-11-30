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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float fft = 0.0;
float ffts = 0.0;
float ffti = 0.0;
float time = 0.0;

vec3 cam = vec3(0.0);
vec3 target = vec3(0.0);

vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3( 1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y));
  mat3 rotz = mat3( cos(z), - sin(z), 0.0, sin(z), cos(z), 0.0,0.0,0.0, 1.0);
  return rotx*rotz*roty*p;
  
}

vec3 repeat( vec3 p, vec3 c)
{
  return mod(p + 0.5*c, c)-0.5*c;
}

vec3 texmap( vec3 p, vec3 n)
{
  return mat3( texture(texTex2, p.yz).rgb, texture(texTex2, p.xz).rgb, texture(texTex2, p.yz).rgb)*n;
}


vec3 getcam(vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross( vec3(0,1,0), forward) );
  vec3 up = normalize( cross( forward, right )) ;
  return normalize( forward*fov + right * uv.x + up * uv.y);
}

float ground( vec3 p, float h)
{
  return p.y-h;
}

vec3 U( vec3 a, vec3 b)
{
  return vec3(  min(a.x,b.x), mix(a.y, b.y,step(b.x, a.x)), mix(a.z, b.z,step(b.x, a.x)));
}

float roundbox( vec3 p, vec3 b, float r)
{
  vec3 d = abs(p)-b;
  return min(max(d.x, max(d.y, d.z)), 0.0)+length(max(d,0.0))-r;
}

vec3 map( vec3 p)
{
  float gh = texture(texNoise, p.xz*0.02).r + texture(texNoise, p.xz*0.02).r*3.0;
  
  
  vec3 cp = repeat( p, vec3( 8.0, 0.0, 8.0));
  cp =rotate( cp+vec3(0, -4.0, 0.0), ffti,0.0, 0.0);
  
  float cube = roundbox( cp, vec3(1,0.5,1),0.15);
  float gr = ground(
    p, 
    gh
  );
  
  vec3 u = vec3( cube, 1.0, gh);
  u = U( u, vec3(gr, 2.0, gh));
  
  return u;
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, out float t)
{
  for(int i = 0; i < 300; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p);
    t += r.x;
    if(r.x < 0.01){
      return r;
    }
    if(t > 50.0)
    {
      return vec3(-1.0);
    }
  }
  return vec3(-1.0);
}

float fftd( float cmp, float x)
{
  return smoothstep(0.01, 0.0,abs( texture(texFFT, x).r-cmp));
}

vec3 normal( vec3 p)
{
  vec3 c = map(p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x);
}

float light( vec3 p, vec3 l, vec3 n)
{
  return max( 0.0, dot(n, normalize(l-p)));
}

void main(void)
{
  time = fGlobalTime;
  
  fft = texture(texFFT, 0.05).r;
  ffts = texture(texFFTSmoothed, 0.05).r;
  ffti = texture(texFFTIntegrated, 0.05).r;
  
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 vuv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  vec3 col1 = vec3( 1.0, 0.9, 0.75);
  vec3 col2 = vec3( 0.0, 0.5, 0.75);
  
  vec3 light1 = vec3( sin(time)*10.0, 5.0, cos(time)*5.0);
  
  vec3 col = vec3(0.0);
  cam = vec3(0,8,20);
  
  
  target = vec3(0,1,0.0);
  float fov = 1.2;
  
  vec3 rd = getcam( cam, target, uv, fov);
  
  vec3 p = cam;
  float travel = 0.0;
  vec3 res = march( cam, rd, p, travel);
  
  if(res.y > 1.5)
  {
    vec3 n = normal(p);
    float sx = floor(mod(p.x, 2.0));
    float sz = floor(mod(p.z, 2.0));
    
    col = mix( col1, col2, sx + sz) * light(p, light1, n);
    
    
    //col = vec3(0.2, 0.6, 0.9)* smoothstep(-0.5, 0.5,res.z);
    col = mix( col, col2, smoothstep(0.0, 0.5,res.z));
    col *= light(p, light1, n);
  }
  else if(res.y > 0.5)
  {
    vec3 n = normal(p);
    col = vec3(1.0, 0.8,0.2) * light(p, light1, n);
    
    vec3 refd = reflect( rd, n);
    vec3 refoutP = p;
    float refoutT= 0.0;
    vec3 refr = march( p+refd*0.02, refd, refoutP, refoutT);
    vec3 rcol = vec3(0.0);
    if(refr.y > 1.5)
    {
      vec3 rn = normal(refoutP);
      float sx = floor(mod(refoutP.x, 2.0));
      float sz = floor(mod(refoutP.z, 2.0));
      
      rcol = mix( col1, col2, sx + sz) * light(refoutP, light1, rn);
      
      rcol = vec3(0.2, 0.6, 0.9)* smoothstep(-0.5, 0.5,res.z);
      rcol = mix( rcol, vec3(0., 0.8, 0.3), smoothstep(0.0, 0.5,res.z));
      rcol *= light(refoutP, light1, rn);
    }
    else
    {
      vec3 rn = normal(refoutP);
      rcol = vec3(1.0)* texmap(refoutP, rn) * light(refoutP, light1, rn);
    
    }
    col = mix(col, rcol, 0.5);
  }
  
  
  vec2 center = vec2( 0.5);
  vec2 duv = center - vuv;
  float angle = atan( duv.y, duv.x)*0.25;
  vec3 fftc = mix( vec3(0.0,0.0, 0.2), vec3(0.2, 0.5,0.4), 1.0-vuv.y)+vec3(.5)*fftd( 1.0-vuv.y, 0.1+abs(0.5-vuv.x) );
  
  
  col = mix(col, fftc, smoothstep(20.0, 50.0, travel));
  
  
  
	out_color = vec4(col, 1.0);
}






















