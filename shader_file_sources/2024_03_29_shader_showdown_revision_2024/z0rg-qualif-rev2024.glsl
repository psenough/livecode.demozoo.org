#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define FFT(a) (texture(texFFT, a).x)
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a)) 
#define sat(a) clamp(a, 0., 1.)
float _cube(vec3 p, vec3 s)
{
  vec3 l = abs(p)-s;
  return max(l.x, max(l.y, l.z));
}
float _seed;
vec2 _min(vec2 a, vec2 b)
{
  if (a.x < b.x)
    return a;
  return b;
}

float hash(float seed)
{
  return fract(sin(123.456*seed)*123.456);
}
float rand()
{
  return hash(_seed++);
}
vec2 map(vec3 p)
{
  vec3 pix = vec3(1.9);
  p = floor(p/pix)*pix;
  p.x += 5.;
  p.z += fGlobalTime*155.;
  p.xy *= rot(p.z*.05);
  vec3 rep = vec3(15.);
  p = mod(p+rep*.5,rep)-rep*.5;
  vec2 shape = vec2(10000., -1.);
  p.xz *= rot(fGlobalTime*.5);
  float an = atan(p.z, p.x);
  
  shape = _min(shape, vec2(length(p)-.1-FFT(an), 0.));
  
  for (float i = 0.; i < 8.; ++i)
  {
    float sz = mix(1.,2.,i/8.);
      vec3 p2 = p;
  //  p2.yz *= rot(i);
//    p2.xz *= rot(i+fGlobalTime*.5);
    float repa = acos(-1.)*2./3.;
  float an2 = atan(p2.x, p2.y);
  float sector = mod(an2+repa*.5,repa)-repa*.5;
  p2 = vec3(sin(sector), cos(sector), 0.)*length(p2)+vec3(0.,0.,p.z);
  p2.y -= sz;
  p2.xy *= rot(i);
  p2.xz *= rot(i+fGlobalTime);
    float cub = _cube(p2, vec2(.1,2.).yxx);
  shape = _min(shape, vec2(cub, i));
  }
  return shape;
}

vec3 getNorm(vec3 p)
{
  vec2 e = vec2(0.01, 0.);
  return -normalize(vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x)-vec3(map(p+e.xyy).x, map(p+e.yxy).x, map(p+e.yyx).x));
}

void main(void)
{
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  _seed = texture(texNoise, uv).x+fGlobalTime;
  
  vec3 ro = vec3(0., 0., -5.)+vec3(rand()-.5, rand()-.5, 0.)*.1;
  vec3 rd = normalize(vec3(uv, 1.));
  
  vec3 p = ro;
vec3 col = vec3(0.);
vec3 accCol = vec3(0.);  
  for (float i = 0.; i <  128.; ++i)
  {
    vec2 res= map(p);
    if (res.x < 0.01)
    {
      vec3 n = getNorm(p);
      col = n*.5+.5;
      col = vec3(.1);
      break;
    }
    float beat = 1./3.;
    vec3 rgb = abs(sin(p));
    rgb *= sat(sin(p.z*15.-fGlobalTime*10.));
    accCol += rgb.xyy*(1.-sat(res.x/1.5))*.1*sat(.4+.5*pow(mod(fGlobalTime, beat)/beat, 5.));
    p+=rd*res.x;
  }
  col += accCol;
  col += vec3(1.)*FFT(abs(uv.x)-abs(uv.y)+fGlobalTime*.5);
  float line = abs(uv.x-FFT(uv.y*.1)*10.)-.4;
  col = mix(col, col.xxx*.3, sat(line*500.));
	out_color = vec4(col, 1.);
}