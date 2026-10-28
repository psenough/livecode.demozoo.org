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

float t=fGlobalTime;
#define T(t,p) texture(t,(p+.5)/textureSize(t,0))
#define fft(f) T(texFFT, f).r
#define ffti(f) T(texFFTIntegrated, f).r
#define ffts(f) T(texFFTSmoothed, f).r

const vec3 e=vec3(0.,.01,1.);
float vmax(vec2 p){return max(p.x,p.y);}
float vmax(vec3 p){return max(max(p.x,p.y),p.z);}
#define box(p,s) vmax(abs(p)-(s))
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define rep(p,s) (mod(p,s)-(s)*.5)
float hash(float f){return fract(sin(f)*34985.54329);}
float hash(vec2 f){return hash(dot(f,vec2(17.1423,54.4573)));}
float noise(vec2 f) {vec2 F=floor(f);f-=F;
  //f*=3.*(2.*f-f);
  return mix(
    mix(hash(F+e.xx),hash(F+e.xz),f.y),
    mix(hash(F+e.zx),hash(F+e.zz),f.y),f.x);
}

float w1(vec3 p) {
  float d=p.y;
  p.y-=1.;
  
  vec2 cs = vec2(2.);
  vec2 cn = floor(p.xz/cs);
  p.xz = rep(p.xz, cs);
  vec2 pp = p.xz;
  
  float ph = fract((.2+.3*hash(cn))*t*.8);
  p.y -= ph * 7. - 2.;
  p.xz *= rot(t*(.5+.5*hash(cn-4.)));
  p.xy *= rot(t*(.5+.5*hash(cn-3.))*1.1);
  float od=box(p, vec3(.6)*(1.-ph));

  od = min(od, -box(pp, cs-.5));
  return min(d,od);
}

float w2(vec3 p) {
  float d=p.y;
  d -= sin(noise(p.xz*2.)+t)*.3;
  p.y -= 1.;
  return min(d,length(p) - 1.);
}

float s_n = 0.;
float w(vec3 p) {
  if (s_n < 1.) return w1(p);
  return w2(p);
}

float tr(vec3 O,vec3 D,float l, float L) {
  for(float i=0.;i<100.;++i){
    float d=w(O+D*l);l+=d;
    if (d<.0001*l||l>L)break;
  }
  return l;
}

vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+e.yxx),
    w(p+e.xyx),
    w(p+e.xxy))-w(p));
}

float ao(vec3 p,vec3 n,float l,float N) {
  l/=N;
  float occ=N;
  for (float i=1.;i<N;++i) {
    float ll = i*l;
    float d=w(p+n*ll);
    occ -= max(0., ll - d);
  }
  return occ/N;
}

struct trd {
  vec3 O,D;
  vec3 bgc,amb;
  vec3 m1d;
  vec3 l1d,l1c;
  vec3 l2d,l2c;
  float bnc;
};

trd trdInit(vec2 uv) {
  trd tt;
  tt.O=vec3(0.,1.,5.);
  tt.D=normalize(vec3(uv,-1.));
  tt.bgc = vec3(1.);
  tt.m1d = vec3(.8);
  tt.amb = vec3(1.);
  tt.l1d=tt.l1c=vec3(0.);
  tt.l2d=tt.l2c=vec3(0.);
  tt.bnc = 0.;
  return tt;
}

vec3 sctr(trd tt) {
  vec3 C=vec3(0.);
  vec3 kc=vec3(1.);
  for (float b=0.;b<=tt.bnc;++b) {
    float L=30.,l=tr(tt.O,tt.D,0.,L);
    if (l>=L) {
      C += kc*tt.bgc;
      break;
    }

      vec3 p=tt.O+tt.D*l,n=wn(p);
      vec3 c = tt.amb * ao(p,n,.7,5.);
      if (any(greaterThan(tt.l1c,e.xxx))) { c += tt.l1c * max(0., dot(n, tt.l1d)); }
      if (any(greaterThan(tt.l2c,e.xxx))) { c += tt.l2c * max(0., dot(n, tt.l2d)); }
      c *= tt.m1d;

      C += kc * mix(c, tt.bgc, l/L);
      tt.O = p + n * .1;
      tt.D = reflect(tt.D, n);
      kc *= tt.m1d;
  }
  return C;
}

vec3 sc1(vec2 uv) {
  s_n = 0.;
  trd tt=trdInit(uv);
  tt.m1d = vec3(.5);
  mat2 ry=rot(.3);
  tt.D.xz*=ry;
  tt.O.xz-=e.xz*ry*t*5.;
  return sctr(tt);
}

vec3 sc2(vec2 uv) {
  s_n = 1.;
  trd tt=trdInit(uv);
  tt.amb = vec3(0.);
  tt.bgc = vec3(0.);
  tt.m1d = vec3(.5);
  tt.l1d = normalize(vec3(1.));
  tt.l1c = vec3(.8,.9,.2);
  tt.l2d = normalize(vec3(-1.,1.,1.));
  tt.l2c = vec3(.2,.1,.8);
  tt.bnc = 2.;
  return sctr(tt);
}

vec3 sc3(vec2 uv) {
  vec2 p=vec2(atan(uv.x,uv.y)/3.1415, 1./length(uv) + t * 3.);

  vec3 C = vec3(0.);  
  vec2 cn = floor(vec2(19., 1.) * p);
  
  //C = vec3(1.) * fract(p.y+t);
  C = vec3(1.)  * step(.5, hash(cn));
  
  return C;
}

vec3 sc4(vec2 uv) {
  uv.y += .5;
  vec2 p = uv * 128.;
  p=floor(p);
  return vec3(fft(p.y));
}

vec3 sc(vec2 uv, float i){
  if (i<1.) return sc2(uv);
  if (i<2.) return sc3(uv);
  if (i<3.) return sc1(uv);
  return sc4(uv);
}

void main(void) {
  float aspect = v2Resolution.x / v2Resolution.y;
	vec2 uv = gl_FragCoord.xy / v2Resolution.xy - .5;
  uv.x *= aspect;
  vec2 uvo=uv;

  vec3 O=vec3(0., 0., 1.),D=normalize(vec3(uv, -2.));
  mat2 ry=rot(.4),rx=rot(.4*sin(t*.2));
  O.xz*=ry;O.yz*=rx;
  D.xz*=ry;D.yz*=rx;
  float l=-O.z/D.z;
  uv =O.xy+D.xy*l;

  float N=4.;
  float zph = fract(t/4.);
  float scl=1. + 150. * zph;
  
  float fsc = 50.;

  uv *= scl;
  vec2 cs = vec2(aspect, 1.);
  vec2 cn = floor(uv/cs);
  vec2 cp = rep(uv, cs);
  
  float mcc = hash(floor(t))*N;
  vec3 mc = sc(cn/fsc*cs, mcc);

  t += hash(cn) * 10.;
  float sci = N * mc.r;
  vec3 C=sc(cp, sci);
  //C=mc;
  //C=sc(uvo, 3.);
	out_color = vec4(sqrt(C), 0.);
}