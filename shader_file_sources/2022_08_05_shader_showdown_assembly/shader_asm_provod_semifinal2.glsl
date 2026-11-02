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
float t = fGlobalTime;
float bt = t * 140. / 60.;
vec3 e=vec3(0.,1.,1.);
#define T(t,s) texture(t,(s+.5)/textureSize(t,0))
#define ffti(f) T(texFFTIntegrated,f).r
#define ffts(f) T(texFFTSmoothed,f).r
float no(vec2 f){return T(texNoise,f).r;}
float hash(float f){return fract(sin(f)*54378.5473);}
vec4 prev(vec2 pix){return T(texPreviousFrame,pix);}
#define rm(a) mat2(cos(a),sin(a),-sin(a),cos(a))

float af(vec2 p){
  return no(p + ffti(4.)) * .6
    + no(p*2. + floor(bt)*10.) * .2
    + no(p*4. - t * 10.) * .2;
  ;
}

vec2 aoff(vec2 pix) {
  float d = 5.;
  return vec2(    
    af(pix+d*e.xy)-af(pix-d*e.xy),
    af(pix-d*e.yx)-af(pix+d*e.yx)
  ) * (d / 2.);
}

float aa(vec2 pix) {
  vec2 off = aoff(pix * .2) * 20. * (.1 + .9*ffts(3.));
  float a = prev(pix + off).a;
  float pbt = fract(bt);
  if (pbt > .9) {
    a *= .9;
    vec2 pn = pix * .8 + 1000.*hash(floor(bt));
    a += step(.3, no(pn));
  }
  return a;
}

float h(vec2 p) {
  return prev(p).a;
}

float w(vec3 p) {
  float d = p.z;
  d -= h(p.xy) * 7.;
  return d;
}

vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+e.zxx),
    w(p+e.xzx),
    w(p+e.xxz)) - w(p)
  );
}

vec3 sc(vec2 uv) {
  vec3 O=vec3(500., 500., 200.), D=normalize(vec3(uv, -2.));
  float pt = bt / 4.;
  float frt = fract(pt);
  float flt = floor(pt);
  
  flt *= flt;
  
  //O.z += 100. * (
  O.z += (100. + 50. * hash(flt*.4)) * frt; 
  O.x += (100. + 50. * hash(flt*.12)) * frt; 
  O.y += (100. + 50. * hash(flt*.3)) * frt; 
  
  D.yz *= rm(-1. + .2*hash(flt*.1));
  D.xy *= rm(sin(pt)*.3 + 17.*hash(flt));
  
  float L=1000.,l=0.;
  for (float i=0.;i<200.;i++) {
    float d= w(O+D*l)*.5;l+=d;
    if(d<.01*l||l>L)break;
  }
  vec3 p =O+D*l,n=wn(p);
  float ph = h(p.xy);
  vec3 ld=normalize(vec3(1.));
  vec3 mc = mix(
    vec3(.1,.8,.1),
    vec3(.7,.1,.2),
    ph)
  ;
  vec3 c = mc * mix(
    max(0., dot(ld, n)),
    pow(max(0., dot(n, normalize(ld-D))), 80.),
    .9);
  return c;
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 pix=gl_FragCoord.xy - .5;
  
  float a=aa(pix);
  vec3 c=sc(uv);
  
	out_color = vec4(sqrt(c), a);
}