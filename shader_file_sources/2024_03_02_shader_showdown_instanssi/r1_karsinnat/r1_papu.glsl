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

float sineH(float x)
{
  return .03*sin(x*20 + fGlobalTime) * (1 + texture(texFFTSmoothed, abs(x)*0.01).r * 10);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv.x += sin(fGlobalTime)*uv.x + cos(fGlobalTime)*uv.y;
  uv.y += -cos(fGlobalTime)*uv.x + sin(fGlobalTime)*uv.y;
  
  float b = .25 + abs(sin(fGlobalTime))*.25;
  uv += b;
  uv = mod(uv, b*2) - b;
  uv /= b;

	//vec2 m;
	//m.x = atan(uv.x / uv.y) / 3.14;
	//m.y = 1 / length(uv) * .2;
	//float d = m.y;

	//float f = texture( texFFT, d ).r * 100;
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;

	//vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = clamp( t, 0.0, 1.0 );
	//out_color = f + t;
  
  vec4 bgc = vec4(1);
  
  float f = texture(texFFT, 0.05).r * 5.;
  vec4 flash = vec4(-vec3(1.)*f, 1.);
  
  vec4 line = vec4(0.);
  line.a = 1.;
  vec2 lv = uv;
  lv.y += sineH(uv.x);
  if (abs(lv.y) < 0.02) {
    line.rgb = vec3(-1.);
  }
  
  vec2 pall = vec2(sin(fGlobalTime), 1.);
  pall.y = -sineH(pall.x);
  
  vec4 pallc = vec4(1.);
  float pallr = .04 + texture(texFFT, 0.02).r * .2;
  float palld = length(uv - pall);
  if (palld < pallr)
    pallc.rgb = vec3(-1 + palld*5);
  else
    pallc.rgb = vec3(0);
  
  out_color = bgc + flash + line + pallc;
}