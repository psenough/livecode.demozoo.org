#version 410 core

uniform float fGlobalTime; // in seconds
#define time fGlobalTime
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
#define backbuffer texPreviousFrame
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
int bt;
float alt,lt,tr,atr;
#define sc(x) hash(vec3(x,1.4,bt))
#define rep(i,n) for(int i=0;i<n;i++)
#define sat(x) clamp(x,0,1)
#define norm(x) normalize(x)
vec3 hash(vec3 v)
{
  uvec3 x=floatBitsToUint(v);
  const uint k=0x91023718;
  x=((x>>8)^x.yzx)*k;x=((x>>8)^x.yzx)*k;x=((x>>8)^x.yzx)*k;
  return vec3(x)/-1u;
}
mat3 bnt(vec3 t)
{
  vec3 b,n=vec3(0,1,0);t=norm(t);b=norm(cross(n,t));n=norm(cross(t,b));return mat3(b,n,t);
}
vec3 erot(vec3 p,vec3 ax,float a){return mix(dot(ax,p)*ax,p,cos(a))+sin(a)*cross(ax,p);}
vec3 pl(vec3 ro,vec3 rd,vec3 pd,float w)
{
  float l=-(dot(ro,pd)-w)/dot(rd,pd);
  vec3 p=rd*l+ro;mat3 b=bnt(pd);
  vec2 uv=vec2(dot(b[0],p),dot(b[1],p));
  return vec3(uv,l<0?1e5:l);
}
vec3 cyc(vec3 x)
{
  float q=1.5;
  vec4 v=vec4(0);
  rep(i,5)
  {
    x+=sin(x.yzx);
    v=v*q+vec4(cross(cos(x),sin(x.zxy)),1);
    x*=q;
  }
  return v.xyz/v.w;
}

vec3 s0(vec2 suv)
{
  vec3 c=pow(sat(cyc(vec3(suv,alt))*.5+.5),vec3(2,1,.5));
  //suv+=vec2(0,alt*.1);
  rep(i,4)
  {
    vec3 h=hash(vec3(floor(suv),i+bt/4));
    if(h.x<.5)break;
    suv*=2;
  }
  vec3 h=hash(vec3(floor(suv),5));
  vec2 fuv=fract(suv);
  c+=step(abs(length(fuv-.5)-.3),length(fwidth(fuv))*2);
  if(h.y<.5)c*=0;
  else c*=step(length(fuv-.5),.3);
  return c;
}
float n0(vec2 uv)
{
  return step(fract(uv.y+alt),.1);
}
vec3 s1(vec2 suv)
{
  int v=bt%2;
  vec3 rp,rd,ro,dir;
  float z=1,l=1e5;
  ro=erot(vec3(3),norm(tan(sc(1)-.5)),alt);
  dir=-ro;
  rd=bnt(dir)*norm(vec3(suv,z));
  vec3 res;
  int n=int(sc(1.7).x*4)*2+1;
  rep(i,n)
  {
    float f=float(i+.5)/8.;
    vec3 uvl;
    if(v==0)uvl=pl(ro,rd,norm(tan(hash(vec3(1,i,bt))-.5)),1);
    else if(v==1)
    {
      uvl=pl(ro,rd,norm(dir),i);
      uvl=erot(uvl,vec3(0,0,1),(f*sc(1.2).x*2.4*alt));
    }
    float s=n0(uvl.xy);
    if(0<s)l=min(l,uvl.z);
  }
  vec3 c;
  c=vec3(exp(-l*.1)*1.5);
  //c=mix(s0(suv),mix(vec3(1,.5,.5),vec3(.5,.5,1),suv.y),exp(-l*.1));
  return c;
}

void main(void)
{
  float bpm=145;
  alt=lt=time*bpm/60.;atr=tr=fract(alt);bt=int(alt);tr=tanh(4*tr);lt=bt+tr;
	vec2 fc=gl_FragCoord.xy,res=v2Resolution,asp=res/min(res.x,res.y),uv=fc/res,suv=(uv*2-1)*asp;
  if(sc(-1).x<.1)suv=abs(suv);
  vec3 back=texture(backbuffer,uv).rgb;
  vec3 c=vec3(0);
  c=s1(suv);
  if(sc(2.1).x<.2){
    c=step(fract(cyc(vec3(suv,alt)).x*5),.5)*vec3(1,0,0);
  }
  if(sc(-6.1).x<.2){out_color=vec4(mix(c,abs(1-c),step(fract(time*10),.5)),1);return;}
  
  if(bt%2==0){
    vec3 aa=vec3(0);
    c=mix(c,aa,sat(step(length(suv),.5)+step(.5,abs(suv.y))));
  }
  if(bt%4==0)c=abs(back-c);
  c=vec3(c.r,back.rg);
  float ema=.0;
  c=mix(c,back,ema);
 
	out_color=vec4(c,1);
}