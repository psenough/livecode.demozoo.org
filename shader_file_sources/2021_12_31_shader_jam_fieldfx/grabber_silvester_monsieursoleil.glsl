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

// HI THERE

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime

struct Matter
{
  float m;
  float glow;
  float glow01;
  bool reflected;
  vec3 norm;
  float glowacc;
  int type;
};

struct Ray
{
  vec3 p;
  vec3 o;
  vec3 dir;
  vec3 t;
};

struct Light
{
  float shad;
  vec3 sunPos;
  vec3 sunDir;
};

struct Res
{
  vec3 col;
  vec3 col01;
  vec3 col02;
};

Matter mat;
Ray ray;
Res res;
Light li;

mat2 rot(float a)
{
  float ca = cos(a);
  float sa = sin(a);
  return mat2(ca, sa, -sa, ca);
}

float rep(float p, float r)
{
  return (fract(abs(p) / r - 0.5) - 0.5) * r;
}

float box(vec3 p, vec3 r)
{
    p = abs(p)-r;
  return max(p.x, max(p.y, p.z));
}

float sphere(vec3 p, float r)
{
    return length(p)- r;
}

void map(inout Matter ma, vec3 p)
{
   float mat01 = 10.0, mat02 = 10.0, mat03 = 10.0, mat04 = 10.0, mat05 = 10.0, mat06 = 10.0, mat07 = 10.0;
  
  vec3 p01 = p, p02 = p, p03 = p;
  
  p01.xz *= rot(time * 0.5 + floor(time) * 0.2);
  p02.zx *= rot(time * 0.25 + floor(time) * 0.1);
  p03.yz *= rot(time * 0.1 + floor(time) * 0.05);
  
  p01.z = rep(p01.z, 0.1);
  p02.x = rep(p02.x, 0.1);
  p03.y = rep(p03.y, 0.1);
  float f = texture( texFFTSmoothed, 0.1 ).r * 10;
  
  
  float size = 0.5 + 1.25 * abs(sin(time * 0.55 + floor(time * 2.0) * 0.1 + f * 0.25) );
  float midS = 0.002;
  
  mat01 = sphere(p, size);
  mat01 = max(mat01, -sphere(p, size));
  
  mat02 = mat01;
  mat03 = mat01;
  
  mat01 = max(mat01, box(p01, vec3(size, size, midS)));
  mat02 = max(mat02, box(p02, vec3(midS, size, size)));
  mat03 = max(mat03, box(p03, vec3(size, midS, size)));
  
  mat01 = min(mat01, mat02);
  mat01 = min(mat01, mat03);
  
  p.xz *= rot(time * 0.5 + floor(time) * 0.2);
  
  mat04 = box(p, vec3(0.65));
  mat04 = max(mat04, - box(p, vec3(0.65) * 0.9975));
  
  p.yz *= rot(time * 0.1 + floor(time) * 0.1);
  
  mat05 = box(p, vec3(0.85));
  mat05 = max(mat05, - box(p, vec3(0.85) * 0.9975));
  
  p.zy *= rot(time * 0.1 + floor(time) * 0.05);
  
  mat06 = box(p, vec3(1.15));
  mat06 = max(mat06, - box(p, vec3(1.15) * 0.9975));
  
  p.xz *= rot(time * 0.1 + floor(time) * 0.3);
  
  mat07 = box(p, vec3(1.55));
  mat07 = max(mat07, -box(p, vec3(1.55) * 0.9975));
  
  mat04 = min(mat04, mat05);
  mat04 = min(mat04, mat06);
  mat04 = min(mat04, mat07);
  
  ma.glow += 0.01 + f * 0.1/(0.05+ clamp(mat01, 0.0, 1.0));
  
  if(mat04 < 0.01 && mat01 < 0.01)
  {
    ma.type = 2;
    
    mat01 = max(mat04, mat01);
    ma.glow += 0.45 + f * 0.5/(0.05+ clamp(mat01, 0.0, 1.0));
    
    ma.m = mat01;
    return;
  }
  
  //mat01 = max(mat01, box(p01, vec3()))
  
  
  
  ma.m = mat01;
}

//Will try T32 linear !

vec3 tri(vec3 p, vec3 n)
{
    p *= 0.5;
  
  return (texture(texNoise, p.xz).rgb * n.z * n.z+
  texture(texNoise, p.zy).rgb * n.x * n.x+
  texture(texNoise, p.xz).rgb * n.y * n.y);
}

vec3 normals(vec3 p)
{
  vec2 uv = vec2(0.001, 0.0);
  
  Matter m02, m03, m04, m05, m06, m07;
  
  map(m02, uv.xyy);
   map(m03, uv.xyy);
   map(m04, uv.yxy);
   map(m05, uv.yxy);
   map(m06, uv.yyx);
   map(m07, uv.yyx);
  
  vec3 nor = vec3(m02.m - m03.m,
  m04.m - m05.m,
  m06.m - m07.m
  );
  
  return normalize(nor);
}

void main(void)
{
  vec2 uv01 = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  ray.o = vec3(fract(mod(time, 4.0)) * 4.0, 0.0, 2.0), ray.t = vec3(0.0);
  vec3 fr = normalize(ray.t-ray.o);
  vec3 ri = normalize(cross(fr, vec3(0.0, 1.0, 0.0)));
  vec3 up = normalize(cross(fr, ri));
  ray.dir = normalize(fr + uv.x * ri + uv.y * up);
  ray.p = ray.dir * 0.25 + ray.o;
  mat.reflected = false;
  
	res.col = vec3(1.0 - (pow(uv.y + 0.5, 2.0) * 2.0));

  for(int i = 0; i < 100; i++)
  {
    //ray.p.zx *= rot(time * 0.1) * 0.1;
    
    map(mat, ray.p);
    
    
    
    if(mat.m < 1.0)
    {
      if(mat.type == 2)
      {
        vec3 n = normals(ray.p);
        if(mat.m < 0.0001 && !mat.reflected)
        {
            n = reflect(ray.dir, -n);
          
          ray.dir = mix(ray.dir, n, 0.5);
          
          mat.m = 0.5;
          mat.reflected = true;
        }
        
        res.col += 0.017 * mix(vec3(0.0, 0.5, 1.0), vec3(1.0, 0.5, 0.0), pow((uv.y + 0.5) + fract(time), 2.2)) * mat.glow * uv.y;
      if(mat.m < 0.0001)
      {
        /*vec3 n = normals(ray.p);
        vec3 t = tri(ray.p, n);
        float tt = t.x * 0.29 + 0.58 * t.y + 0.11 * t.z;
        mat.m = 0.5;
        res.col -= res.col01 * tt;*/
        mat.m = 0.5;
      }
      }
      
      
        
    }
    
    ray.p += ray.dir * mat.m;
  }
  uv01.xy *= rot(0.002);
  
	res.col = mix(texture(texPreviousFrame, vec2(uv01)).xyz, res.col, 0.0 + mod(time, 4.0) * 0.1);
	
	out_color = vec4(res.col, 1.0);
}