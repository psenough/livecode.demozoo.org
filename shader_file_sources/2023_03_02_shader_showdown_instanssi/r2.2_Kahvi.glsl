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
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);
	
	float r;
	float g;
	float a = atan(uv.x,uv.y);
	float b;
	float t=fGlobalTime;
	float f=texture(texFFTSmoothed,0.2).x*500.*abs(a*3.);
	
	uv.y += floor(mod(t,2.)*60.)/60.*floor(uv.x-floor(sin(t*1.+uv.x/160.)/2.*uv.x)*2.);
	
	
vec3 mm = texture(texTex3,-uv*2.).xyz;
vec3 hmm = texture(texTex1,vec2(uv.x*2,uv.y*2.-.5)).xyz;
	//uv *= length(-3.uv)*sin(uv);
	
	//b+=
	
	
	float w = 0.;
	w = cos(a*3.+length(uv*8.+t*4.));
	w = 1.;
	
	
	vec3 col= vec3(w);
	col *= mm+hmm;
	col *= f;
	out_color = vec4(col,1.);
}
