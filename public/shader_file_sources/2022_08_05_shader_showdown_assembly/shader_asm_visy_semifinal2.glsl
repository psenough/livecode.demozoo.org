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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec2 sprite;


float t;
void main(void)
{
  t = fGlobalTime;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  if (uv.x < 0.5) uv.x = 1.0-uv.x;
  if (uv.y < 0.5) uv.y = 1.0-uv.y;
  uv.y*=mod(t,4.0);
  uv.x*=mod(t,1.0);
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec4 cc = vec4(0.0);
  for (float i = 0.0; i < 16.0; i+=1.0) {
  
  float s = (uv.y*20.1+i)*cos(t*0.1+i*0.1)*cos(t*0.01)*20+t*0.01*sin(t+i)*sin(tan(uv.x*i)-t)*cos(t*1.*i*0.01)*1;
  sprite = vec2(uv.x*s,uv.y*s);
  float w = 512.;
  float h = 512.;
  
  float dx = sprite.x / w;
  float dy = sprite.y / h;
  
  float c = w / sprite.x;
  
  float index = cos(i+t*2.1);
  
  float x = mod(index, c);
  float y = floor(index / c);
  
  vec2 uv2 = vec2(dx * uv.x + x * dx, 1.0 - dy - y * dy * uv.y);
  
  float ca = cos(i*10.1+t*10.);
  cc += texture2D(texChecker,uv2);
  }
  
	out_color = cc/8.0+0.1*cos(t*1.)*texture2D(texPreviousFrame,uv)*0.5;
  out_color = out_color;
  
}