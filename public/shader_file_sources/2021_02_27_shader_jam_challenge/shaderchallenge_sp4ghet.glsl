#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

#define time fGlobalTime

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI = 3.14159265;
const float TAU = 2.*PI;


float f(float x, float y, float z) {
    z = fract(z), x /= pow(2.,z), x += z*y;
    float v = 0.;
    for(int i=0;i<6;i++) {
        v += asin(sin(x)) * (1.-cos((float(i)+z)*1.0472));
        v /= 2., x /= 2., x += y;
    }
    return v * pow(2.,z);
}

float parDif(vec3 x, vec3 e){
    return f(x.x + e.x, x.y + e.y, x.z + e.z) - f(x.x - e.x, x.y-e.y, x.z-e.z);
}

vec4 dmin(vec4 a, vec4 b){
  return a.x < b.x ? a : b;
}

float dodecaMap(vec3 p){
  const float phi = (1. + sqrt(5.))/2.;
  const vec3 n = normalize(vec3(phi, 1., 0.));
  
  p = abs(p);
  float a = dot(p, n.xyz);
  float b = dot(p, n.yzx);
  float c = dot(p, n.zxy);
  return max(a, max(b, c)) - phi*n.y;
}

float tormap(vec3 p, vec2 r){
  float x = length(p.xz) - r.x;
  vec2 cp = vec2(x, p.y);
  return length(cp) - r.y;
}

mat2 r2d(float t){
  float c = cos(t), s = sin(t);
  return mat2(c,s,-s,c);
}

vec4 map(vec3 q){
  vec3 p = q;
  vec4 d = vec4(1e5, 0., 0., 0.);
  
  float t = 2. * time;
  float an = floor(t) + 2.*exp(-.5*fract(t));
  p.yz *= r2d(an);
  p.xz *= r2d(an);
  float dod = dodecaMap(p);
  float r = abs(f(p.x*360., p.z*p.y*TAU, time))+0.1;
  vec4 dodd = vec4(dod, r, 0., 0.);
  
  d = dmin(d, dodd);
  p=q;
  float pl = dot(p+vec3(0, 2., 0.), vec3(0., 1., 0.));
  d = dmin(d, vec4(pl, r, 1., 0.));
  
  p = q;
  p.zx *= r2d(-PI*.3);
  p.yx *= r2d(-PI*.15);
  
  float tr = tormap(p, vec2(1.5, 0.2));
  float ang = atan(p.z, p.x);
  r = f(ang*314., p.z*p.y*TAU, time);
  d = dmin(d, vec4(tr, r, 1., 0.));
  
  return d;
}

vec3 nmap(vec3 p){
  const vec2 e = vec2(0., 0.00768);
  
  return normalize(vec3(
    map(p+e.yxx).x - map(p-e.yxx).x,
    map(p+e.xyx).x - map(p-e.xyx).x,
    map(p+e.xxy).x - map(p-e.xxy).x
  ));
}

vec3 grad(float t){
  t = t*TAU;
  vec3 ph = vec3(0.13, 0., 0.) * TAU;
  vec3 a = vec3(0.85, 1., 1.);
  vec3 f = vec3(1.36, 1., 1.36);
  
  return a * 0.5 * cos(ph + f*t) + 0.5;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 c = vec3(0.);
  
  vec3 ro = vec3(0., 0., 5.);
  vec3 rd = normalize(vec3(uv, -1.));
  vec4 d = vec4(0.);
  float t=0.;
  vec3 p = ro;
  for(int i=0; i<64; i++){
    p = ro + rd*t;
    d = map(p);
    t += d.x;
  }
  
  vec3 lpos1 = vec3(2., 4., 3.);
  vec3 lpos2 = vec3(-5., 0., 0.);
  
  if(d.x < 0.01){
    vec3 n = nmap(p);
    vec3 a = grad(d.y);
    if(d.z == 1.) a = vec3(d.y);
    
    vec3 l1 = normalize(lpos1 - p);
    float at1 = length(lpos1 - p);
    float int1 = 40. / (at1*at1);
    c += a * int1 * max(0., dot(n, l1));
    
    vec3 l2 = normalize(lpos2 - p);
    float at2 = length(lpos2 - p);
    float int2 = 20. / (at2*at2);
    c += a * int2 * max(0., dot(n,l2));
  }else{
    t = 30.;
  }
  
  c = mix(vec3(0., 0.05, 0.1), c, exp(-0.2*t));

  c = pow(c, vec3(.4545));
  
	out_color = vec4(c, 1.);
}