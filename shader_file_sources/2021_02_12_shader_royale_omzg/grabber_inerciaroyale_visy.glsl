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
uniform float fMidiK1;
uniform float fMidiK2;
uniform float fMidiK3;
uniform float fMidiK4;
uniform float fMidiK5;
uniform float fMidiK6;
uniform float fMidiK7;
uniform float fMidiK8;
uniform float fMidiS1;
uniform float fMidiS2;
uniform float fMidiS3;
uniform float fMidiS4;
uniform float fMidiS5;
uniform float fMidiS6;
uniform float fMidiS7;
uniform float fMidiS8;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv2 = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec4 fe = texture(texPreviousFrame,uv2);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

 	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = tan(fe.g*1.1)*1. + abs(cos(sin(uv.x+fe.g*1.01)) * 0.1);

  float t = fGlobalTime*0.4;
  float bi = texture(texFFTIntegrated, m.y*cos(t*0.1)*10.).r*0.01;

	float d = m.y;

	float f = texture( texFFT, d ).r * 1;
	m.x += sin( fGlobalTime ) * 0.7;
	m.y += fGlobalTime * 0.65;
  float ef = t*(t*sin(t*5.*cos(bi*abs(cos(t*0.1))*0.1+t*0.9)*0.1*cos(uv.y*4.))*0.9)*0.7;
  float ef2 = (t*sin(t*5.*sin(bi*abs(cos(t*0.2))*0.2+t*0.9)*0.1*cos(uv.y*4.))*0.9)*0.7;
  
	out_color = vec4(0.8,0.5,0.8,ef*0.1+ef2*0.8)-vec4(ef2/fe.b*1.,ef2*fe.r,ef*fe.g,1.0)*0.1*fe*tan(fe.a*1000.);
}