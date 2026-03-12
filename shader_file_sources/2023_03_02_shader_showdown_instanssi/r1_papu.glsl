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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void main(void)
{
	vec2 uv = out_texcoord;
	vec2 tv = uv; tv.y = -tv.y;
	
	uv -= 0.5
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);
	
	vec2 m;
	m.x = atan(uv.x, uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y*0.01;
	
	float f = texture( texFFTSmoothed, d ).r * 10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
	
	float sampy = floor(tv.y*5 + fGlobalTime + f)*.1;
	float rndy = texture(texNoise, vec2(sampy, 0.)).x;
	
	float sampx = floor(tv.x*15)*.1;
	foat rndx = texture(texNoise, vec2(sampx, 0.)).x;
	rndx -= .2*sign(sampx)*30.;
	tv.y += rndx + sign(rndx)*fGlobalTime*.2;
	tv.x += rndy + sign(rndy);
	
	vec4 moicolor = texture(texTex3, tv);
	vec4 moinorm = texture(texTex4, tv);
	float moishadow = clamp(dot(moinorm.xyz, -normalize(vec3,uv, 0.) - vec3(0.))) * 10 * f, 0, 3) + 0.8;
	
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	vec4 bgtex = texture(texTex1, tv);
	out_color = mix(bgtex, moicolor * moishadow, .7); // +t*.05;
}
