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
	uv -= 0.5
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);
	float t = fGlobalTime;
	float a  = atan(uv.x,uv.y);
	float f = texture(texFFT,a-step(0.0,length(uv)/40.)).x;
	float d = length(uv);
	
	float mutsis = 60.;
	float faijas = cos(a*5.+t*3.+(length(uv)*10.*f))*2.;
	uv *= sin(t/30.)*20.;
	uv *= d;
	uv.x = floor(uv.x*mutsis)/mutsis;
	vec2 r_m=uv;
	
	
	f *= 100.;
	float pippeli = cos(t*2.);
	
	f_m.x = uv.y*sin(t) - uv.x*cos(t);
	r_m.y = uv.y*cos(t*0.99) + uv.x*sin(t);
	
	r_m.y += f*step(3.,length(uv)*30.);
	vec3 moiman = texture(texTex1,-r_m+0.5).xyz;
	
	vec3 col= vec3(moiman);
	col.x *= faijas;
	col.y *= cos(faijas+t);
	col.z *= cos(faijas+t)*2.;
	col *= length(uv*4)*-1. + 1.;
	col = col*6.;
	
	out_color = vec4(col,1.);
}
