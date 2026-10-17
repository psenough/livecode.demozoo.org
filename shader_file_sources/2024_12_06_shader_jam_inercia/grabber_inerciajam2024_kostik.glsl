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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define BPM 137.
#define beat (time*BPM/60.)
#define PI 3.1415926535
#define INF (1./0.)
#define rep(p,s) (mod(p,2*(s))-(s))
#define rep2(p,s) (abs(rep(p,2*(s)))-(s))

float hash(float t) {return fract(sin(t)*45654.13414);}
float hash(vec2 t) {return hash(dot(t, vec2(12.12414,32.134532)));}
float hash(vec3 t) {return hash(dot(t, vec3(12.12414,32.134532, 23.132123)));}

float ffts(float t) {return texture(texFFTSmoothed, t).r;}
float ffti(float t) {return texture(texFFTIntegrated, t).r;}

vec4 prev(vec2 t) {return texture(texPreviousFrame,t);}

mat2 mr(float t) {float c=cos(t),s=sin(t);return mat2(c,s,-s,c);}

vec3 pal(float t) {
  return pow(vec3(t), vec3(1.4, 1.2, 1.));
}

vec3 glow = vec3(0.);

float map(vec3 p) {
  float h=hash(p+time);
  float t=time+.05*h;
  float sc=1.;
  vec3 op = p;
  p.z += t+.05*ffti(.01);
  
  for(float i=0.; i<5.; ++i) {
    float s = 1.9;
    p.xy *= mr(.03*t);
    p = rep2(p, 2.);
    p *= s;
    vec3 off=vec3(
      hash(floor(beat)),
      hash(floor(beat)+.3),
      hash(floor(beat)+.145)
    );
    p = abs(p)-5*off;
    p.yz *= mr(2.34-.08*t+.05*ffti(i/10.));
    p.xz *= mr(1.32-.07*t+.05*ffti(i/11.));
    sc *= s;
  }
  float soff = pow(sin(length(op.xy+4*t))*.5+.5, 4.);
  float m=length(p)+.3*length(op.xy) - soff;
  glow += (exp(-5.2*length(op.xy)))*.003 / abs(m);
  m=m/sc;
  return m;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  

  vec3 col = vec3(0.);
  vec3 O=vec3(0.,0.,-3.), D=normalize(vec3(uv,1.));
  mat2 m1=mr(.1*sin(.2*time));
  O.xz *= m1;
  D.xz *= m1;
  mat2 m2=mr(.1*sin(.17*time));
  O.yz *= m2;
  D.yz *= m2;
  float d=0.,i;
  bool hit=false;
  for(i=0.;i<64.;++i) {
    vec3 p=O+D*d;
    float m=map(p);
    d += m;
    if (m<0.01*d) {
      hit=true;
      break;
    }
  }
  col += pal(.9*max(0., 1.-i/64.));
  col += glow;
  col *= smoothstep(1., 0.3, length(uv));
  
  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 e=vec2(.001, .0);
  vec3 p = vec3(
    prev(uv+e).r,
    prev(uv-e).g,
    prev(uv-e).b
  );
  col += p*.7;
  
	out_color = vec4(col, 1.);
}




