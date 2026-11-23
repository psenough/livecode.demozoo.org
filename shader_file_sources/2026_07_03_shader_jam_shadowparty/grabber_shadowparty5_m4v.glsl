#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
uniform float speed;

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texZX;

in vec2 vuv;

// ik the C language but I don't really know how to code the shaders
// apart of that, let's do something combined
// well, coding is pretty fun tho

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

#define PI 3.14f

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.6 + sin( v.x * 580.0 ) + cos( sin( time + v.y ) * 4.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 1.0 + time / .1 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= floor(0.5 * fGlobalTime -15);
	uv /= vec2(v2Resolution.y / v2Resolution.x, 20);

	vec2 m;
	m.x = atan(uv.x / uv.y) / PI * 858;
	m.y = 7 / length(uv) * .1;
	float d = m.y;

	float f = texture( texFFTSmoothed, d ).r * 0;
	m.x += tanh( fGlobalTime ) * 0.84;
	m.y += fGlobalTime * 0.08;
 

	vec4 t = plas( m * (4 * PI), fGlobalTime ) / d;
	t = clamp( t, 0.0, 0.9 );
	out_color = f + t;
}