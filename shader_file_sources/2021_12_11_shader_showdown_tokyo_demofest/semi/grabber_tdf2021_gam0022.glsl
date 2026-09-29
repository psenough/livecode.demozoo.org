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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define time fGlobalTime
#define saturate(x) clamp(x, 0, 1)
#define PI acos(-1)
#define TAU (2*PI)
#define beat (time*140/60)
#define VOL 0
#define SOL 1
#define beatTau (beat*TAU)

float fft(float d) {
  return texture( texFFT, fract(d) ).r;
}

float ffts(float d) {
  return texture( texFFTSmoothed, fract(d) ).r;
}


float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0)) + min(0, max(q.x,max(q.y,q.z)));
}

void U(inout vec4 m, float d, float a, float b, float c) {
  if (d < m.x) m = vec4(d, a, b, c);
}

vec3 pal(float a) {
  return 0.5 + 0.5 * cos(TAU * (a + vec3(0, 1, 2) / 3));
}

void rot(inout vec2 p, float a) {
  p *= mat2(cos(a), sin(a), sin(-a), cos(a));
}

vec4 map(vec3 p) {
  vec4 m = vec4(1, VOL, 0, 0);
  vec3 pos = p;
  vec3 id = abs(pos);
  
  float a = 1 + 5 * ffts(0.01);
  p = mod(p, a) - 0.5 * a;
  
  float b = 1.4;
  float s = 1;
  
  for (int i = 0; i < 5; i++) {
    p = abs(p) - 0.5;
    rot(p.xz, -0.5);
    p = abs(p) - 0.4;
    rot(p.zy, -0.2);
    
    s *= b;
    p *= b;
  }
  
  float d = pow(fract(id.x * 5), 0.5);
  
  U(m, sdBox(p, vec3(2, 0.1, 0.1)) / s, SOL, 1, pos.x * 10);
  U(m, sdBox(p, vec3(2, 0.2, 0.1)) / s, VOL, 10 * fft(d), d);
  U(m, sdBox(p, vec3(0.3, 5, 0.1)) / s, VOL, 200 * fft(d), d);
  
  return m;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 col = vec3(0);
  
  vec3 ro = vec3(0, 0, time);
  vec3 ray = vec3(uv, 1);
  rot(ray.xy, TAU * 2.313 * floor(beat));
  ray = normalize(ray);
  
  float t = 0;
  for(int i = 0; i < 100; i++) {
    vec3 p = ro + ray * t;
    vec4 m = map(p);
    float d = m.x;
    
    if (m.y == SOL) {
      t += d;
      if (d < 0.01) {
        col += 0.01 * float(i);
        break;
      }
    } else {
      t += abs(d) * 0.5 + 0.01;
      col += saturate(0.002 * pal(m.w) * m.z / abs(d));
    }
  }
  
  vec2 uv2 = saturate(abs(uv));
  
  float wave = fft(uv2.x * 0.5) - uv2.y;
  
  col = mix(vec3(0), col, exp(-1.4 * t));
  
  float b = mod(beat, 4);
  
  if (b < 1) {
    col += 5 * wave;
  } else if (b < 2) {
    col += -100 * wave;
  } else if (b < 3) {
    rot(uv, -TAU * mod(beat, 1) / 4);
    float d = abs(uv.x) + abs(uv.y);
    
    d = mod(d * 4, 0.5);
    
    float th = exp(-5 * mod(beat, 1));
    
    if (d < th - 0.1 && d < th) {
      col += 5 * wave;
    } else {
      col += -100 * wave;
    }
  } else {
    col += 10 * wave;
  }
  
  
  
	out_color = vec4(col, 1);
}