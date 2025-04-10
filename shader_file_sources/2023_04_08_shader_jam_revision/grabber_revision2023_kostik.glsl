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

float hash(float t) {return fract(sin(t) * 24535.365);}
float hash(vec2 t) {return hash(dot(t, vec2(34.646,43.66442)));}
float hash(vec3 t) {return hash(dot(t, vec3(34.646,43.66442, 12.544)));}

#define INF (1./0.)
#define time fGlobalTime
#define mr(t) (mat2(cos(t),sin(t),-sin(t),cos(t)))
#define sat(t) (clamp(t, 0.,1.))

#define BPM 130.
float beat = time * BPM/60.;

float ffts(float t) {return texture(texFFTSmoothed, t).r;}
float ffti(float t) {return texture(texFFTIntegrated, t).r;}
vec4 prev(vec2 p) {return texture(texPreviousFrame, p);}

float box(vec3 p, vec3 s) {
  p = abs(p)-s;
  return max(p.x, max(p.y, p.z));
}

float beatstep(float b, float x) {return floor(b) + smoothstep(.0, .3, fract(b)); }

float noise(float t) {
  return mix(hash(floor(t)), hash(floor(t+1.)), smoothstep(0.,1.,fract(t)));
}

float boxs = .4;

float map(vec3 p) {
  //p.yz *= mr(1.5*beatstep(beat/8., .1));
  p.xy *= mr(.2*sin(beat*.2));
  p.xz *= mr(.2*sin(beat*.3));
  p.yz *= mr(ffti(.1)*.3);
  p.xz *= mr(ffti(.13)*.5);
  
  float off = .005;
  vec3 s = vec3(boxs);
  float m, i;
  for(i=0.;i<3.;++i) {
    s /= 2.;
    vec3 sig = sign(p);
    p = abs(p)-s-off;
    float bb = beat/4.;
    float thresh = fract(bb+i*.5);
    thresh = mix(1., .5, smoothstep(.0, .1, thresh) * (1.-smoothstep(.9, 1., thresh)));
    if (hash(sig + floor(bb)) < thresh) break;
  }
  m = box(p, s - off*i);
  return m;
}

vec3 pal(float t, float p) {
  return vec3(pow(t, 5.)) + vec3(.2, .1, 1.) * pow(t, .5);
}

#define quant(x,t) (floor(x/t)*t)

vec3 bg(vec2 p) {
  vec3 c = vec3(0.);
  p.y += noise(p.x/4.+.3*time);
  p.y += noise(p.x/6.3+.1*time);
  vec2 op=p;
  float h = .05;
  float ycid = floor(p.y/h);
  p.y = fract(p.y/h);
  float I=8.;
  float hh = ffts(hash(ycid));
  for (float i=0.; i<I;++i) {
    vec2 p1 = p;
    float xdiv = mix(1.4, 3., hash(ycid+i*.35));
    p1.x -= mix(.3, 1., hash(ycid+i*.88)) * quant(beat, .25);
    p1.x += hash(op.y)*.5;
    p1.x = fract(p1.x / xdiv);
    c += pal(p1.x, mix(5., 1., sat(200*hh)));
  }
  c *= mix(1., 200., hh);
  return c / I;
}

vec3 norm(vec3 p) {
  vec2 E = vec2(.001, .0);
  return normalize(vec3(
    map(p+E.xyy),
    map(p+E.yxy),
    map(p+E.yyx)
  )-map(p));
}

float raymarch(vec3 O, vec3 D, out float i, out bool hit) {
  float d = 0.;
  for (i=0.; i<64.; ++i) {
    vec3 p = O+D*d;
    float m = map(p);
    d += m;
    if(m < .001*d) {
      hit = true;
      return d;
    }
  }
  hit = false;
  return INF;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 O = vec3(0., 0., -2.), D = normalize(vec3(uv, 1.));
  vec2 rot = vec2(0.);
  rot.x += .2*sin(time)+.4*sin(.3*beatstep(beat/4., .2));
  rot.y += .3*sin(time)+.4*sin(.2*beatstep(beat/4., .3));
  O.xz *= mr(rot.x);
  D.xz *= mr(rot.x);
  O.yz *= mr(rot.y);
  D.yz *= mr(rot.y);
  
  vec3 c = vec3(0.);
  bool hit;
  float i;
  float d = raymarch(O, D, i, hit);
  vec3 n;
  if (hit) {
    vec3 p = O+D*d;
    n = norm(p);
    vec3 D1 = reflect(D, n);
    float d1;
    if(D1.z > 0) d1 = (1.-p.z)/D1.z;
    else d1 = (-2.-p.z)/D1.z;
    vec3 p1 = p+D1*d1;
    
    c += bg(p.xy) * exp(-d*1.1) * exp(-i/8.)*.6;
    c += bg(p1.xy) * dot(D1, n) * exp(-d1*2.)*3.;
  } else {
    float d1 = (1.-O.z)/D.z;
    vec3 p = O+D*d1;
    float shad = raymarch(p, vec3(0.,0.,-1.), i, hit);
    shad = step(20., shad);
    c += bg(p.xy)*shad * exp(-d1/8.);
  }

  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  if (hit) {
    vec4 pr = prev(uv + .03*n.xy);
    c += pr.rgb * pow(abs(n.z), 2.) * .9;
  }
	out_color = vec4(c, (hit?1.:0.) * d);
}