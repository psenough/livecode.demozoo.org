#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t=fGlobalTime;
float tt=t*140./60.;
const vec3 e=vec3(0.,1.,.001);
float ha(float f){return fract(sin(f)*26374.236);}
float ha(vec2 v){return ha(dot(v,vec2(17.5326,57.3224)));}
float no(vec2 v){vec2 V=floor(v);v-=V;v*=v*(3.-2.*v);
  return mix(
    mix(ha(V+e.xx), ha(V+e.xy), v.y),
    mix(ha(V+e.yx), ha(V+e.yy), v.y), v.x);
}
#define rm(a) mat2(cos(a),sin(a),-sin(a),cos(a))
float vmax(vec2 v){return max(v.x,v.y);}
#define box(p,s) vmax(abs(p)-(s))
#define PT(t,p) (floor(t)+pow(fract(t),p))
#define PTN(t,p) (floor(t)+1.-pow(1.-fract(t),p))

float h(vec2 p){
  //float ht=
  float d =
    sin(6.28*no(p)+PT(tt/4.,2.))*.4;
  d -= .5*no(p*.45-2.*e.yx*PTN(tt/2.,2.));
  return d;
}

float smin(float a,float b,float k){
  float h=max(0.,1.-abs(b-a)/k);
  return min(a,b)-h*h*k/4.;
}

float w(vec3 p) {
  float d = abs(p.y - h(p.xz)) - .02;
  d*=.5;
  //d = min(d, length(p)-1.);
  
  float sc=1.;
  vec2 C=floor(p.xz*sc),cc=fract(p.xz*sc)-.5;
  vec3 pc=vec3(cc,p.y).xzy;
  float r=.05+.2*ha(C);
  float pt=PT(tt,3.);
  pc.y-=.5-.3*sin(ha(C+.2)*6.283+pt);
  pc.x+=.6*(ha(C+.3)-.5);
  pc.z+=.6*(ha(C+.4)-.5);
  d=smin(d,(length(pc)-r)*.2,.3);
  d=max(d,box(p.xz,4.));
  return d;
}
vec3 no(vec3 p){
  return normalize(w(p)-vec3(
    w(p-e.zxx),
    w(p-e.xzx),
    w(p-e.xxz)
  ));
}

float tr(vec3 ro,vec3 rd,float l,float L){
  for(float i=0.;i<100.;++i){
    float d=w(ro+rd*l);l+=d;
    if(d<l*.001||l>L)break;
  }
  return l;
}


// LOL COPYPASTE THANKS IQ!!11cos(0.)
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}
vec3 pal(float t){
  return palette(t,
    vec3(.5),
    vec3(.5),
    vec3(2.,.8,.3),
    vec3(.5,.25,.2));
}

float ao(vec3 p,vec3 n,float N,float L){
  float k=0.;
  for (float i=0.;i<N;i++){
    float l=(i+1.)*L/N;
    float d=w(p+n*l)*3.;
    k+=step(l,d);
  }
  return k/N;
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 C=vec3(0.),ro=vec3(0.,0.,10.),rd=normalize(vec3(uv,-1.5));
  mat2 X=rm(.5),Y=rm(.6+t*.2);
  rd.yz*=X;ro.yz*=X;
  rd.xz*=Y;ro.xz*=Y;
  float L=20.,l=tr(ro,rd,0.,L);
  
  if (l<L){
    vec3 p=ro+rd*l,n=no(p);
    vec3 sd=normalize(vec3(.3,.5,.1));
    float pp=floor(p.y*30./1.5)/30.;
    pp+=.2*ha(pp*3.);
    vec3 m=pal(pp);
    C=m*vec3(.03);//*ao(p,n,5.,1.);
    float sh=step(5.,tr(p,sd,.05,5.));
    C+=m*max(0.,dot(n,sd))*.7*sh;
    C+=m*pow(max(0.,dot(n,normalize(n+sd))), 150.)*.7*sh;
  }else{
    C=vec3(.6,.8,.9);
  }
  
  C*=smoothstep(1.,.5,length(uv));

	out_color = vec4(sqrt(C),0.);
}