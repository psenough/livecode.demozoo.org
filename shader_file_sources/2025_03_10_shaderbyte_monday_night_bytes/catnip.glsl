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
#define y2r mat3(1,1,1, 0,-.335,1.73, 1.37,-.6, 0)

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

float smin(float a, float b, float k) {
  float h = clamp(.5 + .5 * (b-a) / k, 0., 1.);
  return mix(b, a, h) - k* h * (1.-h);
}

float dolf(vec3 p) {
  p.y += .8;
  p.y += sin(time * 6.) * .1;
  r2d(p.xy, cos(time * 6.)*.1);
  r2d(p.xz, time);
  vec3 op = p;
  float d = length(p) - 1.;
  d = smin(d, length(p - vec3(0,.9,.5)) - .5, .2);
  p -= vec3(0, .5, -.7);
  r2d(p.zy, 1.);
  p.y *= 2.;
  d = smin(d, length(p) - .5, .1);
  p = op;
  p -= vec3(0, 1., 1.1);
  p.y *= 2.;
  d = smin(d, length(p) - .3, .1);
  return d;
}

float torus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xy) - t.x, p.z);
  return length(q) - t.y;
}

float df(vec3 p) {
  float d = -(length(p) - 6);
  d = min(d, p.y + 1. + sin(p.x * 2.147 + time + sin(p.y * 2.5378 + time + sin(p.x * 3.357 + time * 1.47) / 3.)) / 20.);
  
  vec3 op =p;
  //for (int i=0; i<4; i++) {
   // p = op;
    r2d(p.xz, time * .5);
    //p.x += 2.5;
  p.xz = abs(p.xz) - 4;
  p.xz = abs(p.xz) - 2;
    
  d = min(d, dolf(p)); 
  p = abs(p) - texture(texFFTSmoothed, 0.03).x * 4.; 
  d = smin(d, dolf(p * 4.) / 4., .2); 
  p = abs(p) - texture(texFFTSmoothed, 0.03).x * 2.; 
  d = smin(d, dolf(p * 8.) / 8., .2); 
  //r2d(p.xy, time);
  //p = abs(p) - .3; 
  //d = min(d, dolf(p * 16.) / 16.);
  //}
  
  p = op;
  p.y -= 2;
  op =p;
  r2d(p.xz, texture(texFFTIntegrated, 0.01).x * 1.);
  r2d(p.yz, texture(texFFTIntegrated, 0.02).x * 1.);
  r2d(op.xz, texture(texFFTIntegrated, 0.03).x * 1.);
  r2d(op.yz, texture(texFFTIntegrated, 0.04).x * 1.);
  d = smin(d,
    smin(
      torus(p + vec3(sin(time * 1.13728), sin(time * 1.4378), sin(time * 1.24728)), vec2(1, .3)),
      torus(op + vec3(sin(time * 1.13728), sin(time * 1.4378), sin(time * 1.24728)), vec2(1, .3)),
      1.
    ), .5
  );
  return d;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(0.001, 0.);
  return normalize(vec3(
    df(p + e.xyy) - df(p - e.xyy),
    df(p + e.yxy) - df(p - e.yxy),
    df(p + e.yyx) - df(p - e.yyx)
  ));
}

vec4 rm(vec3 p, vec3 d) {
  float l = 1.;
  float r = 0;
  for (int i=0; i<200; i++) {
    float dist = df(p);
    if (dist < 0.01) {
      if (length(p) >= 5.9) {
        vec4 col = vec4(1);
        float x = p.x / 12. + .5;
        col.rgb = hash(vec3(floor(x * 8. + texture(texFFTIntegrated, 0.02).x * 1.)));
        col.yz = col.yz * 2. - 1.;
        r2d(col.yz, time + r);
        col *= l;
        col.rgb = y2r * col.xyz;
        return col;
      } else {
        vec3 n = norm(p);
        p += n * 0.005;
        d = reflect(d, n);
        l *= .7;
        r += dot(d, n) * pi * 4.;
      }
    }
    p += d * dist * .5;
  }
  return vec4(0);
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	
  vec3 p = vec3(0,2,-5),
  d = normalize(vec3(uv, 1));
  
  r2d(d.yz, .5);
  
  r2d(p.xz, time / 4.);
  r2d(d.xz, time / 4.);
  vec4 o = rm(p, d);
  
	out_color = o;
}
