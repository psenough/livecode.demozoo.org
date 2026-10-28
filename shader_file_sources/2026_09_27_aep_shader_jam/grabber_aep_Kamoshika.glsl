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

#define time fGlobalTime
#define FC gl_FragCoord
#define R v2Resolution

const float PI = acos(-1.);
const float PI2 = PI * 2.;
const float numSamples = 10.;
const float BPM = 132.;

float seed;
float Time;

float hash(float p) {
  const uint k = 1103515245u;
  uint x = floatBitsToUint(p);
  x = ((x >> 8u) ^ x) * k;
  x = ((x >> 8u) ^ x) * k;
  x = ((x >> 8u) ^ x) * k;
  return float(x) / float(0xFFFFFFFFu);
}

float random() {
  return hash(seed++);
}

vec2 hash_disc() {
  float r = sqrt(random());
  float a = random() * PI2;
  return vec2(cos(a), sin(a)) * r;
}

void add(ivec2 p, vec3 v) {
  ivec3 q = ivec3(v * 2048.);
  imageAtomicAdd(computeTex[0], p, q.x);
  imageAtomicAdd(computeTex[1], p, q.y);
  imageAtomicAdd(computeTex[2], p, q.z);
}

vec3 read(ivec2 p) {
  return  vec3(imageLoad(computeTexBack[0], p).x,
               imageLoad(computeTexBack[1], p).x,
               imageLoad(computeTexBack[2], p).x) / 2048.;
}

mat3 camera(vec3 dir) {
  dir = normalize(dir);
  vec3 u = abs(dir.y) < 0.999 ? vec3(0, 1, 0) : vec3(0, 0, 1);
  vec3 side = normalize(cross(dir, u));
  vec3 up = cross(side, dir);
  return mat3(side, up, dir);
}

vec3 rayDir(vec2 uv, vec3 dir, float fov) {
  mat3 cam = camera(dir);
  vec3 res = vec3(uv, 1. / tan(fov / 360. * PI));
  return normalize(res * cam);
}

ivec2 proj(vec3 p, vec3 ro, mat3 camera, float fov, float dofFocus, float dofAmount) {
  p -= ro;
  p *= camera;
  if(p.z < 0.) {
    return ivec2(-1);
  }
  p.xy /= p.z * tan(fov / 360. * PI);
  
  p.xy += hash_disc() * abs(p.z - dofFocus) * dofAmount;
  
  ivec2 q = ivec2((p.xy * vec2(R.y / R.x, 1) * 0.5 + 0.5) * R);
  return q;
}

vec3 cyclic(vec3 p, float pers, float lacu) {
  vec4 sum = vec4(0);
  mat3 rot = camera(vec3(3, 1, -2));
  for(int i = 0; i < 5; i++) {
    p *= rot;
    p += sin(p.zxy);
    sum += vec4(cross(cos(p), sin(p.yzx)), 1.);
    sum /= pers;
    p *= lacu;
  }
  return sum.xyz / sum.w;
}

vec3 particle(vec3 p) {
  float pers = 0.5;
  float lacu = 1.5;
  vec3 res = cyclic(p, pers, lacu);
  
  return res * 0.03;
}

float check(vec2 uv) {
  vec2 p = fract(uv) - 0.5;
  return float(p.x * p.y > 0.);
}

mat2 rotate2D(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, s, -s, c);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * 0.5;
  vec3 col = vec3(0);
  Time = time * BPM / 60. * 0.5;
  
  float sampleSeed = hash(fract(time * 0.1) + hash(FC.x + hash(FC.y)));
  
  vec3 ro = vec3(0, 0, 0.05);
  ro.xz *= rotate2D(time * 1.);
  
  vec3 ta = vec3(0, 0, 0);
  vec3 dir = normalize(ta - ro);
  float fov = 60.;
  float amp = pow(sin(fract(Time * 2.) * PI2) * 0.5 + 0.5, 4.);
  fov -= amp * 10.;
  mat3 cam = camera(dir);
  vec3 rd = rayDir(uv, dir, fov);
  float dofFocus = length(ta - ro);
  float dofAmount = 3.;
  float h = hash(floor(Time));
  
  for(float i = 0.; i < numSamples; i++) {
    vec3 pos = vec3(0);
    seed = sampleSeed + i;
    vec3 pp = particle(vec3(random() * 0.05, random() * 100. * fract(Time), h * 500.));
    
    pos += pp;
    ivec2 u = proj(pos, ro, cam, fov, dofFocus, dofAmount);
    add(u, vec3(1) * 0.1);
  }
  
  vec2 dis = uv * R.x * 0.05;
  dis *= amp;
  vec2 u = abs(FC.xy / R - 0.5);
  dis *= smoothstep(0.5, 0.43, max(u.x, u.y));
  
  col.r += read(ivec2(FC.xy + dis)).r;
  col.g += read(ivec2(FC.xy)).g;
  col.b += read(ivec2(FC.xy - dis)).b;
  col /= numSamples;
  
  col = pow(col, vec3(1. / 2.2));
  
  if(mod(Time, 2.) < 1.) {
    col = 0.5 - col;
  }
  
  /*
  Time = time * BPM / 60. * 0.5;
  float amp = pow(sin(fract(Time * 2.) * PI2) * 0.5 + 0.5, 4.);
  
  uv *= 1. - amp * 0.05;
  uv += time * 0.3;
  
  vec2 dis = cyclic(vec3(uv, time * 2.), 0.5, 1.5).xy;
  dis *= amp * 0.1;
  
  col.r += check(uv + dis);
  col.g += check(uv);
  col.b += check(uv - dis);
  */
	out_color = vec4(col, 1.);
}