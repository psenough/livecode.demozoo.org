#version 420 core

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float sdf_circle(vec2 center, float rad, vec2 p, float wh_ratio)
{
    vec2 d_p_center = p - center;
    float d = sqrt(d_p_center[0]*d_p_center[0]/wh_ratio + d_p_center[1]*d_p_center[1]); 
    float res = d - rad;
  
    return res;
}

void main(void)
{
  float wh_ratio = v2Resolution.y/v2Resolution.x;
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 center = vec2(0.5, 0.5);
  float radius = 0.25;
  
  float s = sdf_circle(center, radius, uv, wh_ratio);
  
  if (s > 0.0)
    out_color = vec4(0.0, 0.0, 0.0, 0.0);
  else
    out_color = vec4(0.0, 0.0, 1.0, 0.0);
}