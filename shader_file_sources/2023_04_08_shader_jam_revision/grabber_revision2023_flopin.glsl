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
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float o = abs(uv.x);
  float off = 5.*o*mod(fGlobalTime, 1.0);
  uv.x = mod(uv.x + o*(off-2.5) + fGlobalTime, 1.0);

  float c = 0.;
	float t = mod(floor(fGlobalTime / 0.5), 2.);
  float c1 = step(uv.x, 0.5-t);

	float t2 = mod(floor(fGlobalTime / 0.5), 2.);
  float c2 = step(uv.y, 0.2-t*0.5);
  
  t = floor(mod(fGlobalTime*23., 10.));
  c = step(1-mod(abs(uv.x), 1.0), t/10.);
  
  float m = abs(floor(uv.x*10.))/10.;
  float clr = abs(floor(uv.x*10.))/10.;
  float mr = abs(sin(fGlobalTime*23.));
  
  float beat = 2.;
  float strobe = max(mod(fGlobalTime*6., 2.)-1., 0.);
  
  
  vec4 color = vec4(c*m*mr,c*m*(1.-mr),c*m,1.0);
  
  out_color = mix(color, vec4(1.0, 1.0, 1.0, 1.0), floor(strobe+0.2));
}