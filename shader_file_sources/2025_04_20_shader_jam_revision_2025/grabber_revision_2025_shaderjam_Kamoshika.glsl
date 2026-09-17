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
//#define fGlobalTime 5.
#define FC gl_FragCoord
#define R v2Resolution

const float PI = acos(-1.);
const float PI2 = PI * 2.;
const float BPM = 177.;
float Time;
float reTime;

void add(ivec2 p, vec3 v) {
  ivec3 q = ivec3(v * 2048.);
  imageAtomicAdd(computeTex[0], p, q.x);
  imageAtomicAdd(computeTex[1], p, q.y);
  imageAtomicAdd(computeTex[2], p, q.z);
}

vec3 read(ivec2 p) {
  return vec3(imageLoad(computeTexBack[0], p).x,
              imageLoad(computeTexBack[1], p).x,
              imageLoad(computeTexBack[2], p).x) / 2048.;
}

vec3 hash33(vec3 p) {
  const uint k = 1103515245u;
  uvec3 x = floatBitsToUint(p);
  x = ((x >> 8u) ^ x.yzx) * k;
  x = ((x >> 8u) ^ x.yzx) * k;
  x = ((x >> 8u) ^ x.yzx) * k;
  return vec3(x) / float(-1u);
}

mat2 rotate2D(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, s, -s, c);
}

mat3 camera(vec3 dir) {
  dir = normalize(dir);
  vec3 u = abs(dir.y) < 0.999 ? vec3(0, 1, 0) : vec3(0, 0, 1);
  vec3 side = normalize(cross(dir, u));
  vec3 up = cross(side, dir);
  return mat3(side, up, dir);
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

ivec2 proj(vec3 p, vec3 ro, mat3 m) {
  p -= ro;
  p *= m;
  if(p.z < 0.) {
    return ivec2(-1);
  }
  float fov = 1.;
  p.xy /= p.z * fov;
  ivec2 q = ivec2((p.xy * vec2(R.y / R.x, 1) + 0.5) * R);
  
  return q;
}

ivec2 proj2(vec2 p) {
  p *= min(R.x, R.y);
  p += R.xy;
  p *= 0.5;
  return ivec2(p);
}

float triWave(float x) {
  float res = abs(fract(x) - 0.5) - 0.25;
  return res;
}

void main(void)
{
  vec3 col = vec3(0);
  
  Time = time * BPM / 60. * 0.5;
  reTime = time + triWave(Time * 0.5);
  
  vec3 ro = vec3(0, 0, 3);
  //ro.xz *= rotate2D(reTime * 0.5);
  vec3 ta = vec3(0);
  vec3 dir = normalize(ta - ro);
  mat3 cam = camera(dir);
  
  ivec2 UV = ivec2(FC.xy);
  int ID = UV.x + UV.y * int(R.x);
  
  vec3 h1 = hash33(FC.x * vec3(1, 1.2621, 1.4121));
  vec3 init = h1 * 2. - 1.;
  
  vec3 h2 = hash33(ID * vec3(1, 1.1621, 1.3834));
  
  int n = 10;
  for(int i = 0; i < n; i++) {
    float f = float(i) / float(n);
    float T = reTime + f * 0.1;
    float sp = 0.3;
    vec3 pos = cyclic(vec3(init + T * sp), 0.5, 1.5) * 2.5;
    
    ivec2 u;
    vec3 c;
    if(mod(Time, 4.) < 2. && UV.x < 200) {
      float a = FC.y / R.y * PI2;
      float r = 0.2;
      vec3 ppos = vec3(r * vec2(cos(a) , sin(a)), 0);
      vec3 v = pos + ppos;
      
      u = proj2(v.xy);
      c = h1 * vec3(0.5) - f * 0.1;
    } else if(mod(Time, 4.) >= 2. && 200 < UV.x && UV.x < 2000) {
      float size = 0.1;
      vec3 ppos = normalize(h2 - 0.5) * size;
      vec3 v = pos + ppos;
      
      u = proj(v, ro, cam);
      //c = h1 * vec3(0.5) / float(n);
      c = h1 * vec3(0.5) / float(n);
    }
    
    if(u.x > 0) {
      add(u, c);
    }
  }
  
  col += read(UV);
  col = pow(col, vec3(1. / 2.2));
  
  if(mod(Time, 2.) < 1.) {
    col = 1. - col;
  }
  
  vec2 p = FC.xy / R.xy;
  col *= 0.5 + 0.5 * pow(16. * p.x * p.y * (1. - p.x) * (1. - p.y), 0.5);
  
	out_color = vec4(col, 1.);
}