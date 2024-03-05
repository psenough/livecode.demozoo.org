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

float pallo(vec2 p, float f){
    return length(p)-f;
  } 
  
  
float pallo2(vec2 p, float f){
    return length(vec2(p.x, p.y * 4))-f;
  } 
  
  vec2 rotate(vec2 p, float r){
      mat2 m = mat2(cos(r), sin(r), -sin(r), cos(r));
      return m * p;
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

  vec2 uvA = uv;
  
  uv = rotate(uv, fGlobalTime);
  
  uv = vec2(mod(uv.x * sin(fGlobalTime*2)*3, 1) - 0.5, mod(uv.y* 5 - (-f)*0.1 , 1)-0.5);
  
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  float y = step(pallo2(rotate(uv, fGlobalTime),0.2), 0.1);
  
	out_color = vec4(pallo2(uvA, 0.2*f*2)*f*uv.x , pallo(uv,0.1) + y -  pallo2(uvA, 0.2*f*2)   , pallo2(uvA, 0.2*f*2) , 0);
}