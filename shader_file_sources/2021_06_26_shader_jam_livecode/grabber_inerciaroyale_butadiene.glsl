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

#define time fGlobalTime 
float bpm = 175.;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float PI = acos(-1.);

mat2 rot(float r){
  return mat2(cos(r),sin(r),-sin(r),cos(r));
  }

vec2 pmod(vec2 p,float n){
  float np = PI*2.0/n;
  float r = atan(p.x,p.y)-0.5*np;
  r = mod(r,np)-0.5*np;
  return length(p)*vec2(cos(r),sin(r));
  }

float box(vec3 p,vec3 s){
  vec3 q = abs(p);
  vec3 m = max(s-q,0.);
  return length(max(q-s,0.))-min(min(m.x,m.y),m.z);
  }
 
float kaku(vec3 p,float s){
  p.y = abs(p.y);
  p.y -= 0.07*s;
  p.yz *= rot(PI*0.25);
  return box(p,s*vec3(0.05,0.08,0.2));
  }
 
float kakuring(vec3 p,float r,float k){
  p.xz *= rot(k);
  float sc = 1.0;
  
  p.xz = pmod(p.xz,28.);
  p.x -= r;
  return kaku(p,r*0.5);
  }
 float rand(vec2 st){
   return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43578.543123);
   }
 float ease(float t,float k){
   return 0.5+0.5*cos(PI*exp(-k*t));
   }
   vec3 noi1 = vec3(0);
   float texint = 0.0;
  void noi_ipt(){
    float es = 0.0;
    float kt =floor(time/12.+es);
    float s1 = rand(vec2(kt,0.));
    float s2 = rand(vec2(kt,.5));
    float s3 = rand(vec2(kt,.7));
    noi1 = vec3(s1,s2,s3);
    }
  
 vec4 circring(vec3 p,float ss){
   vec3 sp = p;
   vec3 ecp = vec3(0.5,0.2,0.8);
   vec3 idlist = vec3(0.,2.,4.);
   if(ss<1.2){
     ecp = vec3(0.2,0.8,0.2);
     idlist = vec3(1.,3.,5.);
     }
   float id =  idlist.x;
    vec3 scol = vec3(0.7);
     if(length(p)<1.2){
       scol += vec3(ecp.x,ecp.y,ecp.z);
       }else if(length(p)<2.2){
         scol += vec3(ecp.z,ecp.x,ecp.y);
         id = idlist.y;
         }else{
           scol += vec3(ecp.y,ecp.z,ecp.x);
           id = idlist.z;
           }
     
     const int iterate =2;
     float kp = 1.;
     
     float scale = 1.0;
     for(int i = 0;i<iterate;i++){
       
       kp *= 0.4;
       p.y = abs(p.y)-0.1*kp;
       float sc = 2./clamp(dot(p,p),2.,8.);
       p *= sc;
       scale *= sc;
       
       p = p-kp*noi1*vec3(0.7,2.,0.7)*1.5;
       p.zy *= rot(0.2);
       }
     float dectime = 2.0;
     float ssc = clamp(0.1*mod(time,12.)-id/24.,0.,1.);
       ssc = -ease(ssc,4.);
       
      float d = kakuring(p,1.,4.*ssc*PI-0.3*(6.0-id)*0.2*time)/scale;
       vec3 col =scol;
       return vec4(col*exp(-8.0*d)*(.15+0.5*(clamp(1.2/length(sp),0.3,1.0)-0.3)-sin(ssc*PI)),d);
       
   } 
vec4 dist(vec3 p){
float s = 1.;
  vec4 rsd = circring(p,1.);
  p.xy *= rot(0.5*PI);
  vec4 rsd2  = circring(p,2.);
  rsd.w = min(rsd.w,rsd2.w);
  vec3 col = vec3(1.)*(rsd.xyz+rsd2.xyz);
  return vec4(col,rsd.w); 
  }


void main(void)
{
  noi_ipt();
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);

  vec2 p = 2.*(uv-0.5);

  p.y *= v2Resolution.y/v2Resolution.x;
    p *= rot(2.0*PI*texture(texNoise,vec2(floor(time/12.),0.4)).r);
  float rsc = 1.2;
  float kt = time*0.2;
  vec3 ro = vec3(rsc*cos(kt),0.7,rsc*sin(kt));
  vec3 ta = vec3(0);
  vec3 cdir = normalize(ta-ro);
  vec3 side = cross(cdir,vec3(0,1,0));
  vec3 up = cross(side,cdir);
  vec3 rd = normalize(p.x*side+p.y*up+0.2*cdir);
  
  float d,t = 0.2;
  
  vec3 ac = vec3(0.);
  float esp = 0.0001;
  for(int i = 0;i<86;i++){
    vec4 rsd = dist(ro+rd*t);
    d = rsd.w;
    t += 0.5*d;
    ac += rsd.xyz;
    
    if(d<esp)break;
   }
  vec3 col = ac*0.03;
  
	float f = texture( texFFT, d ).r * 100;

   col = pow(clamp(col,vec3(0),vec3(1)),vec3(1.4));
 
  vec3 bcol = texture(texPreviousFrame,uv).xyz;
   col = mix(col,bcol,0.5);
   
   out_color = vec4(col,0.);
}

















