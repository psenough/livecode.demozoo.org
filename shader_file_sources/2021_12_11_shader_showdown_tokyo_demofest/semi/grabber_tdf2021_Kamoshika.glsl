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
#define saturate(x) clamp(x,0,1)
#define rotpi4(v) v=vec2(v.x+v.y,-v.x+v.y)/sqrt(2)
const float pi=acos(-1);

mat2 rot(float a){
  float s=sin(a),c=cos(a);
  return mat2(c,s,-s,c);
}

#define odd(x) step(1,mod(x,2))
float sqWave(float x){
  float i=floor(x);
  float s=.1;
  return mix(odd(i),odd(i+1),smoothstep(.5-s,.5+s,fract(x)));
}

float smin(float a,float b,float k){
  float h=max(k-abs(a-b),0);
  return min(a,b)-h*h*.25/k;
}

vec3 pos=sin(vec3(13,0,7)*time*.1);
float map(vec3 p){
  float d;
  //d=length(p)-.3;
  vec3 q=p;
  q.y=.7-abs(q.y);
  
  d=q.y;
  q.zx=fract(q.zx)-.5;
  
  vec2 dq=mix(vec2(-.2),vec2(.27,.1),sqWave(time*.15));
  float a=1;
  for(int i=0;i<5;i++){
    vec3 v=q;
    v.zx=abs(v.zx);
    if(v.z>v.x)v.zx=v.xz;
    d=min(d,max(v.x-.1,(v.x*2+v.y)/sqrt(5)-.3)/a);
    q.zx=abs(q.zx);
    rotpi4(q.xz);
    q.xy-=dq;
    rotpi4(q.yx);
    
    q*=2;
    a*=2;
  }
  
  q=p-pos;
  float t=length(q)-.3;
  q*=15;
  q.xy*=rot(time*1.3);
  q.yz*=rot(time*1.7);
  t=max(t,(abs(dot(sin(q),cos(q.yzx)))-.2)/15);
  
  d=smin(d,t,.3);
  
  return d;
}

vec3 calcN(vec3 p){
  vec2 e=vec2(.001,0);
  return normalize(vec3(map(p+e.xyy)-map(p-e.xyy),
  map(p+e.yxy)-map(p-e.yxy),
  map(p+e.yyx)-map(p-e.yyx)));
}

vec3 hsv(float h,float s,float v){
  vec3 res=fract(h+vec3(0,2,1)/3)*6-3;
  res=saturate(abs(res)-1);
  res=(res-1)*s+1;
  res*=v;
  return res;
}

vec3 march(inout vec3 rp,inout vec3 rd,inout vec3 ra,inout bool hit){
  vec3 col=vec3(0);
  float d,t=0;
  hit=false;
  for(int i=0;i<100;i++){
    d=map(rp+rd*t);
    if(abs(d)<.0001){
      hit=true;
      break;
    }
    t+=d;
  }
  rp+=t*rd;
  
  vec3 ld=normalize(-rp);
  
  vec3 n=calcN(rp);
  vec3 ref=reflect(rd,n);
 
  float diff=max(dot(ld,n),0);
  float spec=pow(max(dot(reflect(ld,n),rd),0),20);
  float fog=exp(-t*t*.2);
  
  d=length(rp-pos)-.3;
  float mat=smoothstep(.01,.1,d);
  float phase=length(rp)*4-time*2;
  vec3 al=hsv(floor(phase/pi)*pi*.4,.8,1);
  al=mix(vec3(.9),al,mat);
  float f0=mix(.01,.8,mat);
  float m=mix(.01,.9,mat);
  float fs=f0+(1-f0)*pow(1-dot(ref,n),5);
  float lp=3/abs(sin(phase));
  
  col+=al*diff*(1-m)*lp;
  col+=al*spec*m*lp;
  col=mix(vec3(0),col,fog);
  
  col*=ra;
  ra*=al*fs*fog;
  
  rp+=.01*n;
  rd=ref;
  
  return col;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1)*.5;
  vec3 col=vec3(0);
  
  vec3 ro=vec3(0,-.3,1.9);
  ro.zx*=rot(time*.1);
  
  vec3 rd=normalize(vec3(uv,-2));
  rd.zx*=rot(time*.1);
  
  vec3 ra=vec3(1);
  bool hit=false;
  
  col+=march(ro,rd,ra,hit);
  if(hit)col+=march(ro,rd,ra,hit);
  if(hit)col+=march(ro,rd,ra,hit);
  
  col=pow(col,vec3(1/2.2));
  
	out_color = vec4(col,1);
}