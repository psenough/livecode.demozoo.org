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

float circleSDF(vec2 uv, vec2 p, float r){
	return length(p-uv)-r;
}

vec2 rot(vec2 p1, vec2 p2, float r){
	vec2 p = p1-p2;
	float x = sin(r)*p.x+cos(r)*p.y;
	float y = sin(r)*p.x-cos(r)*p.y;
	return vec2(x,y);
}

void main(void)
{
	vec2 uv = out_texcoord;
	vec2 tv = uv; tv.y = -tv.y;
	
	uv -= 0.5
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);
	
	//vec2 m;
	//m.x = atan(uv.x, uv.y) / 3.14;
	//m.y = 1 / length(uv) * .2;
	//float d = m.y;
	
	//float f = texture( texFFT, d ).r * 100;
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;
	
	//vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = clamp( t, 0.0, 1.0 );
	vec4 pallot = vec4(1.);
	vec4 col = vec4(vec3(1.),1.){
		vec2 p = vec2(mod(fGlobalTime,2)+f-5.,0.);
		float s = float(.5<circleSDF(uv,p,0.));
		pallot -= s*.03;
	}
	
	vec4 intansi = texture(texTex1,rot(uv,vec2(1.),fGlobalTime));
	out_color = col*float(.5<circleSDDF(uv,vec2(0.),.0));
	out_color = pallot*intansi;
	
}
