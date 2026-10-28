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

vec3 E=vec3(0.,.001,1.);

float smin(float a, float b, float k) {
  float res = exp(-k * a) + exp(-k * b);
  return -log(res) / k;
}
 
float hash1(float f){return fract(sin(f)*53425.2349);}
float hash2(vec2 f){return hash1(dot(f,vec2(82.,129.)));}
float n2(vec2 v){
  vec2 V=floor(v);v-=V;
  v*=v*(3.-2.*v);
  return mix(
    mix(hash2(V+E.xx),hash2(V+E.zx),v.x),
    mix(hash2(V+E.xz),hash2(V+E.zz),v.x),v.y);
}

float vmax(vec3 p){return max(max(p.x,p.y),p.z);}
#define box(p,s) vmax(abs(p)-(s))


#define R(a) mat2(cos(a),sin(a),-sin(a),cos(a))
 
float t=fGlobalTime;
float ws=1.;
float mid=0.;
float w(vec3 p) {
  float d=1e6;
  p.xz *= R(t*.1);
  float gd=p.y+1.+n2(p.xz)*.2;
  for (float i=1;i<5;++i) {
    vec3 pp = p + vec3(
      sin(i*.3+t*.3),
      cos(i+t*.4),
      sin(i+1.+t*.2*i)
    ) * .8;
    pp.xz *= R(t*.23+i);
    pp.xy *= R(t*.37+i);
    d=smin(d,box(pp,vec3(.35)), 8.);
    //d=min(d,box(pp,vec3(.35)));
    //d=min(d,length(pp)-.5);
  }
  d*=ws;
  
  if (gd < d) {
    mid = 0;
    d = gd;
  } else {
    mid = 1;
  }
  return d;
}

float tr(vec3 o,vec3 d,float l,float L){
  for(float i=0.;i<100;++i){
    float dd=w(o+d*l);l+=dd;
    if (dd<.0001||l>L)break;
  }
  return l;
}


vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+E.yxx) - w(p-E.yxx),
    w(p+E.xyx) - w(p-E.xyx),
    w(p+E.xxy) - w(p-E.xxy)));
}

void main(void){
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 o=vec3(0.,0.,5.),d=normalize(vec3(uv,-2.));
  vec3 C=vec3(0.);
  vec3 ts=vec3(1.);
  for (float b=0.;b<5;++b){
    float L=40.,l=tr(o,d,0.,L);
    vec3 bc=vec3(d.y+.13)*vec3(.3,.5,.8);
    if (l<L){
      vec3 p=o+d*l,n=wn(p);
      vec3 ld=normalize(vec3(1.));
      C+=ts*vec3(.2,.5,.1)*(
        .4 * max(0,dot(n,ld))
        + vec3(.9,.3,.2) * pow(max(0,dot(normalize(ld-d),n)), 50.)
      );
      
      if (mid == 1){
        o = p - n *.001;
        d = normalize(refract(d, n, .96));
        ws = -ws;
        ts *= vec3(.9,.2,.9);
        //C=vec3(1.);
        //C=abs(n);break;
      } else
        break;
    }
    C =mix(C,bc,min(1.,l/L));
  }
  
	out_color = vec4(sqrt(C),0.);
}
