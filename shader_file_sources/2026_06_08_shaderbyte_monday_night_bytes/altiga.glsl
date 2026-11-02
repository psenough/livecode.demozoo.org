// Inspired by the cover art for Plaid's "Polymer".
#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime;  // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is
                          // higher / treble freq
uniform sampler1D
    texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

float t = fGlobalTime;

layout(location = 0)
    out vec4 out_color; // out_color must be written in order to see anything
float hash11(float p1) {
  float p = fract(p1 * .1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}
float hash21(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}
float hash31(vec3 p) {
  vec3 p3 = fract(p * .1031);
  p3 += dot(p3, p3.zyx + 31.32);
  return fract((p3.x + p3.y) * p3.z);
}
vec2 hash12(float p) {
  vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx + p3.yz) * p3.zy);
}
vec2 hash22(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx + p3.yz) * p3.zy);
}
vec2 hash32(vec3 p) {
  vec3 p3 = fract(p * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx + p3.yz) * p3.zy);
}
vec3 hash13(float p) {
  vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xxy + p3.yzz) * p3.zyx);
}
vec3 hash23(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yxz + 33.33);
  return fract((p3.xxy + p3.yzz) * p3.zyx);
}
vec3 hash33(vec3 p) {
  vec3 p3 = fract(p * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yxz + 33.33);
  return fract((p3.xxy + p3.yxx) * p3.zyx);
}
vec4 hash14(float p) {
  vec4 p4 = fract(vec4(p) * vec4(.1031, .1030, .0973, .1099));
  p4 += dot(p4, p4.wzxy + 33.33);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
vec4 hash24(vec2 p) {
  vec4 p4 = fract(vec4(p.xyxy) * vec4(.1031, .1030, .0973, .1099));
  p4 += dot(p4, p4.wzxy + 33.33);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
vec4 hash34(vec3 p) {
  vec4 p4 = fract(vec4(p.xyzx) * vec4(.1031, .1030, .0973, .1099));
  p4 += dot(p4, p4.wzxy + 33.33);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
vec4 hash44(vec4 p) {
  vec4 p4 = fract(p * vec4(.1031, .1030, .0973, .1099));
  p4 += dot(p4, p4.wzxy + 33.33);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

  float a = hash21(i);
  float b = hash21(vec2(i.x + 1., i.y));
  float c = hash21(i + vec2(0, 1));
  float d = hash21(vec2(i.x + 1., i.y + 1.));

  vec2 u = f * f * (3. - 2. * f);

  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

vec3 voronoi(in vec2 x) {
  vec2 id = floor(x);
  vec2 f = fract(x);

  vec2 minD;   // Min difference between cell IDs
  vec2 minDir; // Min difference between *points*

  float res = 8.0;
  for (int dy = -1; dy <= 1; dy++)
    for (int dx = -1; dx <= 1; dx++) {
      vec2 d = vec2(dx, dy);
      vec2 dir = d + hash22(id + d) - f;
      float d2 = dot(dir, dir);

      if (d2 < res) {
        res = d2;
        minDir = dir;
        minD = d;
      }
    }

  vec2 cell = minD + id;

  return vec3(res, cell);
}

mat2 rot(float angle) {
  float c = cos(angle), s = sin(angle);
  return mat2(c, -s, s, c);
}

float stringy(vec2 n, float a, float b, float c) {
  // mat2 rot = mat2(.6,-.8,.8,.6);
  float o = b;
  for (float i = 0.; i < 5.; i++) {
    n += sin(n.y * o) / o;
    o *= c;
    n *= rot(a);
  }
  n = vec2(length(n)) * 10.;

  return 1. - smoothstep(.9, .95, valueNoise(n));
}

void main(void) {
  vec2 uv =
      vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1 / length(uv) * .2;
  float d = m.y;

  float f = texture(texFFT, d).r * 100;
  m.x += sin(fGlobalTime) * 0.1;
  m.y += fGlobalTime * 0.25;

  vec3 top = vec3(0xe4, 0xc4, 0x19) / 256.;
  vec3 bottom = vec3(0xb2, 0x42, 0x24) / 256.;
  vec3 blu = vec3(0x20, 0x1f, 0x35) / 256;

  vec3 body =
      mix(bottom, top, sin(t + hash22(voronoi(uv * 60.).yz).x * 4.) * .5 + .5);

  vec3 col = mix(body, vec3(1),
                 1. - (step(abs(uv.x), .3) * step(abs(uv.y + .05), .4)));
  vec2 uv2 = uv - vec2(0, .3);

  float s = 1.;
  for (int i = 1; i < 30; i++) {
    vec4 h = hash44(vec4(i));
    s *= stringy(uv2 * (texture(texFFT, .01).x + .5) * rot(h.y * 10. - t) *
                     10. * (h.x + .2),
                 h.y * 4. + t, h.z * 10., h.w * 10.);
  }
  s = mix(1, s, smoothstep(.45, .46, length(uv2 / vec2(1, 1.4) + vec2(0, .7))));
  s = mix(s, 1, smoothstep(0., .01, uv2.y - .1));
  s = mix(s, 1, smoothstep(0., .01, abs(uv2.x) - .4));

  col = mix(blu, col, s);

  out_color = vec4(col, 0);
}