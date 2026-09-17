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
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float t = 0.2*fGlobalTime;
  float rad = length(uv)*sin(1.0*fGlobalTime);
  
  uv = vec2(uv.x*cos(t+rad) + uv.y*sin(t+rad), uv.y*cos(t+rad) - uv.x*sin(t+rad));

  float s = 25.0+5.0*sin(2.0*fGlobalTime);
  uv = round(s*uv)/s;
  
  float r = 1.0+ abs(uv.x) + abs(uv.y) - sin(0.5*fGlobalTime);
  

   
  float c = 0.0;
    c = sin(20.0*r);  
  vec3 col = 0.5 + 0.5*sin(15.0*c+vec3(0.0,2.0,4.0));
  
  if (c < 0.5){
  col *= 0.0;
  }
  
	out_color = vec4(vec3(col), 1.0);}