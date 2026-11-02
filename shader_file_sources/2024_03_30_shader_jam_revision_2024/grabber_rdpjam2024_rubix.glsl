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

#define PI 3.14159526535
#define TAU 6.283185307179586
#define t fGlobalTime
mat2 r2d(float a) { float c=cos(a), s=sin(a); return mat2(c, -s, s, c); }
float sphere(vec3 p, float r) { return length(p) - r; }
float extrude(float d, float d2) { return max(d, -d2); }
vec3 gay(float t) { return 0.5 + 0.5 * cos(TAU * (t + vec3(0.33, 0.66, 1.))); }


float face(vec3 p, vec3 off) {
  return sphere(p - off, .8+sin(t*3.+(off.x+off.y+off.z)*1.5)*.1);
}

float thing(vec3 p) {
  float s = sphere(p, 1.);
  vec2 off = vec2(1., 0.);
  s = extrude(s, face(p, off.xyy));
  s = extrude(s, face(p, off.yxy));
  s = extrude(s, face(p, off.yyx));
  s = extrude(s, face(p, -off.xyy));
  s = extrude(s, face(p, -off.yxy));
  s = extrude(s, face(p, -off.yyx));
  return s;
}
float map(vec3 p) {
  
  p.xy *= r2d(t*1.8);
  p.zy *= r2d(t*1.7);
  p.xz *= r2d(t*1.5);
  vec2 o = vec2(1.+sin(t*2.73)*.9, 0.);

  float s = 10000.;//thing(p);
  s = min(s, thing(p + o.xyy));
  s = min(s, thing(p + o.yxy));
  s = min(s, thing(p + o.yyx));
  s = min(s, thing(p - o.xyy));
  s = min(s, thing(p - o.yxy));
  s = min(s, thing(p - o.yyx));
  return s;
}

vec3 normal(vec3 p) {
  vec2 e = vec2(0.001, 0.);
  return normalize(vec3(
    map(p+e.xyy)-map(p-e.xyy),
    map(p+e.yxy)-map(p-e.yxy),
    map(p+e.yyx)-map(p-e.yyx)));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y); uv -= 0.5; uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float a = atan(uv.x / uv.y) / 3.14;

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
  
  vec3 ro=vec3(0., 0., -4.);
  vec3 rd=vec3(uv, 1.);
  vec3 ld=normalize(vec3(sin(t), cos(t), 3.));
  vec3 p=ro;
  
  float tt = t;
  if (abs(uv.y) + mod(t*.2, .5) > .5) tt += 3.;
  float k = (1.5+sin(tt)*sin(tt)*sin(tt)*2.);
  k = pow(k, 3.);
  vec2 uv2 = r2d(length(uv)*k) * uv;
  vec3 bgcol = vec3(0., tan(uv.y), .5-abs(uv2.x));
  bgcol += .01/(uv2.y+.001);
  bgcol.r = pow(bgcol.r, 2.);
  
  vec3 col = vec3(0.);
  for (int i = 0; i < 50.; i++) {
    float d = map(p);
    if (d > 500.) break;
    if (d < 0.001) {
      vec3 n = normal(p);
      float diff = dot(-ld, n);
      float spec = pow(clamp(0., 1., dot(-ld, n)), 200);
      col = n * diff + vec3(1.) * spec;
      col.r = pow(col.r, 1.5);
      col.g = pow(col.g, 1.5);
      col.b = pow(col.b, 1.5);
      break;
    }
    p += rd * d;
    bgcol += 0.009 * gay(a);
  }
  bgcol = sqrt(bgcol);
  out_color = vec4((col.x == 0 ? bgcol : col), 1.);
}