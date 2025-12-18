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

  uv*= texture(texNoise, vec2(0,0)).xy;
  vec2 olduv = uv;
  if(uv.x > 0){ 
    //uv.x = uv.x + texture(texFFT, uv.x).r * 0.1;
    uv.x = 10 * olduv.y * cos(fGlobalTime) + olduv.x* sin(fGlobalTime) + texture(texFFT, uv.x).r;
    uv.x = round(uv.x* 10) / 10;
    }
  else{
    uv.y += texture(texFFT, 0).r* tan(fGlobalTime) * olduv.x*cos(fGlobalTime) + olduv.y*-sin(fGlobalTime);
    uv.x = round(uv.x);
    }
  olduv = uv;
  
  uv.x += (olduv.x*cos(fGlobalTime)*sin(fGlobalTime));
  float a = 64;
    uv = round(a*uv)/a;

    
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

  m.x = m.x * sin(fGlobalTime) + m.y * cos(fGlobalTime);
  m.y = m.x * cos(fGlobalTime) + m.y * -sin(fGlobalTime);
  // :D
    
	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
}