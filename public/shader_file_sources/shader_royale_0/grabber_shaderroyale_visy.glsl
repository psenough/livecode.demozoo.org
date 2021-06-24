#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const int STEPS = 255;
const float NEAR = 0.0;
const float FAR = 100.;

const float EPSILON = 0.001;

const float PI = 3.14159265;
const float PHI = 1.618033988;

float hash1(float n) { return fract(sin(n)*43758.5453123); }

float iTime;

float scene(vec3 p, float r) {
  vec3 pos = fract(p*vec3(cos(p.x*0.5),sin(p.y*0.9),0.1)*cos(iTime*0.1+p.z*4.));
  float result = length(pos-0.5) - r;
  return result;
}


float march(vec3 eye, vec3 dir, float near, float far) {
  float depth = near;
  
  for (int i = 0; i < STEPS; i++) {
    float dist = scene(eye + depth * dir, 0.5);
    
    if (dist < EPSILON) {
      return depth;
    }
    
    depth+=dist;
    if(depth >= far) {
      return far;
    }
  }
  
  return far;
}

void main(void)
{
  iTime = fGlobalTime;
  
  vec3 eye = vec3(0,0,5.0);
  vec3 up = vec3(0,1,0);
  vec3 right = vec3(1,0,0);
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  if (uv.x < 0.5) uv.x = 1.0-uv.x;

  uv*=2.0;

  float aspect = v2Resolution.x / v2Resolution.y;
  
  vec3 origin = (right * uv.x * aspect + up * uv.y - eye);
  vec3 dir = normalize(cross(right, up));
  
  float dist = march(origin, dir, NEAR, FAR);
  
  vec3 col = cos(abs(sin(iTime*0.1)*0.5)*dist*90.)-vec3(dist,dist,dist*0.2);
  
  col = clamp(col,0.0,1.0);
  
  out_color = vec4(col,1.0);
}