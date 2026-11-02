#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define R v2Resolution
#define T fGlobalTime
#define PI 3.1415
#define PI2 6.2831

#define MIN_DIST 1e-3
#define MAX_DIST 40.

#define eoc(t) (t=t-1)*t*t+1
#define eic(t) t*t*t

 mat2 nx,ny,nz,nw;
mat2 rot(float a){return mat2(cos(a),sin(a),-sin(a),cos(a));}
float hash21(vec2 p){return fract(sin(dot(p,vec2(23.371,45.332)))*473.323);}

float bx(vec3 p, vec3 b){
  vec3 d=abs(p)-b;
  return length(max(d,0.))+min(max(d.x,max(d.y,d.z)),.0);
}
float tspeed=0., tmod=0., t1=0., t3=0., t4=0.;
vec3 hp,hit;
vec2 gid,sid;
const float scale = .75;
const float hscale_h = scale/2.;
const vec2 s = vec2(scale*2.2);

const vec2 pos = vec2(.5,-.5);
const vec2[4] ps4 = vec2[4](pos.yx,pos.xx,pos.xy,pos.yy);
float lrp (float b, float e, float t) { return clamp((t - b) / (e - b), 0., 1.); }
vec2 map(vec3 q3){
  q3.z-=T*.5;
  vec2 res = vec2(1e5,0.), p, ip, ct = vec2(0);
    float t=1e5, y=1e5, m=1.;
    for(int i =0; i<4; i++){
    
        ct = ps4[i]/2. -  ps4[0]/2.;
        p = q3.xz - ct*s;
        ip = floor(p/s) + .5;
        p -= (ip)*s;
        vec2 idi = (ip + ct)*s;
        idi=abs(idi+30.);
        vec3 q = vec3(p.x,q3.y,p.y);
    float tr=texture(texFFT,mod((idi.x*.1)*(idi.y*.02),1.)).r*3.;
      
      float rnd=hash21(idi);
      float ths =(rnd*1.37)+fract(rnd*4323.23);
      
      ths+=rnd;
      float t1 = lrp(ths,ths+.5,tmod);
      t1=eoc(t1);t1=eic(t1);
      float t2 = lrp(ths+5.,ths+5.5,tmod);
      t2=eoc(t2);t2=eic(t2);
      float t3 = lrp(ths+10.,ths+10.5,tmod);
      t3=eoc(t3);t3=eic(t3);
      float t4 = lrp(ths+15.,ths+15.5,tmod);
      t4=eoc(t4);t4=eic(t4);
      
      vec3 nq = q-vec3(0,((t2-t3)+(t1-t4))*scale,0);
      float rf = 1.5707;
      nx=rot(rf*(t1-t2));
      ny=rot(rf*(t3+t4));
      
      nq.xz*=nx;
      nq.xz*=ny;
     
         nz = rot(rf*(t1-t4));
    nw = rot(rf*(t2-t3));
    nq.zy *= nz;
    nq.xz *= nw;
    
    float b = bx(nq,vec3(scale*.8));
    
    if(b<t){
      t=b;
      sid=idi;
      hp=q;
    }
  }
  
  if(t<res.x){
    res=vec2(t,1.);
    hp=q3;
  }
  return res;
}

vec3 normal(vec3 p,float t){
float e = MIN_DIST*t;
    vec2 h =vec2(1,-1)*.5773;
    vec3 n = h.xyy * map(p+h.xyy*e).x+
             h.yyx * map(p+h.yyx*e).x+
             h.yxy * map(p+h.yxy*e).x+
             h.xxx * map(p+h.xxx*e).x;
    return normalize(n);
  
  }
vec3 hsv(vec3 c) {
    vec3 rgb = clamp(abs(mod((c.x+T*.03)*6.+vec3(0,4,2),6.)-3.)-1.,0.,1.);
    return c.z * mix(vec3(1),rgb,c.y);
}

void main(void)
{
  
  tspeed=T*.8;
  tmod=mod(tspeed,20.);
  
  vec2 F = gl_FragCoord.xy;
  vec3 C = vec3(0);
  
  float zm = 5.;
	vec2 uv = vec2(2.*F-R.xy)/max(R.x,R.y);
  vec3 ro=vec3(uv*zm,-(zm+5.));
  vec3 rd=vec3(0,0,1);
  
  mat2 rx=rot(.58);
  mat2 ry=rot(-.82);

   ro.zy*=rx;rd.zy*=rx;
    ro.xz*=ry;rd.xz*=ry;
  
  float d=0.,m=0.;
  vec3 p = ro;
  
  for(int i=0;i<132;i++){
    p=ro+rd*d;
    vec2 ray=map(p);
    if(ray.x<MIN_DIST*d||d>MAX_DIST)break;
    d += i<32 ? ray.x*.25:ray.x;
    m=ray.y;
  }
  hit=hp;
  gid=sid;
  if(d<MAX_DIST){
    vec3 n = normal(p,d);
    vec3 lpos = vec3(1,8,1);
    vec3 l = normalize(lpos-p);
    float dif = clamp(dot(n,l),.0,1.);
    float hs=hash21(gid);
    vec3 h=hsv(vec3(hs,1.,.5));
    C = h*vec3(dif*2.);
    
  }
  
   C = mix(vec3(.2),C, exp(-.0001*d*d*d));
	C=pow(C,vec3(.4545));
	out_color = vec4(C,1.);
}