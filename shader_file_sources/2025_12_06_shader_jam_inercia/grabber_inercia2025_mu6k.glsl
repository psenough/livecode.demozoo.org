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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaID;
uniform sampler2D texInerciaBW;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T (fGlobalTime)
#define aspect(A) (textureSize(A,0).x/textureSize(A,0).y)


float df(vec3 p) {
  vec3 p2=mod(p,vec3(1.0));
  float d=1e3;
  for (float fi=0; fi<10.0; fi+=1.0)
  {
    vec3 offs=vec3(fi+T/4,fi+T/5,fi+T/6);
    vec3 off=sin(offs);
    float sp=length(p+off+sin(p.yzx*10.0+vec3(T*2.5,T,T/2))*0.1)-1.0+sin(T*2.0)*.15;
    sp=abs(sp)-1.0;
    sp=abs(sp)-.01;
    d=min(d,sp);
  }
  vec3 p3=p;
  p3.xy=mod(p3.xy-0.5+vec2(T/10),vec2(1.0))-0.5;
  d=max(d,0.4-length(p3.xy));
  
  return d;
}

void main(void)
{
  vec2 ssuv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv += 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv2=uv;
  uv2 = (gl_FragCoord.xy-v2Resolution.xy/2) / v2Resolution.y;
  
  uv*=vec2(1,aspect(texInerciaBW));
  uv=vec2(0.5,-0.5)*uv*4.5+vec2(T*1,4);
  vec4 overlay = step(uv.y,-4.01)*step(-4.99,uv.y)*texture(texInerciaBW, uv);
  
  int it=0, maxit=50;
  vec3 pos = vec3(0,0,-4);
  vec3 dir = normalize(vec3(uv2,1+length(uv2)));
  float odd=(int(gl_FragCoord.x+gl_FragCoord.y)%2)*1.0;
  float tt=(int(gl_FragCoord.x+gl_FragCoord.y)%2)*1.0;
  
  for (it=0; it<maxit; it+=1)
  {
    float dist=df(pos+dir*tt);
    tt+=dist;
    if (dist<1e-3||dist>1e+3) break;
  }
  vec3 pos2 = pos+dir*tt;
  vec3 col=fract(pos2)/(1.0-float(it)/float(maxit))/tt;
  col=max(col, vec3(0));
  col=mix(mix(vec3(.1,.1,.1),vec3(.1,.1,.1), ssuv.y), col, 10.0/(1.0+tt*tt));
  col=vec3(1)*float(it)/float(maxit)*normalize(dir-vec3(sin(T/9),sin(T/11),0.5));
  col.xyz+=col*.5;
  col*=3.0;
  col+=overlay.xyz;
  col=col*1.4/(col+1.0);
  
  out_color = mix(vec4(col,1),overlay,overlay*0.0);
  out_color = mix(out_color,texture(texPreviousFrame, ssuv+uv2*.01+odd*.01*vec2(sin(T),cos(T))),(0.8+odd*.2)*.8);
  return;
}