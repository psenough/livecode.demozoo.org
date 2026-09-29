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
uniform float midi01;
uniform float midi02;
uniform float midi03;
uniform float midi04;
uniform float midi05;
uniform float midi06;
uniform float midi07;
uniform float midi08;
uniform float midi09;
uniform float midi10;
uniform float midi11;
uniform float midi12;
uniform float midi13;
uniform float midi14;
uniform float midi15;
uniform float midi16;
uniform float midi17;
uniform float midi18;
uniform float midi19;
uniform float midi20;
uniform float midi21;
uniform float midi22;
uniform float midi23;
uniform float midi24;
uniform float midi25;
uniform float midi26;
uniform float midi27;
uniform float midi28;
uniform float midi29;
uniform float midi30;
uniform float midi31;
uniform float midi32;
uniform float midi33;
uniform float midi34;
uniform float midi35;
uniform float midi36;
uniform float midi37;
uniform float midi38;
uniform float midi39;
uniform float midi40;
uniform float midi41;
uniform float midi42;
uniform float midi43;
uniform float midi44;
uniform float midi45;
uniform float midi46;
uniform float midi47;
uniform float midi48;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime

#define mod01 floor(mod(time, 4.0))
#define smod01 smoothstep(fract(mod(time, 4.0)), 0.25, 0.75)
#define fft texture(texFFTSmoothed, 0.01).x * 50.0 * midi03


struct Matter

{
    float m;
  int type;
  bool reflected;
  float glow;
};

struct Ray
{
  vec3 o;
  vec3 p;
  vec3 dir;
  vec3 t;
  
};

struct Res
{
  vec3 col;
};

Matter mat;
Ray ray;
Res res;

mat2 rot(float a)
{
    float ca = cos(a);
    float sa = sin(a);
  
  return mat2(ca, sa, -sa, ca);
}

float sphere(vec3 p, float s)
{
  
  return length(p) - s;
}

float box(vec3 p, vec3 s)
{
  p = abs(p) - s;
  
  
  return max(p.x, max(p.y, p.z));
}

void map(inout Matter ma, vec3 p)
{
    float mat01 = 10.0, mat02 = 10.0;
  vec3 p01 = p, p02 = p;
  
  p01.xy *= rot(0.5 + sin(time * 2.0 + smod01 * 5.0)) * 1.0;
  p01.yz *= rot(0.5 + sin(time * 2.0 + smod01 * 5.0)) * -1.0;
  
  
  p02.xy *= rot(sin(smod01 * 4.0 + sin(ray.p.z * 0.5)) * 2.0);
  p02.yz *= rot(sin(smod01 * 2.0+ sin(ray.p.x * 0.2)) * 2.0);
  
  mat01 = sphere(p + vec3(1.0 * sin(time * 0.25 * mod01), 1.0 * smod01, 0.0), 0.2 * fft);
  mat01 = min(mat01, sphere(p02 + vec3(-4.0 * sin(time * 0.25 * mod01), -2.0 * smod01, 0.0), 0.2*  fft));
   mat01 = min(mat01, sphere(p02 + vec3(-4.0 * sin(time * 0.15 * mod01), -2.0 * smod01, 0.0), 0.5 * fft));
   mat01 = min(mat01, sphere(p02 + vec3(-3.0 * sin(time * 0.25 * mod01), -3.0 * smod01, 0.0), 0.75 * fft));
   mat01 = min(mat01, sphere(p02 + vec3(-2.0 * sin(time * 0.35 * mod01), -1.0 * smod01, 0.0), 0.2 * fft));
  
  mat01 = min(mat01, sphere(p02 + vec3(-5.0 * sin(time * 0.15 * mod01), -5.0 * smod01, 0.0), 1.5 * fft));
   mat01 = min(mat01, sphere(p02 + vec3(-10.0 * sin(time * 0.25 * mod01), -5.0 * smod01, 0.0), 1.75 * fft));
   mat01 = min(mat01, sphere(p02 + vec3(-5.0 * sin(time * 0.35 * mod01), -15.0 * smod01, 0.0), 1.2 * fft));
  
  mat02 = -box(p01, vec3(15.0));
  
    ma.m = min(mat01, mat02);
   ma.glow += pow(0.15/(0.05+abs(ma.m)), 1.0);
   ma.glow += pow(0.10/(0.05+abs(mat02)), 3.0);
  if(mat02 < 0.01)
  {
      ma.type = 1;
    
    return;
  }
   ma.type = 0;
  //ma.m = min(mat01, mat02);
  
   
}


vec3 normal(vec3 p)
{
    vec2 uv = vec2(0.01, 0.0);
  
    Matter mat02, mat03, mat04;
  
  map(mat02, p + uv.xyy);
    map(mat03, p + uv.yxy);
  map(mat04, p + uv.yyx);
  
  return(mat.m - normalize(vec3(mat02.m, mat03.m, mat04.m)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  
  uv *= rot(0.5 + sin(time * 1.0 + mod01 * 0.1));
  
  if(uv.x > 0.0)
  {
    ray.o = vec3(-1.0 * sin(smod01 * 15.0 * mod01), -10.0 * cos(time + smod01 * 25.0), 16.0), ray.t = vec3(0.0);
  } 
  else if(uv.y > 0.0)
  {
    ray.o = vec3(0.5 * cos(smod01 * 5.0 * mod01),15.0 , -2.0 * sin(time + smod01 * 1.0)), ray.t = vec3(0.0);
  }
  else if(uv.y < 0.0)
  {
    ray.o = vec3(5.5 * cos(smod01 * 5.0 * mod01),10.0 , -5.0 * sin(time + smod01 * 1.0)), ray.t = vec3(0.0);
  }else {
    ray.o = vec3(1.0 * sin(smod01 * 5.0 * mod01), 5.0 * cos(time + smod01 * 5.0), 14.0), ray.t = vec3(0.0);
  }
  
  vec3 fr = normalize(ray.t-ray.o);
  vec3 ri = normalize(cross(vec3(0.0, 1.0, 0.0), fr));
  vec3 up = normalize(cross(fr, ri));
  ray.dir = normalize(fr + uv.x * ri + uv.y * up);
  ray.p = ray.dir * 0.25 + ray.o;
  
	res.col = vec3(1.0);
  mat.reflected = false;
  
  for(int i = 0; i < 200; ++i)
  {
      map(mat, ray.p);
    
    
    
      res.col -= 0.001 * midi02 * fft * mat.glow * mix(vec3(0.0, 1.0, 1.0), vec3(1.0,0.5, 0.0), clamp(1.0 * (0.5 +uv.x), 0.0, 1.0)) * fft;
    
    if(mat.m < 0.01)
    {
        mat.m = 15.0 * midi01;
      
      if(mat.type == 1 && !mat.reflected)
      {
        vec3 n = normal(ray.p);
        
        ray.dir = reflect(ray.dir, -n);
        mat.reflected = true;
      }
    }
    
    ray.p += ray.dir * mat.m;
  }
  
  res.col = mix(res.col, texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).xyz, 0.925);
  
	out_color = vec4(res.col, 1.0);
}