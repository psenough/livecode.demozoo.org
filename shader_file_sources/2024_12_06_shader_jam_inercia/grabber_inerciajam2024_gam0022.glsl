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

layout(location = 0) out vec4 out_color;  // out_color must be written in order to see anything

#define time fGlobalTime
#define PI acos(-1)
#define TAU (2. * PI)
#define saturate(x) clamp(x, 0, 1)
#define VOL 0.0
#define SOL 1.0
#define phase(x) (floor(x) + .5 + .5 * cos(TAU * .5 * exp(-5. * fract(x))))

float beat, beatTau, beatPhase;
float scene;

vec4 map(vec3 p);

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0)) + min(0, max(q.x, max(q.y, q.z)));
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

vec3 normal(vec3 p) {
  vec2 e = vec2(0, .0005);
  return normalize(map(p).x - vec3(map(p - e.yxx).x, map(p - e.xyx).x, map(p - e.xxy).x));
}

vec3 pal(float h) {
  vec3 col = vec3(0.5) + 0.5 * cos(TAU * (vec3(0.0, 0.33, 0.67) + h));
  return mix(col, vec3(1), 0.1 * floor(h));
}

vec3 evalLight(vec3 p, vec3 normal, vec3 view, vec3 light, vec3 baseColor, float metallic, float roughness) {
  vec3 ref = mix(vec3(0.04), baseColor, metallic);
  vec3 h = normalize(light + view);
  vec3 diffuse = mix(1.0 - ref, vec3(0.0), metallic) * baseColor / PI;
  float eps = 6e-8;
  float m = clamp(2.0 * (1.0 / (roughness * roughness)) - 2.0, eps, 1.0 / eps);
  vec3 specular = ref * pow(max(0.0, dot(normal, h)), m) * (m + 2.0) / (8.0 * PI);
  return (diffuse + specular) * max(0.0, dot(light, normal));
}

float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}


// GUARDIAN's BOSS!!!!
vec4 map(vec3 pos) {
  vec4 m = vec4(1);
  vec3 p = pos;
  float a = 40.;
  
  if (scene == 1.) p = mod(p, a) - 0.5 * a;
  
  vec3 grid = floor(pos / a);
  
  int _IFS_Iteration = 5;
  vec3 _IFS_Offset = vec3(1.79, 2.42, -0.5);
  p -= _IFS_Offset;
  
  rot(p.xz, beatTau / 8 + grid.z);
  p.y -= 2.1 * cos(beatTau / 4 + grid.z);
  
  float s = 1.;
  
  vec3 _IFS_Rot = vec3(0.09, 0.06, 0.44);
  vec4 _EyeOffset = vec4(1.7, -4.1, 3.51, 0.95);
  float _IFS_Scale = 1.36;

  float d1 = 1000.0;
  float d2 = 1000.0;
  float d3 = 1000.0;

  for (int i = 0; i < _IFS_Iteration; i++) {
      p = abs(p + _IFS_Offset.xyz) - _IFS_Offset.xyz;
      rot(p.xz, TAU * _IFS_Rot.x);
      rot(p.zy, TAU * _IFS_Rot.y);
      rot(p.xy, TAU * _IFS_Rot.z + 0.07 * sin(beatTau / 4.));
      p *= _IFS_Scale;
      s *= _IFS_Scale;

      d1 = opSmoothUnion(d1, sdBox(p, vec3(0.5, 2, 0.5)) / s - 0.3, 1.);
      d2 = opSmoothUnion(d2, sdBox(p, vec3(0.55, 2.1, 0.1)) / s - 0.3, 1.);
      if (i <= 0) d3 = min(d3, (length(p - _EyeOffset.xyz) - _EyeOffset.w) / s);
  }
  
  U(m, d1, SOL, 2., 0.);
  U(m, d2, VOL, 1, 1.01);
  U(m, d3, VOL, 1., beat / 4 + grid.z * 0.3);
  
  // m.x *= 0.5;
  
  return m;
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 col = vec3(0);
  float t = 0;
  for (int i = 0; i < 300; i++) {
    vec3 p = ro + rd * t;
    vec4 m = map(p);
    float d = m.x;
    if (m.y == SOL) {
      t += d * 0.5;
      if (d < t * 0.001) {
        vec3 n = normal(p);
        col += evalLight(p, n, -rd, normalize(vec3(1, 1, -1)), vec3(1), 0.7, 0.5) * pal(m.w) * m.z;
        break;
      }
    } else {
      t += abs(d) * 0.3 + 0.01;
      col += saturate(0.001 * pal(m.w) * m.z / abs(d));
    }
  }
  col = mix(vec3(0), col, exp(-0.01 * t));
  return col;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  beat = time;
  beatTau = beat * TAU;
  beatPhase = phase(beat);
  
  scene = mod(floor(beat / 4), 2);
  // scene = 0;
  
  vec3 ro = vec3(0, 0, beat * 10);
  
  if (scene == 0) ro = vec3(0, 0, -25);
  
  vec3 rd = vec3(uv, 0.7);
  rd = normalize(rd);
  vec3 col = render(ro, rd);
  
	out_color = vec4(col, 1);
}
