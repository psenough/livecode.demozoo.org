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
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 30.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  //shit...
  //halp
  vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .9;
	float d = m.y;

  
  
  float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.65;

	vec4 t = plas( m * 3.14 * fGlobalTime * 0.00025, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  
  vec4 t2 = plas( m * 3.14 + 2, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  float asd = (plas( m * 3.14, fGlobalTime ) / d).x;
  out_color = vec4(t + t2);
  
  float size= 0.05;
  if(uv.x < sin(fGlobalTime * 0.5) + size || uv.y > sin(fGlobalTime * 0.5) - size)
  {
    if(uv.y < sin(fGlobalTime* 0.5) + size || uv.y > sin(fGlobalTime* 0.5) - size)
    {
     out_color = vec4(t.z, t.x,t.y ,1);
    }
  }
  
  out_color = mix(vec4(length(uv * sin(fGlobalTime) * cos(fGlobalTime)) + 0.001, 0, 0, 1), out_color, fGlobalTime);
	

	
	//out_color = f + t;
}