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

vec3 E=vec3(0.,.001,1.);
float VM(vec3 v){return max(max(v.x,v.y),v.z);}
#define box(v,s) VM(abs(v)-(s))
#define rm(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define T(S,V) texture(S,(V+.5)/textureSize(S,0))
#define ffti(v) T(texFFTIntegrated,v).r
#define ffts(v) T(texFFTSmoothed,v).r
#define no(v) T(texNoise,v).r
float t=fGlobalTime;
float hash(float f){return fract(sin(f)*58794.4238);}
float hash(vec2 f){return hash(dot(f,vec2(17.543,119.5435)));}

float g1 = 0.;

float he(vec2 p) {
  return no(p * 3.) * 20.;
}

vec3 cp;
float w(vec3 P) {
  float d = 1e6;
  vec3 p = P;
  
  //if (false)
  {
    //p.y -= 1.;
    p -= cp;
    p.xz *= rm(ffti(5.)*.5);
    p.xy *= rm(ffti(7.)*.3);
    float b = box(p, vec3(.4));
    g1 += 1. / (1. + abs(b));
    d = min(d, b);
  }
  
  {
    p = P;
    float h = he(p.xz);
    float e = p.y - h + 3.;
    d = min(d, e);
    d = min(d, p.y);
  }
  
  
  return d;
}

float tr(vec3 O, vec3 D, float l, float L){
  g1 = 0.;
  for (int i=0;i<100;++i){
    float d=w(O+D*l);l+=d;
    if (d<.001*l||l>L)break;
  }
  return l;
}

vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+E.yxx)-w(p-E.yxx),
    w(p+E.xyx)-w(p-E.xyx),
    w(p+E.xxy)-w(p-E.xxy)));  
}

vec2 curl(vec2 p) {
  float dd = .1;
  vec2 v = vec2(
    no(p+E.zx*dd) - no(p-E.zx*dd), 
    no(p+E.xz*dd) - no(p-E.xz*dd)
  ) / (dd * 2.);
  
  return vec2(v.y, -v.x);
}

vec3 sd = normalize(vec3(-1., .2, -.7));
vec3 sc = vec3(.9, .6, .3);
vec3 bg(vec3 O, vec3 D){
  if (D.y < 0.)
    return vec3(1.);
  
  float l = (50. - O.y) / D.y;
  vec2 p = O.xz + D.xz * l;
  
  vec3 b = vec3(.2, .5, .9);
  
  b = mix(b, vec3(1.), smoothstep(.2, .4, no(p*2.)));
  b = mix(vec3(1.), b, pow(max(0., D.y+.01), .4));
  return b;
}

vec4 pp(vec2 p) {
  vec4 c=T(texPreviousFrame, p);
  c.rgb = pow(c.rgb, vec3(2.));
  return c;
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  t -= .05 * hash(uv+t*.01);
  
  vec3 O=vec3(0.,6.,5.),D=normalize(vec3(uv, -1.)),C=vec3(0.);
  
  O.z -= t * 8. + ffti(3.) * 4.;
  D.xy *= rm(sin(ffti(.7) * .1) * .4);
  D.xz *= rm(.3);//sin(fft*.1)*.2);
  
  cp = O + vec3(-5., sin(t), -10. + 3.*sin(t*.4) - 4. * ffts(6.));
  
  vec3 th=vec3(1.);
  for(int r=0; r<2; ++r) {
    float L=100.,l=tr(O,D,0.,L);
    vec3 sky=bg(O, D);
    vec3 c = vec3(0.);
    
    float gf = exp(g1 * .2) * .2;
    c += vec3(.6,.4,.2) * gf;
    
    if (l < L){
      vec3 p=O+D*l,n=wn(p);
      vec3 mc=vec3(.3,.7,.4);
      
      if (p.y < .05)
        mc = vec3(.2, .6, .9);
      
      float sl=10., ss = step(sl, tr(p,sd,.05,sl));
      c += ss * mc * sc * (
        max(0., dot(n,sd))
        + pow(max(0., dot(n, normalize(sd-D))), 30.)
      );
      c = mix(c, sky, l/L);
      
      C += th * c;
      
      if (p.y > .05)
        break;
      
      O = p + .1 * n;
      D = reflect(D, n);
      th *= mc;
    } else {
      c += sky;
      //C += vec3(.6,.4,.2) * exp(g1) * .2;
      C += th * c;
      break;
    }
  }
  
  //C=vec3(l/L);
  
  uv = gl_FragCoord.xy;
  uv += curl(uv * .05) * 300.;
  vec4 pc = pp(uv);
  C = mix(C, pc.rgb, .8);

	out_color = vec4(sqrt(C), 0.);
}