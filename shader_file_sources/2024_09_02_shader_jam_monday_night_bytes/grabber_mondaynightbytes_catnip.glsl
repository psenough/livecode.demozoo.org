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

vec3 fb(vec2 uv, vec2 ps) {
  uv += (hash(vec3(floor(uv) * 160., 0.1)).xy - .5+vec2(sin(time), cos(time))*texture(texFFTSmoothed, 0.01).x*.2) * .1;
  uv = (uv - .5) * (1. - fract(texture(texFFTIntegrated, 0.01).x*.03)*.03);
  r2d(uv, sin(texture(texFFTIntegrated, 0.01).x*.1)*.03);
  uv += .5;
  vec3 ma = vec3(0.), mi = vec3(1.), md = vec3(0.);
  float maxL = 0.;
  for (float y=-1.;y<=1.;y++) {
    for (float x=-1.;x<=1.;x++) {
      vec3 q = texture(texPreviousFrame, uv + ps * vec2(x,y)).rgb;
      ma += q;
      if (x==0. && y==0.) mi = q;
      if (q != ma && q != mi) md = q;
    }
  }
  return max(mi, ma/9);
}

vec3 glitter(vec3 p, float s) {
  p *= s;
  p += sin(p.yzx + sin(p.zxy)); 
  vec3 col = hash(floor(p));
  float size = col.x / 1.;
  col = hash(col);
  col = pow(col, vec3(2.));
  p = fract(p);
  col *= max(p.x, max(p.y, p.z)) < size ? 1. : 0.;
  return col * vec3(1,texture(texFFT, 0.05).x*30.,1);
}

float smin(float a,float b,float k) {
  float h = clamp(.5+.5*(b-a)/k, 0., 1.);
  return mix(b,a,h) - k*h*(1.-h);
}

float df(vec3 p) {
  vec3 op = p, q;
  // body
  p.z = max(abs(p.z) - 1., 0.);
  float d = length(p) - 1.;
  
  // head
  p = op;
  p -= vec3(0,1,1.5);
  d = smin(d, length(p) - .9, .4);
  q = p;
  p -= vec3(0,-.1,.9);
  d = smin(d, length(p) - .5, .3);
  p = q;
  
  // ear
  p.x = abs(p.x);
  p -= vec3(.5, .8, 0);
  p.z *= 3.;
  d = min(d, (length(p) - .3) / 3.);
  
  p = op;
  // leg
  p.x = abs(p.x);
  p.z = abs(p.z);
  p -= vec3(.8, -.8, 1.);
  p.y = max(0., abs(p.y) - .5);
  d = min(d, length(p) - .4);
  return d;
}

vec4 rm(vec3 p, vec3 d) {
  for (int i=0; i<50; i++) {
    float dist = df(p);
    if (dist < 1e-3) {
      vec3 g = glitter(p, 15.);
      return vec4(g, length(g));
    }
    p += d * dist;
  }
  
  return vec4(0.);
}

void main(void) {
	vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
	//uv -= 0.5;
	//uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	//uv *= 2.;
  bool clear = false;
	vec3 catC = clear ? vec3(0.) :fb(uv, 1. / v2Resolution.xy) * (1.-texture(texFFTSmoothed, 0.03).x / 1.);
  uv = uv * 2. - 1.;
  uv.y *= v2Resolution.y / v2Resolution.x;
  
  vec3 p = vec3(0,0,-7+texture(texFFTSmoothed, 0.05).x * 20.);
  vec3 d = normalize(vec3(uv, 1.));
  r2d(p.xz, time/2.);
  r2d(d.xz, time/2.);
  
  vec4 tmp = rm(p, d);
  catC = mix(catC, tmp.rgb, tmp.a);
	for (float i=0.;i<9.;i++) {
		vec2 o = vec2(sin(i / 10.+time * 1.4284), cos(i/10.+time * 1.325));
		o = pow(abs(o), vec2(7.)) * sign(o);
		//catC[int(i)/3] += cat(uv + o / 4.) / 3.;
	}
	out_color = vec4(catC, 0.);
}
