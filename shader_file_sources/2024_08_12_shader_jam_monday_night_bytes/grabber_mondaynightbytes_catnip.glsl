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

#define time (fGlobalTime / 3.)
#define r2d(p,a) p=cos(a)*p + sin(a)*vec2(-p.y,p.x);

const float maxScale = 1024.;
const int steps = 4;
const float samples = 32.;
const float maxDist = 1e5;
const float zScale = 20.;

vec3 hash(vec3 p) {
	p = fract(p * vec3(443.537, 537.247, 247.428));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
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

float box(vec3 p, vec3 o, float s, float r) {
  p = abs(p - o) - s;
  return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.) - r;
}

float smin(float a, float b, float k) {
  float h = clamp(.5  + .5 * (b-a) / k, 0., 1.);
  return mix(b, a, h) - k * h * (1. - h);
}

float df(vec3 p) {
  float d = maxDist;
  float t = texture(texFFTIntegrated, 0.002).x / 4. + time;
  for (float i=0.; i<128.; i+=16.) {
    r2d(p.xy, 1.);
    r2d(p.xz, 1.);
    d = smin(
      d, 
      box(p, vec3(sin(t * 1.13738 + i), sin(t * 1.428952 + i), sin(t * 1.75367 + i)) * 3., 1., 0.2),
      0.9
    );
  }
  return d;
}

vec3 norm(vec3 p) {
  vec2 e= vec2(.001, 0.);
  return normalize(vec3(
    df(p + e.xyy) - df(p - e.xyy),
    df(p + e.yxy) - df(p - e.yxy),
    df(p + e.yyx) - df(p - e.yyx)
  ));
}

vec4 rm(vec3 p, vec3 dir) {
  float td = 0.;
  for (int i=0; i<100; i++) {
    float d = df(p);
    if (d<0.001) {
      vec3 n = norm(p);
      vec3 ld = normalize(vec3(sin(time * 1.427), sin(time * 1.7478), sin(time * 1.63578)));
      float l = abs(dot(n, ld));
      float s = pow(abs(dot(ld, reflect(dir, n))), 100.);
      return vec4(vec3(l + s), td);
    }
    p += dir * d;
    td += d;
  }
  return vec4(0.);
}

bool getEdge(vec2 c, vec2 r, float z) {
  bool edge = false;
  for (float y=-1.; y<=1.; y++) {
    for (float x=-1.; x<=1.; x++) {
      if (x != 0. && y!= 0.) {
        vec2 uv = vec2(c.x + x, c.y + y) / r;
        float tz = texture(texPreviousFrame, uv).w * zScale;
        edge = edge || distance(tz, z) > 0.5;
      }
    }
  }
  return edge;
}

vec3 fb(vec2 uv) {
  vec3 col = vec3(0);
  for (int i=0; i<8; i++) {
    vec3 tc = texture(texPreviousFrame, uv).rgb;
    tc -= .5;
    r2d(tc.xy, 0.2);
    r2d(tc.xz, 0.2);
    tc *= .9;
    tc += .5;
    col += tc;
    
    uv -= .5;
    uv *= sin(texture(texFFTIntegrated, 0.01).x / 5.) * .02 + 1.;
    r2d(uv, sin(texture(texFFTIntegrated, 0.01).x / 3.) * .03);
    uv += .5;
  }
  return col / 8.;
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float z = texture(texPreviousFrame, uv).w * zScale;
	vec3 col = vec3(0);
  
  float tmp = 3.;
  for (float x=0.; x<16.; x++) {
    bool edge = getEdge(gl_FragCoord.xy - vec2(x * x * 2., 0.), v2Resolution.xy, z);
    if (edge) col -= vec3(1,0,1) * tmp;
    tmp *= 0.9 * min(1., texture(texFFT, gl_FragCoord.y / v2Resolution.y + time).r * 100.);
  }
  
  col += fb(uv) * 0.98;
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 p = vec3(0,0,-6),
  dir = normalize(vec3(uv, 1.));
  tmp = length(uv);
  float a = tmp * 2.5;
  dir = -vec3(uv / tmp * sin(a), -cos(a));
  r2d(p.xy, time);
  r2d(dir.xy, time);
  r2d(p.xz, time);
  r2d(dir.xz, time);
  
  vec4 d = rm(p, dir);
  
  if (d.w == maxDist) d.w = 0.1;
	/*vec3 catC = vec3(0);
	for (float i=0.;i<9.;i++) {
		vec2 o = vec2(sin(i / 10.+time * 1.4284), cos(i/10.+time * 1.325));
		o = pow(abs(o), vec2(7.)) * sign(o);
		catC[int(i)/3] += cat(uv + o / 4.) / 3.;
	}*/
	out_color = vec4(d.xyz + col, d / zScale);
}
