#version 410 core

uniform float fGlobalTime; // in seconds
#define time fGlobalTime
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

#define F float
#define V vec2
#define W vec3
#define N normalize
#define L length
#define S(x) sin(x+2*sin(x+4*sin(x)))
#define sabs(x) sqrt((x)*(x)+.1)
#define smin(a,b) ((a+b-sabs(a-(b)))*.5)
#define T 6.283
#define Z(p,s) (asin(sin(p*T/s)*.9)/T*s)
#define gyr(p,s) (dot(sin((p)*(s)),cos((p).zxy*(s)))/s*.5)
layout(location = 0) out vec4 o; // out_color must be written in order to see anything
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))
F gl=0;

F sdf(W p){
  W pI=p;
  p.x+=S(p.z*.1+time*.3)*p.z*.1;
  p.y+=S(p.z*.161+time*.24)*p.z*.03;
  p.z+=time*3.5;
  F pl=p.y+1;
  p=Z(p,W(15,15,4));
  
  F l=L(abs(p)-.1+.05*S(pI.z*.8+time*1.3))-.01;
  
  p.xy=V(L(p.xy)-2+.5*S(pI.z*.4+time*.8),atan(p.y,p.x)/T*8+S(pI.z*.3+.6*time));
  p.y=Z(p.y,.5);
  F sp=L(p)-.8;
  sp=L(V(sp,gyr(p,8)))-.1;
  sp=L(V(sp,gyr(p,20)))-.001;
  //sp=L(V(sp,gyr(p,53)))-.0001;
  
  sp=smin(sp,pl);
  
  sp=min(l,sp);
  
  gl+=.015/l*sp;
  if(l<.002)gl++;
  
  return sp*.5;
}


W norm(W p){
  V e=V(0,.001); F d=sdf(p);
  return N(W(d-sdf(p-e.yxx),d-sdf(p-e.xyx),d-sdf(p-e.xxy)));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	o*=0;

  F i=0,d=0,e=1;
  W p,rd=N(W(uv,1));
  rd.xz*=rot(.2*S(time*.162));
  rd.yz*=rot(.1*S(time*.08));
  for(;i++<99&&e>.0001;){
    p=rd*d+.00001;
    d+=e=sdf(p);
  }
  
	o+=1-i/99;
  W l=W(0,1,0);
  W n=norm(p);
  o.r+=dot(n,l)*.5+.5;
  o.b+=dot(n,l.zxy)*.5+.5;
  o+=pow(dot(reflect(rd,n),l)*.5+.5,40);
  o+=gl;
  o=pow(o,vec4(.8));
}