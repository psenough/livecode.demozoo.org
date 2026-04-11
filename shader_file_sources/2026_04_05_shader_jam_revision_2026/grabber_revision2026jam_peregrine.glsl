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
uniform sampler2D texFemmes;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// for CALLISTO / GPO who wanted a tunnel with rabbits... there won't be any rabbits sorry

#define EPSILON .001
#define MAXDIST 20
#define sat(x) clamp(x, 0, 1)
#define min2(a, b) (a.x < b.x ? a : b)
#define ffts(f) texture(texFFTSmoothed, f).x
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))

float time = fGlobalTime * 130/60;
const float PI = acos(-1);

vec2 path(float z) {
  return vec2(.9 * cos(.5 * z), .7 * sin(.6 * z));
}

// thanks Inigo Quilez
float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

vec2 sdf(vec3 p) {
  vec2 di = vec2(MAXDIST, -1);
  
  p.z += time;
  p.xy + path(p.z);
  vec3 op = p;
  
  vec3 pc = p;
  float rep = .35;
  pc.z = mod(pc.z + .5 * rep, rep) - .5 * rep;
  float cut = abs(pc.z) - .1; 
  p.xy *= rot(p.z + time);
  float t = -sdEquilateralTriangle(p.xy, 3);
  t = max(t, cut);
  t -= .009 * sin(20 * p.x);
  di = min2(di, vec2(t, 1));
  
  vec3 pt1 = op;
  pt1.xy *= rot(pt1.z + time);
  float t1 = length(pt1.xy - vec2(.5, .5)) - .025;
  di = min2(di, vec2(t1, 2));
  
  vec3 pt2 = op;
  pt2.xy *= rot(-pt2.z - time);
  float t2 = length(-pt2.xy - vec2(-.5, .6)) - .025;
  di = min2(di, vec2(t2, 3));
  
  vec3 pt3 = op;
  pt3.xy *= rot(pt3.z + time);
  float t3 = length(pt3.xy - vec2(-.4, .4)) - .025;
  di = min2(di, vec2(t3, 4));
  
  return di;
}

vec3 material(float i) {
  if (i == 1) { // tunnel
    return vec3(0);
  } else if (i == 2) { // tube 1
    return vec3(1, 0, .816);
  } else if (i == 3) { // tube 2
    return vec3(.416, 0, 1);
  } else if (i == 4) { // tube 3
    return vec3(0, .4, 1);
  } else return vec3(0);
}

vec3 acc;
vec2 trace(vec2 uv, vec3 ro, vec3 rd, float n) {
  vec3 p = ro;
  vec2 di;
  float td = 0;
  
  float dither = mix(.6, 1., 
                     texture(texNoise, vec2(cos(uv.x + time), sin(uv.y * time))).x);
  acc = vec3(0);
  for (float i = 0; i < n && td < MAXDIST; i++) {
    di = sdf(p);
    di.x *= dither;
    if (di.x < EPSILON)
      return vec2(td, di.y);
    p += rd * di.x;
    td += di.x;
    if (di.y != 1)
      acc += material(di.y) * (1 - sat(di.x / .33)) * mix(0., .15, fract(p.z + time + ffts(.1)));
  }
  
  return vec2(-1);
}

vec3 normal(vec3 p) {
  vec2 e = EPSILON * vec2(1, -1);
#define q(s) s * sdf(p + s).x
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}

vec3 camera(vec2 uv, vec3 ro, vec3 target) {
  vec3 f = -normalize(ro - target),
       r = cross(f, vec3(0, 1, 0)),
       u = cross(f, r);
  return normalize(f + uv.x * r + uv.y * u);
}

vec3 render(vec2 uv) {
  vec3 c = vec3(0);
  vec3 ro = vec3(path(-time), -3);
  vec3 rd = camera(uv, ro, vec3(0));
  vec2 tdi = trace(uv, ro, rd, 128);
  vec3 acc0 = acc;
  if (tdi.x > 0) {
    c = material(tdi.y);
    vec3 p = ro + tdi.x * rd,
         n = normal(p);
    vec3 ro_refl = p + EPSILON * n;
    vec3 rd_refl = reflect(n, rd);
    vec2 tdi_refl = trace(uv, ro_refl, rd_refl, 64);
    if (tdi_refl.x > 0) {
      c += material(tdi_refl.y);
      c += acc;
    }
  }
  
  return c + acc0;
}

void main(void) {
	vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
	vec3 c;

  if (uv.y < -.75) {
      uv.y -= .15;
      uv = mix(uv, texture(texNoise, uv).xy, mix(.2, .5, ffts(.01)));
  } else if (uv.y > .75) {
      uv.y += .15;
      uv = mix(uv, texture(texNoise, uv).xy, mix(.2, .5, ffts(.01)));
  }
    
  c = render(uv);
  c = mix(c, texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).rgb, .8);
  out_color = vec4(c, 1);
}