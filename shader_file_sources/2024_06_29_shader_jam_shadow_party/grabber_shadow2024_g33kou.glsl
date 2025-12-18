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

float t = fGlobalTime*2;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	float f = 1.-texture( texFFT, 1. ).r * 50;

  vec2 st = gl_FragCoord.xy/v2Resolution.xy;
  
  float c1 = 1.-smoothstep(.19,.21,distance(st,vec2(0.3)));
  float c2 = 1.-smoothstep(.09,.11,distance(st,vec2(0.5)));
  float c3 = 1.-smoothstep(.09,.11,distance(st,vec2(0.8)));
  float sq = 1.-smoothstep(.02,.04*f,st.x) * smoothstep(.04,.06*f,st.y) * smoothstep(.02,.04*f,1.-st.x) * smoothstep(.04,.06*f,1.-st.y);
  float geo = c1+c2+c3+sq;
//  vec4 col = vec4(1.,1.*abs(sin(t)),1.*abs(cos(t)),1.);
  vec4 col = vec4(1.*st.x,1.*st.y,1.,1.);
  out_color = col*geo;
//  out_color = col;
}