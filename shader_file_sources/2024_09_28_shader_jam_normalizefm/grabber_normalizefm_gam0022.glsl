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

float sdN(vec3 p, float z) {
  rot(p.xy, -0.07 * TAU);
  if (p.x < 0) p.y = -p.y;
  p.x = abs(p.x);
  float w = 0.13;
  float h = 0.07;
  float s = 4;
  float a = w/h/s*p.y;
  return min(sdBox(p, vec3(0.2, h, z)), sdBox(p - vec3(0.25 - a, h * (s-1), 0), vec3(w - a, h * s, z)));
}

vec4 map(vec3 pos) {
  vec4 m = vec4(1);
  
  if (scene == 0) {
    vec3 p = pos;
    rot(p.xz, beatTau / 8);
    U(m, sdN(p, 0.1), SOL, 10, 1);
  } else if (scene == 1) {
    vec3 p = pos;
    float a = 2;
    rot(p.xz, beatTau / 32);
    p -= 0.5 * a;
    p = mod(p, a) - 0.5 * a;
    rot(p.xz, beatTau / 8);
    U(m, sdN(p, 0.1), SOL, 10, 1);
  } else if (scene == 3) {
    vec3 p = pos;
    float a = 2;

    // rot(p.xz, beatTau / 32);
    p -= 0.5 * a;
    vec3 grid = floor(p / a);
    p = mod(p, a) - 0.5 * a;
    pmod(p.xy, 8);
    p.y -= 0.6 + 0.3 * cos(beatTau / 32);
    rot(p.xz, beatTau / 8);
    float e = saturate(cos(beatTau + TAU * pos.z / 16));
    if (e > 0.9) {
      U(m, sdN(p, 0.1), VOL, 10 * e, fract(dot(grid, vec3(0.2))));
    } else {
      U(m, sdN(p, 0.1), SOL, 10, fract(dot(grid, vec3(0.2))));
    }
  } else {
    vec3 p = pos;
    float a = 2;
    vec3 of = vec3(0.32, 0, 0);
    float s = 1;
    // rot(p.xy, pos.z * 0.2);
    // p.y -= cos(p.z * TAU / 8) * 0.5;
    p = mod(p, a) - 0.5*a;
    p -= of;
    for (int i = 0; i < 3; i++) {
      p = abs(p + of) - of;
      U(m, sdN(p * 2, 0.02) / 2, VOL, 1, 0.4);
      rot(p.xz, TAU * 0.8);
      rot(p.yz, TAU * 0.3 + beatPhase + pos.z);
    }
    
    float scale = 1.01;
    s *= scale;
    p *= scale;
    
    float e = saturate(cos(beatTau + TAU * pos.z / 16));
    U(m, sdN(p, 0.02) / s, VOL, 10 * e, 0 * fract(pos.z / 8));
    U(m, sdN(p, 0.1) / s, SOL, 1, 0);
  }
  return m;
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 col = vec3(0);
  float t = 0;
  for (int i = 0; i < 100; i++) {
    vec3 p = ro + rd * t;
    vec4 m = map(p);
    float d = m.x;
    if (m.y == SOL) {
      t += d * 0.5;
      if (d < t * 0.001) {
        vec3 n = normal(p);
        // col += saturate(dot(n, normalize(vec3(1, 1, -1))));
        col += evalLight(p, n, -rd, normalize(vec3(1, 1, -1)), vec3(1), 0.7, 0.5) * pal(m.w) * m.z;
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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	/*vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;*/
  
  beat = time * 145 / 60;
  beat = mod(beat, 8 * 32);
  beatTau = beat * TAU;
  beatPhase = phase(beat);
  float len = 1.;
  scene = floor(mod(beat, len * 4) / len);
  // scene = 4;
  
  vec3 ro = vec3(0, 0, -1);
  if (scene >= 2) ro = vec3(0, 0, beat);
  vec3 rd = vec3(uv, 1.1 + 0 * cos(beatTau / 8) + 0 * texture(texFFT, 0.1));
  rd = normalize(rd);
  // rot(rd.xz, beatTau / 8);
  // rot(rd.xy, beatTau / 8);
  vec3 col = render(ro, rd);
  col += (1 - saturate(5 * abs(uv.y) - 4 * texture(texFFT, saturate(0.2 * abs(0.9 * uv.x))).r)) * pal(fract(beat / 8 + uv.x / 2));
  out_color = vec4(col, 1);
}
