#version 410 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define hash(x) fract(sin(x)*1763.2632)
#define saturate(x) clamp(x,0,1)
const float pi=acos(-1);
const float pi2=acos(-1)*2;
const float N=50;

mat2 rot(float a){
  float s=sin(a),c=cos(a);
  return mat2(c,s,-s,c);
}

float rt=1e5;
vec3 rn;
float rid;
vec2 ruv;
void intersect(vec3 ro,vec3 rd,vec3 ce,mat2 M,float id,float s){
  M[0][1]*=s;
  M[1][0]*=s;
  vec3 n=vec3(vec2(0,1)*M,0);
  float t=dot(ce-ro,n)/dot(rd,n);
  if(t<0||t>rt)return;
  vec3 q=ro+t*rd-ce;
  q.yx*=M;
  if(q.x*s<0)return;
  vec2 p=q.xz;
  
  p.x=abs(p.x)*.8;
  if(p.x>sin(p.y*50)*.025+.4+p.y*.4)return;
  if(p.y<0)p*=1.5;
  p.y=abs(p.y);
  if(length(p)>sin(atan(p.y,p.x)*2)+smoothstep(.1,0.,p.y)*.3)return;
  if(dot(rd,n)>0)n*=-1;
  
  
  rt=t;
  rn=n;
  rid=id;
  ruv=q.xz;
}

vec3 hsv(float h,float s,float v){
  vec3 res=fract(h+vec3(0,2,1)/3)*6-3;
  res=saturate(abs(res)-1);
  res=(res-1)*s+1;
  res*=v;
  return res;
}

float n3d(vec3 p){
  vec3 i=floor(p);
  vec3 f=fract(p);
  vec3 b=vec3(13,193,9);
  vec4 h=vec4(0,b.yz,b.y+b.z)+dot(i,b);
  f=f*f*(3-2*f);
  h=mix(hash(h),hash(h+b.x),f.x);
  h.xy=mix(h.xz,h.yw,f.y);
  return mix(h.x,h.y,f.z);
}

float fbm(vec3 p){
  float ac=0,a=1;
  for(int i=0;i<5;i++){
    ac+=n3d(p*a)/a;
    a*=2;
  }
  return ac-.5;
}
  
float density(vec3 p){
  return saturate(fbm(p*.5)-p.y*.03-.7);
}

#define odd(x) step(1,mod(x,2))
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1)*.5;
  vec3 col=vec3(0);
  
  float cam=odd(time*.2);
  float L=4+odd(time*.4-1)*4;
  vec3 ro=vec3(0,0,time);
  ro.xy=mix(vec2(0,L),vec2(L*.5,0),cam);
  vec3 rd=normalize(vec3(uv,-2));
  rd=mix(vec3(-rd.x,rd.z,rd.y),vec3(rd.z,rd.y,-rd.x),cam);
  //rd=vec3(-rd.x,rd.z,rd.y);
  
  for(float i=0;i<N;i++){
    float T=i/N+time*.1;
    float id=i/N+floor(T);
    vec3 ce=vec3(0,0,ro.z+fract(T)*14-7);
    mat2 M=rot(sin(T*50+hash(id)*pi2));
    ce.xy+=hash(vec2(1.1,1.2)*id)*6-3;
    ce.xy+=sin(vec2(5,7)*time*.2+hash(id*1.3)*pi2);
    
    intersect(ro,rd,ce,M,id,1);
    intersect(ro,rd,ce,M,id,-1);
  }
  
  /*vec2 p=uv;
  
  p.x=abs(p.x)*.8;
  if(p.x>sin(p.y*50)*.025+.4+p.y*.4)return;
  if(p.y<0)p*=1.5;
  p.y=abs(p.y);
  if(length(p)>sin(atan(p.y,p.x)*2)+smoothstep(.1,0.,p.y)*.3)return;*/
  
  vec3 ld=normalize(vec3(-5,2,-2));
  
  if(rt<100){
    float h=hash(rid);
    ruv.x=abs(ruv.x);
    float w=fbm(vec3(ruv,hash(rid*1.2)*500));
    h+=fbm(vec3(ruv+w*5,hash(rid*1.1)*500))*.3;
    col+=hsv(h,.8,fract(h*5+hash(rid*1.3)));
    col*=smoothstep(-1.,-.93,sin(atan(ruv.y,ruv.x)*40));
    rn.x+=fbm(vec3(ruv*10,hash(rid*1.3)*500));
    float diff=max(dot(ld,rn),0);
    float spec=pow(max(dot(reflect(ld,rn),rd),0),20);
    float m=.6;
    float lp=5;
    
    col*=diff*(1-m)*lp+spec*m*lp+.3;
  }else{
    col+=vec3(.5,.6,.9)*.1;
    col=mix(col,vec3(1),pow(max(dot(ld,rd),0),100)*2);
  }
  
  vec3 rp=ro;
  float tra=1,rs=1,t=0,den,ac=0;
  for(int i=0;i<20;i++){
    if(t>rt)break;
    den=density(rp+t*rd);
    ac+=tra*den;
    tra*=1-den;
    if(tra<.001)break;
    t+=rs;
  }
  col+=ac;
  
  col=pow(col,vec3(1/2.2));
  
	out_color = vec4(col,1);
}