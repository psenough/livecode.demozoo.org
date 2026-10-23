#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCookie;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t = fGlobalTime;

#define PI  3.1415926535897932384626
#define TAU (2. * PI)
#define PHI 1.6180339887498948482045
#define EPSILON 0.01

#define fft(f) texture(texFFT, f).x
#define max2(a, b) (a.x > b.x ? a : b)
#define min2(a, b) (a.x < b.x ? a : b)
#define pos(x) ((x) * .5 + .5)
#define rep(p, r) mod((p) + .5 * (r), r) - .5 * (r)
#define repid(p, r) floor(((p) + .5 * (r))/(r))
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define sat(x) clamp(x, 0., 1.)

#define TR_MAX_STEPS   128
#define TR_MAX_DIST    50.
#define GLOW_RADIUS    .4
#define GLOW_INTENSITY .1
#define COLORBG        vec3(0.)
#define COLOR01        rainbow(.3 * t)
#define COLOR02        rainbow(.3 * t + .33)


float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 234.34));
  p += dot(p, p + 23.43);
  return fract(p.x * p.y);
}

vec3 cos_palette(vec3 a, vec3 b, vec3 c, vec3 d, float x) {
  return a + b * cos(TAU * (c * x + d));
}

vec3 rainbow(float x) {
  return cos_palette(vec3(.5), vec3(.5), vec3(1.), vec3(0., .33, .67), x);
}

float sdf_gyroid(vec3 p) {
  float seq = mod(floor(t - length(p) - 2. * fft(0.).x ), 4.);
  float scale = seq + 4.;
  p *= scale;
  p.xy *= rot(t + seq * PI/2.);
  p.yz *= rot(t);
  return (abs(dot(sin(p), cos(p.zxy))))/scale;
}

float sdf_cube(vec3 p, float s) {
  vec3 q = abs(p) - s;
  return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.);
} 

float sdf_cylinder(vec3 p, vec3 c) {
  return length(p.xz - c.xy) - c.z;
}

vec2 sdf(vec3 p) {
  vec2 di = vec2(TR_MAX_DIST, -1.);
  vec3 op = p;
  
  p.yz *= rot(PI/2.);
  di = min2(di, vec2(sdf_cylinder(p, vec3(.3, .3, 0.)), 1.));
  
  p = op;
  di = min2(di, vec2(length(p) - 1., 2.));
  di = max2(di, vec2(sdf_gyroid(p), 2.));
  vec3 r = vec3(fract(t) * .5),
       rid = floor((p + r * .5)/r);
  p = mod(p + r * .5, r) - r * .5;
  p.xy *= rot(t);
  di = max2(di, -vec2(sdf_cube(p, .1 + 3. * fft(.5)), 2.));
  
  return di;
}

vec3 glow;
vec2 trace(vec3 ro, vec3 rd) {
  vec3 p = ro;
  float td = 0.;
 
  glow = vec3(0.);
  for (int i = 0; i < TR_MAX_STEPS && td < TR_MAX_DIST; i++) {
    vec2 di = sdf(p);
    if (di.x < EPSILON)
      return vec2(td, di.y);
    glow += COLOR01 * (1. - sat(di.x/GLOW_RADIUS)) * GLOW_INTENSITY;
    p += di.x * rd;
    td = distance(ro, p);
  }
  
  return vec2(-1.);
}

vec3 get_normal(vec3 p) {
  vec2 e = EPSILON * vec2(1., -1.);
  return normalize(
    e.xyy * sdf(p + e.xyy).x +
    e.yxy * sdf(p + e.yxy).x +
    e.yyx * sdf(p + e.yyx).x +
    e.xxx * sdf(p + e.xxx).x
  );
}

float diffuse(vec3 p, vec3 n, vec3 lo) {
  return max(dot(normalize(lo - p), n), 0.);
}

vec3 get_raydir(vec2 uv, vec3 ro, vec3 ta) {
  vec3 rd = normalize(ta - ro),
       r = normalize(cross(vec3(0., 1., 0.), rd)),
       u = normalize(cross(rd, r));
  return normalize(rd + r * uv.x + u * uv.y);
}

float sdCircle(vec2 uv, float r) {
  return length(uv) - r;
}

// By Marex
vec3 background(vec2 uv) {
  //vec3 col = vec3(0.5) * pos(cos(uv.x * PI));
  vec2 rotatedUV = uv * rot(t);
  vec3 c = vec3(pos(cos(t+uv.xyx+vec3(0,3,3)))) * ceil(-sdCircle(uv*rotatedUV, sin(t)/2.+.5) * sin(t)*2.);
  return c;
}

vec3 render(vec2 uv) {
  vec3 ro = vec3(0., 0., -2.),
       ta = vec3(0.),
       rd = get_raydir(uv, ro, ta),
       lo = vec3(0.),
       c = COLORBG;
  
  vec2 tdi = trace(ro, rd);
  vec3 p = ro + tdi.x * rd;
  if (tdi.x > 0.) {
    vec3 n = get_normal(p);
    if(tdi.y >= 2.)
      c = mix(COLOR01, COLOR02, pos(sin(length(p) - .5 * t))) * diffuse(p, n, lo) + glow;
    else if(tdi.y >= 1.)
      c = mix(COLOR02, COLORBG, pos(sin(t)));
  } else {
      c = background(p.xy);
  }
  return c;
}

void main(void) {
	vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution.xy) / v2Resolution.y;
	vec3 c = render(uv);
  	
	c = pow(sat(c), vec3(1./2.2)); // gamma
	out_color = vec4(c, 1.);
}