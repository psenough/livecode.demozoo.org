#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define time fGlobalTime
#define PI acos(-1)
#define TAU (2 * PI)
#define VOL 0
#define SOL 1
#define saturate(x) clamp(x, 0, 1)

float beat, beatTau;
vec3 pos;
float scene;

vec3 pal(float h) {
  vec3 col = vec3(0.5) + 0.5 * cos(TAU * (vec3(0, 0.33, 0.67) + h));
  return mix(col, vec3(1), 0.1 * floor(h));
}

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p)-b;
  return length(max(q, 0)) + min(0, max(q.x, max(q.y, q.z)));
}

void rot(inout vec2 p, float a) {
  p *= mat2(cos(a), sin(a), -sin(a), cos(a));
}

void U(inout vec4 m, float d, float a, float b, float c) {
  if (d < m.x) m = vec4(d, a, b, c);
}

vec4 map(vec3 p) {
  pos = p;
  
  
  float a = 16;
  vec4 m = vec4(1);
  vec3 of1 = vec3(6.26, 2.7, 1.5);
  p = mod(p, a) - 0.5 * a;
  p -= of1;

  for (int i = 0; i < 1 + scene; i++) {
    p = abs(p + of1) - of1;
    rot(p.xz, TAU * (0.05 + scene * 0));
    rot(p.zy, TAU * 0.35);
    rot(p.xy, TAU * -0.05);
  }

  vec3 p2 = p;
  p2.y = mod(p2.y, 0.4) - 0.5 * 0.4;

  vec3 p3 = p;
  p3.y = mod(p3.y, 4) - 0.5 * 4;
  U(m, sdBox(p2, vec3(1, 0.05, 1)), SOL, 0.1, 1);
  U(m, sdBox(p, vec3(0.5, 20, 0.5)), VOL, saturate(cos(beatTau / 2 + p.y * TAU / 4)), 2.8 + 0.1 * scene + ((scene == 3) ? (fract(p.y * 2.3) - 2) : 0));
  U(m, sdBox(p3, vec3(1, 0.2, 1)), VOL, saturate(cos(beatTau / 2 + TAU / 32 * pos.z / 16)), 2.4 + 0.1 * scene);


  return m;
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 col = vec3(0);
  float t = 0;
  for(int i = 0; i < 100; i++) {
    vec3 p = ro + rd * t;
    vec4 m = map(p);
    float d = m.x;

    if (m.y == SOL) {
      t += d;
      if (d < t * 0.001) {
        col += float(i) / 50 * pal(m.w) * m.z;
        t += d;
        break;
      }
    } else {
      t += abs(d) + 0.1;
      col += 0.2 * pal(m.w) * m.z * exp(d);
    }
  }
  col = mix(vec3(0), col, exp(-0.001 * t));
  return col;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  beat = time * 120 / 60;
  beatTau = beat * TAU;
  scene = floor(beat / 4);
  scene += saturate(pow(fract(beat / 4), 1) - abs(uv.y));
  // vec2 up = vec2(0, 1);
  // rot(up, TAU * pow(fract(beat / 4), 3));
  // scene += dot(uv, up) > 0 ? 1 : 0;
  scene = mod(floor(scene + 0.5), 6);
  

  vec3 ro = vec3(0, 0, 4 * time);
  vec3 rd = vec3(uv, 1);
  rd = normalize(rd);
  vec3 col = render(ro, rd);

	out_color = vec4(col, 1);
}