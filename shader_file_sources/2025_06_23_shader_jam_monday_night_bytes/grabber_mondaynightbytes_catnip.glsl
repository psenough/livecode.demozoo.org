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
#define pi acos(-1)

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

vec4 plas( vec2 v, float time ) {
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

float smin(float a, float b, float k) {
  float h = clamp(.5 + .5 * (b-a) / k, 0., 1.);
  return mix(b, a, h) - k * h * (1. - h);
}

float torus(vec3 p, vec2 t) {
  p.xy = vec2(length(p.xz) - t.x, p.y);
  return length(p.xy) - t.y;
}

float line(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p - a, ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
  return length(pa - ba * h) - r;
}

float df(vec3 p) {
  float m = clamp(-p.z + 1.3, 0.3, 1.);
  float t = texture(texFFTIntegrated, 0.03).x * 3.;
  vec3 hip = vec3(sin(t) * .3, -1.5, -.25);
  float d = torus(p - hip, vec2(1.75, .5));
  d = smin(d, torus(p - vec3(sin(t + .4) * .3, -.75, 0), vec2(2, .5)), m);
  d = smin(d, torus(p - vec3(sin(t + .8) * .3, 0, 0), vec2(2, .5)), m);
  d = smin(d, torus(p - vec3(sin(t + 1.2) * .3, .75, -.2), vec2(1.8, .5)), m);
  vec3 k = vec3(sin(t + 1.6) * .3, 1.5, -.45), a;
  d = smin(d, torus(p - k, vec2(1.55, .5)), m);
  
  // arm
  vec3 q = p;
  a = vec3(0, 2.5, 0);
  r2d(p.xy, sin(texture(texFFTIntegrated, 0.03).x *4.) / 4.);
  r2d(p.yz, sin(texture(texFFTIntegrated, 0.05).x *4.) / 4.);
  a += k;
  d = smin(d, line(p, k, a, .5), .5);
  d = smin(d, length(p - a) - 1.7, .5);
  
  p.x = abs(p.x);
  t = texture(texFFTIntegrated, 0.07).x * 2.;
  k.x += 2;
  a = vec3(2.5, 0, 0);
  r2d(a.xy, sin(t) / 2.);
  r2d(a.yz, cos(t) / 2.);
  a += k;
  d = smin(d, line(p, k, a, 1 - p.x / 20.), 1.);
  t = texture(texFFTIntegrated, 0.09).x * 2.5;
  k = a;
  a = vec3(2.5, 0, 0);
  r2d(a.xy, sin(t) / 2.);
  r2d(a.yz, cos(t) / 2.);
  a += k;
  d = smin(d, line(p, k, a, 1 - p.x / 20.), .3);
//  d = smin(d, line(p, k, a, 1 + p.y / 20.), .5);
  
  // leg
  p = q;
  t = texture(texFFTIntegrated, 0.05).x;
  k = hip - vec3(2 + sin(t), 3, cos(t)),
  a = k - vec3(-sin(t), 3, -cos(t));
  d = smin(d, line(p, hip - vec3(1, 0, 0), k, 1 + p.y / 20.), 1.);
  d = smin(d, line(p, k, a, 1 + p.y / 20.), .5);
  k = hip - vec3(-2 + sin(t), 3, cos(t)),
  a = k - vec3(-sin(t), 3, -cos(t));
  d = smin(d, line(p, hip - vec3(1, 0, 0), k, 1 + p.y / 20.), 1.);
  d = smin(d, line(p, k, a, 1 + p.y / 20.), .5);
  return d;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(.001, 0);
  return normalize(vec3(
    df(p + e.xyy) - df(p - e.xyy),
    df(p + e.yxy) - df(p - e.yxy),
    df(p + e.yyx) - df(p - e.yyx)
  ));
}

vec3 rm(vec3 pos, vec3 dir) {
  for (int i=0; i<80; i++) {
    float d = df(pos);
    if (d < 0.001) {
      vec3 n = norm(pos);
      pos += 4;
      r2d(pos.xy, pos.z + time);
     // r2d(pos.xz, pos.y + time);
      return (abs(sin(pos)) * .5 + .5) * abs(dot(n, normalize(vec3(1,1,1))));
    }
    pos += dir * d;
  }
  return vec3(-1);
}

void main(void) {
  vec2 u = gl_FragCoord.xy / v2Resolution.xy;
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	
  float z = sin(time) * 3.;
  //z = pow(abs(z) + .01, 5.) * sign(z);
  vec3 pos = vec3(0,0,10 + z),
  dir = normalize(vec3(uv, -1.));
  
  r2d(pos.xy, time * .5463);
  r2d(pos.yz, time * .34789);
  r2d(dir.xy, time * .5463);
  r2d(dir.yz, time * .34789);
  
  vec3 col = rm(pos, dir);
  if (col.x < 0.) {
    if (fract(time / 4.) < .5) u = fract(u * 2.);
    u -= .5;
    for(int i=0; i<3; i++) {
      u += vec2(sin(time * 0.2478), cos(time * .45378)) * .03;
      u *= .97001;
      r2d(u, sin(texture(texFFTIntegrated, 0.05).x) * .2);
      col[i] = texture(texPreviousFrame, u + .5).r * .95;
    }
  }
  
	out_color = vec4(col, 0.);
}
