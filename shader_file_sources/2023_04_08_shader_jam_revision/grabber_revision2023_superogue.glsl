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

float t=fGlobalTime;
float f,f2;
float i,s=sin(t);
vec3 p;

float N(vec3 p){return fract(sin(p.x*17.9+p.y*79.3)*4337);}


vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float S(vec3 p)

{
   float a=sin(t-p.z);
//    p = abs(p); 

  p.xy *= mat2(cos(a),-sin(a),sin(a),cos(a));
  p=mod(p,2)-1;
  for (i=0;i<4;i++) p=reflect(abs(p)-clamp(sin(t)*8,.1,.9), vec3(.4,.1,.9))*1.1;
  return dot(p,sign(p))-(sin(t)*.2+.4)/length(p)-.01;     
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float rr=sin(t/3)/2+2.5;
  float l=cos(length(uv)*rr);
  
  p=vec3(uv,1);
  vec3 r=vec3(p.x+s/3,p.y+sin(t*1.2)/4,1)+N(p)/16.;
  float i,d=1;
  f = texture( texFFT, .4 ).r ;// * 100;
  f2 = texture( texFFT, .2 ).r ;// * 100;
  p+=vec3(0,0,t*4+f);
  for (;d>.01&&i++<256;) p+=r*(d=S(p)/8);
//  p+=vec3(sin(f),0,0);

  vec4 c = vec4(3,s/2+1,2,2);
  c = abs( S(p-d)*c - S(p-.9)*c.zyxw);

  
	out_color = clamp(l*c * 9./float(i),0,1)+(-uv.y)*0.3;
}