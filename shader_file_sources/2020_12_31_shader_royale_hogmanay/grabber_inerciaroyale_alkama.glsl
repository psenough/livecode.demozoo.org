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

const float pi=acos(-1);
float g=0,t=mod(.5*fGlobalTime,4*pi);
int mat=1;

#define sat(a) clamp(a,0.,1.)
#define rep(p,r) (mod(p,(r))-(r)*.5)
mat2 rot(float a) { float c=cos(a),s=sin(a); return mat2(c,s,-s,c); }

vec2 moda(vec2 p, float r) {
  r = 2*pi/r;
  float a=mod(atan(p.y,p.x), r) - r*.5;
  return vec2(cos(a),sin(a)) * length(p);
}
float box(vec3 p, vec3 s) {
  vec3 b=abs(p)-s*.5;
  return length(max(b,0.))+min(0, max(max(b.x,b.y),b.z));
}

float city(vec3 p) {
  p.y+=25.;
  float d=10000.;
  float s=1.5;
  float ss=s-.15;
  vec2 id=floor(p.xz/s);
  float den=texture(texNoise, id*0.001).r;
  float h=pow(10*den, 3.)+sin(t*2+id.x*id.y*.01);
  p.xz=rep(p.xz, s);
  d=min(d, box(p, vec3(ss,h,ss)));
  return d;
}

float pawtickles(vec3 p) {
  p.xz *= rot(.25*pi);
  p.xz = moda(p.xz,4.);
  float o=length(vec3(mod(p.x+3.*fract(t*2),3.)-1.5,p.y,p.z))-.05;
  g+=1./(.01+pow(abs(o), 2.)*(10.+5.*sin(t+p.x*p.z*4)));
  return o;
}

float hplus(vec3 p) {
  vec3 pp=p;
  const float s=.3;
  p.xz*=rot(.25*pi);
  p.xz =moda(p.xz,4.);
  float o=1000.;
  o = min(o, box(p, vec3(2.,.8,2)));
  o = min(o, box(p-vec3(1.5,0,0), vec3(3,s,s)));
  o = min(o, box(p-vec3(2.8,0,0), vec3(1.4,.8,1.)));
  return o;
}

float scene(vec3 p) {
  float d=10000.0;
  p.xz *= rot(t*.25);
  
  float o=hplus(p);
  if(o<d) { d=o; mat=1; }
  
  float ptk=pawtickles(p);
  d = min(d, max(ptk, .1));
  
  float c=city(p);
  if(c<d) { d=c; mat=2; }
  return d;
}

vec3 march(vec3 o, vec3 rd, float tr, int it, float md) {
  float d=0;
  int i=0;
  for(i=0; i<it; i++) {
    float h=scene(o+rd*d)*.8;
    if(abs(h)<tr) return vec3(d,i,1);
    if(d>md) return vec3(d,i,0);
    d+=h;
  }
  return vec3(d,i,0);
}

vec3 norm(vec3 p) {
  vec2 e=vec2(0,.01);
  return normalize(scene(p)-vec3(scene(p-e.yxx),scene(p-e.xyx),scene(p-e.xxy)));
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 tg=vec3(0),eye=5.*vec3(1.,.7,1.);
  eye.xz+=2*vec2(sin(t),cos(t));
  vec3 f=normalize(tg-eye);
  vec3 s=normalize(cross(vec3(.5+.25*sin(t),1,0),f));
  vec3 u=normalize(cross(f,s));
  vec3 dir=normalize(f*.8+uv.x*s+uv.y*u);
  
  vec3 lp=3*vec3(1);
  
  vec3 col=vec3(0);
  vec3 m=march(eye,dir,.001,200,500.);
  float ddd=m.x;
  if(m.z==1) {
    vec3 p=eye+dir*m.x;
    vec3 n=norm(p);
    vec3 ld=normalize(lp-p);
    float diff=abs(dot(n,ld));
    float spec=pow(abs(dot(dir, reflect(ld, n))), 30.);
    float fres=sat(max(0., 1-dot(n, -dir)));
    if(mat==1) {
      col+=sat((diff+spec)*fres);
    }
    if(mat==2) {
      col+= .01*vec3(spec)*acos(-dir)*(1-exp2(.01*ddd));
    }
    col*=pow(m.y/50, 2.);
  } else {
    col += smoothstep(0., .2, dir.y) * acos(-dir);
    float den=dot(dir, vec3(0,1,0));
    if(abs(den)>.01) {
      float t= dot(-eye, vec3(0,1,0)) / den;
      if(t>0) {
        vec3 p=dir*t;
        col+= .1 * smoothstep(0., .9, -dir.y) * ( step(.96, fract(p.x*2))+step(.96, fract(p.z*2)) );
      }
    }
  }
  col+=acos(-dir)*g*.01;
  
  out_color.rgb = pow(col, vec3(1./2.2));
}