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
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 color(float t) {
  vec3 a = vec3(0.1, 0.2, 0.7);
  vec3 b = vec3(0.9, 0.2, 0.3);
  vec3 c = vec3(0.6, 0.4, 0.4);
  vec3 d = vec3(0.1, 0.2, 0.3);
  
  return a + b * cos(6.28 * (c*t + d));
}

void main(void)
{
  float t = fGlobalTime;
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 c = vec3(0);
  float num = 30;
  
  for(int i = 0; i < num; i++) {
    float wave = sin(t*uv.x / 20000 + i) * cos(uv.y);
    
    c += color(t * wave) / num;
  }

  
	out_color = vec4(c, 1);
}