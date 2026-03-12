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
uniform sampler2D texSessions;
uniform sampler2D texShort;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define FC gl_FragCoord
#define R v2Resolution

const float PI = acos(-1.);
const float PI2 = PI * 2.;
const float numSamples = 20.;
const float BPM = 148.;
float seed;
float T;

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
  return float(x) / float(-1U);
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

vec3 getTexture(vec2 uv) {
  vec2 size = textureSize(texSessions, 0);
  float ratio = size.x / size.y;
  return texture(texSessions, uv * vec2(1, -ratio) - 0.5).rgb;
}

vec3 hsv(float h, float s, float v) {
  vec3 res = fract(h + vec3(0, 2, 1) / 3.);
  res = clamp(abs(res * 6. - 3.) - 1., 0., 1.);
  res = (res - 1.) * s + 1.;
  res *= v;
  return res;
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

vec3 butterfly(float phase) {
  float a = random() * PI2 * 2.;
  float r = sqrt(random());
  float s = sign(a - PI2);
  vec3 p = vec3(cos(a), 0, sin(a)) * r;
  p.x += s;
  p *= .5;
  p.x *= .75 + p.z * 1.2;
  
  float si = sin(phase);
  p.xy *= rotate2D(s * si);
  p.y += si * .5;
  
  return p * .04;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * .5;
  vec3 col = vec3(0);
  float T = time * BPM / 60. * .5;
  float sampleSeed = dot(FC.xy, vec2(1.3723, 1.8329)) + time;
  seed = sampleSeed;
  T += random() * .03;
  vec3 ro = vec3(0, .001, .5);
  //vec3 ro = vec3(0, .3, -.001);
  ro.xz *= rotate2D(T * .5);
  
  vec3 ta = vec3(0);
  float sp = .2;
  ta += cyclic(vec3(T * sp), .5, 1.5);
  float dofFocus = length(ta - ro);
  vec3 dir = normalize(ta - ro);
  mat3 cam = camera(dir);
  float fov = 60.;
  fov += smoothSqWave(T * .5, .1) * 30.;
  
  seed = FC.y * 1.3724;
  vec3 init = vec3(random(), random(), random()) - .5;
  init += uv.y * .2;
  float fT = fract(T * 2.);
  float bPhase = (fT + random()) * PI2;
  vec3 bPos = cyclic(init + T * sp, .5, 1.5);
  vec3 bDir = normalize(bPos - cyclic(init - .01 + T * sp, .5, 1.5));
  vec3 bXZ = normalize(vec3(bDir.x, 0, bDir.z));
  mat2 rotYZ = rotate2D(sign(bDir.y) * acos(dot(bXZ, bDir)));
  mat2 rotXZ = rotate2D(sign(bDir.x) * acos(dot(vec3(0, 0, 1), bXZ)));
  vec3 bCol = hsv(random(), .8, 1.);
  
  float tL = 0.5;
  float rate = 0.5;
  float x = FC.x / R.x / rate;
  vec3 tPos = cyclic(init + T * sp - x * tL, .5, 1.5);
  
  for(float i = 0.; i < numSamples; i++) {
    seed = FC.x * 1.6116 + i + T;
    vec3 pp = butterfly(bPhase);
    pp.yz *= rotYZ;
    pp.xz *= rotXZ;
    
    seed = sampleSeed + i;
    vec3 pos = x < 1. ? tPos : bPos + pp;
    ivec2 u = proj(pos, ro, cam, fov, dofFocus, 0.05);
    add(u, bCol);
  }
  //col += read(ivec2(FC)) / numSamples;
  
  vec2 dis = uv * R.x * .03;
  float amp = pow(sin(T * 8.) * .5 + .5, 4.);
  dis *= amp;
  col.r += read(ivec2(FC.xy + dis)).r;
  col.g += read(ivec2(FC.xy)).g;
  col.b += read(ivec2(FC.xy - dis)).b;
  col /= numSamples;
  
  col = reinhard(col, 10.);
  col = pow(col, vec3(1. / 2.2));
  
	out_color = vec4(col, 1.);
}