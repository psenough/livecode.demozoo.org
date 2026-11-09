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

#define time (fGlobalTime / 3.)
#define r2d(p,a) p=cos(a)*p + sin(a)*vec2(-p.y,p.x);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float f(vec3 p, float t) {
  vec3 o = p;
  p = fract(p) - .5;
  float s = 3., l;
  for (int i=0; i<8; i++) {
    p = abs(p);
    p = p.x<p.y ? p.zxy : p.zyx;
    l = 2. / min(dot(p,p), 1.);
    s *= l;
    p = p*l - vec3(
      sin(o.z * 1. + t*4. + sin(o.x * 2. + t * 3.)) * .05 + .2, 
      sin(o.y * 2.+t + sin(o.z * 0.5 + t * 2.7)) * 0. + sin(t*4.)*.2+1., 
      cos(o.x / 3. + t * 3. + sin(o.z + t))*1. + 5.);
  }
  return length(p) / s;// - abs(sin(o.z / 8. + t* 1.)*0.01);
}

float df(vec3 p, float t) {
  //p.xy += vec2(sin(p.z), cos(p.z));
  //r2d(p.xy,p.z/8.+time);
  return f(p, t);
}

vec3 norm(vec3 p, float t) {
  vec2 e=vec2(0.001, 0.);
  return normalize(vec3(
    df(p+e.xyy, t)-df(p-e.xyy, t),
    df(p+e.yxy, t)-df(p-e.yxy, t),
    df(p+e.yyx, t)-df(p-e.yyx, t)
  ));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float tmp = length(uv * 2.);
  uv *= pow(tmp, 4.2) + 1.;
  
  vec3 p = vec3(0,0,time / 4.);
  
 // p.xy -= vec2(sin(p.z), cos(p.z));
  
  vec3 d = normalize(vec3(uv, 1));
  r2d(d.xy, time / 5.);
  r2d(d.xz, time / 5.);
  vec3 o = vec3(.5, .5, 1.);
  
  float t = texture(texFFTIntegrated, 0.005).x / 16.;
  
  const int iters = 100;
  for (int i=0; i<iters; i++) {
    float dist = df(p, t);
    if (dist<0.001) {
      vec3 n = norm(p, t);
      float l = max(0., dot(d,-n));
      o = vec3(1, 0, 1) - l;
      dist = float(i + 1) / float(iters+1);
      dist = pow(dist, 2.5);
      //o *= pow(dist, 2.) * 2.;
      o += vec3(.5, .5, 1.) * dist;
      break;
    }
    p += d * dist;
  }
  out_color = vec4(o,1);
}
