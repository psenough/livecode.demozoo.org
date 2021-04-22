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

#define time fGlobalTime
#define mod01 floor(mod(time * 2.0, 4.0))

struct matter 
{
  float m;
  float gg;
  float dist;
};

mat2 rot(float a)
{
  float ca = cos(a);
  float sa = sin(a);
  
  return mat2(ca, sa, -sa, ca);
}

vec3 hash33(vec3 p)
{
  float n = sin(dot(p, vec3(7.0, 15.0, 112.0)));
return   fract(vec3(2356.0, 23564.0, 36521.0) * n);
}

float box(vec3 p, vec3 s)
{
  p = abs(p) - s;
  return max(p.x, max(p.y, p.z));
}

vec2 rep(vec2 p, vec2 r)
{
  return (fract(p/r-0.5)-0.5)*r;
}

vec2 repId(vec2 p, vec2 r)
{
  return (floor(p/r-0.5)-0.5)*r;
}

float rnd2(vec2 uv)
{
    return fract(dot(sin(uv * 126.232 + uv.yx * 465.2354), vec2(1256.3265)));
}

void map(inout matter mat, vec3 p)
{
  float mat01, rand01;
  vec3 p01 = p, p02 = p;
   float f = texture( texFFT, 0.1 ).r * 10;
  
  p02 -= vec3(0.0, 10.0 - 8.0 * sin(p.z * 0.10 + time *0.5), 0.0);
  p01 += vec3(0.0, 2.0 - 1.0 * sin(p.z * 0.05 + time), 0.0);
  
  vec2 id01 = repId(p01.xz, vec2(0.85));
  p01.xz = rep(p01.xz, vec2(0.85));
  float rnd01 = rnd2(id01) + f * 0.05;
  
  vec2 id02 = repId(p02.xz, vec2(0.85));
  p02.xz = rep(p02.xz, vec2(0.85));
  float rnd02 = rnd2(id02) + f * 0.05;
  
  mat01 = box(p01, vec3(0.65, 2.15 * rnd01 * abs(sin((time * 0.5 * rnd01) + mod01 + 1.55) * sin(rnd01 + (f * 0.85))), 0.65));
  
  mat01 = min(mat01, box(p02, vec3(0.45, 1.55 * rnd01 * abs(sin((time * 0.5 * rnd01) + mod01 + 1.55) * sin(rnd01 + (f * 0.85))), 0.45)));
  
  mat.gg += 0.15/(0.05+abs(mat01));
  
 
  
  mat.m = mat01;
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


float shadow(vec3 p, vec3 l, int steps, float minL, float maxL)
{
    matter mat;
  
  for(int i = 0; i< 100; ++i)
  {
    map(mat, p);
    
    mat.dist += mat.m;
    if(mat.m < minL)
      return 1.0;
    
    if(mat.dist > maxL)
      return 0.0;
    
    
  }
  
  return 0.0;
}

void main(void)
{
  vec3 l = normalize(vec3(10.0, 10.0, 5.0));
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 o = vec3(25.0 * cos(time * 0.25 + mod01), 0.0, 3.0 * sin(time * 0.25 + mod01)), t = vec3(0.0, -2.0, 0.0);
  vec3 fr = normalize(t-o);
  vec3 ri = normalize(cross(vec3(0.0, 1.0, 0.0), fr));
  vec3 up = normalize(cross(fr, ri));
  vec3 dir = normalize(fr + uv.x * ri + uv.y * up);
  vec3 p = o + dir * 0.25;
  
  dir *= 0.985 + hash33(p)* 0.02;
  
  matter mat;
  vec3 col= vec3(1.0);
  
  for(int i = 0; i < 100; ++i)
  {
    p.xy *= rot(p.z * 0.0002);
    
    map(mat, p);
    
    vec3 n = normals(p);
    float s = shadow(p+n*0.2, l, 30, 0.2, 20.0);
    
    col -= dot(n, l) * pow( mat.gg * 0.0115 , 30.0) * mix(vec3(1.0), vec3(1.0) * 0.1, mat.dist);
    col -= s * vec3(1.0, 1.0, 0.0) * 0.01;
    
    if(abs(mat.m) < 0.05)
    {
        mat.m = 1.65;
    }
    
    p+= (mat.m * 0.2) * dir;
    mat.dist += mat.m;
  }
  
	col *= (1.0 - mat.dist/250.0);	
	

	out_color = vec4(col, 1.0);
}