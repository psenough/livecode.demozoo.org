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

float t = fGlobalTime;
vec3 E=vec3(0.,.01,1.);

#define rm(a) mat2(cos(a),sin(a),-sin(a),cos(a))
float vmax(vec3 v) { return max(max(v.x, v.y), v.z); }
#define bx(p,s) vmax(abs(p)-s)

#define T(S,p) texture(S,(p+.5)/textureSize(S,0))
#define fft(p) T(texFFT,p).r
#define ffti(p) T(texFFTIntegrated,p).r
#define ffts(p) T(texFFTSmoothed,p).r

float w(vec3 p) {
  p.xz *= rm(p.y);
  //p.zy *= rm(p.x*.1);
  
  p.zy *= rm(ffts(3.) * 3.);
  
  //p.xy *= rm(ffts(8.) * 3.);
  
  float d = p.y + 1.;
  d = min(d, bx(p, vec3(.3, 2., .3)));
  float ri = max(abs(p.y)-.1, max(length(p.xz) - 1., .9 - length(p.xz)));
  d = min(d, ri);
  
  
  
  return d;//min(p.y + 1., length(p) - 1.);
}

vec3 wn(vec3 p) {
  return normalize(vec3(
    w(p+E.yxx),
    w(p+E.xyx),
    w(p+E.xxy)) - w(p));
}

float tr(vec3 O, vec3 D, float l, float L) {
  for (int i = 0; i < 100; ++i) {
    float d = w(O+D*l);
    l+=d;
    if (d<.001*l||l>L) break;
  }
  return l;
}

void main(void) {
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  t = fGlobalTime;
  
  vec3 C = vec3(0.);
  vec3 O=vec3(1., 1.2 + .4 * cos(t), 6.), D=normalize(vec3(uv, -2.));
  
  mat2 my = rm(cos(t) * .01);
  
  //O.xz *= my;
  D.xz *= my;
  
  D.yz *= rm(cos(t*.7) * .02 + .1);

  float L=10.,l=tr(O,D,0.,L);
  
  
  if (l < L) {
    vec3 p = O + D * l;
    vec3 N = wn(p);
    
    vec3 ma = vec3(1.);
    vec3 ld = normalize(vec3(1.));
    vec3 lc = vec3(1.);
    float ms = 100.;
    
    ma = vec3(1.) * mix(.9, .01, step(.5, 
      mod(dot(p, normalize(vec3(5.,4.,3.))
      ) + ffti(.5), 1.)));

    float s = step(10., tr(p, ld, .1, 10.));
    C += ma * lc * max(0., dot(ld, N)) * s;
    
    //C += ma * lc * max(0., dot(ld, N));
    //C += ma * lc * pow(max(0., dot(N,ld-D)), ms);
    
    C *= 1. - l/L;
  }
  
  out_color = vec4(sqrt(C), 1.);
}