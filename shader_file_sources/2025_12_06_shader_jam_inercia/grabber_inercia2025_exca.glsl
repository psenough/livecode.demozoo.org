#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaID;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


float time = 0.0;
float beat = 0.0;
float bar = 0.0;
float beatStep = 0.0;
float barSTep =  0.0;
float fft = 0.0;
float fftS = 0.0;
float fftI = 0.0;
float glow = 0.0;

const float SPHERE = 1.0;

vec3 repeat( vec3 p, vec3 q)
{
  return mod(p+q*0.5, q)-q*0.5;
}

float gyroid( vec3 seed) { return dot(cos(seed), sin(seed.zxy));}
float gyroidSurface( vec3 p, float scale, float thickness, float bias)
{
  p *= scale;
  float gyroid = abs(dot(sin(p)*2.0, cos(p.zxy*1.23))-bias)/(scale*2.0*1.23)-thickness;
  return gyroid;
}

float fbm(vec3 p)
{
  float t = 0.0;
  float a = 0.0;
  for(int i = 0; i< 8; i++)
  {
    p.z -= 0.1*t;
    t += abs(gyroid(p/a))*a;
    a*=0.5;
  }
  return t;
}

float smin( float a, float b, float k)
{
  float h = clamp( 0.5 + 0.5 * (b-a)/k, 0.0, 1.0);
  return mix( b,a,h-k) - k*h*(1.0-h);
}

vec4 getTexture(sampler2D sampler, vec2 uv){
     vec2 size = textureSize(sampler,0);
     float ratio = size.x/size.y;
     return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
}

vec3 getcam(vec3 from, vec3 to, vec2 uv, float fov)
{
  vec3 forward =  normalize(to - from);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize(cross(forward,right));
  return normalize( forward * fov + uv.x * right + uv.y*up);
}

float sphere(vec3 p, float r)
{
  return length(p)-r;
}

vec3 map( vec3 p )
{
   p = repeat(p, vec3(10.0,10.0, 10.0));
  
  float t1 = time + fftI*0.6;
  float t2 = time*0.5 + fftI*0.32;
  float t3 = time*0.9 + fftI*0.65;
  
  
  vec3 S1p = vec3( sin(t1*2.2), cos(t1*1.2), sin(t1*0.785))*1.0;
  vec3 S2p = vec3( sin(t2*1.2), cos(t2*0.2), sin(t2*0.85))*1.0;
  vec3 S3p = vec3( sin(t3*2.7), cos(t3*2.0), sin(t3*1.785))*1.0;
  
  float S1 = sphere(p+S1p,2.65+ sin(fftI));
  float S2 = sphere(p+S2p,2.65);
  float S3 = sphere(p+S3p,2.65);
  S1 = smin(S1, S2,0.5 + fftS*15.0);
  S1 = smin(S1, S3,0.5 + fftS*15.0);
  
  float gyroidD = gyroidSurface(p+fftI, 12.0 + sin(fftI*0.02), 0.01+sin(fftI*0.1)*0.01, 0.5+ sin(fftI*0.2)*0.3);
  S1 = max(gyroidD, S1);
  
  glow += (1.0- smoothstep(0.0, 0.05, S1) )*0.2;
  
  
  return vec3(S1, SPHERE, 0.0);
}

vec3 normal( vec3 p)
{
  vec3 c = map(p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map( p+e.xyy).x,
    map( p+e.yxy).x,
    map( p+e.yyx).x
  )-c.x);
}

float diffuse(vec3 point, vec3 normal, vec3 light)
{
  return max( 0.0, dot(normal, normalize( light-point)));
}

vec3 march( vec3 from, vec3 rd, out vec3 p, out float travel)
{
  float mindist = 9999.99;
  for(int i = 0; i < 100; i++)
  {
    p = from + rd*travel;
    vec3 res = map(p);
    travel += res.x*0.5;
    mindist = min( mindist, res.x);
    if(res.x < 0.001){
      res.z = mindist;
      return res;
    }
    if(travel > 50.0)
    {
      travel = 50.0;
      return vec3(-1.0, -1.0, mindist);
    }
  }
  return vec3(-1.0, -1.0, mindist);
}

void main(void)
{
  time = fGlobalTime;
  fft = texture(texFFT, 0.25).r;
  fftS = texture(texFFTSmoothed, 0.2).r;
  fftI = texture(texFFTIntegrated, 0.15).r;
  beat = floor(time * 160.0 / 60.0);
  beatStep = fract(time * 160.0 / 60.0);
  bar = floor(beat / 4.0);
  barSTep = fract(beat/4.0);
  
  float aspect = v2Resolution.y / v2Resolution.x;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ouv = uv;
	uv -= 0.5;
	uv /= vec2(aspect, 1);
  vec3 col = vec3(0.);
  
	col = getTexture(texInerciaBW,uv + vec2(uv.y*time*0.001+time*0.1,0.0)).rgb*0.15;
  
  
  vec3 light1 = vec3( sin(time*15.), 2.0, cos(time*0.75));
  vec3 light2 = vec3( sin(time*1.2+fftI*4.0), 2.0, cos(time*1.75));
  vec3 light3 = vec3( sin(time-fftI*3.9), 2.0, -cos(time*0.5));
  vec3 camera = vec3(
    sin(time*0.2)*3.5,
    2.0,
    cos(time*0.1)*3.5
    
  );
  vec3 target = vec3(0,0,0);
  float fov = 1.08;
  if(mod(bar, 4.0) < 1.0) fov = 1.5;
  else if(mod(bar, 4.0) < 2.0) fov = 0.1;
  else if(mod(bar, 4.0) < 3.0) fov = 0.3;
  
  vec3 c = vec3(0.0);
  
  vec3 raydir = getcam( camera, target, uv, fov);
  vec3 hit = camera;
  float travel = 0.0;
  vec3 marchres = march( camera, raydir, hit, travel);
  if(marchres.y<-0.5)
  {
    
  }
  else if(marchres.y < SPHERE +0.5)
  {
    vec3 n = normal(hit);
    hit = mod( hit+5.0, vec3(10.0))-5.0;
    float d1 = diffuse( hit, n, light1);
    float d2 = diffuse( hit, n, light2);
    float d3 = diffuse( hit, n, light3);
    
    c = vec3(1.0,0.1, 0.0) * d1 +
        vec3(0.0,0.1, 1.0) * d2 +
        vec3(0.0,1.0, 0.0) * d3;
    
    c*=0.3+0.5*smoothstep(5.0,30.0, travel);
  }
  
  c+=glow*0.01;
  
  
  
  vec2 repeatUv = ouv;
  repeatUv -=0.5;
  repeatUv *= 0.99 - smoothstep(0.0, 0.05, fftS)*0.02;
  repeatUv +=0.5;
  vec3 prev = texture(texPreviousFrame, repeatUv).rgb;
  
  c = mix(c, c+prev*0.85, smoothstep(0.0, 0.02, fftS));
  
  c = mix( c, 0.3*vec3(0.3+uv.x,0.1+uv.y,0.0+uv.x-uv.y), smoothstep(30.0, 50.0, travel));
  
  out_color = vec4(col*0.0 + c,1.0);
  
  
  
}























