#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float Mi01;
uniform float Mi02;
uniform float Mi03;
uniform float Mi04;
uniform float Mi05;
uniform float Mi06;
uniform float Mi07;
uniform float Mi08;
uniform float Mi09;
uniform float Mi10;
uniform float Mi11;
uniform float Mi12;
uniform float Mi13;
uniform float Mi14;
uniform float Mi15;
uniform float Mi16;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define PI 3.141592
#define mod01 floor(mod(time * 2.0, 4.0))

vec3 liPos = vec3(10.0 * Mi07 * cos(time), 10.0 * Mi07 * sin(time), time - 10.0 * Mi08);

struct matter
{
  float m;
  int type;
  float glow;
  float dist;
  vec3 col;
};

float sphere(vec3 p, float s)
{
  return length(p) - s;
}

mat2 rot(float a)
{
  float ca = cos(a);
  float sa = sin(a);
  
  return mat2(ca, sa, -sa, ca);
}

float box(vec3 p, vec3 s)
{
  p = abs(p) - s;
  return max(p.x ,max(p.y, p.z));
}


float tunnel(vec2 p, float s)
{
  return length(p) - s;
}

float rep(float p, float r)
{
  return (fract( (p/r) + 0.5) - 0.5) *r;
}

float rnd(float uv)
{
  return fract(sin(uv * 325.1266) * 126.2356);
}

float pModPolar(inout vec2 p, float rep)
{
    float an = 2.*PI/rep;
  float a = atan(p.y, p.x) + an/2.;
  float r = length(p);
  float c = floor(a/an);
  a = mod(a, an) - an/2.;
  p = vec2(cos(a), sin(a)) * r;
  
  if(abs(c) >= (rep/2.0)) c = abs(c);
  return c;
}

void map(inout matter mat, vec3 p)
{
  float f = texture( texFFT, 0.10 ).r * 100;
  float mat01, mat02, mat03;
  vec3 p01 = p;
  
  float scale = 4.0 - abs(sin(p.z * 0.5 + mod01));
  
  p01 += vec3(0.5 * cos(time), 0.5 * cos(time), 0.0);
  
  p01.xy *= rot(time * 0.0025 * sin(p.z * 0.5));
  float a01 = pModPolar(p01.xy, 64.0);
  float rn = rnd(a01 * 32.0) * 2.0;
  
  p01.x -= scale;
  p01.z = rep(p01.z, 10.0 * Mi04);
  
  mat01 = sphere(p - vec3(0.0, 0.0, time - 2.0), 0.05 + 0.25 * mod01 + 0.5 * f);
  mat02 = -tunnel(p.xy + vec2(0.5 * cos(time), 0.5 * cos(time)), scale  + 0.5 * clamp(f, 0.0, 1.0));
  
  mat03 = box(p01, vec3(0.25 + 1.05 * rn * clamp(f, 0.0, 1.0), 1.0 * Mi05, 1.0 * Mi06 ));
  
  if(mod(a01, 12.0) > 6.0)
    mat.glow += 0.85/(0.05+abs(mat03));
  
  mat.glow += 0.15/(0.05+abs(mat01));
  
  mat.m = min(mat02, mat03);
  
}

float shadows(vec3 p, vec3 dir, float maxSteps, int steps, float limit)
{
  matter mat;
  for(int i = 0; i < steps; ++i)
  {
    map(mat, p);
    
    if(mat.dist > maxSteps)
      return 1.0;
    
    if(mat.m < limit)
      return 0.0;
    
    p += dir * mat.m;
    mat.dist += mat.m;
  }
  
  return 1.0;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 o = vec3(0.25 * cos(time), 0.25 * cos(time), time + 5.0 + mod01), t = vec3(0.25 * cos(time),0.25 * cos(time), time + mod01);
  vec3 fr = normalize(t-o);
  vec3 ri = normalize(cross(vec3(0.0, 1.0, 0.0), fr));
  vec3 up = normalize(cross(fr, ri));
  vec3 dir = normalize(fr + uv.x * ri + uv.y * up);
  vec3 p = o + dir * 0.25;
  
  matter mat;
  float steps = (150.0 * Mi02) / 100.0;
  
  for(int i = 0; i < 50; i++)
  {
    p.xy *= rot(Mi09 * 0.001);
    
    map(mat, p);
    
    vec3 ldir = liPos -p;
    vec3 lDirn = normalize(ldir);
    float ll = length(ldir);
    
    float shad = shadows(p, lDirn, 30.0, 20, 0.1);
    
    mat.col += (0.3/(0.1 + abs(ll))) * shad * mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 0.5, 1.0), sin(p.z * 2.5));
    
    if(mat.m < 0.01)
    {
        break;
    }
    
    mat.col += mix(vec3(1.0, 0.5, 0.0), vec3(0.0, 0.5, 1.0), sin(p.z * 0.5 + mod01)) * mat.glow * 0.01 * Mi03;
    p += dir * steps;
    mat.dist += steps;
  }
  mat.col *= clamp(1.0 - (mat.dist * 0.015 + abs(sin(p.z * 5.0)) * 0.55), 0.0, 1.05);
  
  mat.col *= 1.0 - (0.25 * abs(sin(p.z * 2.0))); 
  
  out_color = vec4(mat.col * Mi01, 1.0);
}