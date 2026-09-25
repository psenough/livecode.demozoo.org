#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT;
uniform sampler1D texFFTSmoothed;
uniform sampler1D texFFTIntegrated;
uniform sampler2D texPreviousFrame;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color;

#define pi acos(-1)
#define pi2 (acos(-1)*2)
#define R v2Resolution

float T = fGlobalTime/60 * 120;

#define FT(i) (texelFetch(texFFTIntegrated,i,0).x*0.1)
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))  
#define saturate(x) clamp(x,0.0,1.0)
float lin2log9(float x){return exp2((saturate(x)-1.0)*9);}
float lin2log10(float x){return exp2((saturate(x)-1.0)*10);}

vec4 ff(vec3 p){
float d=99999;
  
  //d=min(d,length(p)-.1);
  //d=min(d,length(p-1)-.6);
  float mb=0.0;
  vec4 tx=vec4(0);
  for(int i=0;i<8;i++){
    vec3 sd=sqrt(vec3(7,5,3))*sqrt(2+float(i)*1.3);
    vec3 v=1.4*sin(sd*(T*.01401+FT(15+i*2)*2.242)*.3);
    v*=vec3(1,1.2,1);
    v.y=abs(v.y)-.52;
  float nd=length(p-v)-.03-.0251*exp(-4*fract(sd.y*28));
    float w=1./pow(abs(nd),2.0);
    w*=exp(-1*fract(sd.z*128));
    mb+=w;
    tx+=vec4(fract(sd*4.),1)*w*w*w;
    }
    float nd=p.y+1.3+mb*.01+sin(4./mb-T*2)*25.22*exp2(-3.2*length(p));
    //nd=length(p+vec3(0,18,0))-21;
    float w=1./pow(abs(nd),3.0);
    tx+=.01*vec4(.9151,.2,.3,1)*w;
   mb+=w;
  d=min(d,1./pow(abs(mb),0.5)-.431);
  tx.xyz/=tx.w;
  return vec4(d,tx.xyz);
}
float f(vec3 p){
  return ff(p).x;
}
vec3 trace(vec3 ro,vec3 rd){
  vec3 p=ro+rd*0;
  
  for(int i=0;i<100;i++){
    float d=f(p);
  if(abs(d)<.01)break;
    p+=rd*d;
    
    }
    p+=rd*f(p);
  return p;
}
vec3 nor(vec3 p,float eps){
vec2 e=vec2(eps,0);
vec3 n=-vec3(
  f(p-e.xyy)-f(p+e.xyy),
  f(p-e.yxy)-f(p+e.yxy),
  f(p-e.yyx)-f(p+e.yyx));
n=length(n)>0.0?normalize(n):vec3(1,0,0);
  return n;
  
}
vec3 ftex(vec3 p,vec3 ro){
vec3 tx=ff(p).yzw;
  float xf=tx.x;
  xf=abs(fract(tx.x+T*.01)*2-1);
  xf=tx.z*.995;
  //xf=floor(tx.y*38)/38+tx.x*.07;
    float fx=lin2log9(xf*0.98);
  
  vec3 c=vec3(1);
    c=1*pow(texture(texFFTSmoothed,fx).xxx*8*pow(fx*20,.76),exp2(1+.15*vec3(2,1,0)))*2.3;
  c+=1.715*pow(texture(texFFT,fx).xxx*8*pow(fx*20,.6),exp2(1+.15*vec3(2,1,0)))*2.3;
  c*=exp2(-length(p-ro)*.01);
  return c;
 }
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvp=(uv-0.5)*R/R.y;  
  ivec2 ip = ivec2(gl_FragCoord.xy);

  vec3 c=vec3(uv.xy,0);
  float fx=exp2((uv.y-1)*10);
  fx=lin2log9(length(uvp)*0.98);
  
  //c=pow(texture(texFFTSmoothed,fx).xxx*8*pow(fx*20,.6),exp2(1+.5*vec3(2,1,0)))*2.3;
  //c+=.15*pow(texture(texFFT,fx).xxx*8*pow(fx*20,.6),exp2(1+.5*vec3(2,1,0)))*2.3;
  c*=.01;
  vec3 ro=vec3(0,0,-9);
  vec3 rd=normalize(vec3(uvp,1.3*exp2(.6*(1+sin(T*.3+FT(15)*.1)))));
  
   float az=2.6413*sin(T*0.012*pi2+FT(3)*.1027)+fract(T*.018)*pi2;
  float el=.531+0.37*cos(T*0.03515*pi2);
  ro.yz*=rot(el);
  rd.yz*=rot(el);
  
  ro.xz*=rot(az);
  rd.xz*=rot(az);
  
  rd.yz*=rot(.0042*sin(T*.131));
  rd.xz*=rot(.0052*sin(T*.231));
  //rd.yz*=rot(.001*sin(T*.05+FT(6)*13));
  //rd.xz*=rot(.001*sin(T*.06+FT(5)*13));
  
  
  
  vec3 p=trace(ro,rd);
  vec3 n=nor(p,.010);
  if(length(p-ro)<1200||true){
    float g=abs(dot(rd,n));
    
    c=ftex(p,ro)*.2;
    vec3 p0=p;
    vec3 rd0=rd;
    vec3 ro0=ro;
    rd=reflect(rd,n);
    ro=p+n*.06;
    p=trace(ro,rd);
    c+=ftex(p,ro)*.5*exp2(-g*g*4);
    
    
    
  }
  c*=exp2(-length(uvp)*.5);
  c=c*1.05/(1+c);
  vec2 clp=(1-uv)*R/64-0.5-vec2(4,0);

  if(false){
  if(length(clp)<.5)c=vec3(1)*float((atan(clp.x,clp.y)/pi2+.5<fract(T/2))^^(int(floor(T/2))%2==0));
  vec2 fqp=(1-uv)*R/vec2(256,64);
  float fx=exp2((-fqp.x)*8);
  if(abs(fqp.y-0.5)<0.5&&abs(fqp.x-0.5)<0.5)c=vec3(1)*float(log2(texture(texFFT,fx).x*8*pow(fx*20,.6)*30)*0.06+0.5>1.0-fqp.y);
  }
  out_color = vec4(c,1);
}

