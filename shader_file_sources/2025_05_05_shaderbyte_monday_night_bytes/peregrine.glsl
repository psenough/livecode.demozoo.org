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
const float PI = acos(-1);
const float MAXDIST = 10;
const float EPSILON = .001;

#define pos(x) ((x) * .5 + .5)
#define sat(x) clamp(x, 0., 1.)
#define rot(a) mat2(cos(a + vec4(0, 33, 11, 0)))
#define noise(uv) texture(texNoise, uv).x
#define fft(f) texture(texFFT, f).x
#define ffti(f) texture(texFFTIntegrated, f).x

vec3 palette(float t) {
  vec3 a = vec3(.5), b = vec3(.5), c = vec3(2., 1., 0.), d = vec3(.5, .2, .25);
  return a + b * cos(2 * PI * (c * t + d));
}

float kifsKaliset(vec3 p, float n, float s) {
  vec4 q = vec4(p - 1, 1);
  for (float i = 0; i < n; i++) {
    q.xyz = abs(q.xyz + 1) - 1;
    q /= clamp(dot(q.xyz, q.xyz), .25, 1.);
    q *= s;
  }
  
  return (length(q.xy) - 1.5) / q.w;
}

float smoothMin(float a, float b, float k) {
  float h = sat(pos((b - a)/k));
  return mix(b, a, h) - h * (1 - h) * k;
}

float rand(float n) { return fract(sin(n) * 43758.5453123); }

float sdScene(vec3 p) {
  float d = MAXDIST;
  vec3 op = p;
  
  float balls = MAXDIST;
  for (int i = 0; i < 12; i++) {
    p = op;
    float rnd = rand(i);
    float dir = (rnd > .5) ? -1 : 1;
    p += 1. * (vec3(rand(i * 3 + .1), rand(i * 3 + 1.1), rand(i * 3 + 2.1)) - .5);
    p.x += (i + 1)/(2 * i) * sin(.3 * dir * time + i * PI + .1 * ffti(.01));
    p.y += (.2 * i)/5 * sin(.3 * i * dir * time + i * PI + .1 * ffti(.01));
    p.z += (.3 * i)/5 * sin(.4 * i * dir * time + i * PI + .1 * ffti(.01));
    p.xz *= rot(.3 * time + .05 * ffti(.01) + i * PI);
    p.xy *= rot(.3 * ffti(.1) + i * PI);
    float us = length(p) - .25;
    float ks = kifsKaliset(p, 4, mix(1.5, 2.1, pos(sin(time + i))));
    ks = max(us, ks);
    balls = smoothMin(balls, ks, .1);
  }
  
  d = min(d, balls);
  return d;
}

vec3 normal(vec3 p) {
  vec2 e = EPSILON * vec2(1, -1);
#define q(s) s * sdScene(p + s)
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}

vec3 glow;
float march(vec2 uv, vec3 ro, vec3 rd, float n) {
  float td = 0;
  vec3 p = ro;
  
  glow = vec3(0);
  float dithering = mix(.8, 1.2, noise(.05 * uv + noise(vec2(time))));
  for (float i = 0; i < n && td < MAXDIST; i++) {
    float d = sdScene(p);
    d *= dithering;
    if (d < EPSILON)
      return td;
    float glowIntensity = .075 * fft(.01) + .015;
    glow += glowIntensity * smoothstep(0., 1., (.02 + .01 * fft(.01))/d);
    p += rd * d;
    td += d;
  }
  
  return -1;
}

mat3 lookAt(vec2 uv, vec3 ro, vec3 rt) {
  vec3 f = normalize(rt - ro),
       r = cross(vec3(0, 1, 0), f),
       u = -cross(f, r);
  return mat3(f, r, u);
}

vec3 render(vec2 uv) {
  vec3 c = vec3(0);
  vec3 ro = vec3(0, 0, 1.),
       rt = vec3(0),
       rd = normalize(lookAt(uv, ro, rt) * vec3(1, uv));
  
  float d = march(uv, ro, rd, 128);
  if (d > 0) {
    vec3 p = ro + d * rd,
         n = normal(p);
    vec3 lo = ro,
         ld = normalize(lo - p);
    float fresnel = pow(1 - sat(dot(-rd, n)), 2.);
    c = palette(.8 * length(dot(-rd, n)) + .1 * time + .1 * ffti(.01)) * fresnel;
    if (fft(.01) > .35) c = 1 - c;
  }
  
  return c + glow;
}

vec3 background(vec2 uv) {
  vec3 c = vec3(0);
  
  float d = length(uv);
  d = sin(d * 8. - time - ffti(.01))/8.;
  d = abs(d);
  d = .1/d;
  c = vec3(1) * d;
  
  return c;
}

void main(void) {
	vec2 uv = vec2(2 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
  
  uv *= rot(.5 * time);
	vec3 c = vec3(0); //.001 * background(uv);
  c += 1. * render(uv);
  
  ivec2 uv0 = ivec2(gl_FragCoord.xy);
  ivec2 o = ivec2(100 * fft(.01), 100 * fft(.1));
  vec3 pc = vec3(
    texelFetch(texPreviousFrame, uv0 - o, 0).r,
    texelFetch(texPreviousFrame, uv0, 0).g,
    texelFetch(texPreviousFrame, uv0 + o, 0).b
  );
  
  c = mix(c, pc, .75);
  
	out_color = vec4(c, 1);
}