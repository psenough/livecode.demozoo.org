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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T(T,S) texture(T,(S+.5)/textureSize(T,0))
float ffti(float f){return T(texFFTIntegrated, f).r;}

float t=fGlobalTime;
vec3 E=vec3(0.,.01,1.);
float vmax(vec3 v){return max(max(v.x,v.y),v.z);}
#define box(v,s) vmax(abs(v)-(s))
#define rep(v,s) (mod(v,s)-(s)*.5)
#define rm(a) mat2(cos(a),sin(a),-sin(a),cos(a))
float h(float f){return fract(sin(f)*45834.3847);}

float w(vec3 p){
  vec3 pp=p;
  float d = 1e6;
  p.y -= 1.;
  //d=min(d,length(p)-1.);
  vec3 rs = vec3(2.,3.,2.);
  vec3 c = floor(p/rs);
  float off = (h(c.z) - .5) * t;
  off = floor(off) + pow(fract(off), 4.);
  p.x += off * 4.;
  
  p = rep(p, rs);
  //p.xz *= rm(.4);
  //p.xy *= rm(.7);
  
  float bnd = box(p, rs) - .1;
  
  float b1 = box(p,vec3(.6, 1., .8));
  d=min(d,b1);
  
  float b2 = box(rep(p, vec3(.4,.6,.4)*.7), vec3(.13, .17, .16)*.6);
  d=min(d, max(b1-.03, b2));
  
  b2 = box(rep(p, vec3(.2,.3,.2)), vec3(.06));
  //d=min(d, -max(b1-.03, b2));
  d = max(d, -b2);
  
  d = min(d, -bnd);
  
  pp.z = rep(pp.z, 100.);
  //d = max(d, -(length(pp) - 50.));
  return d;
}
float tr(vec3 O,vec3 D,float l,float L){
  for(int i=0;i<200;++i){
    float d=w(O+D*l);l+=d;
    if(d<.001*l||l>L)break;
  }
  return l;
}
vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+E.yxx),
    w(p+E.xyx),
    w(p+E.xxy))- w(p));
}

vec3 bg(vec3 d){
  return vec3(1.);
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ld = normalize(vec3(1.));
  vec3 lc = vec3(.5);
  
  vec3 C=vec3(0.),O=vec3(0., 1., 5.),D=normalize(vec3(uv,-1.));
  D.xz *= rm(.45);
 
  D.xy *= rm(t*.2);
  O.z -= ffti(4.) * 3.;
  //O.x += t*3.;
  
  vec3 th=vec3(1.);
  
  for(int r=0;r<2;++r){
    float L=50.,l=tr(O,D,0.,L);
    if(l>L) {
      C += th * bg(D);
    }
    
    vec3 p=O+D*l,n=wn(p);
    vec3 mc=vec3(.5);
    vec3 c= vec3(0.);
    
    //c += mc * lc * max(0., dot(n, ld));
    //c += mc * lc * pow(max(0., dot(n, normalize(ld-D))), 20.);
    
    C += th * mix(c, bg(D), l/L);
    
    th *= mc;
    O = p + .01*n;
    D = reflect(D, n);
  }
  
	out_color = vec4(sqrt(C),0.);
}