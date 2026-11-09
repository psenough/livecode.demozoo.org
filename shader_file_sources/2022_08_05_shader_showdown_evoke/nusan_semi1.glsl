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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time=mod(fGlobalTime, 300);


mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float musi(float t) {
  return texture(texFFTIntegrated, t*.1).x;
}

float cyl(vec3 p, float d, float h) {
  
  return max(length(p.xz)-d,abs(p.y)-h);
}

float rnd(float t) {
  return fract(sin(t*457.814)*943.824);
}

vec3 rnd3(float t) {
  return fract(sin(t*457.814)*vec3(943.824,724.174,528.934));
}

float map(vec3 p) {
  
  vec3 bp=p;
  
  p.y-=musi(0.02)*5;
  
  p.xz *= rot(time+p.y*.01);
  
  p.xz = abs(p.xz) - 15;
  p.xz = abs(p.xz) - 3;
  
  float d=1000;
  for(int i=0; i<15; ++i) {
    
    vec3 p2=p;
    float s=10;
    p2+=(rnd3(i*.2+.1)-.5)*vec3(2,10,2);
    p2.y=(fract(p2.y/s+.5)-.5)*s;
    d=min(d, cyl(p2, .3,2));
    vec3 p3=p2;
    p3.xz *= rot(time*.3-p.y*.05);
    d=min(d, length(p3.xy)-.1 + max(0,sin(p.y*.15))*0.5);
    
  }
  
  //d=max(d, 2-length(bp.xz));
  
  return d;
}

void cam(inout vec3 p) {
  float t=musi(0.03)*.5;
  p.yz *= rot(sin(t*.05)*.5-.9);
  p.xz *= rot(t*.1);
  
}

vec3 norm(vec3 p, float off) {
  vec2 of=vec2(off,0);
  return normalize(vec3(map(p+of.xyy)-map(p-of.xyy), map(p+of.yxy)-map(p-of.yxy), map(p+of.yyx)-map(p-of.yyx)));
}

float gao(vec3 p, vec3 n, float t) {
  return smoothstep(0,1,map(p+n*t)/t)*.5+.5;  
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 s=vec3(sin(time*.5)*3,0,-10);
  vec3 r=normalize(vec3(uv,1));
  cam(s);
  cam(r);
  
  vec3 p=s;
  
  vec3 col=vec3(0);
  
  for(int i=0; i<100; ++i) {
    float d=map(p);
    if(d<0.001) break;
    if(d>100) break;
    p+=r*d;
  }

  float fog=1-clamp(length(p-s)/100,0,1);
  //col+=map(p-r*.5) * fog;
  
  
  vec3 n=norm(p, 0.01);
  float ao=gao(p,n,0.1)*gao(p,n,0.2)*gao(p,n,0.4);
  vec3 l=normalize(vec3(3,2,1));
  vec3 h=normalize(l-r);
  float spec=max(0, dot(n,h));
  vec3 diff=vec3(1,0.8,0.3);
  float fre=pow(1-abs(dot(n,r)),4);
  col += max(0, dot(n,l)) * (diff*(1 + pow(spec, 10)) + pow(spec, 100));
  col += fre*vec3(0.5,0.7,1);
  col *= fog*ao;
  
  col += pow(1-fog,5) * 0.5*vec3(1.7,0.5,.5) * pow(abs(r.y),5);
  
  col.xz *= rot(time+uv.x);
  col=abs(col);
  
  col *= 2,
  
  col=smoothstep(0,1,col);
  col=pow(col, vec3(0.4545));
    
  
	out_color = vec4(col, 1);
}