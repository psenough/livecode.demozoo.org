#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;

mat2 rot(float a) {
  float sa=sin(a);
  float ca=cos(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return min(0, max(p.x,max(p.y,p.z))) + length(max(p,0));
}

float fa=0.3;
float fft(float t) {
  
  return texture(texFFTSmoothed, fract(t)*0.1+0.01).x*fa;
}
float ffti(float t) {
  
  return texture(texFFTIntegrated, fract(t)*0.1+0.01).x*fa;
}


float rnd(float t) {
  return fract(sin(t*345.293)*754.834);
}


vec3 rnd(vec3 t) {
  return fract(sin(t*345.293+t.yzx*534.929+t.zxy*643.045)*754.834);
}

float map(vec3 p) {
  
  for(int i=0; i<3; ++i){
    p.xz *= rot(time*0.1 + ffti(0.01+0.01*i)*0.2);
    p.xy *= rot(time*0.13 + ffti(0.013+0.013*i)*0.7);
    p.xz = abs(p.xz)-2;
    
  }
  
   float d=box(p, vec3(0.3));
  
  p=abs(p)-10;
  
  p+=sin(p.yzx/3);
  
  d=min(d, box(p, vec3(0,10,0)));

  return d;  
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  fa = 0.2;
  time = mod(fGlobalTime, 300);
  time *= 128/120.0;
  time += rnd(floor(time-length(uv)/3))*1000;
  
  vec3 s=vec3(0,0,-30);
  s.x += sin(time*0.1 + ffti(0)*1) * 2;
  vec3 r=normalize(vec3(uv, 3));
  vec3 p=s;
  
  vec3 col=vec3(0);
  
  float md=10000;
  vec3 mn=vec3(1,0,0);
  
  for(int i=0; i<200; ++i){
    
    float d=map(p);
    if(d<md) {
      md=d;
      vec2 off=vec2(0.01,0);
      mn=normalize(map(p)-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
    }
    if(abs(d)<0.001) {
      //col += map(p-r);
      break;
    }
    if(d>1000) break;
    p+=r*d*0.5;
  }
  
   md *=3;
  
  float ra=atan(mn.y,mn.x)/6.28;
  ra *= ceil(md)*5;
  
  
  ra += (rnd(floor(md))-0.5) * time * 5;
  
  float id=rnd(floor(md)+rnd(floor(ra)+0.3));
  
  col += step(0.01,md)*step(fract(ra),0.8) * step(fract(md),0.8) * rnd(vec3(id, 0.7,0.5));
  
  col *= exp(-0.1*fract(time-length(uv)/3));
  col *= 1.2-abs(uv.y);
  
  if(dot(col,vec3(0.33))<0.05) {
      float t2=time;
    col=vec3(1,0.5,0.3);
    col.xz *= rot(t2+uv.x);
    col.yz *= rot(t2*1.3+uv.y);
    col=abs(col);
    
  }
  
  vec3 lum = vec3(dot(col,vec3(0.33)));
  float lim=abs(uv.y)-0.3+md/20;
  
  vec3 prev = vec3(0);
  vec2 of=uv/60;
  prev.x += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy-of).x;
  prev.y += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy-of*0.2).y;
  prev.z += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy+of).z;
  
  lum *= abs(lim)*3;
  
  lum=mix(lum, prev, 0.95);
  
  
  if(lim>0) {
    col = lum;
  }
  
  
	out_color = vec4(col, 1);
}