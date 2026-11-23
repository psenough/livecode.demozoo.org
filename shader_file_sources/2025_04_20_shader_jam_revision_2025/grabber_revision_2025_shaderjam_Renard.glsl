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
const float pi = acos(-1);
const float tau = pi * 2;
vec2 F = gl_FragCoord.xy,R = v2Resolution,A = R / min(R.x,R.y),A2 = R / max(R.x,R.y);
ivec2 U = ivec2(F);
float alt,lt,tr,atr;
int bt,sid;
vec3 hash(vec3 p)
{
  uvec3 x = floatBitsToUint(p + vec3(1,2,3) / 10);
  uint k = 0xF928A019;
  x = ((x >> 8u) ^ x.yzx) * k;
  x = ((x >> 8u) ^ x.yzx) * k;
  x = ((x >> 8u) ^ x.yzx) * k;
  return vec3(x) / vec3(-1u);
}
vec3 erot(vec3 p,vec3 ax,float t)
{
  ax = norm(ax);
  return mix(ax * dot(ax,p),p,cos(t)) + sin(t) * cross(ax,p);
}
mat3 bnt(vec3 t)
{
  vec3 n = vec3(0,1,0);
  vec3 b = cross(n,t);
  n = cross(t,b);
  return mat3(norm(b),norm(n),norm(t));
}
vec3 cyc(vec3 p,float q,vec3 s)
{
  vec4 v = vec4(0);
  mat3 m = bnt(s);
  rep(i,5)
  {
    p += sin(p.yzx);
    v = v * q + vec4(cross(cos(p),sin(p.zxy)),1);
    p *= q * m;
  }
  return v.xyz / v.w;
}
void add(ivec2 p,vec3 v)
{
  ivec3 q = ivec3(v * 1024);
  imageAtomicAdd(computeTex[0],p,q.x);
  imageAtomicAdd(computeTex[1],p,q.y);
  imageAtomicAdd(computeTex[2],p,q.z);
}
vec3 read(ivec2 p)
{
  return vec3(imageLoad(computeTexBack[0],p).x,imageLoad(computeTexBack[1],p).x,imageLoad(computeTexBack[2],p).x) / 1024.;
}
ivec2 proj(vec3 p,vec3 ro,mat3 m,float z,out float sz)
{
  vec3 od = (p - ro) * m;
  sz = od.z / z;
  vec2 uv = od.xy / sz;
  uv = (uv / A + 1) * .5;
  return ivec2(uv * R);
}
void set(float t)
{
  alt = lt = t;
  atr = tr = fract(alt);
  bt = int(alt);
  //tr = tanh(tr * 3);
  tr=1-exp(-tr*4);
  lt = bt + tr;
}
float sdf(vec3 p)
{
  float a = mod(atan(p.y,p.x) + p.z,tau / 3) - pi / 3,l = length(p.xy);
  p = erot(vec3(l,0,p.z),vec3(0,0,1),a);
  float s=exp(-atr*5)+1;
  p.xz = mod(p.xz,s) - .5*s;
  return length(p.xz);
}
float sdf2(vec3 p)
{
  return length(p.xy)-.01;
}
const vec2 e = vec2(1e-2,0);
#define normal(s,p) norm(vec3(s(p+e.xyy)-s(p-e.xyy),s(p+e.yxy)-s(p-e.yxy),s(p+e.yyx)-s(p-e.yyx)))


float selif(vec2 suv)
{
  suv=round(suv*64)/64;
  float t=exp(-tr*3);
  suv=vec2(atan(suv.y,suv.x)/pi*2+time*.5,length(suv)-.2);
  suv=vec2(fract(suv.x*4)*2-1,suv.y*8);
  vec2 auv=abs(suv);
  float d=max(auv.x*auv.y-.2,-suv.y);
  return smoothstep(1,0,d/fwidth(d));
}
void main(void)
{
  set(time * 170./60./4);
  //if(bt%2==1)set(alt*8);
  sid=bt%4;
  vec2 uv = F / R,suv = (uv * 2 - 1) * A;
  //float _sz;
  //F=proj(vec3(suv,1),cyc(vec3(1,2,time),1.2,vec3(1)),bnt(vec3(0,0,1)),1-length(suv)*.1,_sz);
  uv = F / R,suv = (uv * 2 - 1) * A;
  U = ivec2(F);
  int id = int(F.x + F.y * R.x);
  vec3 c = vec3(0);
  float z=mix(.1,1.,tr),sz;
  vec3 ro,dir;
  ro=(hash(vec3(bt,1,2))*2-1)*2;
  //ro=erot(ro,norm(hash(vec3(bt,3,2))*2-1),exp(-atr*8)*.5);
  if(bt%2==0)
  {
    ro=norm(ro);ro.xy=norm(ro.xy)*.3;ro.z=sign(ro.z);ro=norm(ro);
    //ro=erot(ro,vec3(0,1,0),time);
  }
  dir=-ro;
  if(bt%2==0)
  {
    ro+=cyc(vec3(1,2,time),1.5,vec3(1));
  }
  else
  {
    ro+=cyc(vec3(1,2,time*.3),1.2,vec3(1));
  }
  mat3 m=bnt(dir);
  float rt=bt%2==0?lt*2.4:-lt*2.4;
  m[0]=erot(m[0],m[2],rt);
  m[1]=erot(m[1],m[2],rt);
  
  if(U.x<300)
  {
    vec3 p=(hash(vec3(bt,1,id))*2-1)*3*tr;
    int n=32;
    rep(i,n)
    {
      float f=i/float(n);
      p-=cos(p*pi)*p*mix(.2,.9,tr);
      c=(1+cos(vec3(0,1,2)+f*tau))/n*2;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(0,sz));
    }
  }
  else if(U.x<400&&bt%2==0)
  {
    vec3 p=(hash(vec3(bt,1,id))*2-1)*5*tr;
    int n=32;
    vec3 sd=norm(hash(vec3(bt,7,8))*2-1);
    rep(i,n)
    {
      float f=i/float(n);
      p-=cyc(p,1.5*tr,sd);
      c=(1+cos(vec3(1,2,3)+f*tau))/n*.2;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(0,sz));
    }
  }
  else if(U.x<700&&bt%2==0)
  {
    vec3 p=(hash(vec3(bt,1,id))*2-1)*4*tr;
    int n=32;
    vec3 sd=norm(hash(vec3(bt,7,8))*2-1);
    rep(i,n)
    {
      float f=i/float(n);
      p-=normal(sdf,p)*sdf(p)*.5;
      c=(1+cos(vec3(1,2,3)+f*tau))/n*2;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(0,sz));
    }
  }
  else if(U.x<900&&bt%2==0)
  {
    vec3 p=(hash(vec3(bt,1,id))*2-1)*8*tr;
    int n=32;
    vec3 sd=norm(hash(vec3(bt,7,8))*2-1);
    rep(i,n)
    {
      float f=i/float(n);
      p-=normal(sdf2,p)*sdf2(p)*.2;
      c=(1+cos(vec3(1,2,3)+f*tau+alt*tau*8))/n*2;
      ivec2 u=proj(p,ro,m,z,sz);
      add(u,c*step(0,sz));
    }
  }
  c=read(U);
  
  // hud
  //vec3 od = (vec3(0) - ro) * m;
  ivec2 o=proj(m*vec3(-suv,0),ro,m,z,sz);
  vec2 v=vec2(o)/R,sv=(v*2-1)*A;
  if(bt%2==1)c=mix(1-c,vec3(0,0,1),selif(sv)*step(fract(time*8),.5));
  if(bt%2==0)
  {
    c=mix(c,1-c,step(fract(atr*16),.5)*step(atr,.25));
  }
  if(bt%4==3)
  {
    vec2 auv=abs(suv);
    if(.95<max(auv.x,auv.y))c=c.rrr;
    else c=abs(1-texture(texPreviousFrame,fract((uv-.5)*1.05+.5)).rgb);
  }
  
  out_color = vec4(c,1);
}