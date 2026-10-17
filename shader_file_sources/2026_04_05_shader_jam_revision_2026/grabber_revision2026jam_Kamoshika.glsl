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
uniform sampler2D texSessions;
uniform sampler2D texShort;
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
const float numSamples = 20.;
const float BPM = 136.;
const float cylHeight = 8.;
const float cylRadius = 8.;

float seed;
float Time;

mat2 rotate2D(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, s, -s, c);
}

float hash(float p) {
  const uint k = 1103515245U;
  uint x = floatBitsToUint(p);
  x = ((x >> 8U) ^ x) * k;
  x = ((x >> 8U) ^ x) * k;
  x = ((x >> 8U) ^ x) * k;
  return float(x) / float(0xFFFFFFFFU);
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

vec3 reinhard(vec3 col, float L) {
  return col / (1. + col) * (1. + col / (L * L));
}

float smoothSqWave(float x, float factor) {
  x -= 0.5;
  float odd = mod(floor(x), 2.);
  factor *= odd * 2. - 1.;
  float res = smoothstep(0.5 - factor, 0.5 + factor, fract(x));
  return res * 2. - 1.;
}

vec2 petal() {
  vec2 p = hash_disc();
  
  p.x *= pow(p.y + 1., 0.25) * 0.7;
  p.y *= 1. - float(p.y > 0.) * pow(max(0.4 - abs(p.x), 0.), 4.) * 16.;
  
  return p * 0.15;
}

vec3 rotPetal(vec3 p) {
  p.xy *= rotate2D(random() * PI2);
  
  p.yz *= rotate2D((fract(time) + random()) * PI2);
  
  float phi = random() * PI2;
  p.yx *= rotate2D(phi);
  
  float theta = acos(random() * 2. - 1.);
  theta += sign(random() - 0.5) * fract(time * 0.2) * PI2;
  p.xz *= rotate2D(theta);
  
  return p;
}

vec3 movePetal(vec3 p) {
  vec2 pos = hash_disc() * cylRadius;
  p.xz += pos;
  
  p.xz += sin(vec2(5, 7) * time * 1. + random() * PI2) * 0.2;
  
  p.y += (1. - fract(time * 0.5 + random()) * 2.) * cylHeight;
  
  return p;
}

void moveCamera(inout vec3 ro, inout vec3 ta, inout float fov) {
  fov += smoothSqWave(Time, 0.1) * 20.;
  
  float I = floor(Time);
  float cH = 0.2;
  float cR = 0.5;
  
  seed = I;
  float a = random() * PI2;
  vec2 pos = vec2(cos(a), sin(a)) * cylRadius * cR;
  float h = (random() * 2. - 1.) * cylHeight * cH;
  vec3 ta1 = vec3(pos.x, h, pos.y);
  
  seed = I + 1.;
  a = random() * PI2;
  pos = vec2(cos(a), sin(a)) * cylRadius * cR;
  h = (random() * 2. - 1.) * cylHeight * cH;
  vec3 ta2 = vec3(pos.x, h, pos.y);
  
  float s = 0.25;
  ta = mix(ta1, ta2, smoothstep(0.5 - s, 0.5 + s, fract(Time)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * 0.5;
  vec3 col = vec3(0);
  Time = time * BPM / 60. * 0.5;
  
  float sampleSeed = dot(FC.xy, vec2(1.6287, 1.3473)) + fract(time * 0.1) * 500.;
  
  vec3 ro = vec3(0);
  vec3 ta = vec3(1, 0, 0);
  float fov = 60.;
  moveCamera(ro, ta, fov);
  
  vec3 dir = normalize(ta - ro);
  mat3 cam = camera(dir);
  
  float dofAmount = 0.05;
  float dofFocus = length(ta - ro);
  
  vec3 pCol = vec3(255, 20, 147) / 255.;
  pCol *= 2.;
  
  for(float i = 0.; i < numSamples; i++) {
    seed = sampleSeed + i * 500.;
    vec3 ppos = vec3(petal(), 0.);
    
    float dy = 8.;
    float ID = FC.x + floor(FC.y / (R.y / dy)) * FC.x;
    
    seed = ID;
    ppos = rotPetal(ppos);
    ppos = movePetal(ppos);
    
    seed = (sampleSeed + i * 500.) * 1.1278;
    ivec2 u = proj(ppos, ro, cam, fov, dofFocus, dofAmount);
    add(u, pCol);
  }
  
  vec2 dis = uv * R.x * 0.05;
  float amp = pow(sin(fract(Time * 2.) * PI2) * 0.5 + 0.5, 4.);
  dis *= amp;
  vec2 c = abs(FC.xy / R - 0.5);
  dis *= smoothstep(0.5, 0.4, max(c.x, c.y));
  
  col.r += read(ivec2(FC.xy + dis)).r;
  col.g += read(ivec2(FC.xy)).g;
  col.b += read(ivec2(FC.xy - dis)).b;
  col /= numSamples;
  
  col = reinhard(col, 10.);
  col = pow(col, vec3(1. / 2.2));
  
	out_color = vec4(col, 1.);
}