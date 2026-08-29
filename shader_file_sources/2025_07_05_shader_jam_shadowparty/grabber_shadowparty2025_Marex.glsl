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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

float sdf(vec3 p){
    
  vec2 uv = (gl_FragCoord.xy/v2Resolution-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  vec2 R2D = uv*R2D(fGlobalTime/8.);
  
    float tex = texture(texFFTSmoothed,(R2D.x*1.)*(R2D.y*1.)-.5).x;
  
  p.xyz = mod(p.xyz-fGlobalTime,5.)-2.5;

  float sp = length(p)-120.5*tex;
  
  return sp;
  
  }

float march(vec2 uv, vec3 eye, vec3 ray, float n) {
  float total_distance = 0.;
  vec3 p = eye;
  
  for (int i = 0; i < n; i++) {
    float d = sdf(p);
    if (d < 0.001) return total_distance;
    p += d * ray;
    total_distance += d;
  }
  
  return -1.;
}


vec3 normal(vec3 p) {
  vec2 e = .001 * vec2(1, -1);
#define q(s) s * sdf(p + s)
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}

void main(void) {
  vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / min(v2Resolution.x, v2Resolution.y);
  vec2 R2D = uv*R2D(fGlobalTime/8.);
  vec3 color = vec3(0., 0., 0.);
  vec3 eye = vec3(2.5, 0., 0.);
  vec3 ray = normalize(vec3(R2D, 1.));

  float d = march(uv,eye, ray, 128);
  if (d > 0.) {
    vec3 p = eye + ray * d;
    vec3 n = normal(p);
    vec3 lo = vec3(0, 2, -3);
    float diffuse = max(0., dot(normalize(lo - p), n));
    color =   vec3(10.) / p.z  * diffuse;
  }
      vec3 col = .5+.5*cos(fGlobalTime+uv.xyx+vec3(0,2,4));

	out_color = vec4(color*col, 1.0);
}