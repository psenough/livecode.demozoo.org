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
uniform float fMidiK1;
uniform float fMidiK2;
uniform float fMidiK3;
uniform float fMidiK4;
uniform float fMidiK5;
uniform float fMidiK6;
uniform float fMidiK7;
uniform float fMidiK8;
uniform float fMidiS1;
uniform float fMidiS2;
uniform float fMidiS3;
uniform float fMidiS4;
uniform float fMidiS5;
uniform float fMidiS6;
uniform float fMidiS7;
uniform float fMidiS8;

float iTime;

const int STEPS = 155;
const float NEAR = 0.0;
const float FAR = 100.;

const float EPSILON = 0.001;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float scene(vec3 p, float r) {
  vec3 pos = fract(p*vec3(fract(p.z*0.5),fract(p.z*0.9)+fract(p.z*0.1),1.0)*(0.3-mod(p.z,2.0)*p.z*0.01));
  pos.z = fract(p.z*0.01*cos(iTime*0.03))*4.;
  float res = length(pos-0.5)-r;
  return res;
}

float march(vec3 eye, vec3 dir, float near, float far) {
  float d = near;
  
  for (int i = 0; i < STEPS; i++) {
    float dist = scene(eye + d * dir, 0.5);
    
    if (dist < EPSILON) {
      return d;
    }
    
    d+=dist;
    if (d >= far) {
      return far;
    }
  }

    return far;
}

void main(void)
{
  iTime = mod(fGlobalTime, 300)*3.0;
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);

  uv*=10.5;
  uv.x*=0.5;

  float aspect = v2Resolution.x / v2Resolution.y;
  
  vec3 eye = vec3(4.5,0.0,iTime*0.1);
  vec3 up = vec3(0.0,1.0,0.0);
  vec3 right = vec3(1,0,0.0);
  
  vec3 origin = (right * uv.x * aspect + up * uv.y - eye);

  vec3 dir = normalize(cross(right,up));
  float dist = cos(march(origin, dir, NEAR, FAR));

  float esa = 0.0+abs(fract(iTime*0.1+dist*0.1)*10.);
  esa-=fract(texture(texFFTIntegrated,uv.x*0.0005).r*4.)*fract(iTime*0.1*uv.y*0.1)*0.2;
  dist*=esa*0.1;

  vec4 col = 1.0-vec4(dist*abs(cos(iTime*0.1)),dist*esa,dist*1.2,1.0);
  out_color = col;
}