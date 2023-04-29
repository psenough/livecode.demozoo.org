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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float fft(float d) {
  return texture( texFFT, fract(d) ).r;
}

#define time fGlobalTime
float beat, bpm, beatTau, beatPhase;

#define VOL 0
#define SOL 1
#define PI acos(-1)
#define TAU (2*PI)
#define saturate(x) clamp(x, 0, 1)
 
 vec3 pal(float x) {
  return 0.5 + 0.5 * cos(TAU * (x + vec3(0, 0.333, 0.666)));
}
 
void U(inout vec4 m, float d, float a, float b, float c) {
  m = (d < m.x) ? vec4(d, a, b, c) : m;
}
 
float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0)) + min(0, max(q.x, max(q.y, q.z)));
}
 
void rot(inout vec2 p, float x) {
  p = mat2(cos(x), sin(x), -sin(x), cos(x)) * p;
}

float phase(float x) {
  return floor(x) + 0.5 + 0.5 * cos(PI * exp(-5 * fract(x)));
}

vec3 target;

vec4 map(vec3 p) {
  vec4 m = vec4(1, VOL, 0, 0);
  vec3 pos = p;

  float a = 15;
  p = mod(p, a) - 0.5 * a;

  vec3 of = vec3(1.5);
  vec3 ro = vec3(0.34 - 0.02 * sin(TAU * phase(beat) / 4), 0.3, 0.3);
  p -= of;

  for(int i = 0; i < 5; i++) {
    p = abs(p + of) - of;
    rot(p.xz, ro.x * TAU);
    rot(p.yx, ro.y * TAU);
    rot(p.zy, ro.z * TAU);
  }

  float hue = 0.9 + pos.z * 1;
  if (mod(beat, 16) < 8) hue = 0.9;
  float emi = saturate(cos(beat * 2 + pos.z / 8));

  U(m, sdBox(p, vec3(1)), SOL, 0, 1);
  U(m, sdBox(p, vec3(0.1, 1.1, 1.1)), VOL, hue, emi);
  U(m, sdBox(p, vec3(1.1, 1.1, 0.1)), VOL, hue + 0.5, emi);
  
  vec3 p2 = pos - target;
  
  of = vec3(0.3);
  ro = vec3(0.34 - 0.2 * sin(TAU * phase(beat) / 4), 0.3, 0.3);
  
  for(int i = 0; i < 2; i++) {
    p2 = abs(p2 + of) - of;
    rot(p2.xz, ro.x * TAU);
    rot(p2.yx, ro.y * TAU);
    rot(p2.zy, ro.z * TAU);
  }

  float s = 0.4 + fft(0.1) * 30;
  hue = beat / 8;
  emi = fft(0.1) * 10;
  U(m, sdBox(p2, s * vec3(1)), SOL, beat / 8, 1);
  U(m, sdBox(p2, s * vec3(0.1, 1.1, 1.1)), VOL, hue + 0.5, emi);
  U(m, sdBox(p2, s * vec3(1.1, 1.1, 0.1)), VOL, hue + 0.0, emi);

  return m;
 }
 
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  bpm = 130;
  beat = bpm * time / 60;
  beatTau = beat * TAU;
  
  vec3 col = vec3(0);
  
  vec3 ro, ray;
  target = ro + vec3(0, 0, beat * 2);
  
  if (mod(beat, 16) < 4) {
    ro = target + vec3(0, 0, -10);
    ray = vec3(uv, 0.3);
  } else {
    float a = 6;
    ro = target + vec3(a * cos(beatTau / 32), sin(beatTau / 16), a * sin(beatTau / 32));
    vec3 up = vec3(0, 1, 0);
    vec3 fwd = normalize(target - ro);
    vec3 right = normalize(cross(up, fwd));
    up = normalize(cross(fwd, right));
    ray = normalize(uv.x * right + uv.y * up + fwd * 0.3);
  }
  
  float t, d;
  for(int i = 0; i < 300; i++) {
    vec3 p = ro + ray * t;
    vec4 m = map(p);
    d = m.x;
    
    if (m.y == VOL) {
      col += clamp(0.01 * m.w *pal(m.z) / abs(d), 0.0, 0.3);
      t += 0.25 * abs(d) + 0.01;
    } else {
      if (d < 0.01) {
        col += 0.01 * float(i);
        break;
      }
      
      t += d;
    }
  }
  
  col = mix(vec3(0), col, exp(-0.1 * t));
  col = saturate(col);
  vec2 uv2 = abs(uv);
  float hue = beat / 8;
  col += pal(hue) * clamp((fft(uv2.y * 0.2) - uv2.x), 0, 1);
  col += pal(hue + 0.5) * clamp((fft(uv2.y * 0.3) - uv2.x), 0, 1);
  // col += pal(hue + 0.5) * clamp((fft(uv2.y * 0.4) - uv2.x) * 10, 0, 1);
  
	out_color = vec4(col, 1);
}