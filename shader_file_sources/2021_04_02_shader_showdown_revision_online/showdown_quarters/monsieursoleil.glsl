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
#define mod02 floor(mod(time * 2.0, 4.0))
#define soundFFT texture( texFFT, 0.05 ).x * 100

struct matter
{
  float m;
  float glow;
};

matter mat;

mat2 rot(float a)
{
  float ca= cos(a);
  float sa = sin(a);
  
  return mat2(ca, sa, -sa, ca);
}

float box(vec3 p, vec3 s)
{
  p = abs(p) -s;
  
  return max(p.x, max(p.y, p.z));
  
}

vec2 rep(vec2 p, vec2 r)
{
  
  return (fract(abs(p/r) - 0.5) - 0.5) * r;
  
}

void map(vec3 p)
{
  float mat01;
  vec3 p01 = p, p02 = p, p03 = p;
  
  p.xz *= rot(sin(time * 0.5) * sin(p.y * 0.01)) * 0.9;
  
  p02.xz *= rot(sin(time * 0.1) * sin(p02.y * 0.01)) * 1.0;
  p02.xz = rep(p02.xz, vec2(0.7));
  
  p03.xz *= rot(sin(time * 0.5) * sin(p03.y * 0.01)) * 2.5;
  p03.yz *= rot(sin(time * 0.5) * sin(p03.x * 0.01)) * 1.1;
  
  p03.yz = rep(p03.yz, vec2(0.5));
   
  mat01 = box(p + vec3(2.0 * cos(p.y * 0.2 + time * 0.5), 0.0, 2.0 * sin(p.y * 0.2 + time * 0.5)), vec3(2.1 + mod01 * 0.2, 10000000.0, 0.2));
  
  mat01 = min(mat01, box(p + vec3(3.0 * cos(p.y * 0.5 + time * 0.5) + soundFFT * 5.0 , 0.0, 4.0 * sin(p.y * 0.1 + time * 1.0)  + soundFFT * 5.0 ), vec3(1.5 + mod01 * 0.2 + soundFFT * 2.0, 10000000.0, 0.52)));
  
  mat01 = min(mat01, box(p + vec3(1.0 * cos(p.y * 0.5 + time * 0.5), 0.0, 2.0 * sin(p.y * 5.1 + time * 1.0)), vec3(2.1 + mod01 * 0.2 + soundFFT * 2.0, 10000000.0, 1.2 + soundFFT * 2.0)));
  mat01 = min(mat01, box(p + vec3(5.0 * cos(p.y * 0.5 + time * 0.5), 0.0, 2.0 * sin(p.y * 5.1 + time * 1.0)), vec3(2.1 + mod01 * 0.2 + soundFFT * 2.0, 10000000.0, 1.2 + soundFFT * 2.0)));
  
  
  mat01 = max(mat01, -box(p02, vec3(0.21 * sin(p.y * 0.1 + time * 2.0), 10000.0, 0.11 + soundFFT * 0.01)));
  mat01 = max(mat01, -box(p03, vec3(1000.1, 0.01 + soundFFT * 0.01,  0.25 + soundFFT * 0.01 + mod02 * sin(p.y * 0.2 + time * 2.0))));
  
 /* mat01 = max(mat01, box(p + vec3(0.0, -time 
  - cos(time) * 15.0 + 75.0, 0.0), vec3(225.0)));*/
  
  mat.glow += 0.15/(0.05+abs(mat01));
  
  mat.m = mat01;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

  vec3 col = vec3(0.7);
  
  vec3 o = vec3(10.0  * sin(time) + mod01 * 2.0, time * 0.5 + mod02 * 20.0, 15.0 * cos(time)  + mod01 * 2.0), t = vec3(0.0, time * 0.5 + mod02 * 20.0 + 10.0, 0.0);
  vec3 fr = normalize(t-o);
  vec3 ri = normalize(cross(vec3(0.0, 1.0, 0.0), fr));
  vec3 up = normalize(cross(ri, fr));
  vec3 dir = normalize(fr + uv.x * ri + uv.y * up);
  vec3 p = o + dir * 0.25;
  
  for(int i = 0; i < 200 * midi01; ++i)
  {
    map(p);
    
    col -= (0.0005 * (mat.glow)) * (midi02 + mod02 * 0.2)  * mix(vec3(0.0), vec3(1.0, 0.5, 0.3), clamp(abs(cos(p.y * 0.01 + time * 1.0 + soundFFT * 4.0)), 0.0, 1.0));
    
    if(mat.m< 0.01)
    {
      mat.m = 5.0 * midi03;
    }
    
    p += dir * mat.m;
  }
  
	
	out_color = vec4(col, 1.0);
}