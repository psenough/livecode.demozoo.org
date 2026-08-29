#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
uniform vec3 iResolution;

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
// my first shader jam ever btw :) why not to have fun with it

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// i have better idea
// filippp here as always

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.xy ) / v2Resolution;
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  // adding more thungs probably
  // the sessions tunnel, why not :D
  // i finally did it
  
  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 0.1 / length(uv) * .9;
  float d = m.y;
  
  float f = texture( texFFTSmoothed, d ).r * 600;
  m.x += sin( fGlobalTime ) * 0.14;
  m.y += fGlobalTime * 1;
  
  vec4 t = texture( texSessions, m.xy ) * d;
  out_color = f * t;
}