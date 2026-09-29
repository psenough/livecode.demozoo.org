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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define mod01 floor(mod(time, 4.0))
#define mod02 floor(mod(time, 4.0))
#define mod03 floor(mod(time * 2.0, 4.0))
#define mod04 floor(mod(time * 2.0, 8.0))

struct matter
{
  float m;
  vec3 col;
  int type;
  float dist;
  float glow;
  bool reflected;
  
};

mat2 rot(float a)
{
  float ca = cos(a);
  float sa = sin(a);
  
  return mat2(ca, sa, -sa, ca);
}

float box(vec3 p, vec3 s)
{
    p = abs(p) - s;
  return max(p.x, max(p.y, p.z));
}

vec2 repeat(vec2 p, float rep)
{
  return (fract(abs(p)/rep - 0.5) - 0.5) * rep;
}

vec2 id(vec2 p, float rep)
{
  return (floor(abs(p)/rep - 0.5) - 0.5) * rep;
}

float rnd(vec2 x)
{
    return fract(dot(sin(x * 352.1263 + x.yx * 5623.2365), vec2(451.2365)));
}

float rnd(float x)
{
    return fract(sin(x * 352.1263 + x * 5623.2365));
}

float curve(float x)
{
  return mix(rnd(x), rnd(x + 1.0), fract(time));
}

void map(inout matter mat, vec3 p)
{
  p.xy *= rot( p.z * (0.001 - sin(abs(time * 0.000025)) * 0.075) + (mod03 * 8.5) + time * 1.25) * 2.25;
  
  float repV = 0.25 + sin(abs(mod03 * 0.1)) * 2.0;
  vec3 p01 = p, p02 = p, p03 = p, p04 = p;
  
  vec2 id0111 = id(p01.xz, repV * 22.0);
  
  vec2 id011 = id(p01.xz, repV * 4.0);
  vec2 id01 = id(p01.xz, repV);
  p01.xz = repeat(p01.xz, repV);
  
  float rnd01 = rnd(id01 * 32.0);
  float rnd011 = rnd(id011 * 32.0);
  float rnd0111 = rnd(id0111 * 132.0);
  
  vec2 id02 = id(p02.yz, repV);
  p02.yz = repeat(p02.yz, repV);
  
  float rnd02 = rnd(id02 * 32.0);
  
  vec2 id031 = id(p03.yz, repV * 8.0);
  vec2 id03 = id(p03.yz, repV);
  p03.yz = repeat(p03.yz, repV);
  
  float rnd03 = rnd(id03 * 32.0);
  float rnd031 = rnd(id031 * 32.0);
  
  vec2 id041 = id(p04.xz, repV * 6.0);
  p04.xz = repeat(p04.xz, repV);
  float rnd041 = rnd(id041 * 32.0);
  
  float scaleV = 0.4 * sin(abs(time * 1.5)) + 0.75;
  
    float mat01 = box(p01 + vec3(0.0,26.0 + 4.0 * sin(p.z * 0.1 + time) + rnd0111 * 4.0, 0.0), vec3(scaleV) + vec3(0.8 * rnd01 + 0.575 * mod01 * rnd01) - vec3(0.0, rnd011 * 8.55 * sin(time * 2.0), 0.0) - vec3(0.0, 2.0 * rnd0111, 0.0)) ;
  
  float mat02 = box(p02 + vec3(55.0 - fract(time * 0.45) * 32.0, 0.0 , 0.0), vec3(scaleV) * 0.8 * rnd02 * (mod02 + 0.25) - vec3(rnd031 * sin(abs(time * 4.0)) * 7.0));
  
  float mat03 = box(p03 + vec3(-45.0 - fract(time * 0.05 + mod03) * 38.0, 0.0, 0.0), vec3(scaleV * 0.8 * rnd03 * (mod02 + 0.25)));
  
  float mat04 = box(p04 + vec3(0.0, -45.0  + 2.0 * sin(p.z * 0.25 + time + (mod03)) , 0.0), vec3(0.1) + vec3(0.1 + 0.275 - sin(time * rnd041)));
  
  mat.m = min(mat01, mat02);
  mat.m = min(mat.m, mat03);
  mat.m = min(mat.m, mat04);
  
  mat.glow += 0.15/(0.05+abs(mat.m));
}
vec3 normals(vec3 p)
{
    vec2 uv = vec2(0.01, 0.0);
  
  matter m01, m02, m03, m04;
  
  map(m01, p);
   map(m02, p - uv.xyy);
   map(m03, p - uv.yxy);
   map(m04, p - uv.yyx);
  
  return normalize(m01.m - vec3(m02.m, m03.m, m04.m));
  
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 o = vec3(0.0, 5.0, 5.0 + time * 85.0 + mod01 * 5.0), t = vec3(00., 2.5 * sin(time * 0.5) + 4.0, time * 85.0 + mod01 * 5.0 );
  vec3 fr = normalize(t-o);
  vec3 ri = normalize(cross(vec3(0.0, 1.0, 0.0), fr));
  vec3 up = normalize(cross(fr, ri));
  vec3 dir = normalize(fr + ri * uv.x + up * uv.y);
  vec3 p = o + dir * 0.25;
  
  
  matter mat;
 for(int i = 0; i < 100; ++i)
  {
    map(mat, p);
    
    if(mat.m < 0.01)
    {
      mat.m = 0.15;
      mat.glow *= 0.95;
      mat.dist -= 0.1 * mat.dist;
      if(!mat.reflected)
      {
        vec3 n= normals(p);
        dir = reflect(-n, dir);
        mat.m = 2.5;
        mat.reflected = true;
        mat.glow *= 5.95;
      }
      
    }
    
    
    vec3 selCol = vec3(1.0, 1.0, 1.0) * 1.0;
    if(mod01 > 1.0)
    {
      selCol = vec3(0.0, 0.5, 1.0);
    }
    if(mod01 > 2.0)
    {
      selCol = vec3(0.0, 0.5, 1.0);
    }
    
    mat.col += mat.glow * (0.00012 - (sin(abs(p.z * 0.001 + time * 2.25)) * 0.000155)) * selCol * 0.2325;
    p+= mat.m * dir * 0.5;
    mat.dist += 0.5;
    
  }
  
  mat.col += pow(clamp((mat.dist/100.0), 0.0, 1.0), 1.2) * mix(vec3(0.0, 0.5, 1.0), vec3(1.0, 0.0, 0.0), sin(abs(time * 0.1 + (mat.dist/100.0 * 2.5)))) * ((0.8 * mod04)/8.0);
  
  mat.col = pow(mat.col, vec3(1.0/2.2));
  
  out_color = vec4(mat.col, 1.0);
}