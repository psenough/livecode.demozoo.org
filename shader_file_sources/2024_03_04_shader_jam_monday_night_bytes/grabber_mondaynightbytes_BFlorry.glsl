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

vec2 rot(vec2 tex, float r){
  mat2 rotm = mat2(cos(r), -sin(r), sin(r), cos(r));
  vec2 qv = rotm*tex;
  return qv;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5;// + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	//uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  uv.x = abs(uv.x);
  uv+= sin(texture( texFFT, uv.x ).r);
  uv = (1/uv*5) * 0.01;
  
  float s=abs(sin(fGlobalTime)*5)*0.1+10;
  //uv = round(s*uv)/s;
  
  if(uv.x>0){
    //uv.x = pow(uv.x, 3);
  }
  uv *= rot(uv, texture( texFFTSmoothed, 1 ).r * 100);
  uv += rot(uv, fGlobalTime*0.1);

  
	vec2 m;
	//m.x = atan(uv.x / uv.y) / 3.14;
	//m.y = 1 / length(uv) * 0.2;
  m.y = length(uv);
  m = rot(uv,fGlobalTime);
	float d = sin(m.y*mod(fGlobalTime,20));

	float f;
	//f = sin(fGlobalTime);
  f = texture( texFFTSmoothed, d ).r * 100;
  m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
  
  

	vec4 t;
  //t = plas( m * 3.14, fGlobalTime ) / d;
	//
	t = vec4(texture( texFFTSmoothed, uv.x ).r*10,texture( texFFTSmoothed, uv.y ).r*10,texture( texFFTSmoothed, uv.x*uv.y ).r*10,texture( texFFTSmoothed, sin(uv.x)*10 ).r);
  t = clamp( t, 0.0, 1.0 );
  out_color = f + t;
}