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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;
void add(ivec2 p,vec3 c){ivec3 a = ivec3(c*1000.);
  imageAtomicAdd(computeTex[0],p,a.x); imageAtomicAdd(computeTex[1],p,a.y); imageAtomicAdd(computeTex[2],p,a.z);}
vec3 load(ivec2 p){return 0.001*vec3(imageLoad(computeTexBack[0],p).x,imageLoad(computeTexBack[1],p).x,imageLoad(computeTexBack[2],p).x);}
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float t =  fGlobalTime*2.+texture(texFFTIntegrated,0.2).x*5.;
float rand(float t){return fract(sin(dot(floor(t),45.236))*7854.236);}
float no(float t){ return mix(rand(t),rand(t+1.),smoothstep(0.,1.,fract(t)));}
float rd(vec2 p){return fract(sin(dot(floor(p),vec2(45.65,98.26)))*7845.236);}
float hs(vec2 p){return fract(sin(dot((p),vec2(45.65,98.26)))*7845.236);}
mat2 rot(float t){float c = cos(t); float s=  sin(t); return mat2(c,-s,s,c);}
float sl(vec3 p, vec3 b){
  vec3 v = pow(abs(p-b*clamp(dot(p,b)/dot(b,b),0.,1.)),vec3 (10.));
return pow(v.x+v.y+v.z,0.1);}
float zl;float zf;
float map(vec3 p){vec3 pn = p;
  for(int  i = 0 ; i < 5 ; i++){
    p.xy *= rot(sin(t)*0.5+0.5);
    p.xz *= rot(cos(t)*.5+0.5);
    p -= 0.5;
    p = abs(p);
  }
  p.xz *= rot(p.y);
   vec3 pb = pn;
  pb.xy *= rot(t);
  pb = mix(pb,abs(pb),step(0.5,fract(t*0.25)));
  float d3 = mix(length(mix(pb,p,step(0.5,no(t*4.+98.)))-vec3(0.,6.,0.)),length(pb.zy)+1.,step(0.8,fract(t)))-mix(1.,4.,no(t+87.));
  vec3 rp = vec3(10.,0.,10.);
  p = mod(p+0.5*rp,rp)-0.5*rp;
  float d1 = sl(p,vec3(0.,4.,0.))-smoothstep(4.,0.,p.y);
  float d2 = max(pn.y+2.+smoothstep(1.,0.,d1)+texture(texNoise,p.xz*0.05).x*2.,-(d3-2.));
 zf = d1;
  zl = mix(d3,d1,step(0.8,rand(t)));
  return min(min(d1,d2),d3);}
  float rm(vec3 p,vec3 r){float dd = 0.;
    for(int  i = 0 ; i < 64 ;i ++){
      float d= map(p);
      if(d<0.01){break;}
      p += r*d;
      dd +=d;}return dd;}
      float de;float li = 0.;float mo;float de2;
      vec3 nor(vec3 p){vec2 e  =vec2 (0.01,0.); return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
      float e;float rd(){return fract(sin(e +=45.)*7845.236);}
      vec3 vr(){float a = rd()*6.28;return vec3(cos(a),sin(a),(rd()-0.5)*2.)*sqrt(rd());}
      vec3 rc(vec3 p, vec3 r){  vec3 r1 = vec3(0.); float at = 2.;vec3 lum = vec3(0.);
  for(int  i =0 ; i < 4 ; i++){
    float d = rm(p,r);
    if(d>200.){break;}
    if(i==0){de = smoothstep(200.,0.,d);li = step(zl,0.01);mo = step(zf,0.01);
      }
    if(zl>0.01){p += r*d;
      vec3 n = nor(p);
      r = n + vr();
      p +=r*0.2;
      at *= 0.5;
      lum = vec3(0.5,0.5,1.);}
    else{r1 = vec3(lum)*at;break;}
  }return r1;}
        vec3 ru(vec3 p, vec3 r){  vec3 r1 = vec3(0.); float at = 2.;vec3 lum = vec3(0.);float lo;
  for(int  i =0 ; i < 2 ; i++){
    float d = rm(p,r);
    if(d>200.){break;}
    if(i==0){lo = 1.-step(zl,0.01);}
    if(zl>0.01){p += r*d;
      vec3 n = nor(p);
      r = normalize(refract(n,r,1.)) + vr()*3.;
      p +=r*0.2;

      lum = vec3(0.5,0.5,1.);}
    else{r1 = vec3(1.,0.3,0.2)*2.;break;}
  }return r1;}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;uv *= 2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  e  =(uv.x*v2Resolution.y+uv.y)*step(0.1,fract(t));
  vec3 p = vec3(0.,0.,-7.);vec3 r = normalize(vec3 (uv+(vec2(hs(uv),hs(uv+78.))-0.5)*smoothstep(0.7,1.,no(t*4.))*length(uv.y),no(t)*1.5+0.5));
  e += t;
vec3 r1 = rc( p, r)+ru(p,r);
   float trr = 1.-step(0.2,rand(t*1.+6.));
  r1 = mix(vec3(1.),3.*abs(1.-2.*fract(r1.x*0.7+t*10.+vec3(0.,-1./3.,1./3.)))-1.,trr*0.5)*r1;
  vec3 r2 = mix(r1,load(ivec2(gl_FragCoord)),0.6);
  add(ivec2(gl_FragCoord),r2);
 
  vec3 r3 = mix(r2,1.-r2,trr);
  float ct = max(mo,texture(texPreviousFrame,uc+(vec2(rd(uv*10.),rd(uv*10.+95.)+(rd()-0.5)*2.)*0.01)).a*0.9);
  vec3 ctc = mix(vec3(1.),3.*abs(1.-2.*fract(ct*0.7+vec3(0.,-1./3.,1./3.)))-1.,0.3)*ct*smoothstep(0.6,0.7,no(t*2.));
	out_color = vec4(pow((r3+li)*mix(vec3(0.5,0.5,1.),vec3(1.),de),mix(vec3(0.25),vec3(2.),trr))+ctc*(1.-mo)*0.5,ct);
}