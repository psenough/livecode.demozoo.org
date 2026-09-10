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
void add(ivec2 p,vec3 c){ivec3 a =ivec3(1000.*c);imageAtomicAdd(computeTex[0],p,a.x);
  imageAtomicAdd(computeTex[1],p,a.y);imageAtomicAdd(computeTex[2],p,a.z);}
  vec3 load(ivec2 p){return vec3(imageLoad(computeTexBack[0],p).x,imageLoad(computeTexBack[1],p).x,imageLoad(computeTexBack[2],p).x)/1000.;}
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float rd(float t){return fract(sin(dot(floor(t),45.23))*7845.236);}
float no(float t){return mix(rd(t),rd(t+1.),smoothstep(0.,1.,fract(t)));}
mat2 rot(float t){float c = cos(t); float s = sin(t); return mat2(c,-s,s,c);}
float t1 = texture(texFFTIntegrated,0.25).x*2.+fGlobalTime*0.05;
float box(vec2 p, vec2 b){vec2 q = abs(p)-b; return length(max(q,vec2(0.)))+min(0.,max(q.x,q.y));}
float smin(float a, float b, float h){float k = clamp((a-b)/h*.5+0.5,0.,1.);
  return mix(a,b,k)-h*k*(1.-k);}
  vec3  smin(vec3  a, vec3  b, float h){vec3  k = clamp((a-b)/h*.5+0.5,0.,1.);
  return mix(a,b,k)-h*k*(1.-k);}
  float ta = no(t1*6.4);
float map(vec3 p){
  vec3 pp = p;
  for(int  i = 0 ; i <  5 ; i++){
    pp -=0.5;
    pp.zy*=rot(t1);
    pp.zx*=rot(t1);
    pp = smin(pp,-pp,-1.);
  }
  float d1 = min(smin(length(pp)-0.5,length(pp-0.75)-0.25,0.5),length(pp-2.)-0.5*ta)-ta*0.5;
  float d2 = p.y+2.+sin(d1*10.+t1*-20.)*0.1;
  return smin(d1,d2,2.);}
  vec3 nor(vec3 p){vec2 e = vec2(0.01,0.);
    return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc  = uv;
	uv -= 0.5;uv*= 2.;vec2 res = v2Resolution.xy;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 r = normalize(vec3(uv,no(t1)+0.5));vec3 pp;
  if(rd(t1*0.5)>0.5){
  pp = vec3(0.,0.,-5.-no(t1*2.5)*6.);
  r.zy *=rot(no(t1*4.2)-0.5);
  r.xz *=rot(t1*0.8);
  pp.xz *=rot(t1*0.8);
  }
  else{
      pp = vec3(0.,5.+no(t1*2.5)*6.,0.);
    r.zy*=rot(-1.5);
  }
  for(int  i = 0 ; i <  64 ; i++){
    float d = map(pp);
    if(d<0.01){
      vec3 n = nor(pp);
      r = reflect(r,n);
      d = 0.2;}
      pp+=r*d;
  }
  vec2 pb = vec2(no(t1*8.),0.2);
  float d = box(uv,mix(pb,pb.yx,step(0.5,rd(t1))));
  vec2 ut = uv*vec2(0.8,1.)+vec2(-0.2,sin(uv.x*4.+fGlobalTime*7.)*0.2);
  float d2 = box(ut-vec2(-1.2,0.),vec2(0.,0.5));
  d2 = min(d2,box(ut-vec2(-1.,0.),vec2(0.,0.5)));
  d2 = min(d2,box(ut-vec2(-0.8,0.),vec2(0.,0.5)));
  d2 = min(d2,box((ut-vec2(-0.9,0.))*rot(-0.3),vec2(0.,0.5)));
  
  d2 = min(d2,box(ut-vec2(-0.6,0.),vec2(0.,0.5)));
  d2 = min(d2,box(ut-vec2(-0.5,0.),vec2(0.05,0.)));
  d2 = min(d2,box(ut-vec2(-0.5,0.5),vec2(0.05,0.)));
  d2 = min(d2,box(ut-vec2(-0.5,-0.5),vec2(0.05,0.)));
  
  d2 = min(d2,box(ut-vec2(-0.3,0.),vec2(0.,0.5)));
  d2 = min(d2,box(ut-vec2(-0.2,0.),vec2(0.1,0.)));
  d2 = min(d2,box(ut-vec2(-0.2,0.5),vec2(0.1,0.)));
  d2 = min(d2,box(ut-vec2(-0.1,0.25),vec2(0.,0.25)));
  d2 = min(d2,box((ut-vec2(-0.1,-0.25))*rot(-0.3),vec2(0.,0.25)));
  
  d2 = min(d2,box(ut-vec2(0.1,0.),vec2(0.,0.5)));

  d2 = min(d2,box(ut-vec2(0.2,0.5),vec2(0.1,0.)));
  d2 = min(d2,box(ut-vec2(0.2,-0.5),vec2(0.1,0.)));
  
   d2 = min(d2,box(ut-vec2(0.5,0.),vec2(0.,0.5)));
   
    d2 = min(d2,box(ut-vec2(.7,0.),vec2(0.,0.5)));
  d2 = min(d2,box(ut-vec2(0.8,0.),vec2(0.1,0.)));
  d2 = min(d2,box(ut-vec2(0.8,0.5),vec2(0.1,0.)));
  d2 = min(d2,box(ut-vec2(0.9,0.),vec2(0.,0.5)));
  float rtt =smoothstep(0.7,0.75,no(t1*1.5+98.));
  d = mix(d,d2,rtt);
  float dt = smoothstep(0.0075,0.,d2-0.);
  float li = smoothstep(0.075,0.,fract(d*8.))*step(d,0.5+0.5*no(t1+45.));

  vec2 pos = uc*res;
  float a = (d-no(t1+56.))*1.5;
  vec2 b = vec2(cos(a),sin(a));
  vec2 p  =b;
  p*=rot(a);
  p*=1.5;
  pos+=p;
  float rot = dot(texture(texPreviousFrame,fract((pos+p)/res)).aa-0.5,p.yx);
  vec2 v = p.yx*rot/dot(b,b)*texture(texPreviousFrame,uc).a*5.;
  float l1 = texture(texPreviousFrame,fract((pos+v*vec2(-2.,2.))/res)).a*0.98+li;
  float r1 = 0.;vec2 r2 = mix(r.xy*0.5+0.5,uc,rtt);float dm = 0.002*no(t1*8.);
  for(int  i = 0 ; i <  20 ; i++){
    float d = i/20.;
    r2 += r2*dm;
    r1 = texture(texPreviousFrame,r2).a;
    if(dot(r1,1.)<d){break;}
  }
  
  vec3 l2 = 1.-mix(vec3(1.),clamp(3.*abs(1.-2.*fract(r1*3.+vec3(0.,-1./3.,1./3.)))-1.,0.,1.),no(t1*4.))*r1;
  vec3 l3 = mix(1.-l2,l2,smoothstep(0.75,0.8,no(t1*7.)));
  vec3 rf ;
  add(ivec2(uc*res),l3);
  float pi = 6.28;vec2 df = length(uv.y)*(20.+50.*no(t1*8.1)*mix(vec2(1.),100.*v,smoothstep(0.75,0.9,no(t1*2.+12.))));
  for(float i = 0.2; i <1.; i +=0.2)
  for(float j = pi/16.;j<pi;j+=pi/16.){
    vec2 b = vec2(cos(j),sin(j));
    rf += load(ivec2(uc*res+b*i*df));
  }
  rf/= 64.;
	out_color = vec4(rf+dt*rtt*fract(fGlobalTime*10.),l1);
}