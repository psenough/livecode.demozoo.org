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
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define PI acos(-1)
#define TAU (2. * PI)
#define saturate(x) clamp(x, 0, 1)
#define VOL 0.0
#define SOL 1.0
#define phase(x) (floor(x) + .5 + .5 * cos(TAU * .5 * exp(-5. * fract(x))))

float beat, beatTau, beatPhase, beatPulse;
float scene;

float map(vec3 p);

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0)) + min(0, max(q.x, max(q.y, q.z)));
}

void rot(inout vec2 p, float a) { p *= mat2(cos(a), sin(a), -sin(a), cos(a)); }

void pmod(inout vec2 p, float s) {
  float n = TAU / s;
  float a = PI / s - atan(p.x, p.y);
  a = floor(a / n) * n;
  rot(p, a);
}

vec3 normal(vec3 p) {
  vec2 e = vec2(0, .0005);
  return normalize(map(p) - vec3(map(p - e.yxx), map(p - e.xyx), map(p - e.xxy)));
}

vec3 pal(float h) {
  vec3 col = vec3(0.5) + 0.5 * cos(TAU * (vec3(0.0, 0.33, 0.67) + h));
  return mix(col, vec3(1), 0.1 * floor(h));
}

vec2 F = gl_FragCoord.xy, R = v2Resolution;
ivec2 FI = ivec2(F);

vec3 hash(vec3 p) {
  uvec3 x = floatBitsToUint(p + vec3(1, 2, 3) / 10);
  uint k = 0xF928A019;
  x = ((x >> 8u) ^ x.yzx) * k;
  x = ((x >> 8u) ^ x.yzx) * k;
  x = ((x >> 8u) ^ x.yzx) * k;
  return vec3(x) / vec3(-1u);
}

mat3 bnt(vec3 t) {
  vec3 n = vec3(0, 1, 0);
  vec3 b = cross(n, t);
  n = cross(t, b);
  return mat3(normalize(b), normalize(n), normalize(t));
}

vec3 cyc(vec3 p, float q, vec3 s) {
  vec4 v = vec4(0);
  mat3 m = bnt(s);
  for (int i = 0; i < 5; i++) {
    p += sin(p.yzx);
    v = v * q + vec4(cross(cos(p), sin(p.zxy)), 1);
    p *= q * m;
  }
  return v.xyz / v.w;
}

void add(ivec2 p, vec3 v) {
  ivec3 q = ivec3(v * 2048);
  imageAtomicAdd(computeTex[0], p, q.x);
  imageAtomicAdd(computeTex[1], p, q.y);
  imageAtomicAdd(computeTex[2], p, q.z);
}

vec3 read(ivec2 p) {
  return vec3(
    imageLoad(computeTexBack[0], p).x,
    imageLoad(computeTexBack[1], p).x,
    imageLoad(computeTexBack[2], p).x
  ) / 2048;
}

vec2 disk(vec3 h) {
  return h.x * vec2(cos(h.y * TAU), sin(h.y * TAU));
}

ivec2 proj(vec3 p, vec3 ro, mat3 m, float z, out float sz) {
  vec3 od = (p - ro) * m;
  sz = od.z / z;
  
  od.xy += disk(hash(p)) * abs(sz - 4) * 0.05;
  
  vec2 uv = od.xy / sz;
  uv = (uv / (R / min(R.x, R.y)) + 1) * .5;
  return ivec2(uv * R);
}

float dMenger(vec3 z0, vec3 offset, float scale, float iteration) {
  vec4 z = vec4(z0, 1.0);
  for (int n = 0; n < iteration; n++) {
    z = abs(z);

    if (z.x < z.y) z.xy = z.yx;
    if (z.x < z.z) z.xz = z.zx;
    if (z.y < z.z) z.yz = z.zy;

    z *= scale;
    z.xyz -= offset * (scale - 1.0);

    if (z.z < -0.5 * offset.z * (scale - 1.0)) {
      z.z += offset.z * (scale - 1.0);
    }
  }

  return sdBox(z.zxy, vec3(1)) / z.w;
}

float map(vec3 pos) {
  float d = 1;
  if (scene == 0) {
    vec3 p = pos;
    d = min(d, length(p - 4 * cyc(p + mod(beatPhase, 4), 1, vec3(1))) - 4);
  } else if (scene == 1) {
    vec3 p = pos;
    d = min(d, dMenger(p, vec3(4.5, 0.1, 0.4), 2.5 + cos(beatTau / 4), 3));
  } else if (scene == 2) {
    vec3 p = pos;
    float a = 4;
    p = mod(p,a) - 0.5 * a;
    //rot(p.xz, beatTau / 8);
    d = min(d, length(p - 4 * cyc(p + mod(beatPhase, 4), 1, vec3(1))) - 4);
  } else if (scene == 3) {
    vec3 p = pos;
    float a = 4;
    p -= 0.5 * a;
    p = mod(p,a) - 0.5 * a;
    pmod(p.xy, 8);
    p.y -= 1.1 + 0.7 * cos(beatTau / 4);
    d = min(d, length(p - 4 * cyc(p + mod(beatPhase, 4), 1, vec3(1))) - 4);
  }
  else {
    vec3 p = pos;
    float a = 4;
    vec3 of = vec3(0.3, 0.3, 0.3);
    float s = 1;
    if (mod(beat, 2) < 1) rot(p.xy, pos.z);
    p = mod(p, a) - 0.5 * a;
    p -= of;
    for(int i = 0; i < 4; i++) {
      p = abs(p + of) - of;
      rot(p.xz, TAU * 0.2);
      rot(p.zy, TAU * 0.2 * beatPhase);
    }
    
    float scale = 1.05;
    s *= scale;
    p *= scale;
    d = min(d, length(p - 4 * cyc(p + mod(beatPhase, 4), 1, vec3(1))) - 4);
  }
  
  return d;
}

vec3 render(vec3 ro, vec3 dir) {
  vec2 uv = F/R, suv = (uv * 2 - 1) * R / min(R.x, R.y);
  int id = int(F.x + F.y * R.x);
  vec3 c = vec3(0);
  
  float z= 2 + 0 * texture(texFFT, 0.1).r + cos(beatTau / 16);
  float sz;
  
  mat3 m = bnt(dir);
  if (FI.x < 1000) {
    vec3 p = 2 * (hash(vec3(id)) * 2 - 1);
    int N = 30;
    for (int i = 0; i < N; i++) {
      p -= normal(p);
      c = vec3(0.4, 0.4, 1);
      c = mix(c, pal(2 + fract(beatPhase + length(p * 0.1 + beat))), 0.5 + 0.5 * cos(beatTau / 4));
      
      if (mod(beat, 4) > 3) {
        p -= sin(p * 8);
        c *= saturate(cos(time * 30 * TAU)) * 4;
      }
      else if (mod(beat, 8) < 1) {
        c *= saturate(cos(abs(dot(vec3(1), p)) + beatTau));
      }
      else if (mod(beat, 8) > 4 && mod(beat, 8) < 5) {
        c *= texture(texFFT, 0.1).r * 100;
      }
      
      c *= 0.8 / N;
      ivec2 u = proj(p, ro, m, z, sz);
      if (sz > 0) add(u, c);
    }
  }
  
  c = read(FI);
  return c;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float bpm = 88;
  beat = time * bpm / 60;
  beatTau = beat * TAU;
  beatPhase = phase(beat);
  beatPulse = saturate(cos(beatTau));
  
  float len = 4;
  scene = floor(mod(beat, len * 5) / len);
  scene = 2;

	vec3 col = vec3(0);
  
  vec3 ro = vec3(4);
  if (mod(beat, 8) < 7) ro = 4 * vec3(cos(beatTau / 8), 1, sin(beatTau / 16));
  col += render(ro, -ro);
  

  
  vec2 uv2 = abs(uv);
  //col += texture(texFFT, uv2.x * 0.2).r - uv2.y;
  //col += beatPulse;
  
  col = pow(col * 1.2, vec3(1.5));
  //col *= texture(texFFT, 0.1).r * 100;
  
  if (mod(beat, 4 * 5 * 2) < 4 * 5) col = saturate(vec3(1) - col);
  
  vec3 back = texture(texPreviousFrame, F/R).rgb;
  col = mix(col, back, 0.5);
  
  //vec2 suv = (uv * 2 - 1) * R / min(R.x, R.y);
  if (texture(texRevisionBW, saturate(uv * 2. + 0.5)).r > 0.5){
    //if (texture(texFFT, 0.1).r > 0.03) {
    // if (mod(beat * 4, 2) < 1) {
      // col = saturate(vec3(1) - col);
      //col += texture(texFFT, 0.1).r * 30;
    //}
  }
  
  

  
	out_color = vec4(col, 1);
}