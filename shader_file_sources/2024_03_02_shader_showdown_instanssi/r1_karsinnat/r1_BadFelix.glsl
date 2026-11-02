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

vec4 hsl( float h, float s, float l) {
  float rc = cos(h);
  float rg = cos(h + 6.283/3);
  float rb = cos(h + 6.283/3*2);
  float e = exp(l-s);
  float f = exp(l+s);
  float a = e/(e+1);
  float b = f/(f+1);
  return vec4(rc*a, rg*a, rb*a, 1.0);
}  

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x, gl_FragCoord.y);
  float x = (uv.x - v2Resolution.x/2) / v2Resolution.y;
  float y = (uv.y - v2Resolution.y/2) / v2Resolution.y;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  float r = pow(x*x + y*y, 0.5);
  float li = sin(r*10 + fFrameTime * 100);
//	out_color = vec4(li, li, li, 1.0);
  float be = texture( texFFT, 0.5 ).r;
  float e = texture(texFFT, 0.8).r;
  if (sin(x*exp(sin(fGlobalTime * 3)) * 10) < 0) {
    out_color = hsl(r + 1, 1.0, be + 1);
  } else {
    out_color = vec4(texture(texFFT, 0.2).r * 10);
  }
}