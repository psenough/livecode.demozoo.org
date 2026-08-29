#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTensu;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time, float f, float f2)
{
	float c = 0.5 + sin( v.x /100 ) + cos( abs( time/0100 + v.y/1000 -time) );
  float asd = sin(f2/1000+time);
	return vec4( sin(time), tan(v.x/50), sin(v.y*10)/10, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  
  vec2 uv2 = uv*vec2(1,1.2);
 

	float f = texture( texFFT, d ).r * 100;
  float f2 = texture( texFFTSmoothed, d).r * 100;
  
   vec4 last = texture(texPreviousFrame, uv2 / sin(fGlobalTime/100));
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.35*0.2*sin(f/1000);
  
  vec4  noise = texture(texNoise, abs(uv2));

	vec4 t = plas( m * 3.14, 100*sin(fGlobalTime/100), f, f2) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = noise *t -.2/(0.9*abs(noise)-t +f);
}