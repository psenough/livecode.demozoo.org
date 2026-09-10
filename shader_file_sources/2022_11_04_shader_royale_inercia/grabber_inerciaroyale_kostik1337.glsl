#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float BPM = 120.;
float beat = time*BPM/60.;

vec3 ct(vec3 p) {
  if(p.x<p.y) p.xy=p.yx;
  if(p.y<p.z) p.yz=p.zy;
  if(p.x<p.y) p.xy=p.yx;
  return p;
}

#define mr(t) (mat2(cos(t), sin(t), -sin(t), cos(t)))
#define quant(p,x) (floor(p/x)*x)
#define rep(p,s) (mod(p,(s))-(s)/2.)
#define rep2(p,s) (abs(rep(p,(2.*s)))-(s)/2.)
#define PI 3.14159265
#define TAU (2.*PI)
#define INF (1./0.)

float hash(float x) {return fract(sin(x*325.88913));}

vec4 back(vec2 uv) {return texture(texPreviousFrame, uv);}
float ffti(float t) {return texture(texFFTIntegrated, t).r;}

vec3 glow = vec3(0.);

float box(vec3 p, vec3 s) {
  p = abs(p)-s;
  return max(p.x, max(p.y, p.z));
}

vec3 calcglow(float m) {
  return .003*vec3(1.,1.2,1.4) / abs(m-.05*vec3(1.3, 1.2, .9));
}

float mycube(vec3 p) {
  vec3 p2 = p;
  float m = 1./0.;
  vec3 s = vec3(.2 + .02*smoothstep(.6, 1., fract(beat)));
  float gi = floor(4.*fract(beat));
  for(float i=0.;i<4.;++i) {
    s.xz *= mr(2.31*floor(beat));
    s.yz *= mr(1.19*floor(beat));
    s = abs(s)/1.5;
    if(i==2.) p.xz *= mr(PI/4.);
    p = abs(p)-s;
    p=ct(p);
    vec3 p1 = p;
    float qf = fract(beat + hash(dot(vec3(.12,.34,.32),quant(p2, .1))));
    p1 = quant(p1, mix(.001, .05, qf));
    float mm = length(p1.xy)-s.x/64.;
    m = min(m, mm);
    if (i==gi) glow += calcglow(mm);
  }
  return m;
}

float map(vec3 op) {
  vec3 p=op;
  p.xy *= mr(time);
  p.xz *= mr(floor(beat) + smoothstep(0., .5, fract(beat)));
  p.yz *= mr(1.12* (floor(beat) + smoothstep(0., .5, fract(beat))));
  p.xz *= mr(ffti(.13)*4.);
  float m;
  float h = hash(floor(beat));
  if(h < .1) {
    p = abs(p);
    m = dot(p, normalize(vec3(1.)))-.3;
    glow += calcglow(m);
  } else if(h < .2) {
    m = box(p, vec3(.3));
    glow += calcglow(m);
  } else if(h < .3) {
    p = abs(p)-.2;
    p = abs(p)-.1;
    m = length(p)-.05;
    glow += calcglow(m);
  } else if(h < .4) {
    p = ct(abs(p));
    m = box(p, vec3(.01, .01, .5).yxz);
    glow += calcglow(m);
  } else {
    m = mycube(p);
  }
  vec3 s;
  
  p = op;
  p.z += 8.*ffti(.2);
  s = vec3(12.2);
  float maxx = -box(op, vec3(2.,1., INF));
  for(float i = 0.;i<4.;++i) {
    float t = i==1.? .01*(floor(beat) + smoothstep(0., .3, beat)) : 0.;
    s.xy *= mr(.12+t);
    s.yz *= mr(.23+t);
    s = abs(s)/2.;
    p = rep2(p, s);
    p = ct(p);
    vec3 pp = p;
    pp = quant(pp, mix(.001, .05, fract(beat+.5)));
    float mm = length(pp.yz)-s.x/128.;
    mm = max(mm, maxx);
    m = min(m, mm/1.3);
    glow += .0005 * (sin(4.*op.z-1.3*time)*.5+.5) / abs(mm-.01*vec3(1.,1.4,1.2));
  }
  
  return m;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 c = vec3(0.);
  vec3 O = vec3(0., 0., -2.), D = vec3(uv, 1.);
  
  mat2 m = mr(.1*sin(time) + .07*sin(1.1*time));
  O.xz *= m;
  D.xz *= m;
  m = mr(.08*sin(1.2*time) + .06*sin(1.3*time));
  O.xz *= m;
  D.xz *= m;
  O.z -= .5+.5*sin(PI/16.*beat);
  
  D.xy *= mr(PI/4.*smoothstep(.0, .1, fract(beat/4.)));
  
  float d = 0.;
  float hit = 0.;
  for(float i=0.;i<64.;++i) {
    vec3 p=O+D*d;
    float m = map(p);
    d += m;
    if(m < .01*d) {
      c += (1.-i/64.)*.1 * exp(-d*.5);
      float thresh = mix(10., 40., fract(beat/4.));
      hit = i > thresh ? 1. : 0.;
      break;
    }
  }
  glow *= exp(-d*.2);
  c += glow;
  
  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float gg = 1.;
  if (fract(beat) < .05) {
    uv = quant(uv, .05);
    gg = 1.2;
  }
  vec4 prev = back(uv);
  vec2 e = vec2(.01, .0);
  e *= 8. * smoothstep(.9, 1., fract(beat/4.));
  e *= mr(floor(beat));
  e *= hash(quant(uv.y, .05))-.5;
  prev = vec4(
    back(uv-e).r,
    back(uv).g,
    back(uv+e).b,
    prev.a
  )*gg;
  float mf = mix(.6, .9, prev.a);
  
  c = mix(c, prev.rgb, mf);
  
  for(float i=1.;i<4.;++i) {
    vec2 disp = vec2(
      hash(i+floor(beat)),
      hash(i+.13+floor(beat))
    )-.5;
    vec3 cc = back((uv+disp)/(1.+i)).rgb;
    c += cc* mix(.04, .1, (1.-fract(beat)));
  }
  c *= 1.-hit;

	out_color = vec4(c, glow);
}