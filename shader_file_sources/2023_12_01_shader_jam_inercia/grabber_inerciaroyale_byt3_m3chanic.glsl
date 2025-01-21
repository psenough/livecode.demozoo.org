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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define R v2Resolution
#define T fGlobalTime
#define mindist 1e-3
#define maxdist 25.
#define PI  3.141592
#define PI2 6.283185
#define SCALE .75

float hash21(vec2 p) {
  return fract(sin(dot(p,vec2(27.03,57.3)))*43.3);
}
mat2 r2(float a) { 
  return mat2(cos(a),sin(a),-sin(a),cos(a)); 
}
float box(vec3 p, vec3 b, float r) {
  vec3 q = abs(p)-b;
  return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.)-r;
}
float trs(vec3 p, vec2 t){
  vec2 q=vec2(length(p.xy)-t.x,p.z);
  return length(q)-t.y;
}

vec3 shp,fhp;
vec2 sip,bid;
float thsh;

const float sz = 1./SCALE;
const float hf = sz/2.;

vec2 mq(vec2 q) {
    return mod(q+hf,sz)-hf;
}

vec2 map(vec3 p) {
  vec2 res = vec2(1e5,0.);

  p.z += 5.;
  p.x -= T*.83;
  
  vec2 qid = floor((p.xy+hf)/sz);
  vec3 qm = vec3(mq(p.xy),p.z);
  
  float hs = hash21(qid);
  if(hs>.5) qm.x=-qm.x;
  
  vec2 q = length(qm.xy-hf)<length(qm.xy+hf)?qm.xy-hf:qm.xy+hf;
  vec3 q3 = vec3(q,qm.z);
  
  float thx = .125+.1*sin(p.y*.56+T);
  float t = trs(q3,vec2(hf,thx));

  sip = qid;
  thsh = hs;
  
  if(t<res.x) {
    res = vec2(t,1.);
    shp = qm;
  }

  float bx = box(qm+vec3(0,0,1),vec3(hf*.82),.05);
  if(bx<res.x) {
    res = vec2(bx,2.);
  }
  
  float cx = box(qm,vec3(hf*.70),.05);
  float sx = length(qm)-hf;
  float nx = max(cx,-sx);
  if(nx<res.x&&hs>.8) res = vec2(nx,3.);

  return res;
}

vec3 normal(vec3 p, float t){
    t*=mindist;
    float d = map(p).x;
    vec2 e = vec2(t,0);
    vec3 n = d - vec3(
        map(p-e.xyy).x,
        map(p-e.yxy).x,
        map(p-e.yyx).x
    );
    return normalize(n);
}

vec2 marcher(vec3 ro, vec3 rd,int steps) {
    float d = 0., m = 0.;
  for(int i=0;i<steps;i++){
    vec3 p =ro+rd*d;
    vec2 t = map(p);
    d+=i<32?t.x *.45:t.x ;
    m = t.y;
    if(abs(t.x)<d*mindist||d>maxdist) break;
  }
  return vec2(d,m);
  
}

vec3 hue(float a){
  return  .45 + .45 * cos(PI2* a * vec3(1.,.15,.25));
}

float diff(vec3 p,vec3 n, vec3 lpos){
    vec3 l = normalize(lpos-p);
    float dif = clamp(dot(n,l),.1 , 1.);
    float shdw = 1.;
    for( float t=.01;t<12.; ) {
       float h = map(p + l*t).x;
       if( h<mindist ) { shdw = 0.; break; }
       shdw = min(shdw, 32.*h/t);
       t += h * .95;
       if( shdw<mindist || t>1. ) break;
    }
    dif = mix(dif,dif*shdw,.35);
    return dif;
}
vec3 thp,ghp;
vec2 tip,fid;
float hsh;

vec3 color(float m, vec3 p, vec3 n) {
    vec3 h = vec3(.5);
  if(m==1.) {
        thp/=1./SCALE;
        float dir = mod(tip.x + tip.y,2.) * 2. - 1.;  

        vec2 cUv = thp.xy-sign(thp.x+thp.y+.001)*.5;
        float angle = atan(cUv.x, cUv.y);
        float a = sin( dir * angle * 6. + T * 2.25);
        a = abs(a)-.45;a = abs(a)-.35;
        vec3 nz = hue((p.x+(T*.12))*.25);
        h = mix(nz, vec3(1), smoothstep(.01, .02, a)); 
  }
  if(m==2.) h=hue(hash21(tip));
  if(m==3.) h=hue(hash21(tip));
  return h;
}

void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy-R.xy) /max(R.x,R.y);
  vec3 ro = vec3(0,0,-1);
  vec3 rd = normalize(vec3(uv,-1));
 
  mat2 rx = r2(.058*sin(T*.3)),ry = r2(.18*sin(T*.2));
  ro.zy*=rx;ro.xz*=ry;
  rd.zy*=rx;rd.xz*=ry;
  
	vec3 C = vec3(0.);
  vec3 FC =vec3(.03);
  
  vec2 r = marcher(ro,rd,90);
    thp = shp;
    tip = sip;
    hsh = thsh;
  
  if(r.x<maxdist) {
    vec3 p = ro+rd * r.x;
    vec3 n = normal(p,r.x);
    vec3 lpos = vec3(2,3,6);
    
    float df = diff(p, n, -lpos);
    vec3 h = color(r.y,p,n);
    C = df*h;
    if(h.x<.9999&&h.y<.9999&&h.z<.9999){
        vec3 rr = reflect(rd,n); 
        vec2 tr = marcher(p ,rr, 70);
        thp = shp;
        tip = sip;
        hsh = thsh;
        if(tr.x<maxdist){
          p += rr * tr.x;
          n = normal(p,r.x);
          df = diff(p, n, lpos);
          h = color(r.y,p,n);
          C += (df*h)*.5;
        } 
    }
  }
  C = mix( C, FC, 1.-exp(-.01*r.x*r.x*r.x));
  C = pow(C,vec3(.4545));
	out_color = vec4(C,1.);
}