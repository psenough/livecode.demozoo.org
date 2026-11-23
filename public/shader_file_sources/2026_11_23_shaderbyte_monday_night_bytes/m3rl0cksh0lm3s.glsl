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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(sin(uv.y)/128.0) / 3.14;
	m.y = 1 / length(uv.x/4.0+uv.x) * .2*uv.x*2.0-m.x*6.0;
	float d = m.y*uv.y;

	float f = texture( texFFTIntegrated, d ).r * 100;
	m.x += sin( m.y/32.0 ) * 5.1/d;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14+uv.x*m.y/16.0*m.x*32.0/m.y*4.0, fGlobalTime/4.0+m.y*1.0*d*2.0/uv.y ) / d;
	t = clamp( t+d/32.0+m.x/1.0/sin(uv.y)/8.0/m.y, 0.0, 1.0 );
	out_color = f + t+d/2.0;
}