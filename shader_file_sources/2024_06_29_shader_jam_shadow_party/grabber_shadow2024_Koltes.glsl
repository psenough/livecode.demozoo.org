#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
#define t fGlobalTime
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
mat2 rot(float a) {
  float c=cos(a),s=sin(a);
  return mat2(c,s,-s,c);
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv *=10.+sin(floor(t*4.)*2.)*5.;
  vec2 uv1 = uv+texture(texNoise, uv+t).xy*2.+vec2(1.0, 0.)*rot(t);
  
  vec2 uv2 = uv-texture(texNoise, uv+t*2.+1.).xy*3.+vec2(5.+4.*sin(t), 0.)*rot(t*1.3);
  
  float d1 = step(1., mod(length(uv1), 2.));
  float d2 = step(1., mod(length(uv2), 2.));
  
  float c = step(1., mod(d1 + d2, 2.));
	out_color = mix( texture(texPreviousFrame, (uv*.05+.5)*rot(texture(texFFTIntegrated, .03).x*1.)),vec4(c),fFrameTime*(30.+sin(t)*20.));
}