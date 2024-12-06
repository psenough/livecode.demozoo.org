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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI 3.141592653589793
#define EPSILON 0.001
#define MAX_DIST 100.
#define REPETITION 7.5

#define AMBER vec3(1., .25, 0.)
#define BLACK vec3(0.)

#define ID_FILAMENT 1
#define ID_CAP 2
#define ID_WIRE 3
#define ID_BULB 4

#define min2(a, b) (a.x < b.x ? a : b)
#define pos(x) ((x) * .5 + .5)
#define rep(p, r) (mod(p + .5 * (r), r) - .5 * (r))
#define repid(p, r) floor((p + .5 * (r))/(r))
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define sat(x) clamp(x, 0., 1.)

float time = fGlobalTime;

float hash11(float seed) {
  return fract(sin(seed * 123.456) * 123.456);
}

float _seed;
float rand(void) {
  return hash11(_seed++);
}

float sd_sphere(vec3 p, float r) {
  return length(p) - r;
}

//from iq
float sd_capsule(vec3 p, float h, float r) {
  p.y -= clamp(p.y, 0., h);
  return length(p) - r;
}

float sd_cylinder(vec3 p, float h, float r) {
  vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
  return length(max(d, 0.)) + min(max(d.x, d.y), 0.);
}

// from blackle
float sd_spring(vec3 p, float r, float h, float n) {
  vec2 base = normalize(p.xz) * r;
  vec3 pc = vec3(base.x, clamp(p.y, -h/2., h/2.), base.y);
  float d2cyl = distance(p, pc);
  float d2coil = asin(sin(p.y * n + .5 * atan(p.x, p.z))) / n;
  vec3 ps = vec3(d2cyl, d2coil, 0.);
  return sd_sphere(ps, .01);
}

// signed hashes copypasted from Lygia library
float shash21(in vec2 st) {
  return -1. + 2. * fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 shash22(in vec2 st) {
    const vec2 k = vec2(.3183099, .3678794);
    st = st * k + k.yx;
    return -1. + 2. * fract(16. * k * fract(st.x * st.y * (st.x + st.y)));
}

vec2 sd_lightbulb(vec3 p, vec2 id) {
  vec2 di = vec2(MAX_DIST, -1.);
  float rnd = shash21(id + vec2(5.));
  vec2 rnd2 = shash22(id);
  
  p.y -= 3. * rnd;
  p += .99 * vec3(rnd2.x * sin(time), 0., rnd2.y * cos(time));
  
  float radius = mix(.05, .25, abs(rnd));
  float height = 1.5;
  float coils = (2. + mod(floor(rnd2.y * 10.), 5.)) / (height / PI);
  float filament = sd_spring(p, radius, height, coils);
  di = min2(di, vec2(filament, float(ID_FILAMENT)));
  
  float cap = sd_cylinder(p - vec3(0., 1.1, 0.), .3, .3);
  di = min2(di, vec2(cap, float(ID_CAP)));
  
  float wire = sd_capsule(p - vec3(0., 1.1, 0.), MAX_DIST, .05);
  di = min2(di, vec2(wire, float(ID_WIRE)));
  
  float bulb = abs(sd_sphere(p, 1.)) - .01;
  di = min2(di, vec2(bulb, float(ID_BULB)));
  return di;
}

vec2 sd_scene(vec3 p, float hollow) {
  vec2 di = vec2(MAX_DIST, -1.);
  vec2 dr = vec2(REPETITION);
  vec2 drid = repid(p.xz, dr);
  p.xz = rep(p.xz, dr);
  for (float j = -1.; j <= 1.; j++)
    for (float i = -1.; i <= 1.; i++) {
      vec2 cell = vec2(i, j);
      vec3 pc = p;
      pc.xz -= REPETITION * cell;
      di = min2(di, sd_lightbulb(pc, drid + cell));
    }
  return vec2(di.x * hollow, di.y);
}

vec3 normal(vec3 p, float hollow) {
  vec2 e = EPSILON * vec2(1., -1.);
  return normalize(
    e.xyy * sd_scene(p + e.xyy, hollow).x +
    e.yxy * sd_scene(p + e.yxy, hollow).x +
    e.yyx * sd_scene(p + e.yyx, hollow).x +
    e.xxx * sd_scene(p + e.xxx, hollow).x
  );
}

struct Raymarching {
  bool hit;
  vec3 rd, p, n, acc;
  float td, id;
};

Raymarching march(vec3 ro, vec3 rd, float n_steps, float hollow) {
  Raymarching r;
  r.hit = false;
  r.rd = rd;
  r.p = ro;
  r.td = 0.;
  r.acc = vec3(0.);
  
  for (float i = 0.; i < n_steps && r.td < MAX_DIST; i++) {
    vec2 di = sd_scene(r.p, hollow);
    if (di.x < EPSILON) {
      r.hit = true;
      r.id = di.y;
      r.n = normal(r.p, hollow);
      break;
    }
    if (int(di.y) == ID_FILAMENT)
      r.acc += AMBER * (1. - sat(di.x/.1))
               * (pos(sin(.5 * time)) + .75)
               * texture(texFFT, 0.0).x;
    r.p += di.x * rd;
    r.td += di.x;
  }
  
  return r;
}

vec3 shade(Raymarching r) {
  vec3 lo = vec3(0.);
  vec3 ld = normalize(lo - r.p);
  
  float fresnel = sat(1. - dot(-r.rd, r.n)),
        diffuse = sat(dot(ld, r.n));
  
  // fake!
  float specular;
  for (float j = -1.; j <= 1.; j++)
    for (float i = -1.; i <= 1.; i++) {
      lo = REPETITION * vec3(i, 0., j);
      ld = normalize(lo - r.p);
      specular += pow(sat(dot(normalize(ld - r.rd), r.n)), 10000.);
    }
  
  switch (int(r.id)) {
    case ID_FILAMENT: return AMBER * (3. + r.acc);
    case ID_CAP: return AMBER * (.5 * diffuse + .5 * specular);
    case ID_WIRE: return vec3(.05) * (.5 * diffuse + .5 * specular);
    case ID_BULB: return AMBER * (.025 * fresnel + .001 * diffuse + .5 * specular);
    default: return BLACK;
  }
}

vec3 raydir(vec2 uv, vec3 ro, vec3 rt) {
  vec3 f = normalize(rt - ro),
       r = cross(vec3(0., 1., 0.), f),
       u = cross(f, r);
  return normalize(f + uv.x * r + uv.y * u);
}

vec3 offset_dof(vec3 ro, vec3 rd) {
  vec3 r = normalize(cross(vec3(0., 1., 0.), rd)),
       u = cross(rd, r);
  float k = mix(.005, .1, 2. * texture(texFFT, .2).x);
  return ro + (rand() - .5) * k * r + (rand() - .5) * k * u;
}

vec3 render(vec2 uv) {
  vec3 color = BLACK;
  vec3 ro = vec3(2. * sin(.2 * time), 0., 2. * cos(.2 * time));
  ro = offset_dof(ro, normalize(-ro));
  vec3 rd = raydir(uv, ro, vec3(0.));
  
  
  Raymarching r = march(ro, rd, 128., 1.);
  
  if (r.hit) {
    color = shade(r);
    if (int(r.id) == ID_BULB) {
      float ior = 1./1.5, hollow = -1.; // glass refractive index
      for (int i = 1; i < 5; i++) {
        ro = r.p - 2. * EPSILON * r.n;
        rd = refract(rd, r.n, ior);
        r = march(ro, rd, 64., hollow);
        if (r.hit)
          color += shade(r) / float(i);
        if (i % 4 == 2)
          color += r.acc;
        ior = 1./ior;
        hollow *= -1.;
      }
    }
  }
  
  return color;
}

void main(void) {
	vec2 uv = (2. * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
  _seed = time + texture(texNoise, uv).x;
	vec3 color = render(uv);
  color *= 1.75 - length(uv);
  color = smoothstep(0., 1., color);
  color = pow(color, vec3(1./2.2));
	out_color = vec4(color, 1.);
}