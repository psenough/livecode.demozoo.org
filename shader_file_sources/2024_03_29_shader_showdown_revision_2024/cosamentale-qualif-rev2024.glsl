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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2 rot(float t){ float c = cos(t); float s= sin(t); return mat2(c,-s,s,c);}
float t = fGlobalTime+texture(texFFTIntegrated,0.2).x*1.;float e; float zl;
float rd(){return fract(sin(e +=45.)*7845.236);}
vec3 vr(){float a = rd()*6.28; 
  return vec3(cos(a), sin(a),(rd()-0.5)*2.)*sqrt(rd());}
float b(vec3 p){vec3 q = abs(p)-10.;
  return length(max(q,0.))+min(0.,max(q.x,max(q.y,q.z)));}
  vec3 co ;
  float map(vec3 p){
    p.xy *= rot(p.z*0.1*sin(t));
    vec3 pb = p;
    float fr = step(0.5,fract(p.x/12.))+step(0.5,fract(p.z/12.));
    pb= mod(pb,vec3(6.,0.,6.))-vec3(3.,0.,3.);
    pb.y += -5.*abs(sin(t*2.+fr));
   float t1 = smoothstep(-0.5,0.5,sin(t));
    float d1 = max(length(pb)-mix(3.,2.,t1),length(mod(p,vec3(2.))-1.)-mix(0.5,2.,t1));
    float d2 = max(-100.,-b(p-vec3(0.,8.,0.)));
    float d3 = mix(mix(-p.y+12.,p.x+9.9,step(0.5,fract(t*4.))),length(p.xz)-2.*step(0.5,fract(t*4.)),step(0.5,fract(t)));
    zl = d3;
    float l1 = step(0.5,fract(atan(pb.x,pb.z)/3.14*4.));
    float l2 = mix(l1,1.-l1,step(0.5,fract(pb.y*1.)));
    co  = mix(vec3(0.8,0.9,1.)*max(vec3(0.,0.1,0.3),step(0.05,fract(p.x+0.5))*step(0.05,fract(p.y+0.5))*step(0.05,fract(p.z+0.5))),
    mix(mix(vec3(1.,0.,0.),vec3(1.),l2),vec3(1.), step(0.01,d1)),step(0.01,d2));
    return min(d1,min(d2,d3));}
  float rm(vec3 p, vec3 r){ float dd= 0.;
    for(int  i = 0 ; i < 64 ; i++) {
      float d = map(p);
      if(d<0.01){break;}
      p += r*d;
      dd +=d;}return dd;}
vec3 nor(vec3 p){vec2 e = vec2(0.01,0.); 
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc  = uv;
	uv -= 0.5;uv *= 2.;
  uv = mix(uv,abs(uv),step(0.75,fract(t*0.25)));
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 p  = vec3(0.,0.,-7.); vec3 r = normalize(vec3(uv,1.+sin(t)*0.5));
  p.xz *=  rot(t);r.xz *= rot(t);
  float r1 = 0.;float de = 0.;
  e = uv.x*v2Resolution.y+uv.y;
  e +=t;
  float at = 2.;vec3 lum;
	for(int  i = 0 ; i < 4 ; i++){
    float d = rm(p,r);
    if(i == 0){lum = co;}
    if(zl>0.01){p +=r*d;
      vec3 n = nor(p);
      r  = n+vr();
      p +=r*0.2;
      at *= 0.5;
      }
    else{r1 = at;}}
    float r2 = mix(r1,texture(texPreviousFrame,uc).a,0.6);
	out_color = vec4(pow(vec3(r2*mix(lum,1.-lum,step(0.9,fract(t*4.)))),vec3(0.25)),r2);
}