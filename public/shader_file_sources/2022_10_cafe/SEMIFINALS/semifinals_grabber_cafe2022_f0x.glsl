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
	
  vec2 uv2 = uv- 0.5;
	uv2 /= vec2(v2Resolution.y / v2Resolution.x,1);

  
  uv.x-=pow(fract(fGlobalTime*1.),2.)*.1+.1*abs(uv.y);
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x,1);

	vec2 m;
	m.x = atan(uv.x / uv.y/2.)/  3.14;
	m.y = 1 / length(uv) * .2;
	float d = fract(m.x*5.);

  d+=sin(fGlobalTime*10.1)+fract(fGlobalTime);
  
  m.y-=abs(pow(d,d))*.1;
  m.y+=.1*sin(fGlobalTime*10.1)+.3*fract(fGlobalTime);
  
  
  
  if (m.y<.5) d=0.;
  if (m.y>.6) d=0.;
  
  float r;
  
  r=fract(uv2.x+uv2.y*2.+.2);
  r=clamp(r,.75,1.-uv2.y*.3);
  if (r<uv2.x+1.15) r=0.0; else r=1;
  
	//float f = texture( texFFT, d ).r * 100;
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;

	//vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = 0.0;
	out_color = vec4(r,r,d,1.0);
 ;
}