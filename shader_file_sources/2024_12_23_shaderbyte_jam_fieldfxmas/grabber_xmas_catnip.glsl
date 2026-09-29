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

vec3 paint=vec3(0.1,0.3,0.8);

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

float bd(vec3 p, vec3 b, vec3 s, float r) {
  p = abs(p - b) - s + r;
  return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.) - r;
}

float torus(vec3 p, vec2 s) {
  vec2 t = vec2(length(p.xz) - s.x, p.y);
  return length(t) - s.y;
}

vec2 df(vec3 p) {
  vec3 q = p;
  
  vec2 d = vec2(p.y, 0), 
  e = vec2(bd(p, vec3(0), vec3(2,1.5,2), .1), 1);
  e.x = max(e.x, -bd(p, vec3(0), vec3(1.6, 2.2, 1.6), .1));
  
  p.x = mod(p.x, .2)-.1;
  e.x = max(e.x, -bd(p, vec3(0, 1.5,0), vec3(.05, .05, 3.), 0));
  
  p=q;
  p.x = mod(p.z, .2)-.1;
  e.x = max(e.x, -bd(p, vec3(0, 1.5,0), vec3(3., .05, .05), 0));
  
  p = q;
  p.y = max(0., p.y - .5);
  e.x = max(e.x, -length(p.yz) + .5);
  
  p = q;
  d=d.x<e.x?d:e;
  
  p.xz = abs(p.xz) - 2.;
  e.x = max(p.y - 2., length(p.xz) - .5);
  
  d=d.x<e.x?d:e;
  
  p = q;
  
  e.y = 3;
  
  vec3 k = hash(floor(p.xzz));
  p.xz = fract(p.xz) - .5;
  r2d(p.xz, k.x*6.);
  e.x = length(p) -.1;
  p.xy -= .07;
  p.y -= abs(sin(time*4.))*.05;
  e.x = min(e.x, length(p) - .05);
  p.z = abs(p.z)-.03;
  p.y -= .05;
  e.x = min(e.x, length(p)-.02);
  d=d.x<e.x?d:e;
  p = q;
  //d=d.x<e.x?d:e;

  e.x = torus(p, vec2(5, .5));
  e.y=2;
  d=d.x>-e.x?d:e;
  
  e.y = 0;
  for (int i=0; i<3; i++) {
    p = q * 2. + time;
    vec3 k = hash(floor(p));
    p = fract(p)-.5;
    r2d(p.xz, k.x*6+time);
    r2d(p.yz, k.y*6+time);
    e.x = max(length(p.xy)-.05, abs(p.z)-.01);
    p.xy = abs(p.xy)-.04;
    e.x = max(e.x, -bd(p, vec3(0), vec3(.03), 0.));
    //    e.x = length(p+vec3(sin(time+k.x), sin(time*1.2+k.y), sin(time*1.4+k.z))/3) -.05;
    e.x *= .25;
    d=d.x<e.x?d:e;
    r2d(q.xz, .2)
    r2d(q.xy, .2)
  }
  
  return d;
}

vec3 norm(vec3 p){
  vec2 e = vec2(0.001, 0);
  return normalize(vec3(
    df(p + e.xyy).x - df(p - e.xyy).x,
    df(p + e.yxy).x - df(p - e.yxy).x,
    df(p + e.yyx).x - df(p - e.yyx).x
  ));
}

const vec3 ld = normalize(vec3(1));

vec3 rm(vec3 p, vec3 d) {
  p += d * .5;
  for (int i=0; i<100; i++) {
    vec2 dist = df(p);
    if (dist.x < 0.001) {
      vec3 pal[] = vec3[](
        vec3(1.5), // grass
        vec3(.8), // wall
        paint,
        vec3(1,.7, .3)
      );
      
      vec3 col = pal[int(dist.y)];
      vec3 n = norm(p);
      n = round(n * 4) / 4;
      //if (dist.y==0) 
        n += hash(floor(p*20.))*.2-.1;
      col *= max(0., dot(n, ld)) * .8 + .2;
      
      return col;
    }
    
    p += d * dist.x;
  }
  return mix(vec3(.8), vec3(.2,.2,.8), pow(abs(d.y+.2), .5));
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;

  vec3 p = vec3(0,2,-5),
  d = normalize(vec3(uv, 1));
  
  r2d(p.xz, time * .5);
  r2d(d.xz, time * .5);
  
	vec3 catC = rm(p,d);


	out_color = vec4(catC, 0.);
}
