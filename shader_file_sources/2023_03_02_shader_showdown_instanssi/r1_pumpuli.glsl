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

float sdHex( in vec2 p, in float r )
{
	const vec3 k = vec3(-0.866025404,0.5,0.577350269);
	p = abs(p);
	p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
	p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
	return length(p)*sign(p.y);
}

float ang;

void main(void)
{
	vec2 uv = out_texcoord;
	vec2 uv_ = uv;
	uv_ *= -1;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
	
	
	
	
	float smf2 = texture(texFFTSmoothed,0.1).r*100;
	float smf = texture(texFFTSmoothed,abs(m.x*0.5)).r*400;
	float fft = texture(texFFT,abs(m.x*0.6)).r*400;
	float f = texture ( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) *0.1;
	m.y += fGlobalTime * 0.25;
	
	ang += fGlobalTime+(smf*0.8);
	
	vec2 rot = uv;
	
	rot.x=sin(ang)*uv.x+cos(ang)*uv.y;
	rot.y=sin(ang)*uv.y-cos(ang)*uv.x;
	
	vec4 moi = texture(texTex1,rot);
	vec4 nor = texture(texTex2,rot);
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	vec4 c = (fft*4)*moi/sdHex(rot,0.1+smf2)/sdHex(rot,0.8)+step(sdHex(rot,0.1),ang)*0.8;
	c = clamp(c,-0.5,1.0);
	vec4 sub = vec4(0,0,0,1);
	vec4 add = vec4(2,smf*2,0.5+smf,1);
	c *= add;
	out_color = sub+c;
}