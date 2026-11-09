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
  int d=6;
  float mz=.5;
  p.z=mod(p.z+mz*.5,mz)-mz*.5;
  float a=atan(p.y,p.x);a=mod(a,tau/d)-pi/d;
  //a+=length(p.xy)*.5;
  p.xy=vec2(cos(a),sin(a))*length(p.xy);
  return min(length((p-vec3(.5,0,0)).xz),length(q.xy)-.01);
}
const vec2 e=vec2(1e-2,0);
#define normal(s,p) norm(vec3(s(p+e.xyy)-s(p-e.xyy),s(p+e.yxy)-s(p-e.yxy),s(p+e.yyx)-s(p-e.yyx)))

void main(void)
{
  set(time*140./60./8.);
  bool fast=bt%2==0;
  set(alt*(fast?16:1));
  
	vec2 uv=F/R,suv=(uv*2-1)*A;
  int id=int(F.x+F.y*R.x);
  vec3 c=vec3(0);
  float z=1.,sz;
  vec3 ro,dir;
  ivec3 h1=ivec3(sc(12.3)*4);
  
  ro=vec3(0,0,-4);
  //if(h1.y!=0)ro=erot(ro,sc(1)-.5,tr);
  ro=erot(ro,sc(1)-.5,(fast?1:tr));
  
  dir=-ro;
  if(!fast){
    dir=vec3(0,0,1);
    ro=vec3(0,0,-4);
  }
  if(fast)z=1;
  else z=.5+tr*2;
  
  mat3 m=bnt(dir);
  if(U.x<400)
  {
    vec3 p=(hash(vec3(bt,1,id))*2-1)*4*tr;
    int n=30;
    rep(i,n)
    {
      float f=i/float(n);
      p-=sin(p*pi)*tr*.5;
      c=(1+cos(vec3(1,2,3)+f*tau))/n*.1;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(.0,sz));
    }
  }
  else if(U.x<800)
  {
    vec3 p=(hash(vec3(bt,1,id))*2-1)*2*tr;
    int n=30;
    vec3 di=sc(-1)-.5;
    rep(i,n)
    {
      float f=i/float(n);
      p+=cyc(p+vec3(0,alt,0)*vec3(fast),tr*1.5,di);
      c=(1+cos(vec3(1,2,3)+f*tau))/n*.2;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(.0,sz));
    }
  }
  else if(U.x<1200)
  {
    vec3 p=(hash(vec3(bt,1,id))*2-1)*4*tr;
    int n=30;
    rep(i,n)
    {
      float f=i/float(n);
      p-=normal(sdf,p)*sdf(p)*.1;
      c=(1+cos(vec3(1,2,3)+f*tau))/n*.1;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(.0,sz));
    }
  }
  
	c=read(U);
  {
    // hud
    vec2 ruv=uv*A*32,fuv=fract(ruv),iuv=floor(ruv);
    // TODO
  }
  //c=mix(c,texture(backbuffer,uv).rgb,.5);
  vec3 ba=vec3(c.r,texture(backbuffer,uv).rg);
  c=mix(c,texture(backbuffer,uv).rgb,.5);
  //c=mix(c,ba,.9);
	out_color=vec4(c,1);
}