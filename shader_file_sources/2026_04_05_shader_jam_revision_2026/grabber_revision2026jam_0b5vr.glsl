#version 420 core

#define saturate(x) clamp(x,0.,1.)
#define repeat(i,n) for(int i=0;i<n;i++)

const float PI=acos(-1.);
const float TAU=PI*2.;

float beat;
float mode;

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
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 hue2rgb(float t){
  return saturate(abs(mod(6.*t + vec3(0,4,2), 6.) - 3.) - 1.);
}

vec2 cis(float t){
  return vec2(cos(t),sin(t));
}

mat2 r2d(float t){
  float c=cos(t),s=sin(t);
  return mat2(c,s,-s,c);
}

mat3 orthbas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)>.99?vec3(0,0,1):vec3(0,1,0);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

vec3 cyclic(vec3 p){
  mat3 b=orthbas(vec3(3,4,-5));
  vec3 sum=vec3(0);
  repeat(i,5){
    sum*=2.;
    p+=sin(p.yzx);
    sum+=cross(cos(p),sin(p.zxy));
    p*=2.;
  }
  return sum/31.;
}

float sdcapsule(vec2 p,vec2 tail){
  float t=saturate(dot(p,tail)/dot(tail,tail));
  return length(p-tail*t);
}

float sdarc(vec2 p,float r,float t){
  p.y=abs(p.y);
  float tt=clamp(atan(p.y,p.x),0.,t);
  return length(p-r*cis(tt));
}

float sdclippyclip2(vec2 p){
  float d=1.;
  d=min(d, sdcapsule(p-vec2(-.1,0),vec2(0,-.1)) );
  d=min(d, sdarc((p-vec2(0,-.1))*r2d(-PI/2.),.1,PI/2.) );
  d=min(d, sdcapsule(p-vec2(.1,-.1),vec2(0,.4)) );
  d=min(d, sdarc((p-vec2(-.05,.3))*r2d(PI/2.),.15,PI/2.) );
  d=min(d, sdcapsule(p-vec2(-.2,.3),vec2(0,-.5)) );
  d=min(d, sdarc((p-vec2(0,-.2))*r2d(-PI/2.),.2,PI/2.) );
  d=min(d, sdcapsule(p-vec2(.2,-.2),vec2(0,.1)) );
  d=min(d, sdarc((-p-vec2(-.4,.1))*r2d(-PI/8.),.2,PI/8.) );
  return d;
}

float sdclippyclip(vec3 p){
  float d=length(vec2(
    sdclippyclip2(p.xy),
    p.z
  ));
  return d-.04;
}

vec4 map(vec3 p){
  if(mode==0.){
    p.x+=.5*sin(3.0*fGlobalTime)*p.y*p.y;
    p.zx*=r2d(.5*sin(2.*fGlobalTime));
  }

  float d=sdclippyclip(p);
  p.x=abs(p.x+.05);
  d=min(d, length(p-vec3(.15,.15,.05))-.1 );
  d=min(d, length(p-vec3(.15,.15,.1))-.07 );
  d=min(d, length(vec2(sdarc((p.xy-vec2(.15,.12))*r2d(1.3),.2,.4),p.z-.05)) - .05+.12*p.x );
  return vec4(d);
}

vec3 nmap(vec3 p){
  vec2 d=vec2(0,.001);
  return normalize(vec3(
    map(p+d.yxx).w-map(p-d.yxx).w,
    map(p+d.xyx).w-map(p-d.xyx).w,
    map(p+d.xxy).w-map(p-d.xxy).w
  ));
}

void main(void){
  beat=135./60.*fGlobalTime;
  float heartbeat=cos(TAU*exp(-3.0*fract(beat)));
  
  mode=step(mod(beat,4.),1.);
  float heckframe=floor(fGlobalTime*30.);
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  
  float roz=mode==0.?.7+.1*heartbeat:.4+.05*mod(heckframe,2.);
  vec3 ro=vec3(0,0,roz);
  vec3 rd=normalize(vec3(p,-1));
  
  float rl=0.;
  vec3 rp=ro;
  vec4 march;
  float accum=0.;
  
  repeat(i,64){
    march=map(rp);
    accum+=.1*saturate(exp(-20.*abs(march.w)));
    rl+=.8*march.w;
    rp=ro+rd*rl;
  }
  
  if(march.w<.01){
    vec3 n=nmap(rp);
    vec3 r=reflect(rd,n);
    r.zx*=r2d(7.*fGlobalTime);
    vec3 noise=cyclic(r);
    out_color=vec4(vec3(1,.6,.2)*exp(noise.x),1);
  }else{
    float theta=atan(p.y,p.x);
    
    // rainbow
    {
      vec3 noise=cyclic(vec3(.2*sqrt(length(p))-fGlobalTime,cis(theta)));
      vec3 hue=hue2rgb(.3*noise.x+2.*theta/TAU+fract(fGlobalTime));
      vec3 col=mix(vec3(1),hue,.9);
      col=col*exp(2.*sin(20.*noise.y)-1.);
      col*=(1.-exp(-length(p)));
      out_color=vec4(col,1);
    }
    
    // lines
    {
      vec3 noise=cyclic(2.*vec3(sqrt(length(p))-8.*fGlobalTime,40.*cis(theta)));
      float value=exp(5.*noise.x-4.);
      value*=(1.-exp(-length(p)));
      out_color.xyz+=value;
    }
    
    out_color.xyz+=accum*hue2rgb(p.x+p.y+fGlobalTime);
    
    if(mode==1.&&mod(heckframe,4.)==2.){
      out_color.xyz=1.-out_color.xyz;
    }
    
    if(mode==1.&&mod(heckframe,4.)==3.){
      out_color.xyz=vec3(step(dot(out_color.xyz,vec3(1)),1.5));
    }
  }
}