#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float t=fGlobalTime;
const vec3 E=vec3(0.,.01,1.);
#define T(t,s) texture(t,(s+.5)/textureSize(t,0))
#define fft(s) T(texFFT, s).r
#define ffts(s) T(texFFTSmoothed, s).r
#define ffti(s) T(texFFTIntegrated, s).r
#define fbm(s) T(texNoise, s).r
float ha(float f){return fract(sin(f)*54783.5743);}
float ha(vec2 f){return ha(dot(f,vec2(19.453,41.247)));}
float no(float f){float F=floor(f);f-=F;f*=f*(3.-2.*f);
  return mix(ha(F),ha(F+1.),f);
}
float no(vec2 f){vec2 F=floor(f);f-=F;f*=f*(3.-2.*f);
  return mix(
    mix(ha(F+E.xx),ha(F+E.zx),f.x),
    mix(ha(F+E.xz),ha(F+E.zz),f.x), f.y);
}
float smin(float a, float b, float k){
  float h=max(k-abs(a-b),0.)/k;
  return min(a,b)-h*h*k/4.;
}
float vmax(vec3 p){return max(max(p.x,p.y),p.z);}
float bo(vec3 p,vec3 s){return vmax(abs(p)-s);}
#define rm(a) mat2(cos(a),sin(a),-sin(a),cos(a));

float allofyouare(vec3 p) {
  float r = length(p.xy);
  float a = atan(p.x, p.y) / 6.2832;
  a = fract(a*6.);
  p.xy = r * vec2(cos(a), sin(a));
  return bo(p, vec3(.05, .5, .05));
}

float d, dsp, dwedro, dmorkow;
float ins=1.;
float w(vec3 p) {
//  d=1e6;
  
  vec2 uv = p.xz;
  float hh = no(uv*.3);// + ffti(5.) * .4;
  uv += (vec2(no(hh),no(hh+40.5))-.5) * 8.;
  float h=no(uv*.7);
  h += .3 * smoothstep(.3, .6, fbm(p.xz*40.));
  
  //d=smin(d,,.5);

  p.x -= 2.; p.y += .5;
  vec3 bp=p;bp.xy*=rm(.8);bp.xz*=rm(.5);
  
  d=bo(bp,vec3(.5));
  
  p.y-=.9;
  bp=p;bp.xy*=rm(-.3);bp.xz*=rm(.5);
  d=smin(d,bo(bp,vec3(.3)),.1);
  
  p.y-=.6;
  bp=p;bp.xy*=rm(-.9);bp.xz*=rm(.5);
  d=smin(d,bo(bp,vec3(.2)),.1);
  d-=fbm(p.xy*95.)*.3;
  
  d = smin(d, p.y+2.+h*.5, .4);
  
  d += fbm(p.xz*256.*1.)*.08;
  
  dwedro=length(p.zx)-.25 + p.y*.08;
  dwedro=max(dwedro, p.y - .8);
  dwedro=max(dwedro, .3 - p.y);
  d=min(d,dwedro);
  
  vec3 mp = p; mp.z+=.1;
  mp.xy *= rm(t+ffts(5.) * 10.);
  dmorkow = bo(mp, vec3(.03,.03,.7));
  d=min(d,dmorkow);

  p.x+=2.;
  bp=p;bp.xz*=rm(t);bp.xy*=rm(ffti(4.));
  dsp=bo(bp,vec3(.7));//ins*(length(p) - 1.);
  dsp-=.1 * sin(ffti(7.)*2. + bp.y * 5.);
  dsp *=.8;
  
  //dsp = allofyouare(p);
  
  dsp*=ins;
  d=min(d,dsp);
  return d;
}

vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+E.yxx)-w(p-E.yxx),
    w(p+E.xyx)-w(p-E.xyx),
    w(p+E.xxy)-w(p-E.xxy)));
}

float tr(vec3 O,vec3 D,float l,float L){
  for(int i=0;i<200;++i){
    float d=w(O+D*l);
    l+=d;
    if(d<.001*l||l>L)break;
  }
  return l;
}

void main(void) {
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 sd=normalize(vec3(1.,2.,3.2));
  vec3 sc=vec3(.9,.8,.78)*1.;
  vec3 skyc=vec3(.3,.7,.9);
  
  vec3 C=vec3(0.);
  vec3 O=vec3(1.,0.,5.),D=normalize(vec3(uv,-1.));
  O.x += (no(t)-.5)*.2;
  O.y += (no(t+5.4)-.5)*.1;
  O.z += (no(t+15.8)-.5)*.3;
  
  vec3 kc = vec3(1.);
  for(int r=0;r<3;++r) {
    float L=20.,l=tr(O,D,0.,L);
    if (l>L) {
      C += kc*skyc;
      break;
    }
    
    vec3 p=O+D*l;
    float m=(d==dsp)?1.:(d==dwedro)?2.:(d==dmorkow)?3.:0.;
    vec3 n=wn(p);
    vec3 c=vec3(0.);
    vec3 md=vec3(1.);
    vec4 ms=vec4(vec3(1.), 50.);
    float occ=1.;
    float sh = step(10.,tr(p,sd,.01,10.));
    
    if (m==1.) {
      md=vec3(1.,0.,0.);
    } else if(m==2.){
      md=vec3(.2,.5,1.);
    } else if(m==3.) {
      md=vec3(.9,.3,.1);
    } else {
      vec2 uv = p.xz * 64.;
      /*
      n = normalize(n + .4 * vec3(
        no(uv)-.5,
        no(uv+2.)-.5,
        no(uv+4.)-.5));
      */
      //n = normalize(mix(n, -D, step(.9, no(uv))));
    }
    
    c+=md*sc*max(0., dot(n,sd))*sh;
    c+=md*vec3(.3)*max(0., -n.y);
    if (ms.a > 0.) {
      c += ms.rgb * sc * pow(max(0.,dot(normalize(sd-D),n)), ms.a);
    }
    c+=occ*skyc*.1;
    //c*=1.-vec3(l/L);
    c=mix(c, skyc, pow(l/L, 3.));
    
    C+=c*kc;
    
    if (m!=1.)
      break;
 
    ins=-ins;
    O=p-n*.01;
    D=refract(D,n,.9);
    //D=reflect(D,n);
    kc*=.8;
    //break;
  }
  
  C*=smoothstep(1.2,.4,length(uv));

  out_color = vec4(sqrt(C), 1.);
}