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
#define R v2Resolution
#define T fGlobalTime

mat2 rot(float a){return mat2(cos(a),sin(a),-sin(a),cos(a));}
float hash21(vec2 a){return fract(sin(dot(a,vec2(22.5,35.35)))*48823.);}
float smp(float a){return texture(texFFTSmoothed, a).x;}
float smx(float a){return texture(texFFT, a).x;}
float tor(vec3 p, float t, float r){
  vec2 q = vec2(length(p.xy)-r,p.z);
  return length(q)-t;
}
float box(vec3 p, vec3 a){
  vec3 q = abs(p)-a;
  return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}
vec3 dom(inout vec3 p, float s){
  float h = s/2.;
  vec3 id = floor((p+h)/s);
  p=mod(p+h,s)-h;
  return id;
}
float glow = 0.;
vec3 gid,sid;

vec2 map(vec3 p, float a){
  vec2 res=vec2(1e5,0.);

  p.y+=T*.5;
  p.y=mod(p.y+2.,4.)-2.;

  vec3 o=p,q=p,w=p,i=p;
  float k = 11./dot(o,o);
  o*=k;
  float tt = .75+.5*cos(T*.15);

  p=mix(p,o,tt);
  
  p.z-=T;
  w.z-=T;
  vec3 id = dom(p,2.);
  vec3 xd = dom(w,1.);
  gid=id;
  float hs = hash21(id.xy+id.z);
  
  float pp = smx(mod(id.z*.1,1.))*8.;
  float pp2 =smp(mod(id.z*.2,1.))*4.;
  
  bool check = id.x==0.&&id.y==0.;
  float pt=.75+.25*cos(T*.234);

  float d = tor(p,.05+pp,.67);
  if(d<res.x) res=vec2(d,1.);
 
  float dd = min(length(abs(w.xy)-.5)-.05,length(abs(w.zy)-.5)-.05);
  dd = min(length(abs(w.xz)-.5)-.05,dd);
  
  dd=mix(1.,dd,pt);
  
  if(dd<res.x) res=vec2(dd,1.);

  float l = length(p)-pp2;
  if(l<res.x&&!check&&hs>.6) res=vec2(l,2.);
  if(a==1.&&!check&&hs>.6) glow+=.002/(.015+l*l);
  float sp=length(i-vec3(0,0,pt))-(.5+tt);
   if(sp<res.x) res=vec2(sp,1.);

  float mul = 1./k;
  res.x=mix(res.x,res.x*(mul/1.),tt);
  
  return res;
}
vec3 normal(vec3 p, float t){
  vec2 e=vec2(t*1e-4,0.);
  float d = map(p,0.).x;
  vec3 n=d-vec3(
    map(p-e.xyy,0.).x,
    map(p-e.yxy,0.).x,
    map(p-e.yyx,0.).x
  );
  return normalize(n);
}
vec3 hue(float a){ return .4+.4*sin( 3.4*a*vec3(.45,1.,.25)*vec3(1,.98,.95) );}
void main(void)
{
	vec2 uv = (2*gl_FragCoord.xy-R.xy)/max(R.x,R.y);
  vec2 vuv=uv;
  vec2 di = floor(vuv*3.);
  vuv = fract(vuv*3.)-.5;

 //uv=floor(uv*95.)/1.;
  uv*=rot(6.41*sin(T*.25));

	vec3 C = vec3(0),ro=vec3(0,0,5),rd=normalize(vec3(uv,-1.));
  
  float tt = floor(T*.4);
  float hs=hash21(vec2(tt,25.));
  float xt= 1.015*sin(uv.x*45.+T*22.);float yt= .015*sin(uv.y*45.+T*22);
  
  if(uv.x>yt&&hs>.65){
    ro.xz*=rot(30.+T*.2);
    rd.xz*=rot(30.+T*.2);
  }
  hs=hash21(vec2(15,tt));
  
  if(uv.y>xt&&hs>.46){
    ro.yz*=rot(50.+T*.1);
    rd.yz*=rot(50.+T*.1);
  }
  
  vec3 p=ro;
  float d=0.,m=0.;
  for(int i=0;i<164;i++){
    p=ro+d*rd;
    vec2 ray = map(p,1.);
    m=ray.y;
    ray.x=max(abs(ray.x),1e-3);
    d+=abs(ray.x*.3);
  }
  sid=gid;
    vec3 cr = hue(hash21(sid.xy+sid.z)*3.1);
  if(d<25.){
    vec3 n=normal(p,d);
    vec3 l=normalize(vec3(5,5,-5));
    float diff = clamp(dot(n,l),0.,1.);
    
    float sp = length(dot(n,p))-.5;
    
    C+=diff*hue((n.x+n.y+n.z)*.5+T*.5);
    //C=mix(C,cr,sp);
  }

  
  C=mix(C,hue((T*.25)+(uv.x+uv.y)*.2),1.-exp(-.009*d*d*d));
  C=mix(C,vec3(glow),clamp(glow,0.,1.));

  
	out_color = vec4(C,1.);
}