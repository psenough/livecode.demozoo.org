#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texBlueNoise;
uniform sampler2D texChecker;
uniform sampler2D texCookie;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define fft(f) texture(texFFT, f).x

const float MAXDIST = 50;
const float EPSILON = .001;
const float PI = acos(-1);
const float TAU = 2 * PI;
const float BEAT = 140/60;
float time = fGlobalTime;

vec3 erot(vec3 p, vec3 ax, float t) {
  return mix(dot(ax, p) * ax, p, cos(t)) + cross(ax, p) * sin(t);
}

mat2 rot(float angle) {
  float s = sin(angle), c = cos(angle);
  return mat2(c, -s, s, c);
}

// Totetmatt's animation, thanks!
float anim(float phase) {
  return tanh(cos(time * .1 * BEAT + phase) * 10) * PI;
}

// Again a Totetmatt function
vec3 hash33(vec3 p) {
  uvec3 q = floatBitsToUint(p) * 12345678u + 123456789u;
  q.x += q.y * q.z; q.y += q.x * q.z; q.z += q.x * q.y;
  q ^= q >> 16;
  q.x += q.y * q.z; q.y += q.x * q.z; q.z += q.x * q.y;
  return vec3(q)/float(-1u);
}

// IQ's
float sdCucube(vec3 p, float s, float t) {
  p = abs(p) - s;
  vec3 q = abs(p + t) - t;
  return min(min(
    length(max(vec3(p.x, q.y, q.z), 0)) + min(max(p.x, max(q.y, q.z)), 0),
    length(max(vec3(q.x, p.y, q.z), 0)) + min(max(p.x, max(p.y, q.z)), 0)),
    length(max(vec3(q.x, q.y, p.z), 0)) + min(max(p.x, max(q.y, p.z)), 0));
}

float sdTorus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

float sdCapsule(vec3 p, float h, float r) {
  return mix(length(p.xz) - r,
             length(vec3(p.x, abs(p.y) - h, p.z)) - r,
             step(h, abs(p.y)));
}

vec2 path(float t) {
  return vec2(.1 * sin(.1 * t), .2 * cos(.1 * t));
}

vec3 palette(float t) {
  vec3 a = vec3(.5), b = a, c = vec3(1), d = vec3(0., .67, .33);
  return a + b * cos(TAU * (c * t + d));
}

float getBand(vec3 id) {
  float rnd = hash33(id).x;
  if (rnd < .33) return 0;
  else if (rnd < .66) return 1;
  else return 2;
}

vec3 getColor(vec3 id) {
  float rnd = hash33(id).z;
  const float thres = .25;
  return rnd < thres ? palette(rnd / thres) : vec3(1);
}

#define min2(a, b) (a.x < b.x ? a : b)
vec4 map(vec3 p) {
  vec4 di = vec4(MAXDIST, vec3(MAXDIST));
  p.xy -= path(p.z);
  
  vec3 rep = vec3(5);
  vec3 id = floor((p + .5 * rep)/rep);
  vec3 rnd3 = hash33(id);
  p = mod(p + .5 * rep, rep) - .5 * rep;
  p -= 2 * (rnd3 - .5);
  
  p = erot(p, vec3(0, 0, 1), (rnd3.x > .5 ? 1 : -1) * time + anim(rnd3.x * PI/2));
  p = erot(p, vec3(0, 1, 0), (rnd3.y > .5 ? 1 : -1) * time + anim(PI/3));
  p = erot(p, vec3(1, 0, 0), (rnd3.z > .5 ? 1 : -1) * time + anim(PI/5));
  
  float band = getBand(id);
  float shape = MAXDIST;
  if (band == 0)
    shape = sdCucube(p, .5, .02);
  else if (band == 1)
    shape = sdTorus(p, vec2(.5, .05));
  else
    shape = sdCapsule(p, .25, .1);
  
  di = min2(di, vec4(shape, id));
  di.x *= .9;
  return di;
}

struct Raymarch {
  bool hit;
  vec4 di;
  vec3 p, n, acc;
  float i, td;
};

Raymarch march(vec2 uv, vec3 ro, vec3 rd) {
  Raymarch r;
  r.hit = false;
  r.p = ro;
  r.acc = vec3(0);
  r.td = 0;
  
  // NuSan's method to hide artifacts: ADD NOISE!!!
  float dither = mix(.8, 1.1, hash33(vec3(uv, time)).x);
  for (r.i = 0; r.i < 128; r.i++) {
    r.di = map(r.p);
    r.di.x *= dither;
    if (r.di.x < EPSILON) {
      r.hit = true;
      return r;
    }
    if (r.td > MAXDIST) break;
    float band = getBand(r.di.yzw);
    if (band == 0) band = fft(.01);
    else if (band == 1) band = 3 * fft(.1);
    else band = 15 * fft(.3);
    float intensity = mix(0, 1, 2 * pow(band, 3));
    vec3 hue = getColor(r.di.yzw);
    if (hue != vec3(1))
      r.acc += hue * intensity * (1 - smoothstep(0, 1, r.di.x/.4));
    r.p += r.di.x * rd;
    r.td += r.di.x;
  }
  
  return r;
}

vec3 lookAt(vec2 uv, vec3 ro, vec3 target) {
  vec3 f = normalize(target - ro),
       r = cross(vec3(0, 1, 0), f),
       u = cross(f, r);
  return normalize(f + uv.x * r + uv.y * u);
}

vec3 normal(vec3 p) {
  vec2 e = vec2(1, -1) * EPSILON;
#define q(s) s * map(p + s).x
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}

vec3 render(vec2 uv) {
  vec3 c = vec3(0);
  vec3 ro = vec3(2.5, 2.5, 10 * time);
  ro.xy += path(ro.z);
  vec3 target = ro + vec3(0, 0, 1);
  target.xy += path(target.z);
  vec3 rd = lookAt(uv, ro, target);
  rd = erot(rd, vec3(0, 0, 1), anim(0));
  Raymarch r = march(uv, ro, rd);
  if (r.hit) {
    r.n = normal(r.p);
    float fresnel = pow(1 - clamp(dot(-rd, r.n), 0, 1), 2);
    c = getColor(r.di.yzw) * fresnel;
  }
  
  return c + r.acc;
}

float sdGyroid(vec3 p) {
  return dot(sin(p), cos(p.yzx));
}

// from Leon's love for gyroid fbms
float fbm(vec3 p, float n) {
  float r = 0, a = .5;
  for (int i = 0; i < n; i++) {
    p.z += r * .5;
    r += abs(sdGyroid(p/a)) * a;
    a *= .5;
  }
  return r;
}

void main(void) {
	vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
#define ffts(f) texture(texFFTSmoothed, f).x
  uv = mix(uv, .35 * vec2(ffts(.01) * fbm(vec3(.1 * time, uv), 3),
                         2 * ffts(.4) * fbm(vec3(uv.x, .2 * time, uv.y), 3)), length(.25 * uv));
  uv = mix(uv * rot(sin(.15 * time)), .1 * hash33(vec3(uv, time)).xy, length(.15 * uv));
  vec3 c = render(uv);
  c = mix(c, texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).rgb, .4);
	out_color = vec4(c, 1);
}