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

const float E = 0.001;

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float sdbox(in vec2 p, in vec2 b) {
	vec2 d = abs(p)-b;
	return length(max(d,0))+min(max(d.x,d.y),0);
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv.y += texture(texFFTSmoothed,floor(uv.x*10.)*.1).x*200;
	vec2 tv = uv;
	tv.y = -tv.y;
	uv -= 0.5
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);
	uv.y *=-1;
	uv.x *= sin(texture(texFFTSmoothed, uv.y*0.001).x);
	
	vec2 m;
	m.x = atan(uv.x, uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y*0.01;
	
	float f = texture( texFFTSmoothed, d ).r * 10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
	
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	
	vec4 dragon_c = texture(texTex1, tv+vec2(fGlobalTime)*vec4(1.,.3,1.,1.);
	vec2 qv = uv*6. + vec2(-.9,.5);
	float a = sdbox(qv, vec2(1.,1.));
	
	if (a < E) {
		vec2 qqv = qv;
		qqv.x += sin(qv.x + fGlobalTime) - cos(qv.y + fGlobalTime);
		qqv.y += -sin(qv.y + fGlobalTime) + cos(qv.x + fGlobalTime);
		dragon_c = texture(texTex3, qqv/2+vec2(.5))* dot(texture(texTex4, qqv/2+vec2(.5)).rgb, normalize(vec3(1.,1.,0.)));
		dragon_c *= 1. + texture(texFFTSmoothed, 0.02).x*300*vec4(4,1,2,1);
	}
	
	vec2 qv1 = uv*6*vec2(sin(fGlobalTime), -cos(fGlobalTime)) + vec2(1.4+sin(fGlobalTi  me), -1.6+cos(fGlobalTime));
	float b = sdbox(qv2, vec2(1.,1.));
	if (b < E) {
		dragon_c = texture(texTex3, qv2/2+vec2(.5));
		dragon_c *= 1. + texture(texFFTSmoothed,0.02).x*300,vec4(2,4,2,1);
		}
	
	vec4 moiNormal = texture(texTex2, tv);
	
	out_color = (f + t)*.1 + dragon_c * dot(moiNormal.rgb, normalize(vec3(1.,1.,0.)));
}
