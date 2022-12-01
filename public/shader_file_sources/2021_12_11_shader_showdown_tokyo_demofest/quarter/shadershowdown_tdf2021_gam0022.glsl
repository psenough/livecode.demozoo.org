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
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 200.0 * sin(fGlobalTime) );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define time fGlobalTime
#define PI acos(-1)
#define TAU (2.*PI)
#define saturate(x) clamp(x, 0, 1)

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0)) + min(0, max(q.x, max(q.y, q.z)));
}

void U(inout vec4 m, float d, float a, float b, float c) {
  if (d < m.x) m = vec4(d, a, b, c);
}

void rot(inout vec2 p, float a) {
  p *= mat2(cos(a), sin(a), -sin(a), cos(a));
}

vec4 map(vec3 p) {
  vec3 pos = p;
  p = mod(p, 1) - 0.5;
  // return length(p) - 0.1;
  vec4 m = vec4(1, 1, 1, 1);
  
  float s = 1.;
  for(int i = 0; i < 5; i++) {
    p = abs(p) - 0.5;
    rot(p.xy, -0.5);
    p = abs(p) - 0.4 + 0. * cos(TAU * time / 4);
    rot(p.yz, -0.1);
    
    float a = 1.4;
    p *= a;
    s *= a;
  }
  
  U(m, sdBox(p, vec3(0.5, 0.05, 0.05)) / s, 1, 1, 0);
  U(m, sdBox(p, vec3(0.5 + 0.5 * (cos(TAU * time / 4)), 0.06, 0.05)) / s, 0, 0.1, 0.5);
  U(m, sdBox(p, vec3(0.2, 0.6, 0.1)) / s, 0, saturate(cos(TAU * (time + pos.z / 8))), -0.5);
  
  return m;
}

vec3 fbm(vec3 p) {
  return sin(p) + sin(p*2) / 2 + sin(p*4) / 4;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	/*vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;*/
  
  vec3 col = vec3(0);
  
  vec3 ro = vec3(0, 0, time);
  vec3 ray = vec3(uv, 1.1 + cos(TAU * time / 8));
  ray += 0.1 * fbm(vec3(1, 2, 3) + TAU * time / 4);
  // rot(ray.xy, time);
  // rot(ray.yz, time);
  ray = normalize(ray);
  
  float t = 0.;
  for(int i = 0; i < 100; i++) {
    vec3 p = ro + ray * t;
    vec4 m = map(p);
    float d = m.x;
    if (m.y == 1.) {
      t += d;
      if (d < 0.001) {
        col += 0.005 * float(i);
        break;
      }
    } else {
      t += abs(d) * 0.5 + 0.01;
      col += saturate(0.001 * vec3(1 + m.w, 1, 1 - m.w) * m.z / abs(d));
    }
  }
  
  col = mix(vec3(0), col, exp(-0.7 * t));
  
  out_color = vec4(col, 1);
  
}