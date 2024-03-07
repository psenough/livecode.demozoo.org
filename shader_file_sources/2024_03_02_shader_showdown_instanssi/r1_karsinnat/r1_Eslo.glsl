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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float pallo(vec2 v, float p){
  return length(v)-p;
  }
  
  float pallo2(vec2 v, float p){
    return length(vec2(v.x,v.y*2))-p;
    }
  
    vec2 rotate(vec2 v, float r){
      mat2 m = mat2(cos(r), sin(r), -sin(r), cos(r));
      return m * v;
      }

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
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

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
  
  uv = vec2(mod(uv.x*2,1) - 0.5, abs(sin(uv.y*2)) - 0.5);

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  float p1 = pallo2(rotate(uv, fGlobalTime), 0.01);
  uv = vec2(abs(sin(uv.x*1)) - 0.5 , uv.y*3);
  float p2 = pallo2(rotate(uv, -fGlobalTime), 0.01); 
	out_color = vec4(pallo2(rotate(uv, fGlobalTime* f/2),0.01*f)-p1, p2,p1*sin(fGlobalTime*f),0);
}