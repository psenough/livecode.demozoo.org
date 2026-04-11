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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define time fGlobalTime
#define backbuffer texPreviousFrame
#define sat(x) clamp(x,0,1)
#define norm(x) normalize(x)
#define rep(i,n) for(int i=0;i<n;i++)
#define sc(x) hash(vec3(bt,x,129.1)-1.9203)
const float pi=acos(-1);
const float tau=pi*2;
vec2 F=gl_FragCoord.xy,R=v2Resolution,A=R/min(R.x,R.y),A2=R/max(R.x,R.y);
ivec2 U=ivec2(F);
float alt,lt,tr,atr;int bt;
vec3 hash(vec3 p)
{
  uvec3 x=floatBitsToUint(p+vec3(1,2,3)/10);
  uint k=0xF928A019;
  x=((x>>8u)^x.yzx)*k;x=((x>>8u)^x.yzx)*k;x=((x>>8u)^x.yzx)*k;
  return vec3(x)/vec3(-1u);
}
vec3 erot(vec3 p,vec3 ax,float t)
{
  ax=norm(ax);
  return mix(ax*dot(ax,p),p,cos(t))+sin(t)*cross(ax,p);
}
mat3 bnt(vec3 t)
{
  vec3 n=vec3(0,1,0);
  vec3 b=cross(n,t);
  n=cross(t,b);
  return mat3(norm(b),norm(n),norm(t));
}
vec3 cyc(vec3 p,float q,vec3 s)
{
  vec4 v=vec4(0);
  mat3 m=bnt(s);
  rep(i,5)
  {
    p+=sin(p.yzx);
    v=v*q+vec4(cross(cos(p),sin(p.zxy)),1);
    p*=q*m;
  }
  return v.xyz/v.w;
}
void add(ivec2 p,vec3 v)
{
  ivec3 q=ivec3(v*2048);
  imageAtomicAdd(computeTex[0],p,q.x);
  imageAtomicAdd(computeTex[1],p,q.y);
  imageAtomicAdd(computeTex[2],p,q.z);
}
vec3 read(ivec2 p)
{
  return vec3(imageLoad(computeTexBack[0],p).x,imageLoad(computeTexBack[1],p).x,imageLoad(computeTexBack[2],p).x)/2048.;
}
ivec2 proj(vec3 p,vec3 ro,mat3 m,float z,out float sz)
{
  vec3 od=(p-ro)*m;
  sz=od.z/z;
  vec2 uv=od.xy/sz;
  uv=(uv/A+1)*.5;
  return ivec2(uv*R);
}
void set(float t){alt=lt=t;atr=tr=fract(alt);bt=int(alt);tr=tanh(tr*2);lt=bt+tr;}
float sdf(vec3 p)
{
  vec3 q=p;
  float d=1e9;
  float a=mod(atan(p.y,p.x)+p.z,tau/3)-pi/3,l=length(p.xy);
  p=erot(vec3(l,0,p.z),vec3(0,0,1),a);
  p.xz=mod(p.xz,1)-.5;
  if(bt/2%2==0)d=min(d,length(p.xz));
  if(bt/2%2!=0)d=min(d,length(erot(q,vec3(0,0,1),q.z*2).xy-vec2(1,0)));
  return d;
}
const vec2 e=vec2(1e-2,0);
#define normal(s,p) norm(vec3(s(p+e.xyy)-s(p-e.xyy),s(p+e.yxy)-s(p-e.yxy),s(p+e.yyx)-s(p-e.yyx)))

void main(void)
{
  set(time*137./60.);
  //bool fast=bt%2==0;
  //set(alt*(fast?16:1));
	vec2 uv=F/R,suv=(uv*2-1)*A;
  float _a;
  if(bt/8%2==0)F=proj(vec3(suv,.8),cyc(vec3(time),1.1,vec3(-1)),bnt(vec3(0,0,1)),1-length(suv)*.2,_a);
  U=ivec2(F);
  uv=F/R,suv=(uv*2-1)*A;
  
  int id=int(F.x+F.y*R.x);
  vec3 c=vec3(0);
  float z=1.,sz;
  vec3 ro,dir;
  
  ro=vec3(0,0,-4);
  if(bt%3!=0)ro=erot(ro,sc(0),lt+1.);
  dir=norm(-ro);
  mat3 m=bnt(dir);
  
  if(U.x<400)
  {
    vec3 p=(sc(id)*2-1)*4*tr;
    int n=30;
    rep(i,n)
    {
      float f=i/float(n);
      p-=sin(p*pi*.5)*tr*.5;
      if(bt%5!=0)p=erot(p,dir,length(p-ro)*tr);
      c=(1+cos(vec3(1,2,3)/tr+f*tau))/n*.3;
      ivec2 u=proj(p,ro,m,z-length(suv)*tr*length(p-ro)/30*float(bt%3==0)*2,sz);
      add(u,c*step(0,sz));
    }
  }
  else if(U.x<800&&bt%2==0)
  {
    vec3 p=(sc(id)*2-1)*4*tr,nyan=sc(-2);
    int n=30;
    rep(i,n)
    {
      float f=i/float(n);
      p-=cyc(p,1.5*tr,nyan)*tr;
      //if(bt%5!=0)p=erot(p,dir,length(p-ro)*tr);
      c=(1+cos(vec3(1,2,3)+f*tau))/n*.1*vec3(1,.2,.2);
      ivec2 u=proj(p,ro,m,z-length(suv)*tr*length(p-ro)/30*float(bt%3==1),sz);
      add(u,c*step(0,sz));
    }
  }
  else if(U.x<1200&&bt%2==1)
  {
    vec3 p=(sc(id)*2-1)*5*tr,nyan=sc(-2);
    int n=30;
    rep(i,n)
    {
      float f=i/float(n);
      p-=sdf(p)*normal(sdf,p)*tr;
      //if(bt%5!=0)p=erot(p,dir,length(p-ro)*tr);
      c=(1+cos(vec3(1,2,3)+f*tau))/n*.2*vec3(1,.2,.2).gbr;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(0,sz));
    }
  }
  
	c=read(U);
  if(bt/8%2==0)
  {
    float s=.01,ww=.4;
    vec2 ruv=abs(erot(vec3(suv,0),vec3(0,0,1),hash(vec3(int(alt*4),1,2)).x*tau).xy);
    float nya=smoothstep(s*.4,s*.2,abs(ruv.x*ruv.y-s*5));
    nya+=step(ww,ruv.x)*step(ww,ruv.y)*step(length(ruv),length(vec2(ww+.05)));
    nya+=step(abs(length(suv)-.5),s*.5);
    if(1.<abs(suv.y))
    {
      c=vec3(0);
    }
    c+=nya*step(fract(alt*4),.5)*vec3(1,0,0);
  }
  vec3 ba=texture(backbuffer,uv).rgb;
  //c=mix(c,ba,.5);
  //if(bt/2%8==0)c=abs(ba-c);
  if(bt%7==0)c=mix(c,1-c.rrr,step(fract(alt*4),.5));
	out_color=vec4(c,1);
}