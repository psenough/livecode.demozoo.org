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


vec4 map(float x){
	if(x > 0.9){
		return vec4(1.0);
	}
	vec3 col = vec3(1.0,0.0,1.0)*exp(-3.0*(1.0-x));
	
	return vec4(col,1.0);
	
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);
	
	vec4 col = vec4(0.0,0.0,0.0,1.0);
	
	if(uv.y <0.0){
		col += map(pow(cos(20.0*sqrt(sqrt(abs(uv.y))) - 8.0*fGlobalTime),8.0));
		col += map(pow(cos(15*atan(uv.y,uv.x)),8.0));
		
		}
	
	
	
	float f = texture( texFFT, 0.1 ).r * 100,
	
	vec2 xy = 2.0*((1.0+0.25*f)*vec2(uv.x, -uv.y);
	
	vec4 tex = texture(texTex1,xy);
	
	float f2 = texture(texFFT, abs(0.5*uv.x)).r *100;
	
	if(uv.y> 0.0){
	vol += vec4(f2,0.0,f2,1.0);
	
	col += vec4(0.0,0.0,1.0,1.0)*exp(-10.0*pow(uv.x,2.0));
	
	col += tex;}
	
	/*
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
	
	float f = texture ( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) *0.1;
	m.y += fGlobalTime * 0.25;
	
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	*/
	
	out_color = col;
	
}
