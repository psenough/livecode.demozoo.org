#version 410 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define FFT(f) (10. * texture(texFFT, f).x)
#define PI 3.1415926535897932
#define T (.5 * fGlobalTime)
#define TAU (2. * PI)

mat3 yaw(float a) {
  float s = sin(a), c = cos(a);
  return mat3(c, s, 0., -s, c, 0., 0., 0., 1.);
}

mat3 pitch(float a) {
  float s = sin(a), c = cos(a);
  return mat3(c, 0., -s, 0., 1., 0., s, 0., c);
}

mat3 roll(float a) {
  float s = sin(a), c = cos(a);
  return mat3(1., 0., 0., 0., c, s, 0., -s, c);
}

mat3 rotation(void) {
  float s = .05;
  return yaw(T + s * FFT(0.)) * pitch(T + s * FFT(.5)) * roll(T + s * FFT(1.));
}

vec3 palette(float x) {
  vec3 a = vec3(.5),
       b = a,
       c = vec3(1.),
       d = vec3(0., 1./3., 2./3.);
  return a + b * cos(TAU * (c * x + d));
}

vec3 dots(vec2 uv) {
  float d = length(uv);
  uv = fract(20. * uv) - .5;
  float r = sin(TAU * (T - d)) * .25 + .25;
  vec3 c = palette(d - FFT(0.));
  return c * step(0., r - length(uv));
}

float sdf_box(vec3 p, vec3 s, float r) {
  vec3 q = abs(p) - s + r;
  return length(max(q, 0.)) + min(0., max(q.x, max(q.y, q.z))) - r;
}

float sdf(vec3 p) {
  float d = 1000.;
  p *= rotation();
  for (float i = 0.; i < 3.; i++) {
    for (float j = 0.; j < 3; j++) {
      for (float k = 0.; k < 3; k++) {
        float c = sdf_box(p + (vec3(i, j, k) - 1.)/.8, vec3(.5), .1);
        d = min(d, c);
      }
    }
  }
  return d;
}

vec3 get_normal(vec3 p) {
  vec2 e = .01 * vec2(1., -1);
  return normalize(
    e.xyy * sdf(p + e.xyy) +
    e.yxy * sdf(p + e.yxy) +
    e.yyx * sdf(p + e.yyx) +
    e.xxx * sdf(p + e.xxx)
  );
}

vec3 uv_map(vec3 p, vec3 n, mat3 r, float k) {
  float scale = 20.;
  p *= r;
  n *= r;
  vec3 x = dots(p.yz);
  vec3 y = dots(p.xz);
  vec3 z = dots(p.xy);
  vec3 w = pow(abs(n), vec3(k));
  return (x * w.x + y * w.y + z * w.z) / (w.z + w.y + w.z);
}

#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))

void main(void) {
  vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	vec3 c = vec3(0.),
       ro = vec3(0., 0., -4.),
       rd = normalize(vec3(uv, 1.)),
       lo = ro,
       p = ro;
  float d;
   
  uv *= rot(FFT(.0));
  uv *= FFT(.5)/2.;
  c = .1 * dots(uv);
  
  for (int i = 0; i < 128; i++) {
    d = sdf(p);
    if (d < .01) {
      vec3 n = get_normal(p);
      c = uv_map(p, n, rotation(), 2.);
      break;
    }
    p += d * rd;
  }
  
	out_color = vec4(c, 1.);
}
