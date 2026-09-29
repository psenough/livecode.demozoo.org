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

#define PI       3.14159265358979
#define TAU      (2 * PI)
#define EPSILON  .01
#define MAX_DIST 50.

#define FFT(f) texture(texFFTSmoothed, f).x
#define pos(x) ((x) * .5 + .5)
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define sat(x) clamp(x, 0., 1.)

float t = fGlobalTime;

vec3 cos_palette(vec3 a, vec3 b, vec3 c, vec3 d, float x) {
  return a + b * cos(TAU * (c * x + d));
}

vec3 palette(float x) {
  return cos_palette(vec3(pos(sin(t - PI/2)) * .5 + .5), 
                     vec3(pos(sin(t)) * .5 + .5), 
                     vec3(1., 1., .5),
                     vec3(.8, .9, .3), x);
}

vec2 path(float x) {
  return vec2(2 * sin(.2 * x), 2 * cos(.15 * x));
}

float sdf_gyroid(vec3 p, float scale) {
  return dot(scale * sin(p), scale * cos(p.yzx));
}

float sdf(vec3 p) {
  float d = MAX_DIST;
  p.xy -= path(p.z);
  p.xy *= rot(.1 * t);
  
  float period = mod(t/2, 4.);
  float scale;
  if (period >= 3.)
    scale = pos(sin(.4 * t)) * .1 + .1;
  else if (period >= 2.)
    scale = pos(sin(.4 * t)) * .3 + .5;
  else if (period >= 1.)
    scale = pos(sin(.4 * t)) * .5 + .9 + .1 * pos(sin(t));
  else
    scale = pos(sin(.4 * t)) * .3 + .5;
  
  
  float tunnel = length(p.xy) - 3.;
  tunnel += sin(.8 * p.x) * sin(.9 * p.y) * sin(.8 * p.z) * .1;
  float gyr = sdf_gyroid(p, scale);
  gyr = abs(gyr) - pos(sin(.5 * t)) * .2 - 1.1 * FFT(.01);
  gyr = max(gyr, -tunnel);
  d = min(d, gyr);
  
  return d;
}

vec3 acc;
float trace(vec3 ro, vec3 rd, int steps) {
  vec3 p = ro;
  float td = 0.;
  
  acc = vec3(0.);
  for (int i = 0; i < steps && td < MAX_DIST; i++) {
    float d = sdf(p);
    if (d < EPSILON)
      return td;
    acc += .08 * palette(p.z) * sat(p.y) * texture(texNoise, p.xz * .5 + t * .1).x;
    p += d * rd;
    td = distance(ro, p);
  }
  
  return -1.;
}

vec3 get_normal(vec3 p) {
  vec2 e = EPSILON * vec2(-1, 1);
  return normalize(
    e.xyy * sdf(p + e.xyy) +
    e.yxy * sdf(p + e.yxy) +
    e.yyx * sdf(p + e.yyx) +
    e.xxx * sdf(p + e.xxx)
  );
}

float diffuse(vec3 p, vec3 n, vec3 lo) {
  return max(0., dot(normalize(lo - p), n));
}

float specular(vec3 rd, vec3 n, vec3 lo) {
  return pow(max(0., dot(normalize(rd + lo), n)), 128);
}

vec3 get_camera(vec2 uv, vec3 ro, vec3 ta) {
  vec3 f = normalize(ta - ro),
       r = normalize(cross(vec3(0, 1, 0), f)),
       u = cross(r, f);
  return normalize(f + uv.x * r + uv.y * u);
}

vec3 render(vec2 uv) {
  vec3 ro = vec3(1, 1, 4. * t),
       ta = ro + vec3(0, 0, 1);
  ro.xy += path(ro.z);
  ta.xy += path(ta.z);
  vec3 rd = get_camera(uv, ro, ta);
  vec2 swivel = path(ta.z);
  rd.xy *= rot(swivel.x/32);
  rd.yz *= rot(swivel.y/16);
  vec3 lo = ta,
       c = vec3(0);
  
  float td = trace(ro, rd, 128);
  float depth = MAX_DIST;
  vec3 acc_col = acc;
  if (td > 0.) {
    depth = td;
    vec3 p = ro + rd * td,
         n = get_normal(p);
    c = palette(p.z * .1) * (diffuse(p, n, lo) + specular(rd, n, lo));
    vec3 ro_refl = p + 2. * EPSILON * n,
         rd_refl = normalize(reflect(rd, n));
    float td_refl = trace(ro_refl, rd_refl, 64);
    if (td_refl > 0.) {
      vec3 p_refl = ro_refl + rd_refl * td_refl,
           n_refl = get_normal(p_refl);
      c += palette(p_refl.z * .1) * 
           (diffuse(p_refl, n_refl, lo) + specular(rd_refl, n_refl, lo));
    }
  }
  
  c += acc_col * .5;
  vec3 fog_col = palette(rd.y);
  c = mix(fog_col, c, 1. - exp(-depth * 8.));
  return sat(c + acc_col);
}

void main(void) {
	vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
	vec3 c = render(uv);
	out_color = vec4(c, 1.);
}