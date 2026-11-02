#version 410 core

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
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define BPM 130.
#define INF (1./0.)
#define time fGlobalTime
#define beat (time*BPM/60.)
#define PI 3.1415926536
#define rep(p,s) (mod(p,s)-s/2.)
#define rep2(p,s) (abs(rep(p,2.*s))-s/2.)

float hash(float t) {return fract(sin(t)*35628.54654);}
float hash(vec2 t) {return hash(dot(t, vec2(12.6456, 32.63456345)));}
float hash(vec3 t) {return hash(dot(t, vec3(12.6456, 32.63456345, 48.546984)));}

vec3 back(vec2 uv){return texture(texPreviousFrame, uv).rgb;}
float ffts(float t) {return texture(texFFTSmoothed, t).r;}

vec3 ct(vec3 p) {
  if(p.x<p.y) p.xy = p.yx;
  if(p.y<p.z) p.yz = p.zy;
  if(p.x<p.y) p.xy = p.yx;
  return p;
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  float m=max(p.x, max(p.y,p.z));
  return m>0.? length(p): m;
}

mat2 mr(float t) {float c=cos(t),s=sin(t); return mat2(c,s,-s,c);}

float beatstep(float t, float a) {return floor(t) + smoothstep(0., a, fract(t));}

vec2 polar(vec2 p, float n) {
  p = vec2(length(p), atan(p.y, p.x));
  p.y = rep(p.y, PI/n);
  return p.x * vec2(cos(p.y), sin(p.y));
}

#define quant(t,s) (floor(t/s)*s)

void main(void)
{
	vec2 uv = gl_FragCoord.xy / v2Resolution.xy - .5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 c = vec3(0.);
  vec3 O=vec3(0.,0.,-1.);
  vec3 D = vec3(uv, 1.);
  D.z *= 1.-length(D.xy);
  D=normalize(D);
  float I=64.;
  for(float i=0.; i<I; ++i) {
    float d = mix(0.1, 5., i/I + hash(uv+time+i));
    d /= D.z;
    vec3 op = O+D*d;
    
    {
      vec3 p=op;
      p.z += time;
      vec3 pos=floor(p-.5);
      p = rep(p, 1.);
      p.xz *= mr(beat+hash(pos*1.17));
      p = ct(abs(p));
      float m = box(p, vec3(.1, vec2(.01)));
      float amp = 1.+exp(-fract(beat+quant(hash(pos), .8)));
      c += amp * .003 / abs(m) * exp(-d*.5);
    }
    
    {
      vec3 p=op;
      p.z += time;
      float pz = floor(p.z);
      p.xy *= mr(p.z + PI/4.*beatstep(beat/4. + quant(hash(pz*1.886), .5) + hash(uv+i+time)*.2, .1));
      p.z = rep(p.z, 1.);
      vec3 s=vec3(.2, .2, .02);
      p = mix(p, ct(abs(p))-.2, .5+.5*cos(PI*beatstep(beat/8., .3)));
      float m = box(p, s);
      m = max(m, -box(p, vec3(s.xy-.02, INF)));
      float amp = 1.+exp(-fract(beat+quant(hash(pz), .8)));
      c += amp * .008 / abs(m) * exp(-d*.5);
    }
    
    {
      vec3 p=op;
      p.z += time;
      float phaseoff = 0.;
      phaseoff = hash(uv+i+.17*time) * (.5+.5*sin(beat/4.));
      p.xy *= mr(beatstep(p.z*.2 + phaseoff, .8));
      p.xy = polar(p.xy, 5.);
      p.x -= 1.5;
      float m = length(p.xy)-.05;
      c += .005 / abs(m) * exp(-d*.5);
    }
  }
  uv = gl_FragCoord.xy / v2Resolution.xy;
  vec2 e=vec2(.002, .0);
  e *= 1.+4.*exp(-3.*fract(beat));
  vec3 prev = vec3(
    back(uv-e).r,
    back(uv).g,
    back(uv-e).b
  );
  c = mix(c, prev.xyz, .7);
  
	out_color = vec4(c, 0.);
}