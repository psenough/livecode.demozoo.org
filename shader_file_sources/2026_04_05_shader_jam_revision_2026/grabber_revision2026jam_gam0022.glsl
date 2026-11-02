#version 420 core

uniform float fGlobalTime;  // in seconds
uniform vec2 v2Resolution;  // viewport resolution (in pixels)
uniform float fFrameTime;   // duration of the last frame, in seconds

uniform sampler1D texFFT;            // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed;    // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated;  // this is continually increasing
uniform sampler2D texPreviousFrame;  // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color;  // out_color must be written in order to see anything

#define time fGlobalTime
#define PI acos(-1)
#define TAU (2. * PI)
#define saturate(x) clamp(x, 0, 1)
#define phase(x) (floor(x) + .5 + .5 * cos(TAU * .5 * exp(-5. * fract(x))))
#define ZERO (min(int(time), 0))

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

vec3 normal(vec3 p, float eps) {
  vec2 k = vec2(1, -1);
  return normalize(k.xyy * map(p + k.xyy * eps).x + k.yyx * map(p + k.yyx * eps).x + k.yxy * map(p + k.yxy * eps).x + k.xxx * map(p + k.xxx * eps).x);
}

vec3 pal(float h) {
  vec3 col = vec3(0.5) + 0.5 * cos(TAU * (vec3(0.0, 0.33, 0.67) + h));
  return mix(col, vec3(1), 0.1 * floor(h));
}

float fft(float x) { return texture(texFFT, saturate(x)).r; }

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

vec3 read(ivec2 p) { return vec3(imageLoad(computeTexBack[0], p).x, imageLoad(computeTexBack[1], p).x, imageLoad(computeTexBack[2], p).x) / 2048; }

vec2 disk(vec3 h) { return h.x * vec2(cos(h.y * TAU), sin(h.y * TAU)); }

ivec2 proj(vec3 p, vec3 ro, vec3 right, vec3 up, vec3 fwd, float fov, out float sz) {
  vec3 pos_rel = p - ro;

  // World to Camera space
  vec3 cam_pos = vec3(dot(pos_rel, right), dot(pos_rel, up), dot(pos_rel, fwd));

  sz = cam_pos.z;

  // Perspective projection
  float f = 1.0 / tan(fov * TAU / 720.0);
  vec2 screen_pos = cam_pos.xy / cam_pos.z * f;

  // Convert to screen coordinates (considering aspect ratio)
  screen_pos.x = (screen_pos.x + 1.0) * 0.5;
  screen_pos.y = (screen_pos.y * R.x / R.y + 1.0) * 0.5;
  return ivec2(screen_pos * R);
}

float dRope(vec3 p) {
  vec2 p1 = p.xz;

  p1.x = abs(p1.x);

  float vibe = (hash(floor(8. * vec3(p1, 0.0))) - 0.5).x * saturate(cos(beatTau + p.y * 0.2));
  float time = beat;
  p1 *= 1 + 0.4 * vibe;
  vec2 q = vec2(1, 0);

  float th = 0.4 * p.y - 0.6 * time;
  float m = 1.8;

  for (float i = 0.; i < 2 + int(10.0 + 10.0 * (cos(beatTau / 8))); i++) {
    p1 -= m * q;
    th += 0.5 * p.y;
    rot(p1, th);
    p1.x = abs(p1.x);
    m *= 0.05 * cos(8. * length(p1)) + 0.55 + 0.1 * cos(0.4 * p.y - 0.6 * time);
    m -= 0.001;
  }

  float d = length(p1) - 2.0 * m * (0.5 + 0.5 * cos(beatTau / 32));
  
  return 0.35 * d;
}

float map(vec3 pos) { return dRope(pos); }

vec3 render_compute(vec3 ro, vec3 right, vec3 up, vec3 fwd, float fov) {
  vec2 uv = F / R, suv = (uv * 2 - 1) * R / min(R.x, R.y);
  int id = int(F.x + F.y * R.x);
  vec3 c = vec3(0);
  float sz;

  vec3 p = 2 * (hash(vec3(id)) * 2 - 1);
  int N = 5;
  for (int i = 0; i < N; i++) {
    p -= normal(p, 0.001) * (float(i) / N) * (0.6 + 0.4 * cos(beatTau / 4));

    c = pal(4 + fract(beatPhase + length(p * 0.1 + beat)));
    c = mix(c, vec3(0.5, 0.5, 1), 0.5 + 0.5 * cos(beatTau / 16));

    c *= 0.5 / N;
    ivec2 u = proj(p, ro, right, up, fwd, fov, sz);
    if (sz > 0) add(u, c);
  }

  c = read(FI);
  return c;
}

vec3 skyColor(vec3 ro, vec3 rd) {
  vec3 col1 = pal(5.0 + fract(beat / 8 + 0.5));
  vec3 col2 = vec3(1.0);
  vec3 col3 = pal(5.0 + fract(beat / 8));
  float exp1 = 1.0;
  float exp2 = 1.0;

  float p = rd.y;
  float p1 = 1.0f - pow(min(1.0f, 1.0f - p), exp1);
  float p3 = 1.0f - pow(min(1.0f, 1.0f + p), exp2);
  float p2 = 1.0f - p1 - p3;
  return col1 * p1 + col2 * p2 + col3 * p3;
}

// https://iquilezles.org/articles/rmshadows
float calcSoftshadow(vec3 ro, vec3 rd, float mint, float tmax) {
  float tp = (0.8 - ro.y) / rd.y;
  if (tp > 0.0) tmax = min(tmax, tp);

  float res = 1.0;
  float t = mint;
  for (int i = ZERO; i < 24; i++) {
    float h = map(ro + rd * t).x;
    float s = saturate(8.0 * h / t);
    res = min(res, s);
    t += clamp(h, 0.01, 0.2);
    if (res < 0.004 || t > tmax) break;
  }
  res = saturate(res);
  return res * res * (3.0 - 2.0 * res);
}

// https://iquilezles.org/articles/nvscene2008/rwwtt.pdf
float calcAO(vec3 pos, vec3 nor) {
  float occ = 0.0;
  float sca = 1.0;
  for (int i = ZERO; i < 5; i++) {
    float h = 0.01 + 0.12 * float(i) / 4.0;
    float d = map(pos + h * nor).x;
    occ += (h - d) * sca;
    sca *= 0.95;
    if (occ > 0.35) break;
  }
  return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

vec3 F_fresnelSchlick(vec3 F0, float cosTheta) { return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0); }

float D_GGX(float NdotH, float roughness) {
  float alpha = roughness * roughness;
  float alphaSq = alpha * alpha;
  float denom = (NdotH * NdotH) * (alphaSq - 1.0) + 1.0;
  return alphaSq / (PI * denom * denom);
}

float schlickG1(float cosTheta, float k) { return cosTheta / (cosTheta * (1.0 - k) + k); }

float G_schlickGGX(float NdotL, float NdotV, float roughness) {
  float r = roughness + 1.0;
  float k = (r * r) / 8.0;
  return schlickG1(NdotL, k) * schlickG1(NdotV, k);
}

// https://www.shadertoy.com/view/WlffWB
vec3 directLighting(vec3 pos, vec3 albedo, float metalness, float roughness, vec3 N, vec3 V, vec3 L, vec3 lightColor) {
  vec3 H = normalize(L + V);
  float NdotV = max(0.0, dot(N, V));
  float NdotL = max(0.0, dot(N, L));
  float NdotH = max(0.0, dot(N, H));
  float HdotL = max(0.0, dot(H, L));

  vec3 F0 = mix(vec3(0.04), albedo, metalness);

  vec3 F = F_fresnelSchlick(F0, HdotL);
  float D = D_GGX(NdotH, roughness);
  float G = G_schlickGGX(NdotL, NdotV, roughness);
  vec3 specularBRDF = (F * D * G) / max(0.0001, 4.0 * NdotL * NdotV);

  vec3 kd = mix(vec3(1.0) - F, vec3(0.0), metalness);
  vec3 diffuseBRDF = kd * albedo / PI;

  float shadow = calcSoftshadow(pos + N * 0.1, L, 0.1, 5.);
  vec3 irradiance = lightColor * NdotL * shadow;

  return (diffuseBRDF + specularBRDF) * irradiance;
}

vec3 ambientLighting(vec3 pos, vec3 albedo, float metalness, float roughness, vec3 N) {
  float ao = calcAO(pos, N);
  return albedo * mix(skyColor(pos, N), vec3(1), 0.7) * ao;
}

vec3 render_raymarch(vec3 ro, vec3 rd) {
  vec3 col = vec3(0);
  vec3 p;
  float t = 0.;
  float d, eps;

  for (int i = ZERO; i < 200; i++) {
    p = ro + rd * t;
    d = map(p);
    t += d;
    eps = t * 0.001;
    if (d < eps) {
      break;
    }
  }

  if (d < eps) {
    vec3 N = normal(p, eps);

    vec3 albedo = vec3(pal(7 + fract(p.y * 0.4)));
    vec3 emissive = vec3(0.);
    float metalness = 0.4;
    float roughness = 0.1;

    vec3 sundir = normalize(vec3(0.1, 0.1, -1.0));
    vec3 lightColorDirectional = vec3(0.9, 0.8, 1.);
    vec3 lightColorAmbient = vec3(0.9, 0.8, 1.);
    col += directLighting(p, albedo, metalness, roughness, N, -rd, sundir, lightColorDirectional);
    col += ambientLighting(p, albedo, metalness, roughness, N);
    col += emissive;
    col = mix(vec3(1.0), col, exp(-0.01 * t));
  } else {
    col = skyColor(ro, rd);
  }

  return col;
}

vec3 scroll(vec2 uv) {
  vec2 p = uv;
  rot(p, TAU / 8 + floor(mod(beat * 0.5, 4)) * TAU * 3. / 8);
  p += beat * 0.1;
  float a = int(beat) % 4;
  if (mod(beat, 8) < 1) a = 0.1;
  return mod(p.y, a) < a * 0.5 ? vec3(1) : vec3(0);
}

float sdBox(in vec2 p, in vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec3 diamond(vec2 uv) {
    vec3 col = vec3(0);

    vec2 p = uv;

    p += vec2(0.0, 0.1);

    rot(p, TAU / 8.);

    float a = 8;

    p *= a;
    vec2 grid = floor(p);

    p = mod(p, 1) - 0.5;

    vec2 abs_grid = abs(grid);

    float w = 2;
    if (mod(beat, 4) > 3) w += 1;
    // if (mod(beat, 8) > 7) w += 6;

    if (abs_grid.x <= w && abs_grid.y <= w) {
        float a = 1;
        float[4] ary = float[](
            (dot((grid), a * vec2(1, -1))), //
            (dot((grid), a * vec2(1, 1))), //
            abs(dot((grid), a * vec2(1, -1))), //
                               // abs(dot((grid), a * vec2(1, 1)))
            hash(vec3(grid, 1) + 32 * floor(beat)).x * 10.
        );

        float b = mod(beat / 2, 4.);  //
        float c = ary[int(b)];
        float d = saturate(cos(beat * TAU - c * TAU / 20));
        vec3 e = vec3(1.0);
        // e = pal(hash12(abs_grid * 10.));
        // e = pal(fract(beat));
        col += sdBox(p, vec2(0.45 * d)) < 0.0 ? e * d : vec3(0.0);
    }

    return col;
}

void main(void) {
  vec2 uv = F / R, suv = (uv * 2 - 1) * R / min(R.x, R.y);

  float bpm = 141;
  beat = time * bpm / 60;
  beatTau = beat * TAU;
  beatPhase = phase(beat);
  beatPulse = saturate(cos(beatTau));

  vec3 col = vec3(0);

  vec2 noise = hash(vec3(time, gl_FragCoord)).xy - .5;  // AA
  vec2 uv2 = (2. * (F.xy + noise) - R.xy) / R.x;

  float fov = 60.0;
  vec3 ro = vec3(0, 0, -7);
  vec3 target = ro + vec3(0, 0, 1);

  int camera_id = (int(beat) / 4) % 3;

  if (camera_id == 1) {
    ro = vec3(6 * cos(beatTau / 128), 0.0, 6 * sin(beatTau / 128));
    target = vec3(0, ro.y - 1, 0);
  } else if (camera_id == 2) {
    ro = vec3(6.0, 0.0, 0.0);
    target = vec3(0, 0, 0);
  }

  vec3 up = vec3(0, 1, 0);
  vec3 fwd = normalize(target - ro);
  vec3 right = normalize(cross(up, fwd));
  up = normalize(cross(fwd, right));
  vec3 rd = normalize(right * uv2.x + up * uv2.y + fwd / tan(fov * TAU / 720.));

  vec2 uv3 = (2. * F.xy - R.xy) / R.y;
  vec3 col_2d = scroll(uv3);
  
  int tl = int(beat / 8) % 8;
  
  vec3 col_diamond = diamond(uv3);
  
  if (tl == 0) {
    col += render_raymarch(ro, rd);
    col -= col_diamond;
  } else if (tl == 4) {
    col += render_compute(ro, right, up, fwd, fov);
    col += col_diamond;
  } else {
    if (dot(col_2d, vec3(0.33)) > 0.5) {
      col += render_compute(ro, right, up, fwd, fov);
      col += col_diamond;
    } else {
      col += render_raymarch(ro, rd);
      col -= col_diamond;
    }
  }

  if (int(beat / 4) % 2 == 0) col = 1.0 - saturate(col);
  
  //col += vec3(10) * fft(0.2);

  vec3 back = texture(texPreviousFrame, F / R).rgb;

  col = mix(col, back, 0.5);

  out_color = vec4(col, 1);
}