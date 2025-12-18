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

#define fft(f)    texture(texFFTSmoothed, f).x
#define min2(a,b) (a.x < b.x ? a : b)
#define pos(x)    ((x) * .5 + .5)
#define sat(x)    clamp(x, 0., 1.)

const float T = fGlobalTime;
const float EPSILON = 0.01;
const float PI = atan(1.) * 4.;
const float TAU = atan(1.) * 8.;
const float MAX_DIST = 10.;
const float SPEED = .25;

float beat = 2. * fft(0.) + .5;

mat2 rot2D(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c, -s, s, c);
}

vec3 full_rot(vec3 p, float a) {
  p.xz *= rot2D(a);
  p.yz *= rot2D(a);
  p.xy *= rot2D(a);
  return p;
}

float smooth_max(float a, float b, float k) {
  float h = sat(.5 - .5 * ((a - b) / k));
  return mix(a, b, h) - k * h * (1. - h);
}

float sdf_unit_cube(vec3 p) {
  vec3 q = abs(p) - 1. + .1;
  return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.) - .1;
}

float sdf_capsule(vec3 p, float h, float r) {
  p.y -= clamp(p.y, 0., h);
  return length(p) - r;
}

float sdf_torus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

//special dedication to NuSan, kifs master
//this specific kaliset kifs was designed by an anonymous artist
float kifs_kaliset(vec3 p, float niter, float s, float bv) {
  vec4 q = vec4(p - 1., 1.);
  
  for(float i = 0.; i < niter; i++) {
    q.xyz = abs(q.xyz + 1.) - 1.;
    q /= clamp(dot(q.xyz, q.xyz), .25, 1.);
    q *= s;
  }
  
  float ks = (length(q.xy) - 1.5) / q.w;
  return max(ks, bv);
}

vec2 de(vec3 p) {
  vec2 di = vec2(MAX_DIST, -1.);
  vec3 op = p;
  float period = mod(T * .5, 4.);
  
  //centerlightbars
  float l = 1.5 + fft(.0) - .5;
  p = full_rot(p, T * SPEED * .5);
  di = min2(di, vec2(sdf_capsule(p - vec3(-.15, -l/2., .15), l, .01), 1.));
  p = op;
  p = full_rot(p, PI/4.);
  p = full_rot(p, -T * SPEED * .5);
  di = min2(di, vec2(sdf_capsule(p - vec3(.1, -l/2., -.2), l, .01), 1.));
  
  //some rings!!
  p = op;
  p.yz *= rot2D(PI/2);
  p = full_rot(p, T * SPEED * .7);
  di = min2(di, vec2(sdf_torus(p, vec2(2.2 + beat, .0025)), 1.));
  p = op;
  p.xy *= rot2D(PI/2);
  p = full_rot(p, T * SPEED * .8);
  di = min2(di, vec2(sdf_torus(p, vec2(2.2 + beat, .0025)), 1.));
  p = op;
  p.xz *= rot2D(PI/2);
  p = full_rot(p, T * SPEED * .9);
  di = min2(di, vec2(sdf_torus(p, vec2(2.2 + beat, .0025)), 1.));
  
  //kalicubes
  float bv = sdf_unit_cube(p);
  p = op;
  bv = abs(bv) - EPSILON * 2. - beat * .025;
  p = full_rot(p, T * SPEED);
  float cube1 = kifs_kaliset(p, period + 1., pos(sin(T * SPEED + PI/2.)) + 1.3, bv);
  p = op;
  p = full_rot(p, PI/5.);
  p = full_rot(p, -T * SPEED * .66);
  float cube2 = kifs_kaliset(p, period + 1., pos(sin(T * SPEED * .9)) + 1.5, bv);
  di = min2(di, vec2(smooth_max(cube1, cube2, .1), 2.));
  return di;
}

vec3 get_normal(vec3 p) {
  vec2 e = EPSILON * vec2(1., -1.);
  return normalize(
    e.xyy * de(p + e.xyy).x +
    e.yxy * de(p + e.yxy).x +
    e.yyx * de(p + e.yyx).x +
    e.xxx * de(p + e.xxx).x
  );
}

struct Raymarch {
  vec3 p;
  vec3 n;
  float td;
  float id;
};

float glow;
Raymarch trace(vec3 ro, vec3 rd, float steps) {
  vec3 p = ro;
  vec2 di;
  float i, td = 0.;
  
  glow = 0.;
  for(i = 0.; i < steps && td < MAX_DIST; i++) {
    di = de(p);
    if(di.x < EPSILON)
      break;
    if(di.y == 1.) {
      glow += (1. - sat(di.x/(.025 * beat))) * beat;
    }
    p += di.x * rd;
    td += di.x;
  }
  
  Raymarch r;
  r.p = p;
  r.n = get_normal(p);
  if(i >= steps || td >= MAX_DIST) td = 0.;
  r.td = td;
  r.id = di.y;
  
  return r;
}

vec3 get_raydir(vec2 uv, vec3 ro, vec3 ta) {
  vec3 f = normalize(ta - ro),
       r = normalize(cross(vec3(0., 1., 0.), f)),
       u = cross(f, r);
  return normalize(f + uv.x * r + uv.y * u);
}

float lighting(vec3 p, vec3 n, vec3 lo, vec3 rd) {
  vec3 h = normalize(lo - rd);
  float ambient = sat(pos(n.y)),
        diffuse = sat(dot(lo, n)),
        specular = pow(sat(dot(h, n)), 64.);
  return ambient + diffuse + specular;
}

vec3 render(vec2 uv) {
  vec3 ro = vec3(0., 0., -3.5),
       ta = vec3(0.),
       rd = get_raydir(uv, ro, ta),
       c  = vec3(0.);
  Raymarch r = trace(ro, rd, 128.);
  
  if(r.td > 0.) { //special dedication to dok the shiny monochrome master
    if(r.id >= 2.) { //kalicubes
      c = vec3(0.) * lighting(r.p, r.n, ta, rd) + glow;
      vec3 ro_refl = r.p + r.n * EPSILON * 2.,
           rd_refl = normalize(reflect(rd, r.n));
      Raymarch refl = trace(ro_refl, rd_refl, 64.);
      if(refl.td > 0.) {
        c = vec3(1.) * lighting(refl.p, refl.n, ta, rd_refl) + glow;
      }
    } else if(r.id >= 1.) { //bars
      c = vec3(1.) + (1. + glow);
    }
  }
  
  return c + glow;
}

void main(void) {
	vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution.xy) / max(v2Resolution.x, v2Resolution.y);
  vec3 c = render(uv);
  c = pow(1. - exp(-c), vec3(1./2.2));
	out_color = vec4(c, 1.);
}