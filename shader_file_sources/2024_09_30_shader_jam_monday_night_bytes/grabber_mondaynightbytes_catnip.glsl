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

//#define time fGlobalTime
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

vec3 tunnel(vec3 p, vec3 dir) {
  float d = 4.0 / length(dir.xy);
  p += dir*d;
  return vec3(d, atan(p.y, p.x), p.z);
}

float sphere(vec3 p, vec3 o, vec3 dir) {
  p -= o;
  float t = dot(dir, p) * 2., 
  a = dot(p, p) - 1.;
  a = t * t - 4. * a;
  if (a<0) return -100.;
  
  a = sqrt(a);
  vec2 g = (vec2(-a, a) - t) / 2.;
  a = g.x < 0. ? g.y : g.x;
  if (a < 0.) return -100.;
  return a;
  return -100.;
}

vec3 map(vec2 c) {
  c.x += c.y / 8.;
  c.x = (c.x/3.142) * 16. + 8.;
  ivec2 ic = ivec2(c / (sin(c.y / 0.001) * 3. + 4.));
  //if (mod(fGlobalTime, 8.) < 4.) {
 //   return ic.y % 2 == 0. ? vec3(1) : vec3(0);
 // } else {
    return (ic.x % 2 + ic.y % 2) % 2 == 0. ? vec3(1) : vec3(0);
//  }
}
#define pi acos(-1.)

vec3 pos(vec2 k) {
  k = vec2(pi * 2. * k.x, 2. * k.y - 1.);
  return vec3(
    vec2(cos(k.x), sin(k.x)) * sqrt(1.0001 - k.y * k.y), 
    k.y);
}

#define interval 8
#define samples (interval * interval)

void main(void)
{
	vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
  vec3 col = vec3(0);
  
  for (int i=0; i<samples; i++) {
    float samp = float(i) / float(samples);
    
    float time = fGlobalTime + samp / 5.;
    vec2 u = uv;
    
    float r = sin(texture(texFFTIntegrated, 0.03).x) + 3.;
    vec3 p = vec3(0,0,-r), dir;
    r2d(p.xz, time / 3.);
    r2d(p.xy, time / 4.);
    r2d(p.yz, time / 5.);
    
    float z = time * 10.;
    p.z += z;
    //vec3(sin(time / 3.),cos(time / 3.),time * 4.), dir;
  
    float a = length(u);
    u /= a;
    a *= (samp / 40.) + 1.;
    dir = -vec3(u * -sin(a), -cos(a));
    r2d(dir.xz, time / 3.);
    r2d(dir.xy, time / 4.);
    r2d(dir.yz, time / 5.);
  
    vec3 tp = p + dir * 3.;
    p = tp - (
      dir * 2. + pos(
        hash(
          vec3(
            u, float(i) / float(samples)
          )
        ).xy
      ) * .1
    );
    dir = normalize(tp - p);

    vec3 tcol = tunnel(p, dir);
  
    vec3 so = vec3(sin(texture(texFFTIntegrated, 0.01).x),sin(texture(texFFTIntegrated, 0.02).x), z + sin(texture(texFFTIntegrated, 0.03   ).x));
    float l = 1.;
    float sd = sphere(p, so, dir);
    if (sd > 0.) { // && sd < col.x
      p += dir * sd * 0.999;
      dir = reflect(dir, normalize(p - so));
      tcol = tunnel(p, dir);
      l = .8;
    }
    col[int(samp * 3.)] += map(tcol.yz).r * l;
  }
  col *= 3.;
  out_color = vec4(col / samples, 0.);
}
