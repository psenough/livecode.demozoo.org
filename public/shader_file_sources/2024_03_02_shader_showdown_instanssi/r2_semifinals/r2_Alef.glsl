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

  uv = uv + 0.5*cos(2.0*length(uv)+fGlobalTime);
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	//float f = texture( texFFT, d ).r * 100;
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;

	//vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = clamp( t, 0.0, 1.0 );
	//out_color = f + t;

  vec3 color = (0.5+0.5*sin(vec3(0.0,2.0,4.0)+fGlobalTime))*exp(-uv.x*uv.x)*20.0*texture(texFFTSmoothed,0.1).r;
 
  float scale = 1.0+20.0*texture(texFFTSmoothed,0.15).r;

  float f = exp(-length(uv-0.25*vec2(sin(4.0*fGlobalTime),cos(2.43*fGlobalTime)))/0.1/scale);
  f += exp(-length(uv-0.25*vec2(sin(2.0*fGlobalTime),cos(3.43*fGlobalTime)))/0.15/scale);
  f += exp(-length(uv-0.25*vec2(sin(3.65*fGlobalTime),cos(5.43*fGlobalTime)))/0.15/scale);  
  if (f > 0.5)
      color = (0.5+0.5*cos(vec3(0.0,2.0,4.0)+fGlobalTime))*f;

  color += vec3(1.0,0.0,0.0)*(1-exp(-length(uv)/0.75))*texture(texFFTSmoothed,0.02).r;
  
  out_color = pow(vec4(color,1.0),vec4(1/2.2));
  }