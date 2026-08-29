#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texDfox;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define INF (1./0.)
#define PI 3.14159265
#define rep(p,s) (mod(p,s)-s/2.)
#define rep2(p,s) (abs(rep(p,2.*s))-s/2.)
#define time fGlobalTime

#define mr(t) (mat2(cos(t), sin(t), -sin(t), cos(t)))

float ffti(float t) {return texture(texFFTIntegrated, t).r;}
float ffts(float t) {return texture(texFFTSmoothed, t).r;}

float box(vec3 p, vec3 s) {
  p = abs(p)-s;
  return max(p.x, max(p.y, p.z));
}

vec3 ct(vec3 p) {
  if(p.x < p.y) p.xy = p.yx;
  if(p.y < p.z) p.yz= p.zy;
  if(p.x < p.y) p.xy = p.yx;
  return p;
}

float hash(float t) {
  return fract(sin(t * 3234.12345));
}

float glow = 0.;

float map(vec3 op) {
  op.z += time + 20.*ffti(.07);
  float m = INF;
  vec3 p = op;
  p = 2.-abs(p);
  
  float off = 0.;
  vec3 p1 = p;
  for(float i=0.; i<1.; ++i) {
    p1 += vec3(hash(i), hash(i+.17), hash(i+.21));
    off += hash(dot(vec3(.17, .21, .92), floor(p1/6.)));
    p1 *= 2.;
  }
  m = min(m, max(p.x, p.y) + 1. + off);
  
  p = op;
  float wires = INF;
  float t = time / 4.;
  t = floor(t) + smoothstep(.8, 1., fract(t));
  for(float i = 0.; i<3.;++i) {
    p.xz *= mr(.22);
    p.yz *= mr(.28);
    p = rep2(p, vec3(130.) / exp2(i));
    p.xz *= mr(.3);
    p.yz *= mr(.13);
    if(i == 2.) p.xz *= mr(t * .1);
    p = abs(p)-1.2;
    p = ct(abs(p));
    wires = min(wires, length(p.yz)-.1);
    
    vec3 p1 = p;
    p1.x = rep2(p1.x + time, 12.);
    p1 = abs(p1)-.2;
    p1.yz *= mr(3.*p1.x);
    float m1 = max(abs(p1.s)-2, length(p1.yz)-.01);
    wires = min(wires, m1);
    glow += .01 / abs(m1+.003);
  }
  m = max(m, -wires+.3);
  m = min(m, wires);
  
  p = op;
  float zdiv = 8.;
  float cz = floor(p.z/zdiv);
  p.z = rep(p.z, zdiv);
  float ang = hash(cz) * 2*PI + time * (hash(cz+.111)*2.-1.);
  p.xy -= 3.*vec2(cos(ang), sin(ang));
  p1 = p;
  float figure = INF;
  p.xz *= mr(3.*time * mix(.3, .9, hash(cz+.1344)));
  p.yz *= mr(3.*time * mix(.3, .9, hash(cz+.37887)));
  if(hash(cz + .911) < .5) {
    figure = box(p, vec3(.5));
  } else {
    p = abs(p);
    figure = dot(p, normalize(vec3(1.))) - .4;
  }
  float h = hash(cz+1.221);
  float pawah = min(1., ffts(h)*90.);
  glow += mix(.001, .003, pawah) / abs(figure-mix(.01, .3, pawah));
  m = min(m, figure);
  
  return m;
}

vec3 normal(vec3 p) {
  vec2 E = vec2(0., .001);
  return normalize(
    vec3(map(p+E.yxx), map(p+E.xyx), map(p+E.xxy)) - map(p));
}

vec3 bg(vec3 n) {
  vec2 uv = vec2(atan(n.x, n.z), atan(n.x, n.y));
  return 1.*vec3(.5, .7, 1.);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv1 = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 c = vec3(0.);
  vec3 O = vec3(0.,0.,-3.), D = normalize(vec3(uv, 1.));
  D.xz *= mr(.3);
  D.yz *= mr(.1);
  D.xy *= mr(time*.3 + .1*ffti(.09));
  float d = 0., i;
  vec3 p;
  bool hit = false;
  for(i=0.; i<64.;++i) {
    p = O+D*d;
    float m = map(p);
    d += m;
    if(m < .001 * d) {
      hit = true;
      break;
    }
  }
  if(hit) {
    vec3 n = normal(p);
    vec3 col = vec3(1.);
    vec3 bg = bg(D);
    vec3 expVec = vec3(1., 1.3, 1.3);
    vec3 cc = mix(bg, col, dot(n, vec3(0.,0.,-1.)) * exp(-d*expVec*.1));
    cc += col * max(0., dot(abs(D), n)) * exp(-d*expVec*.1);
    c += cc;
    c = mix(c, vec3(0.), glow * exp(-d*.04));
  } else {
    c= bg(D);
  }
  
  vec2 e = vec2(.003 + .003 * (sin(time)*.5+.5), .0);
  vec3 prev = vec3(
    texture(texPreviousFrame, uv1-e).r,
    texture(texPreviousFrame, uv1).g,
    texture(texPreviousFrame, uv1+e).b
  );
  
  float mad = 1.2*mix(.2, .1, sin(time)*.5+.5);
  c -= .04/(smoothstep(.2, .0, prev)+mad);
  c += .2 * smoothstep(.5, 1., prev);
  c = max(c, vec3(0.));
  
	out_color = vec4(c, 1.);
}






