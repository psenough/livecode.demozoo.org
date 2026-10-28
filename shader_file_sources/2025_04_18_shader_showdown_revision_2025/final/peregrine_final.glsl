#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// today, i'll take inspiration from nusan's great shaders
// she rocks!!

#define eps .001
#define maxdist 10.

#define fft(f) texture(texFFT, f).x
#define ffti(f) texture(texFFTIntegrated, f).x
#define sat(x) clamp(x, 0, 1)
#define pos(x) ((x) * .5 + .5)
#define rot(a) mat2(cos(a + vec4(0, 33, 11, 0)))

float time = fGlobalTime;

float kifsKaliset(vec3 p, float n, float s, float bv) {
  vec4 q = vec4(p - 1, 1);
  for(int i = 0; i < n; i++) {
    q.xyz = abs(q.xyz + 1) - 1;
    q /= clamp(dot(q.xyz, q.xyz), .25, 1.);
    q *= s;
  }
  
  float ks = (length(q.xy) - 1.5)/q.w;
  return max(ks, bv);
}
  
float sdCube(vec3 p, vec3 s, float r) {
  vec3 q = abs(p) - s + r;
  return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0) - r;
}
  
float si(float a, float b, float k) {
  float h = sat(.5 - .5 * (b - a)/k);
  return mix(b, a, h) + h * (1 - h) * k;
}

float sd(vec3 p) {
  float d = maxdist;
  vec3 p1 = p - vec3(.1);
  p1.xz *= rot(time + .3 * ffti(.02));
  p1.yz *= rot(time  + .3 * ffti(.02));
  p1.xy *= rot(time + .3 * ffti(.02));
  float cube1 = kifsKaliset(p1, mod(time, 5) + 2, pos(sin(time + .1 * ffti(.02))) + 1.1, sdCube(p1, vec3(1), .1));
  
  vec3 p2 = p + vec3(.1);
  p2.xz *= rot(-.78 * time);
  p2.yz *= rot(.5 * time);
  p2.xy *= rot(-.2 * time);
  float cube2  = kifsKaliset(p2, mod(time, 5) + 2, pos(sin(time + .1 * ffti(.02))) + 1.2, sdCube(p2, vec3(1.1), .1));;
  
  float cubes = si(cube1, cube2, .1);
  
  d = min(d, cubes);
  return d;
}

vec3 glow;
float march(vec2 uv, vec3 ro, vec3 rd, float n) {
  vec3 p = ro;
  float td = 0;
  glow = vec3(0);
  float dith = mix(.9, 1.9, texture(texNoise, uv + time).x);
  for (int i = 0; i < n && td < maxdist; i++) {
    float d = sd(p);
    d *= dith;
    if (d < eps)
      return td;
    glow += 1. * (1 + .1 * fft(.01)) * smoothstep(0., 1., (.02 * .01 * fft(.02))/d);
    p+=rd * d;
    td+=d;
  }
  return -1;
}

vec3 normal(vec3 p) {
  vec2 e = vec2(1, -1) * eps;
#define q(s) s * sd(p + s)
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxy));
}

vec3 render(vec2 uv) {
  vec3 c = vec3(0),
       ro = vec3(0, 0, -2),
       rd = normalize(vec3(uv, 1));
  
  float d = march(uv, ro, rd, 128);
  if (d > 0) {
    vec3 p = ro + d * rd;
    vec3 n = normal(p);
    vec3 lo = ro;
    vec3 ld = normalize(lo - p);
    float fresnel = pow(1 - sat(dot(-rd, n)), 2);
    float specular = pow(max(0, dot(-rd, ld)), 1000);
    c = vec3(1) * (.1  + fresnel + specular);
  }

  return c + glow;
}
  
void main(void)
{
	vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
	// z0rg school of shaders
  vec2 o = .1 * vec2(fft(.04), fft(.01));
  vec3 c;
  c.r = render(uv + o).r;
  c.g = render(uv).g;
  c.b = render(uv - o).b;
  c = mix(c, texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).xyz, .85);
  out_color = vec4(c, 1);
}