#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D blueNoise;
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texCookie;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;

#define PI 3.141592653589793
#define EPS .001
#define MAXDIST 10.

#define sat(x) clamp(x, 0, 1)
#define rot(a) mat2(cos(a + vec4(0, 33, 11, 0)))
#define pos(x) ((x) * .5 + .5)
#define fft(f) texture(texFFT, f).x
#define ffti(f) texture(texFFTIntegrated, f).x
#define noise(uv) texture(texNoise, uv).x
#define min2(a, b) (a.x < b.x ? a : b)

vec3 cosinePalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(PI * 2 * (c * t + d));
}

vec3 rainbow(float t) {
  return cosinePalette(t, vec3(.5), vec3(.5), vec3(1.), vec3(0., .33, .67));
}


float sdCube(vec3 p, vec3 s, float r) {
  vec3 q = abs(p) - s + r;
  return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0) - r;
}

float sdCylinder(vec3 p, vec3 s) {
  return length(p.xz - s.xy) - s.z;
}

vec2 sdScene(vec3 p) {
  
  p.xy *= rot(-sin(time));
  float s = mix(.5, 1.2, pos(sin(time + ffti(.02))));
  p = asin(sin(p * s))/s;
  
  vec2 di = vec2(MAXDIST, -1);
  p.xz *= rot(1.5 * time + 1. * ffti(.02));
  p.xy *= rot(time + 1. * ffti(.05));
  p.yz *= rot(.8 * time + ffti(.5));
  float cube = sdCube(p, vec3(1), .2);
  cube -= .02 * texture(texRevision, pos(p.xy)).x;
  cube -= .02 * texture(texLynn, pos(p.xz)).x;
  cube -= .02 * texture(texAcorn1, pos(p.yz)).x;
  di = min2(di, vec2(cube, 1));
  
  p.yz *= rot(PI/2);
  float whip1 = sdCylinder(p, vec3(0, 0, .1));
  di = min2(di, vec2(whip1, 2));
  
  return di;
}

vec3 glow;
vec2 march(vec2 uv, vec3 ro, vec3 rd, float n) {
  vec3 p = ro;
  float td = 0;
  
  glow = vec3(0);
  float dith = mix(.9, 1.2, noise(1. * uv + time));
  for (float i = 0; i < n && td < MAXDIST; i++) {
    vec2 di = sdScene(p);
    di.x *= dith;
    if (di.x < EPS)
      return vec2(td, di.y);
    if (di.y == 2)
      glow += rainbow(time + ffti(.2)) * noise(5. * p.yz) * (.5 * fft(.02) + 1) * 1. * smoothstep(0, 1, (.1 + .3 * fft(.01))/di.x);
    p += di.x * rd;
    td += di.x;
  }
  
  return vec2(-1);
}

vec3 camera(vec2 uv, vec3 ro, vec3 rt) {
  vec3 f = normalize(rt - ro),
       r = cross(vec3(0, 1, 0), f),
       u = cross(f, r);
  return normalize(f + uv.x * r + uv.y * u);
}

vec3 normal(vec3 p) {
  vec2 e = EPS * vec2(1, -1);
#define q(s) s * sdScene(p + s).x
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}


vec3 iridescence(vec3 n, vec3 rd) {
  float nz = texture(texNoise, .002 * n.xy).x;
  float fresnel = 1. - dot(n, rd);
  return rainbow(fresnel + nz);
}

vec3 render(vec2 uv) {
  vec3 c = .5 * rainbow(time + ffti(.2)),
       ro = vec3(1., 1., -2.),
       rt = vec3(0),
       rd = camera(uv, ro, rt);
  
  vec2 tdi = march(uv, ro, rd, 128);
  if (tdi.x > 0) {
    vec3 p = ro + tdi.x * rd,
         n = normal(p);
    vec3 lo = ro,
         ld = normalize(lo - p);
    float diffuse = max(dot(ld, n), 0);
    float specular = pow(max(dot(normalize(ld + -rd), n), 0), 1000);
    float fresnel = pow(1 - sat(dot(rd, n)), 2);
    if (tdi.y == 1) {
      c = rainbow(time + ffti(.2)) * (.9 * diffuse + specular + .1 * fresnel);
      if (mod(floor(time + ffti(.02)), 2) != 0)
        c += iridescence(n, rd);
    } else {
      c = rainbow(time + ffti(.2));//rainbow(tdi.x);
    }
  }

  c *= exp(-.004 * tdi.x * tdi.x * tdi.x);
  
  return c + glow;
}

void main(void) {
	vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
	uv *= rot(time);
  float pix = mix(.0, .1, pos(sin(time)));
  if (mod(floor(uv.x * 20), 10) == 0)
    uv = floor(uv/pix) * pix;
  vec3 c = render(uv);
  c = mix(c, .1 * noise(3. * uv + time).xxx, .4);
  c = mix(c, texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).xyz, .75);
  out_color = vec4(c, 1);
}