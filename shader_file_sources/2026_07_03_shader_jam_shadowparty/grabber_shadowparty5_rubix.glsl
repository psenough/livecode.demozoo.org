#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define TAU 6.2831853071795864769
#define PI  3.1415926535897932384
#define t   fGlobalTime
#define sat(a) clamp(a, 0., 1.)
float hash11(float seed) { return fract(sin(seed*123.456789)*123.456); }
float sin3(float x) { return sin(x)*sin(x)*sin(x); }
float tsin(float x) { return tan(sin(x))/tan(1.); }
float ststs(float x) { return sin(tan(sin(tan(sin(x))))); }
float s3c3(float x) { return sin(x)*sin(x)*sin(x)+cos(x)*cos(x)*cos(x); }
float ass(float x) { return asin(sin(x))/(PI/2.); }
float cir(float x) { return -sign(mod(.5*x,2.)-1.)*sin(acos(mod(x, 2.) - 1.)); }
float stshc(float x) { return sin(tan(sinh(cos(x)))); }
float wtf(float x) { return -1.+2.*fract(atan(atanh(fract(x*.5))/tan(x*.5))); }
vec4 polar(vec2 v) { return vec4(length(v), 0., 0., atan(v.y, v.x)); } // r=radius, a=angle
mat2 rot(float a) { float c=cos(a), s=sin(a); return mat2(c, s, -s, c); }

vec2 smin(float a, float b, float k) // quadratic with mix, non-associative
{   float h = max( k-abs(a-b), 0.0 )/k;
    float m = h*h*0.5;
    float s = m*k*0.5;
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}

float torus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sea=0;
ivec2 id = ivec2(0);
float tra=0.;
float map(vec3 p)
{
  p.y -= -2;
  p.y -= sin(p.x*.2+t);

  float tt=t;
  //p.yx *= rot(tt*.5);
  //p.yz *= rot(tt*1.1*.5);
  p.xz *= rot(tt*1.3*.5);
  //p.yx *= rot(tt*1.2*.5);
  
  float m = 6;
  id = ivec2((p.xz - m/2) / m);
  p.xz = mod(p.xz - m/2, m) - m/2;
  
  float t1 = torus(p, vec2(1, .45));
  vec3 pp=p;
  pp.xz *= rot(.8 * (id.x + id.y * 5 + t*6 * ( (id.x *7 + id.y * 3 + 500) % 4 < 2 ? 1 : -1)));
  pp -= vec3(-1.2, 0.45,0);
  pp.xy *= rot(TAU/3);
  float t2 = torus(pp, vec2(.4, .4));
  vec2 v = smin(t1, t2, .2);
  tra = v.y < 0.5 ?
    (p.y < 0 ? 1 : 0) :
    (pp.y > 0 ? 1 : 0);
  vec3 sp=p;
  sp.y-=-.5;
  sea = sp.y<0.2 ? 1 : 0;
  return min(v.x, length(sp.y));
}
vec3 normal(vec3 p) { vec2 e=vec2(.001,0.); return normalize(
  vec3(map(p+e.xyy),map(p+e.yxy),map(p+e.yyx)) -
  vec3(map(p)) );
}

float trace(vec3 ro, vec3 rd)
{
  vec3 p=ro;
  float td = 0;
  for (int i=0; i<100; i++)
  {
    float d=map(p);
    td += d;
    if (d>20.) return -2;
    if (d<.001)
    {
      return td;
    }
    p += d * rd;
  }
  return -1;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec4 pol = polar(uv);
	float fft = texture( texFFT, 0. ).r * 100;

  vec3 col = vec3(.6,.07,.7);
	col += .03*fft*abs(uv.y) + .3*mod(pol.a+t*4.+sin(t*5.)*.5, TAU/8.);
  col.b=.3;

  float blinnPhong=0; 
  
  vec3 ro=vec3(0,0,-5);
  vec3 rd=normalize(vec3(uv,1.));
  float d = trace(ro, rd);
  if (d>0)
  {
      vec3 p = ro + d * rd;
      vec3 n = normal(p);
      vec3 ldir=normalize(vec3(sin(t), cos(t), 1.));
      float diff = sat(dot(n, -ldir));

      vec3 h = -normalize(rd + ldir);
      blinnPhong += pow(sat(dot(h, n)), 200.);

      float co = (id.x + id.y * 3 + 500) % 4 < 2 ? 1 : 0;
    
      vec3 c2 = vec3(0);
      if (tra > .5)
      {
        float d2 = trace(p, rd);
        if (d2 > 0)
        {
      vec3 p = ro + d * rd;
      vec3 n = normal(p);
      vec3 ldir=normalize(vec3(sin(t), cos(t), 1.));
      float diff = sat(dot(n, -ldir));

      vec3 h = -normalize(rd + ldir);
      blinnPhong += pow(sat(dot(h, n)), 200.);
      c2 = diff *
          (sea > .5 ? vec3(0,0,.9) :
        (co > .5 ?
        vec3(.38, .8, .0) :
        vec3(0, .8, .8))
);
        }
      }
    
      vec3 c =
           (sea > .5 ? vec3(0,0.3,.9) :
      diff *
        (co > .5 ?
        vec3(.38, .8, .0) :
        vec3(0, .8, .9)));
      col = mix(col + .4, c, tra);
  }
  col = clamp( col, 0.0, 1.0 ) + blinnPhong;
  col.xy *= rot(t);
  col.yz *= rot(t);
  col.zx *= rot(t);
  
	out_color = vec4(sqrt(col), 1);
}
