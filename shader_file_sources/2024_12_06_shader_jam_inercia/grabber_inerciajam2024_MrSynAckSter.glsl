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

const float PI = 3.14159265;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec4 ourplas(vec2 uv, float t, float be,float by){
  float c1,c2,cf;
  c1= sin(uv.x*5.+t);//*(by/10.); 
  c2=sin(uv.y*(5.*be)+t)+sin(by);
  c2=sin(5.0*(uv.x*sin(t/2.)+uv.y*cos(t/3.0))+t);
  float cx,cy,c3;
  cx=uv.x+sin(t/5.0)*5.0; 
  cy=uv.y+sin(t/3.0)*5.0; 
  
  c3= sin(sqrt(100.0*(cx*cx+cy*cy+(be/10000.)))+t);   
  
  cf=c1+c2/c3; 
  
  float r,g,b; 
  
  r=cos(cf*PI);
  g=sin(cf*PI+6.0*PI/3.0*be);//+sin(by); 
  b=sin(cf*PI+4.0*PI/3.0);
  vec4 col = vec4(r,g,b,1.); 
  return col; 
  
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv *= sin(fGlobalTime/10.)*4.;
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  
  float de = gl_FragCoord.x*gl_FragCoord.y; 

	float f = texture( texFFT, d ).r * 100;
  float fx = texture(texFFT,de).r*15;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  
  vec4 pp = ourplas(uv,fGlobalTime,fx,f); 
	t = clamp( t, 0.0, 1.0 );
	out_color = pp;
}