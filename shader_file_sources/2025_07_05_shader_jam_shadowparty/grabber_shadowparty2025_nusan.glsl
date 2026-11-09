#version 420 core

// greetings to peregrine!!! cookie collective!!! Marex!!! Callisto!!! P0ke!!!
// come to shadow partyy!!! it's great
// thanks to all the orga team for the awesome event!
// and of course, grretings to alkama!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time=mod(fGlobalTime, 300);
float time2=mod(fGlobalTime, 300);

float fft(float t) {
  return texture(texFFTSmoothed, fract(t)*0.1).x * 10;
}

float ffti(float t) {
  return texture(texFFTIntegrated, fract(t)*0.1).x * 10;
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float rnd(float t) {
  return fract(sin(t*623.923)*382.642);
}

vec3 atm=vec3(0);
float map(vec3 p) {
  
  for(int i=0; i<4; ++i) {
    p.xz*=rot(time*0.1);
    p.yz*=rot(time*0.15);
    p.xz=abs(p.xz)-2;
  }
  float d=length(p)-1;
  
  float d2=length(abs(p.xz)-0.2)-0.;
  float d3=length(abs(p.yz)-1.2)-0.;
  d=min(d,d2);
  d=min(d,d3);
  
  atm+=vec3(0.4,0.2,0.3) * 0.03/(0.06+abs(d2));
  atm+=vec3(0.1,0.3,0.7) * 0.02/(0.06+abs(d3));
  
  return d;
  
}

vec3 norm(vec3 p) {
  vec2 off=vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
  
}

vec3 back(vec3 r) {
  vec2 uv2=r.xy;
  uv2 *= rot(ffti(0.01)*0.05);
  uv2 *= 1.5-fft(0.02)-length(r.xy);
  return vec3(1,0.5-abs(r.x),0.7+abs(r.z)) * fft(abs(floor(uv2.x*40)/40));
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  
  
  return max(p.x,max(p.y,p.z));
}

float box2(vec2 a, float s) {
  a=abs(a)-s;
  return max(a.x,a.y);
}

float map2(vec3 p) {
  
  p.xz*=rot(time2*0.1);
  p.yz*=rot(time2*0.15);
  
  float d=box(p,vec3(1));
  float ss=0.9;
  d=max(d,-box(p,vec3(ss,ss,10)));
  d=max(d,-box(p,vec3(ss,10,ss)));
  d=max(d,-box(p,vec3(10,ss,ss)));
  vec3 p2=p;
  p2.xz*=rot(0.7);
  p2.xy*=rot(0.7);
  d=min(d,box(p2,vec3(0.7)));
  p=abs(p)-1;
  d=min(d,box(p,vec3(0.3)));
  p=abs(p)-0.3;
  d=min(d,box(p,vec3(0.1)));
  
  p2=abs(p2)-3;
  d=min(d,box2(p2.xz,0.05));
  d=min(d,box2(p2.yz,0.05));
  d=min(d,box2(p2.xy,0.05));
  
  
  return d;
  
}

vec3 second(vec3 base, vec2 uv) {
 
  uv.y -= (fft(0.02)-1)*0.05;
  
  vec3 col=base;
  vec3 s=vec3(0,0,-6);
  float fov=1;
  vec3 r=normalize(vec3(uv, fov));
  vec3 p=s;

  bool near=false;
  for(int i=0; i<100; ++i) {
    float d=abs(map2(p));
    if(d<0.03) near=true;
    if(near && d>0.3) {
      col += vec3(0.2,1,0.3);
      near=false;
    }
    if(d<0.001) {
      col*=0.4*map2(p-r);
      //col+=vec3(0.2,1,0.3)*max(0,map2(p-r));
      d=0.1;
      break;
    }
    if(d>100.0) break;
    p+=r*d;
  }

  return col;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  time=mod(fGlobalTime, 300);
  float ss=10;
  vec2 uv3=uv;
  uv3 *= rot(ffti(0.01)*0.01);
  time += fft(floor(abs(uv3.x)*ss)/ss)*0.5;
  time += rnd(floor(fGlobalTime/4-length(uv)*0.2))*300;
  
  time2=mod(fGlobalTime, 300);
  time2 += ffti(0.01)*0.3;
  
	vec3 col=vec3(0);
  
  vec3 s=vec3(0,0,-10);
  s.x += sin(time*0.05)*3;
  s.y += sin(time*0.07)*2;
  float fov=1+fft(0.01)*0.2;
  vec3 r=normalize(vec3(uv, fov));
  
  
  
  col += back(r);
  
  vec3 coco=vec3(0);
  vec3 coca=vec3(0);
  vec3 p=s;
  float alpha=1;
  for(int i=0; i<100; ++i) {
    float d=map(p);
    if(d<0.001) {
      vec3 n=norm(p);
      float amb=map(p-r);
      r=-reflect(n,r);
      col*=0;
      coco = amb * back(r) * alpha;
      coca += atm * alpha;
      atm=vec3(0);
      alpha*=amb;
      d=0.1;
      p+=n*0.1;
      //break;
    }
    if(d>100.0) break;
    p+=r*d;
  }
  coca += atm * alpha;
  
  col += coco;
  col += coca;
  
  col.xz *= rot(uv.y*0.7);
  col=abs(col);
  
  col *= 0.4;
  
  col = second(col, uv);
  
  col=smoothstep(0,1,col);
  col=pow(col,vec3(0.4545));
  
  uv.x += sin(fGlobalTime*0.1)*0.4;
  uv.x += sin(fGlobalTime*0.14)*0.2;
  vec2 uv2=uv;
  uv2*=rot(fGlobalTime);
  vec3 prev=vec3(1,0.8+0.5*uv2.y,1)*texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy -uv*0.03).xyz;
  prev+=vec3(1,0.4,0.2)*0.01/(0.1+length(uv2));
  float fac = 0.58+(sin(time2/20)-0.9)*1.5;
  //fac=1;
  prev=mix(prev,mix(vec3(0.8*(1-4*pow(abs(uv.y),1.4))),(0.02+0.08*fft(0.01))/length(uv)+vec3(0.2-length(uv),0.2+0.4*sin(3.14*10*atan(uv.x,uv.y)),0.8),step(length(uv),0.2)), step(length(uv*vec2(1,1/(0.6*pow(1-max(0,sin(fGlobalTime*10)),3)))),0.4));
  col=mix(col,prev,clamp(fac,0,1));
  
	out_color = vec4(col, 1);
}