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
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define rot(a) mat2(cos(a), sin(a),-sin(a),cos(a))
float bx(vec3 p, vec3 s){
  p = abs(p)-s;
  return max(max(p.x,p.y), p.z);
}
float t = mod(fGlobalTime, 100.);
vec3 smin(vec3 a, vec3 b , float k){
  vec3 h = max(vec3(0.), k-abs(a-b))/k;
  return min(a,b) - h*h*k*.25;
}

float cc(float a,float k){
  return mix(floor(a), floor(a+1), pow(fract(a),k));
}

float h(vec2 p){
  return fract(sin(dot(p, p.yx*23.)*234.234)*234.34);
}

float m1(vec3 p){
  vec3 p1 = p;
  float md = 1e3;
  float sc = 1.0123;
  p1.xz *= rot(t);
  p1.yz *= rot(t);
  float ss = sin(cc(t*.65,3.))*.25-.25;
  for(float i = 0; i++ < 8.;){
    for(float ii = 0.; ii++ < 5.;){
      //p1 = abs(p1)-ss;
      //p1 = abs(p1)-3.;
      p1 = smin(p1, .38-p1, .35625);
      
      p1.xy *= rot(cc(t*.515, 10.)); p1.yz *= rot(cc(t*.325,.55));
      
    }
    p1.xz *=rot(cc(t*.175,13.));
    md = min(md, length(p1/sc)-.1-i*.015);
    p1*=.23;
    sc*=.23;
  }
  //return length(p1)-1.;
  return md;
}
float m(vec3 p){
  float d1 = m1(p);
  p.yx *= rot(cc(t,2.3));
  vec3 p3 = p;
  p3.yz *= rot(t);
  float d = bx(p3,vec3(1.15,cos(t)*.5+.5,sin(t)*.5+.75));
  float ss = 1.445;
  vec3 p1=p;
  p1.z += t*8.;
  vec2 gid = floor(p1.xz/ss-.5);
  float id = h(gid);
  //p1.y += id*.345*1.5+sin(t*2.)*.5-.5;
  p1.y = abs(p1.y)-7.;
  //p1.z = abs(p1.z)-6.;
  
  
  p1.xz = (fract(p1.xz/ss-.5)-.5)*ss;
  
  float b2 = bx(p1,vec3(1., 1.+id*.24345*1.5+sin(t*2.)*.5-.5, 1.)*.88);
  
  d = max(d1, d);
  d=min(d, b2);
  
  return d;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 s = vec3(0.01, 0.01, -10.);
  vec3 p = s;
  vec3 r = normalize(vec3(uv, 2.-length(sin(cc(t,20.)))));
  float i = 0.;
	for(; i++ < 100.;){
    float d = m(p);
    if(abs(d) < 0.001) break;
    p+=d*r;
  }
  vec3 co = vec3(pow(1.5-i/23., 3.));
  
	out_color = vec4(co ,1.);
}