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

float pDist(vec3 p, vec3 dir) {
  if (dir.y > 0.) return distance(p.y, 4.) / -dir.y;
  return distance(p.y, -4.) / dir.y;
}

vec2 coord(vec3 p, vec3 dir) {
   float d = pDist(p, dir);
    p += dir * d;
    
    return p.xz / 8.;
}

float map(vec2 c) {
  float t = texture(texFFTIntegrated, 0.02).x * 1.5;
  for (float i=16.; i>1.; i /= 2.) {
    vec3 k = hash(vec3(floor(c / i), .1));
    if (k.x < 0.25 || i < 3.) {
      c = fract((c / i) * i) * 2. - 1.;
      if (k.y < 1./3.) {
        return 1. - step(0.1, abs(fract(length(c) - time / 3.)));
      }else if (k.y < 2./3.) {
        //c = abs(fract(c + time));
        return 1. - step(0.1, distance(c.y, sin(c.x * 3. + time * 8.) * texture(texFFTSmoothed, 0.03).x));
      }else {
        c = abs(c);
        return 1. - step(0.1, min(c.x, c.y));
      }
    }
  }
  
  return 0.;
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	
  vec3 catC = vec3(0);
	/*for (float i=0.;i<9.;i++) {
		vec2 o = vec2(sin(i / 10.+time * 1.4284), cos(i/10.+time * 1.325));
		o = pow(abs(o), vec2(7.)) * sign(o);
		catC[int(i)/3] += cat(uv * .5 + o / 4.) / 3.;
	}*/
  
  const int samples = 16;
  for (int i=0; i<samples; i++) {
    float interval = float(i) / float(samples);
    float t = time + interval / 40.;
    float dx = t * .434893;
    float dy = t * .5185378;
    vec3 p = vec3(sin(dx) * 8., sin(dy) * 3., -t * 30.);
    //vec3(sin(texture(texFFTIntegrated, 0.07).x * 2.) * 3.,sin(texture(texFFTIntegrated, 0.05).x) * 3.,-t);
    float a = length(uv);
    vec2 u = uv / a;
    a = a * (sin(texture(texFFTIntegrated, 0.03).x / 3.) * .5 + 1. + interval / 32.);
    vec3 dir = -vec3(u * -sin(a), -cos(a));
    r2d(dir.xz, cos(dx) / 1.);
    r2d(dir.xy, cos(-dy) / 1.);
    r2d(dir.yz, cos(dy) / 1.);
  
    vec2 c = coord(p, dir);
   
    catC[int(interval * 3.)] += map(c) / float(samples / 4.);
    //catC[int(interval * 3.)] += 1. -step(0.03, min(c.x, c.y));
	}
	out_color = vec4(catC, 0.);
}
