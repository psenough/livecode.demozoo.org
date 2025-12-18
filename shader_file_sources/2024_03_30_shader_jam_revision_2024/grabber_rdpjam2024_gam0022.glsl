#version 410 core

uniform float fGlobalTime;  // in seconds
uniform vec2 v2Resolution;  // viewport resolution (in pixels)
uniform float fFrameTime;   // duration of the last frame, in seconds

uniform sampler1D texFFT;  // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed;    // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated;  // this is continually increasing
uniform sampler2D texPreviousFrame;  // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;

layout(location = 0) out vec4 out_color;  // out_color must be written in order to see anything

#define time fGlobalTime
#define PI acos(-1)
#define TAU (2. * PI)
#define saturate(x) clamp(x, 0, 1)
#define VOL 0.0
#define SOL 1.0
#define phase(x) (floor(x) + .5 + .5 * cos(TAU * .5 * exp(-5. * fract(x))))

float beat, beatTau, beatPhase;
vec3 pos, light;
float scene;

vec4 map(vec3 p);

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;return length(max(q, 0)) + min(0, max(q.x, max(q.y, q.z)));
}

void U(inout vec4 m, float d, float a, float b, float c) {
  if (d < m.x) m = vec4(d, a, b, c);
}

void rot(inout vec2 p, float a) { p *= mat2(cos(a), sin(a), -sin(a), cos(a)); }

void pmod(inout vec2 p, float s) {
  float n = TAU / s;
  float a = PI / s - atan(p.x, p.y);
  a = floor(a / n) * n;
  rot(p, a);
}

float fft(float d) { return texture(texFFT, fract(d)).r; }

float minRadius2 = 0.5;
float fixedRadius2 = 1.0;
float foldingLimit = 1.0;

void sphereFold(inout vec3 z, inout float dz) {
  float r2 = dot(z, z);
  if (r2 < minRadius2) {
    float temp = (fixedRadius2 / minRadius2);
    z *= temp;
    dz *= temp;
  } else if (r2 < fixedRadius2) {
    float temp = fixedRadius2 / r2;
    z *= temp;
    dz *= temp;
  }
}

void boxFold(inout vec3 z, inout float dz) { z = clamp(z, -foldingLimit, foldingLimit) * 2.0 - z; }

vec3 normal(vec3 p) {
  vec2 e = vec2(0, .0005);
  return normalize(map(p).x - vec3(map(p - e.yxx).x, map(p - e.xyx).x, map(p - e.xxy).x));
}

vec3 fbm(vec3 p) { return sin(p) + sin(p * 2) / 2 + sin(p * 4) / 4; }

vec3 pal(float h) {
  vec3 col = vec3(0.5) + 0.5 * cos(TAU * (vec3(0.0, 0.33, 0.67) + h));
  return mix(col, vec3(1), 0.1 * floor(h));
}

#define FLT_EPS 5.960464478e-8
float roughnessToExponent(float roughness) {
  return clamp(2.0 * (1.0 / (roughness * roughness)) - 2.0, FLT_EPS, 1.0 / FLT_EPS);
}

vec3 evalLight(vec3 p, vec3 normal, vec3 view, vec3 baseColor, float metallic, float roughness) {
  vec3 ref = mix(vec3(0.04), baseColor, metallic);
  vec3 h = normalize(light + view);
  vec3 diffuse = mix(1.0 - ref, vec3(0.0), metallic) * baseColor / PI;
  float m = roughnessToExponent(roughness);
  vec3 specular = ref * pow(max(0.0, dot(normal, h)), m) * (m + 2.0) / (8.0 * PI);
  return (diffuse + specular) * max(0.0, dot(light, normal));
}

vec4 dMenger(vec3 z0, vec3 offset, float scale, float iteration) {
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

  float d1 = sdBox(z.zxy, vec3(1)) / z.w;
  float d2 = sdBox(z.zxy, vec3(0.1, 1.2, 0.8)) / z.w;
  vec4 m = vec4(d1, SOL, 1, 10);
  float hue = 2 + fract(pos.z * 2 + length(pos.xy) * 0.2);
  U(m, d2, VOL, saturate(cos(pos.z / 4 * TAU + beatTau / 2)), hue);
  return m;
}

float dMandel(vec3 z, float scale, int n) {
  vec3 offset = z;
  float dr = 1.0;
  for (int i = 0; i < n; i++) {
    boxFold(z, dr);          // Reflect
    sphereFold(z, dr);       // Sphere Inversion
    z = scale * z + offset;  // Scale & Translate
    dr = dr * abs(scale) + 1.0;
  }
  float r = length(z);
  return r / abs(dr);
}

vec4 map(vec3 p) {
  pos = p;
  vec4 m = vec4(1, 1, 1, 1);
  float a = 3.3;
  
  pos += 0.2 * fbm(pos * 4.);
  rot(pos.xy, beat / 4);
  // rot(pos.zx, beat / 4);

  if (scene == 0) {
    a = 10;
    p = pos;
    rot(p.xz, beatTau / 32);
    rot(p.xy, beatTau / 64);
    p -= 0.5 * a;
    p = mod(p, a) - 0.5 * a;
    return vec4(dMandel(p, -3.3 + 15 * fft(0.1), 10), SOL, 8, 5 + fract(length(p)));
  }
  else if (scene == 1) {
    a = 20;
    p = pos;
    rot(p.xz, beatTau / 32);
    p -= 0.5 * a;
    p = mod(p, a) - 0.5 * a;
    return vec4(dMandel(p, 2.78 + 15 * fft(0.1), 10), SOL, 8, 4.7);
  }
  else if (scene == 2) {
    a = 4;
    p = pos;
    p -= 0.5 * a;
    p = mod(p, a) - 0.5 * a;
    pmod(p.xy, 8);
    return dMenger(p, vec3(1.5, 2.2, 0.7 + 2.5 * (0.5 + 0.5 * cos(beatTau / 16))), 2.2, 4);
  }
  else if (scene == 3) {
    a = 3.3;
    p = mod(pos, a) - 0.5 * a;
    float s = 1;
    for (int i = 0; i < 4; i++) {
      p = abs(p) - 0.5;
      rot(p.xy, -0.5);
      p = abs(p) - 0.4;
      rot(p.yz, -0.1);

      float b = 1.4;
      p *= b;
      s *= b;
    }

    U(m, sdBox(p, vec3(0.5, 0.05, 0.05)) / s, SOL, 1, 10);
    U(m, sdBox(p, vec3(0.1 + 0.5 * cos(beatTau / 8), 0.06, 0.05)) / s, VOL, 0.1, 1.9);
    U(m, sdBox(p, vec3(0.2, 0.1, 0.1)) / s, VOL, saturate(cos(beatTau / 2 + TAU * pos.z / 8)), 5.5);
  }
  else if (scene == 4) {
    a = 16;
    vec3 of1 = vec3(2.68, 2.1, 1.9);
    p = mod(pos, a) - 0.5 * a;
    p -= of1;

    for (int i = 0; i < 4; i++) {
      p = abs(p + of1) - of1;
      rot(p.xz, TAU * (0.05));
      rot(p.zy, TAU * 0.21);
      rot(p.xy, TAU * (-0.52));
    }

    vec3 p2 = p;
    p2.y = mod(p2.y, 0.4) - 0.5 * 0.4;

    vec3 p3 = p;
    p3.y = mod(p3.y, 4) - 0.5 * 4;
    U(m, sdBox(p2, vec3(1, 0.05, 1)), SOL, 0.1, 1);
    U(m, sdBox(p, vec3(0.5, 20, 0.5)), VOL, saturate(cos(beatTau / 2 + p.y * TAU / 4)), 2.4 + fract(beat / 8));
    U(m, sdBox(p3, vec3(1, 0.2, 1)), VOL, saturate(cos(beatTau / 2 + TAU / 32 * pos.z / 16)), 2.9 + fract(beat / 16));
  }

  return m;
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 col = vec3(0);
  float t = 0.;
  for (int i = 0; i < 100; i++) {
    vec3 p = ro + rd * t;
    vec4 m = map(p);
    float d = m.x;

    if (m.y == SOL) {
      t += d;
      if (d < t * 0.001) {
        // col += evalLight(p, n, -ray, vec3(1), 0.7, 0.5) * 2;
        vec3 n = normal(p);
        float diffuse = saturate(dot(n, light));
        col += evalLight(p, n, -rd, vec3(1), 0.7, 0.5) * pal(m.w) * m.z;
        t += d;
        break;
      }
    } else {
      t += abs(d) * 0.5 + 0.01;
      col += saturate(0.001 * pal(m.w) * m.z / abs(d));
    }
  }
  col = mix(vec3(0), col, exp(-0.01 * t));
  return col;
}

void main(void) {
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  beat = time * 140 / 60;
  float span = 1;
  float count = 5;
  beat = mod(beat, span * count);
  // beat = 16 * 5 + mod(beat, 16);
  beatTau = beat * TAU;
  beatPhase = phase(beat / 2.);
  scene = floor(beat / span);
  // scene += saturate(pow(fract(beat / 4), 1) - abs(uv.y));
  // scene = mod(floor(scene + 0.5), count + 1);
  // scene = 4;

  vec3 ro = vec3(0, 0, 0.5 * time);
  // ro = vec3(0, 2.5, -4);
  if (scene == 0) ro = vec3(0, 0, -8);
  else if (scene == 1) ro = vec3(0, 0, -15);
  else if (scene == 4) ro = vec3(0, 0, 10 * time);

  vec3 rd = vec3(uv, 1.1 + 0 * cos(TAU * time / 8));
  rd = normalize(rd);
  light = normalize(vec3(1, 1, -1));
  vec3 col = render(ro, rd);
  // col += texture(texSessions, saturate(vec2(0.5 + uv.x, 0.5 - uv.y * 2))).rgb * 100 * fft(0.2);
  // col += 10 * fft(40 * abs(uv.x)) - abs(uv.y);
  out_color = vec4(col, 1);
}