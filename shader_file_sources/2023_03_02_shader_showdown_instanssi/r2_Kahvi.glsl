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
	float juuh_elikas = 70.;
	uv = floor(uv*juuh_elikas)/juuh_elikas;
	float t = fGlobalTime;
	float f = texture(texFFT,a-step(0.0,length(uv)/40.)).x;
	float r = 0.;
	float g = 0.;
	float b = 0.;
	vec2 aurinko_uv = uv; // HAHA AURINKO JA UV :DDD
	vec2 laiva_uv = uv;
	aurinko_uv-=0.4;
	laiva-uv.x += sin(t);
	laiva_uv.x = mod(laiva_uv.x,3.2)*2.;
	laiva_uv.y -= 0.3*sin(t);
	float a = atan(aurinko_uv.x,aurinko_uv.y);
	float aurinkon_sateet = sin(a*10.+t*3.+f)*step(0.1,length(aurinko_uv));
	aurinkon_sateet *= step(0.3,length(aurinko_uv)*-1.+1.);
	float laiva = step(0.1,laiva_uv.x)-step(-laiva_uv.x,-0.4)-step(-0.2,laiva_uv.y)-step(-laiva_uv.y,0.4);
	float aurinko = length(aurinko_uv)*-1.+1. ;
	vec2 meri_uv = uv;
	float meri = sin(-uv.y+sin(uv.x*30.)/20.+(sin(t*f)*0.04));
	b = step(0.3,meri);
	
	aurinko = step(0.5,aurinko) ;
	aurinko += aurinkon_sateet;
	r = laiva;
	b+= aurinko;
	r+= aurinko;
	g+= aurinko;
	vec3 col = vec3(r,g,b);
	col = normalize(col);
	out_color = vec4(col,1.);
}
