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

float T = fGlobalTime;
const vec2 UV = gl_FragCoord.xy;
const vec2 R = v2Resolution.xy;
const float PI = acos(-1);
const float TAU = 2 * acos(-1);
const float EPSILON = .001;
const float MAXDIST = 50.;

#define pos(x) ((x) * .5 + .5)
#define sat(x) clamp(x, 0., 1.)
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define ffti(f) texture(texFFTIntegrated, f).x
#define fft(f) texture(texFFT, f).x

float hash11(float seed) {
  return fract(sin(seed * 123.546) * 123.456);
}

float _seed;
float rand() {
  return hash11(_seed++);
}

float sdCube(vec3 p, float s) {
  vec3 q = abs(p) - s;
  return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0);
}

void ballFold(inout vec3 v, inout float dv) {
  float r2 = dot(v, v);
  if (r2 < .5) {
    v *= 2;
    dv *= 2;
  } else if (r2 < 1.) {
    v *= 1/r2;
    dv *= 1/r2;
  }
}

void boxFold(inout vec3 v) {
  v = clamp(v, -1, 1) * 2 - v;
}

float sdMandelbox(vec3 p) {
  const float s = mix(2., 3.5, pos(sin(.1 * T + .1 * ffti(.01))));
  vec3 offset = p;
  float dr = 1;
  float n = mod(.5 * T, 7) + 5;
  for (float i = 0; i < n; i++) {
    boxFold(p);
    ballFold(p, dr);
    p = s * p + offset;
    dr = dr * abs(s) + 1;
  }
  
  return length(p)/abs(dr);
}

float camDist = 1.5;
float sdScene(vec3 p) {
  float d = MAXDIST;
  vec3 op = p;
  p += camDist;
  float s = length(p) - 2.25;
  
  p = op;
  p.xz *= rot(.1 * T + .1 * ffti(.01));
  p.xy *= rot(.3 * T + .1 * ffti(.2));
  p.xz = asin(sin(p.xz * 1.5));
  float cube = sdMandelbox(p * 2.5);
  d = min(d, cube);
  d = max(d, -s);
  return d;
}

float march(vec3 ro, vec3 rd, int n) {
  float td = 0;
  vec3 p = ro;
  
  for (int i = 0; i < n && td < MAXDIST; i++) {
    float d = sdScene(p);
    if (d < EPSILON)
      return td;
    p += rd * d;
    td += d;
  }
  
  return -1;
}

vec3 normal(vec3 p) {
  vec2 e = EPSILON * vec2(1, -1);
#define q(s) s * sdScene(p + s)
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}

mat3 lookAt(vec2 uv, vec3 ro, vec3 rt) {
  vec3 f = normalize(rt - ro),
       r = cross(vec3(0, 1, 0), f),
       u = cross(f, r);
  return mat3(r, u, f);
}

vec3 offset_dof(vec3 ro, vec3 rd) {
  vec3 r = normalize(cross(vec3(0, 1, 0), rd)),
       u = cross(rd, r);
  float factor = .015;
  return ro + (rand() - .5) * factor * r + (rand() - .5) * factor * u;
}

vec3 render(vec2 uv) {
  vec3 c = vec3(0),
       ro = camDist * vec3(0, 0, -1.),
       rt = vec3(0);
  ro = offset_dof(ro, normalize(rt - ro));
  vec3 rd = normalize(lookAt(uv, ro, rt) * vec3(uv, 1));
  float td = march(ro, rd, 128);
  if (td > 0) {
    vec3 p = ro + td * rd,
         n = normal(p);
    float fresnel = pow(1 - sat(dot(-rd, n)), 1);
    c = vec3(1) * fresnel;
  }
  
  c = mix(c, vec3(0), 1 - exp(.0005 * td));
  if (fract(T * .5 + ffti(.01)) > .95) c = 1 - c;
  return c;
}

void main(void) {
	vec2 uv = (2 * UV - R) / min(R.x, R.y);
  _seed = T + texture(texNoise, uv).x;
  vec3 c = render(uv);
  
  vec2 offset = vec2(.03) * rot(floor(fft(.01)));
  vec3 chroma = vec3(
    textureLod(texPreviousFrame, UV/R + offset, 0.).r,
    textureLod(texPreviousFrame, UV/R, 0.).g,
    textureLod(texPreviousFrame, UV/R - offset, 0.).b
  );
  c = mix(c, chroma, .5 * fft(.01) + .5);
  
	out_color = vec4(c, 1);
}