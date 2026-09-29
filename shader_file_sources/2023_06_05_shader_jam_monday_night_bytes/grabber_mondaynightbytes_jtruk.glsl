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
uniform sampler2D texTex2;
uniform sampler2D texTex1;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
//	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( sin(v.y) ) * 20.0 );
  return vec4(.5+sin(time+v.x*6.28)*.5,.5+sin(time-v.x*(6.28/sin(time*.2)*v.y))*.5,.5+cos(v.x*v.y)*.5,1);
}

vec4 stripe(vec2 v, float time)
{
  return vec4(sin(pow(v.x,2)+time),0,cos(pow(v.x,2)+time),0);
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

	float f = 0.2+texture( texFFTSmoothed, d/100 ).r*sin(fGlobalTime)*4;
  m.x += sin( fGlobalTime *.1) * 0.1;
	m.y += cos(1+fGlobalTime * .1) * 0.1;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t*4, 0.0, 1.0 );
  vec4 s = stripe(m * 3.14, fGlobalTime );
 out_color = f + t + s;
// out_color = s;
//  out_color = t;
}