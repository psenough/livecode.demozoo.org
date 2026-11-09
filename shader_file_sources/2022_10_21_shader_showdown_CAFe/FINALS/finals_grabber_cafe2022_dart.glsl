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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 4.2 + cos(time)), c * 4.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(float a)
{
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

float box(vec3 p, vec3 c) 
{
  vec3 a = abs(p)-c;
  return max(max(a.x, a.y),a.z);
}

vec2 min2(vec2 a, float d, float m)
{
  if (a.x < d)
    return a;
  return vec2(d,m);
}

float rnd(float t)
{
  return fract(sin(t*3.5552)*9.52376);
}

float cur(float a, float b)
{
  float g = a / b;
  return mix( rnd(floor(g)), rnd(floor(g+1)), fract(g) );
}

float t = fGlobalTime;


vec3 objcol;
vec2 map(vec3 p0)
{
  vec2 d=vec2(1e5,-1);
  vec3 p;
  p = p0;
  p.yz *= rot(t + p.y*0.3);
  p.xz *= rot(t + p.x*0.1);
  float f = texture(texFFTSmoothed, (0.04+0.5)/1024).r*10;
  d = min2(d, box(p, vec3(1+f)),2);

  {
    p = p0;
    float h = 0.1;
    p.xy *= rot(sin(t)*1.14 + p.z*0.4);
    p.z += cur(t, 2.0)+1.;
    p.y = abs(p.y);
    p.y -=3;
    p.xz = mod(p.xz - 1, 2) - 1;
    d = min2(d, box(p, vec3(0.9, h, 0.9)),1);  
  objcol = abs(p0) * 0.01;
  }
  return d;
  
  
}

vec3 norm(vec3 p)
{
  float b= map(p).x;
  vec2 o = vec2(0.01, 0);
  return normalize(vec3(map(p-o.xyy).x, map(p-o.yxy).x,map(p-o.yyx).x ));
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(0,0,-22 + cur(t*0.6,0.3)*10);
  vec3 rd = normalize(vec3(uv, dot(uv,uv)+cur(t,1.0)));
  
  vec3 col, p = ro;
  float sd;
  int i;
  vec2 d;
  for (i = 0; i < 100; ++i)
  {
    d = map(p);
    if (d.x < 0.01) {
      if (d.y != 2)
        break;
      vec3 n = norm(p);
      rd = reflect(n, rd);
  d.x = 0.1;
    }
    p += rd * d.x *0.48;
    col += objcol * 0.81;
    sd += d.x;
  }
  
  float s = 1.0 - float(i)/100.;
  //col = vec3(s);
  out_color = vec4(col,1);
  return;
 
  
}