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
#define Eps 0.001

const float maxScale = 1024.;
const int steps = 4;
const float samples = 32.;

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

float smin(float a, float b, float k) { 
  float h = clamp(.5 + .5 * (b-a)/k, 0., 1.);
  return mix(b, a, h) - k * h * (1. - h);
}

float lDist(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p - a, ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
  return length(pa - ba * h) - r;
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

float df(vec3 p, float t) {
  vec3 c = hash(floor(p.xz / 6.).xyy);
  t += c.x * 3.;
  p.xz = mod(p.xz, 6.) - 3.;
  //r2d(p.xz, c.y * 3.);
  
  p.y -= abs(sin(t)) - .5;
  
  // body
  float d = lDist(p, vec3(0,.7,0), vec3(0), 0.4);
 
  // l1
  vec3 a = vec3(0,-.3,-.3), b = vec3(0,-.6, 0);
  r2d(b.xy, sin(t));
  float e = lDist(p, a, a+b, 0.2);
  d = smin(d, e, .2);
  
  // ll1
  a = a+b;
  b = vec3(0, -.6, 0);
  r2d(b.xy, sin(-t) / 4. - 1.);
  e = lDist(p, a, a+b, 0.2);
  d = smin(d, e, .2);
  
  
  // l2
  a = vec3(0,-.3,.3); b = vec3(0,-.6, 0);
  r2d(b.xy, sin(-t));
  e = lDist(p, a, a+b, 0.2);
  d = smin(d, e, .2);
    
  // ll2
  a = a+b;
  b = vec3(0, -.6, 0);
  r2d(b.xy, cos(-t) / 2. - 1.);
  e = lDist(p, a, a+b, 0.2);
  d = smin(d, e, .2);
  
  // a1
  a = vec3(0, .6, -.4), b = vec3(.5, 0, 0);
  r2d(b.xy, sin(-t) / 2. - 1.);
  e = lDist(p, a, a+b, 0.15);
  d = smin(d, e, .2);
  
  // a12 
  a = a+b;
  b = vec3(0, .6, 0);
  r2d(b.xy, cos(-t) / 4. - 1.5);
  e = lDist(p, a, a+b, 0.14);
  d = smin(d, e, .2);
  
  // a2
  a = vec3(0, .6, .4), b = vec3(.5, 0, 0);
  r2d(b.xy, sin(t) / 2. - 1.);
  e = lDist(p, a, a+b, 0.15);
  d = smin(d, e, .2);
  
  // a22 
  a = a+b;
  b = vec3(0, .6, 0);
  r2d(b.xy, cos(t) / 4. - 1.5);
  e = lDist(p, a, a+b, 0.14);
  d = smin(d, e, .2);
  
  // head
  p.xy -= vec2(.2, 1.3);
  e = length(p) - .35;
  d = smin(d, e, .1);
  
  p.z = abs(p.z);
  e = length(p - vec3(.1, .3, .2)) - .1;
  float f = length(p - vec3(.17, .3, .22)) - .1;
  e = max(e, -f);
  d = min(d, e);
 
  e = length(p - vec3(.25, -.75, .3)) - .15;
  d = smin(d, e, .4);
  return d;
}

vec3 norm(vec3 p, float t) {
  vec2 e = vec2(Eps, 0.);
  return normalize(vec3(
    df(p + e.xyy, t) - df(p - e.xyy, t),
    df(p + e.yxy, t) - df(p - e.yxy, t),
    df(p + e.yyx, t) - df(p - e.yyx, t)
  ));
}

vec3 light(vec3 n, vec3 dir) {
  float h = dot(n, dir);
  vec3 o = abs(h) < 0.6 ? vec3(1,.7,.3) : vec3(0);
  //o = max(o, vec3(1, .7, .2) * dot(n, normalize(vec3(1,1,-1))));
  return o;
}

vec4 rm(vec3 p, vec3 dir, float t) {
  for (int i=0; i<100; i++) {
    float d = df(p, t);
    if (d < Eps) {
      vec3 n = norm(p, t);
      return vec4(light(n, dir), 1.);
    }
    p += dir * d;
  }
  return vec4(0.);
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
  vec3 p = vec3(0, 0.5, -6),
  dir = normalize(vec3(uv, 1.));
  //r2d(p.xz, time);
  r2d(dir.xz, sin(time) / 3.);
  p.x -= time;
  //r2d(dir.yz, .5);
 	vec3 catC = vec3(0);
vec4 bkg = vec4(0.);
  bool refine = true;
  vec2 coords = gl_FragCoord.xy / 512. + time;
  vec3 k;
	for (float i=0.;i<10.;i++) {
		//vec2 o = vec2(sin(i / 10.+time * 1.4284), cos(i/10.+time * 1.325));
		//o = pow(abs(o), vec2(7.)) * sign(o);
		//catC[int(i)/3] += cat(uv + o / 4.) / 3.;
    
    if (refine) {
      k = hash(floor(coords.xyy));
      if (k.x < .8) {
        coords *= 2.;
      } else {
        break; 
        refine = false;
      }
    }
	}
  k = hash(k + floor(texture(texFFTIntegrated, 0.02).x / 2.) / 100.);
        coords = gl_FragCoord.xy / v2Resolution.xy;
        coords += (k.yz - .5) * 0.01;// * texture(texFFTSmoothed, k.x * .1).x;
        //coords.x += 0.004;
        bkg = texture(texPreviousFrame, coords);
  //if (bkg.a == 1.) bkg.rgb = vec3(1.);
  bkg.rgb *= hash(k) * .2 + .86;
  
  float t = time * 3. + k.z / 3.;// + texture(texFFTIntegrated, 0.001).x;
  vec4 c2 = k.y > 0.5 ? rm(p, dir, t) : vec4(0.);
	if (c2.a == 0.) {
    c2.rgb = bkg.rgb;
  }
  out_color = c2;
}
