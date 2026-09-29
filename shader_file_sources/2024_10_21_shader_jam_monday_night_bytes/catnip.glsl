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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define r2d(p,a) p=cos(a)*p + sin(a)*vec2(-p.y,p.x);

const float maxScale = 1024.;
const int steps = 4;
const float samples = 32.;

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float cat(vec2 p) {
	p.x = abs(p.x);
	vec2 q=p;
	q.x = abs(q.x-.2);
	q.y += q.x - .2;
	float r = abs(q.y)<.05 && q.x<.15 ? 1. : 0.;
	p.x -= .6;
	p.y = abs(p.y) - .08;
	r += abs(p.y)<0.03 && abs(p.x)<.15 ? 1. : 0.;
	return r;
}

float bdist(vec3 p, vec3 b, float r) {
  p=abs(p)-b - r;
  return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.) - r;
}

float tdist(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xy) - t.x, p.z);
  return length(q) - t.y;
}

float smin(float a, float b, float k) {
  float h = clamp(.5 + .5 * (b-a)/k, 0., 1.);
  return mix(b,a,h) - k*h* ( 1. - h);
}

float df(vec3 p, float s) {
  if (s < 1. / 3.) {
    vec3 q=p;
    p += sin(vec3(time * 1.242, time * 1.3735, time * 1.5738));
    r2d(p.xy, time * 1.247);
    r2d(p.xz, time * 1.672);
    
    q += sin(vec3(time * 1.442, time * 1.5735, time * 1.1738));
    r2d(q.xy, time * 1.547);
    r2d(q.xz, time * 1.472);
    
    return smin(
     tdist(p, vec2(1.5, .5)),
      tdist(q, vec2(1.5, .5)),
      0.5);
  } else if (s < 2. / 3.) {
    vec3 q=p;
    p += sin(vec3(time * 1.242, time * 1.3735, time * 1.5738));
    r2d(p.xy, time * 1.247);
    r2d(p.xz, time * 1.672);
    
    q += sin(vec3(time * 1.442, time * 1.5735, time * 1.1738));
    r2d(q.xy, time * 1.547);
    r2d(q.xz, time * 1.472);
    return smin(
      bdist(p, vec3(.5), 0.5),
      bdist(q, vec3(.5), 0.5),
      0.5);
  } else {
    return smin(
      length(p + vec3(sin(time * 1.324), sin(time * 1.535), sin(time*1.7536))*1.5) - 1.5,
      length(p + vec3(sin(time * 1.124), sin(time * 1.335), sin(time*1.5536))*1.5) - 1.5,
      0.5
    );
  }
}

vec3 norm(vec3 p, float s) {
  vec2 e = vec2(0.001,0);
  return normalize(vec3(
    df(p+e.xyy,s) - df(p-e.xyy,s),
    df(p+e.yxy,s) - df(p-e.yxy,s),
    df(p+e.yyx,s) - df(p-e.yyx,s)
  ));
}

vec3 rm(vec3 p, vec3 dir, float s) {
  for (int i=0; i<50; i++) {
    float d = df(p,s);
    if (d<0.0001) {
      vec3 n = norm(p,s);
      vec3 ld = normalize(vec3(sin(time * 0.47), sin(time * 0.562), sin(time * 0.62849)));
      return (abs(n)*.75 +.25) * abs(dot(n, ld)) + pow(max(0., dot(reflect(dir, n), ld)), 50.);
    }
    p += dir * d;
  }
  return vec3(0);
}

void main(void) {
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.x;
	uv *= 2.;
  uv.y += time / 3.;
  vec2 cell = vec2(floor(uv) + 10.);
  vec3 k = hash(vec3(floor(cell * vec2(0,1)), 0.1) / 19.);
  uv = fract(uv) * 2. - 1.;
  cell.x = mod(cell.x, 2.0);
  float sep = -0.3;
  vec3 p = vec3((cell.x * 2. -1.) * sep, 0, -5);
  vec3 dir = normalize(vec3(uv, 1));
  
  vec3 col = rm(p, dir, floor(mod(cell.y, 3.)) / 3.);
  
	out_color = vec4(col, 0.);
}
