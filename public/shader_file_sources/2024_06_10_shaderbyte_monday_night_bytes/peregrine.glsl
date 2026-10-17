#version 420 core

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t = fGlobalTime;

#define EPSILON 0.01
#define PI      3.141592653589793238

#define TR_MAX_DIST  120.
#define TR_MAX_STEPS 128

#define CELL_SIZE 5.

#define min2(a, b) (a.x < b.x ? a : b)
#define pos(x) ((x) * .5 + .5)
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define sat(x) clamp(x, 0., 1.)

vec2 hash22(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .973));
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.xx + p3.yz) * p3.zy);
}

float sdf_sphere(vec3 p, float r) {
  return length(p) - r;
}

float sdf_rounded_cube(vec3 p, float s, float r) {
  vec3 q = abs(p) - s + r;
  return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.) - r;
}

float sdf_bar(vec3 p, vec3 c) {
  return length(p.xz - c.xy) - c.z;
}

// iq to help!
float sdf_capped_cylinder( vec3 p, float h, float r )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec2 sdf(vec3 p) {
  vec2 di = vec2(TR_MAX_DIST, -1.);
  
  vec3 op = p;
  vec3 cell = vec3(8.),
       cell_id = floor((p + cell * .5)/cell);
  p = mod(p + cell * .5, cell) - cell * .5;
  
  p.xy *= rot(t);
  p.xz *= rot(t);
  p.yz *= rot(t);
  
  float bump = 5.;
  p.xz += sin(3. * p.y + t * .4) * .1;
  p.yz += sin(4. * p.x + t * .3) * .1;
  p.xy += sin(5. * p.z + t * .5) * .1;
  float cx = sdf_capped_cylinder(p, 1. + bump * texture(texFFTSmoothed, .01).x, .1);
  p.xy *= rot(PI/2.);
  
  float cy = sdf_capped_cylinder(p, 1. + bump * texture(texFFTSmoothed, .5).x, .1);
  p.yz *= rot(PI/2.);
  float cz = sdf_capped_cylinder(p, 1. + bump * texture(texFFTSmoothed, .99).x, .1);
  
  di = min2(di, vec2(cx, 1.));
  di = min2(di, vec2(cy, 1.));
  di = min2(di, vec2(cz, 1.));
    
  return di;
}

vec2 trace(vec3 ro, vec3 rd) {
  vec3 p = ro;
  vec2 di;
  float td = 0.;
  
  for (float i = 0.; i < TR_MAX_STEPS && td < TR_MAX_DIST; i = i + 1.) {
    di = sdf(p);
    if (di.x < EPSILON) {
      return vec2(td, di.y);
    }
    p += di.x * rd;
    td = distance(ro, p);
  }
  
  return vec2(-1);
}

vec3 get_normal(vec3 p) {
  vec2 e = EPSILON * vec2(1., -1);
  return normalize(
    e.xyy * sdf(p + e.xyy).x +
    e.yxy * sdf(p + e.yxy).x +
    e.yyx * sdf(p + e.yyx).x +
    e.xxx * sdf(p + e.xxx).x
  );
}

vec3 get_raydir(vec2 uv, vec3 ro, vec3 ta) {
  vec3 rd = normalize(ta - ro),
       r = normalize(cross(rd, vec3(0., 1., 0.))),
       u = normalize(cross(rd, r));
  return normalize(rd - r * uv.x - u * uv.y);
}

float diffuse(vec3 p, vec3 n, vec3 lo) {
  return max(0., dot(normalize(lo - p), n));
}

float specular(vec3 rd, vec3 n, vec3 lo) {
  vec3 h = normalize(lo + rd);
  return max(0., pow(dot(h, n), 64.));
}

float path(float z) {
  return 12. * sin(z / 24.) * cos(z / 12.);
}

vec3 render(vec2 uv) {
  vec3 ro = vec3(-6.5 * cos(t/8.), 0., -6.5 * sin(t/8.)),
       ta = vec3(0., 0., 0.),
       rd = get_raydir(uv, ro, ta);
  
  vec2 tdi = trace(ro, rd);
  vec3 p = ro + tdi.x * rd;
  
  if (tdi.x > 0.) {
    vec3 n = get_normal(p),
         lo = ro;
    if (tdi.y >= 1.) {
      vec3 c = vec3(1., 0., .5) * (diffuse(p, n, lo) + specular(rd, n, lo));
      return c;
    } 
  } 
  
  return mix(vec3(.1), vec3(0.), pos(2.5 * uv.y));
}

void main(void) {
	vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution.xy) / v2Resolution.y;

	vec3 c = render(uv);
	out_color = vec4(c, 1.);
}