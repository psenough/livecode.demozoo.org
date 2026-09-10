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

float l1norm(vec2 xy){
	return abs(xy.x) +abs(xy.y);
}

vec3 map(float x){
	if(x < 0.9){
		return vec3(0.8,0.0,0.0);
	}
	return vec3(0.8,0.8,0.8)*exp(-2.0*pow(1.0-x,2.0));
}


vec4 addImg(vec2 uv, float scale){
	
	vec2 coord = (uv - vec2(0.5))/scale + vec2(0.5);
	
	if( abs(coord.x - 0.5) < 0.5 &&  abs(coord.y - 0.5) < 0.5){
	
	return texture(texTex1,uv);
	}
	
	return vec4(0.0);
}

void main(void)
{
	vec2 uv = out_texcoord;
	vec2 xy = out_texcoord;
	
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);
	
	uv.x += 0.01*sin(float(int(10.0*uv.y) % 4))*sin(fGlobalTime);
	uv.y += 0.01*sin(2.0*float(int(10.0*uv.x) % 4))*sin(fGlobalTime);
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
	
	vec3 col = vec3(0.0);
	
	
	float scale = 1.0 + 2.0*texture(texFFTSmoothed,0.1).r *100;
	
	
	col += map(pow(cos(10.0*pow(l1norm(uv),2.0) -2.5*fGlobalTime ),2.0))*exp(-2.0*length(uv));
	
	
	float angle = 0.1*atan(uv.y, uv.x)/3.14;
	float fft =  sqrt(sqrt(1.0*texture(texFFT,abs(angle)).r));
	
	
	if(length(uv) < .25+ .5*fft ){
		col += vec3(0.0,0.0,0.0)*exp(-2.5*length(uv));
		}
	
	if(l1norm(uv) < 0.24*scale ){
		
			col = vec3(1.0,0.2,0.0);
		
		}
	
	
	if (l1norm(uv) <0.2*scale ){
			
			col = vec3(.0,1.0,0.0);
			
		}
	
	//HEI MAAILMA!!!
	
	
	out_color = vec4(col,1.0) + addImg(vec2(xy.x,1.0-xy.y),1.0)*exp(-scale);;
	
	//KIITOS INSTANSSI!!
}
