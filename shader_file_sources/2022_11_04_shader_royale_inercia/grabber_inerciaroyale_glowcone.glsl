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

float sphere(vec3 pos, float size) {
  return length(pos)-size;
}

vec2 getDist(vec3 pos) {
  vec3 pos2 = pos;
  float f = texture(texFFT, pos2.x).r;
  pos2.x = cos(pos2.x) - cos(fGlobalTime*f*.5);
  pos2.y = cos(pos2.y) - cos(fGlobalTime * 5);
  return vec2(sphere(pos2, f * 10.));
}

void main(void)
{
  vec2 uv = (2.*gl_FragCoord.xy-v2Resolution.xy)/v2Resolution.y;
  vec3 cam = vec3(0, fGlobalTime * texture(texFFTSmoothed, fGlobalTime).r * 0.01, -5.);
  vec3 dir = normalize(vec3(uv, 1));
  
  vec3 color = vec3(0, clamp(uv.y, 0, 1), clamp(uv.y, 0.4, 0.8));
  float traveled = 0.;
  for (int i=0; i<100; i++) {
    vec3 point = cam + dir * traveled;
    vec2 dist = getDist(point);
    traveled += dist.x;
    if (dist.x < 0.0001) {
      break;
    }
    if (traveled > 100.) {
      color = vec3(0,0,0);
      break;
    }
    
  }
  out_color = vec4(color, 1.);
}