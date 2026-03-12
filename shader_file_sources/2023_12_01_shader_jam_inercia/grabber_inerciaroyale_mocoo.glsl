#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const int scale = 6;
const int steps = 1000;
const int bounces = 3;
const int samples = 10;

const vec3 os = vec3(.5, 1, 2);
const vec3 oa = 4 * vec3(.1,.2,.4);
const vec3 ot = os + oa;

uint seed = 31415;

uint uhash(uint x) {
  x *= 9;
  x = (x ^ (x >> 4)) * 0x27d4eb2b;
  x = (x ^ (x >> 15));
  return x;
}

float hash() {
  uint x = uhash(seed);
  seed = x;
  return float(x) / float(0xffffffffu);
}

mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

vec2 box(vec3 ro, vec3 rd) {
  vec3 m = 1./rd;
  vec3 n = m * ro;
  vec3 t1 = -n - abs(m);
  vec3 t2 = -n + abs(m);
  float tN = max(t1.x, max(t1.y, t1.z));
  float tF = min(t2.x, min(t2.y, t2.z));
  if(tN > tF || tF < 0) return vec2(-1);
  return vec2(tN, tF);
}

vec3 environment(vec3 rd) {
  float beat = 2 * texture(texFFTSmoothed, 0).x;
  float off = texture(texFFTSmoothed, atan(rd.x, rd.z) * 2).x;
  float gyroid = dot(sin(rd.xyz), cos(rd.yzx));
  float k = max(sqrt(sin(20 * (rd.y + gyroid + .2 * fGlobalTime))), 0);
  vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution.xy) / v2Resolution.x;
  k *= max(pow(length(uv)*5, 4), 1);
  return mix(vec3(.08,.02,.08), vec3(.7,.4,.2), k) * (2 * beat + .1);
}

float density(ivec3 p) {
  float beat = texture(texFFTSmoothed, 0).x;
  float t = mod(fGlobalTime, 20);
  float k;
  k = length(p) < beat * 10 + 3 ? .5 : 0;
  return max(k, .03);
}

float regular_tracking(vec3 ro, vec3 rd, vec3 c) {
  float z = hash();
  float T = 0;
  
  // branchless DDA by fb39ca4 on shadertoy
  vec3 p = ro * scale;
  ivec3 p_int = ivec3(floor(p));
  vec3 delta = abs(vec3(length(rd)) / rd);
  vec3 dist = (sign(rd) * (vec3(p_int) - p) + sign(rd) * .5 + .5) * delta;
  bvec3 mask;
  
  float d = 0;
  for(int i = 0; i < steps; ++i) {
    vec3 api = abs(p_int);
    if(api.x > scale + 1 || api.y > scale + 1 || api.z > scale + 1) break;
    
    float d_diff = min(dist.x, min(dist.y, dist.z));
    float u = dot(c, ot) * density(p_int);
    float T_diff = d_diff * u;
    if(exp(-(T + T_diff)) < z) {
      return (d + ((-log(z) - T) / u)) / scale;
    }
    d += d_diff;
    T += T_diff;
    
    mask = lessThanEqual(dist.xyz, min(dist.yzx, dist.zxy));
    dist += vec3(mask) * delta;
    p_int += ivec3(vec3(mask)) * ivec3(sign(rd));
  }
  return -1;
}

void main(void)
{
	vec2 uv = 2 * (gl_FragCoord.xy - .5 * v2Resolution.xy) / v2Resolution.x;
  seed = uhash(uint(gl_FragCoord.x)) + uhash(uint(gl_FragCoord.y)) + uhash(uint(fGlobalTime * 100));
  
  // ====== //
  
  vec3 L = vec3(0);
  
  for(int s = 0; s < samples; ++s) {
  
    float e = hash();
    vec3 c = e < .3333 ? vec3(1, 0, 0) : e < .667 ? vec3(0,1,0) : vec3(0,0,1);
    
    vec3 ro = vec3(0, 0, -3);
    vec3 rd = normalize(vec3(uv, 1));
    vec3 light = normalize(vec3(1,1,-1));
    
    ro.xz *= rot(fGlobalTime);
    rd.xz *= rot(fGlobalTime);
    
    vec3 att = vec3(1);
    
    vec2 t0 = box(ro, rd);
    
    if(t0.x > 0 && t0.y > 0) {
      vec3 p = ro + t0.x * rd;
      
      for(int i = 0; i < bounces; ++i) {
        float t = regular_tracking(p, rd, c);
        if(t == -1) {
          L += c * environment(rd);
          break;
        }
        p += t * rd;
        if(hash() < dot(oa, c) / dot(ot, c)) {
          break;
        }
        if(regular_tracking(p, light, c) < 0) {
          L += att * c * dot(os, c) / dot(ot, c);
        }
        rd = normalize(tan(vec3(hash(), hash(), hash())));
      }
    } else {
      L += c * environment(rd);
    }
  }
  L *= 5. / samples;
  vec2 texcoord = gl_FragCoord.xy / v2Resolution.xy;
  vec4 last = texture(texPreviousFrame, texcoord);
  out_color = mix(vec4(L, 1), last, .5);
}