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

#define time fGlobalTime
#define r2d(p,a) p=cos(a)*p + sin(a)*vec2(-p.y,p.x);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// catpoo is smellier 

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float cat(vec2 p) {
  float s = texture(texFFTSmoothed, 0.01).x/3.  - .05;
  p.x = abs(p.x);
    vec2 q=p;
    q.x = abs(q.x-.2);
    q.y += q.x - .2;
    p.x -= .6;
    p.y = abs(p.y) - .08;
  float r = abs(q.y)<.05+s && q.x<.15+s ? 1. : 0.;
  r += abs(p.y)<0.03+s && abs(p.x)<.15+s ? 1. : 0.;
  return r;
}

float smin(float a, float b, float k) {
  float h = clamp(.5 + .5 * (b-a) / k, 0., 1.);
  return mix(b, a, h) - k * h * (1. - h);
}

vec3 hash(vec3 p) {
  p = fract(p*vec3(335.6378, 247.3487, 532.345));
  p += dot(p, p.yxz + 19.19);
  return fract((p.xxy + p.yxx) * p.zyx);
}

vec4 sDist(inout vec3 p, inout vec3 dir) {
  vec3 op = p;
  vec3 q = fract(p) - 0.5;
  float t = dot(dir, q) * 2.,
  a = dot(q, q) - 0.5*0.5;
  
  a=t*t - 4. * a;
  if (a < 0.) return vec4(1,1,1,0);
  a = sqrt(a);
  vec2 g = (vec2(-a, a)-t) / 2.;
  a = min(g.x,g.y);
  //if (a==g.y && a<0.) return vec4(1,1,1,0);
  p += a;
  q += a;
  vec3 n = normalize(q);
  dir = reflect(dir, n);
  return vec4(hash(floor(op))*.5 + .5, 1.);;
}

vec4 f(inout vec3 p, inout vec3 dir) {
  vec3 q = p;
 // q += sin(q);
  float s = 4.;
  q = floor(q * s) / s;
  //float time = 0.;
  float d = smin(
   length(q + vec3(sin(time*.8), sin(time*.7), sin(time*.6)) * 10.),
   length(q + vec3(sin(time*.67), sin(time*.573), sin(time*.82456)) * 10.),
   8.) - 10.;

 // d = min(d, -(length(q) - 45.));
  if (d < 0.) {
    vec4 tmp = sDist(p, dir);
    if (length(q) > 30) tmp.xyz = vec3(1);
    return tmp;
    //q /= 20.;
    //return abs(sin(q+sin(q))) / 20.;
  }
  return vec4(1,1,1,0);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 p=vec3(0., 0., -35. + sin(time) * 5.);
  vec3 d=normalize(vec3(uv, 1.));
  
  r2d(p.xy, time / 3.);
  r2d(p.xz, time / 3.);
  r2d(d.xy, time / 3.);
  r2d(d.xz, time / 3.);
  
  vec4 c = vec4(1,1,1,0);
  for (int i=0; i<200; i++) {
    c *= f(p, d);
    p += d / 2.;
    //if (c.a > 4.) break; 
  }
	c *= vec4(step(d.y, 0.));
  
  r2d(uv, sin(time)/3.);
  out_color = vec4(cat(uv)) + c;
}