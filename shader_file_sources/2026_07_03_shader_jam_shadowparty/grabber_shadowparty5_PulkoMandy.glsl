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

float shape(vec2 uv, float r)
{
    return length(uv) / r;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;


	out_color = vec4(
    sin(
      fGlobalTime + sin(fGlobalTime * 7)
    ) * acos(uv.x * 3) / sin(uv.y + sin(fGlobalTime/8)),
    mix(uv.x, uv.y, sin(fGlobalTime/sin(uv.x*(uv.y+fGlobalTime)))),
    cos(fGlobalTime + sin(uv.x/(uv.y*(sin(fGlobalTime)+1)))), 0) 
    * mix(shape(uv + vec2(sin(fGlobalTime + uv.x/3), cos(fGlobalTime)), 0.5 * sin(fGlobalTime * 7 + f))
  , shape(uv + vec2(fGlobalTime* 2.6 / 8, cos(fGlobalTime * 7)/3), sin((fGlobalTime + 7)/0.25) / sin(fGlobalTime * 7 + f)), sin(fGlobalTime));
}