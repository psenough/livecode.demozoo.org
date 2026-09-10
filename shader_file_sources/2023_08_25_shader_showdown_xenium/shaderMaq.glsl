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


void main(void)
{
  float iTime = fGlobalTime;
  vec2 p = out_texcoord;
  p /= vec2(v2Resolution.y / v2Resolution.x, 1);
  p-=0.5;
  p.y*=1.1;
  p*=4.0;
  
  vec2 iT=vec2(sin(iTime*0.5)*1.4, sin(iTime*1.3)*1.2);

  float d=length(p);
  
  //vec2 uv = 4.0*p;
  vec2 uv=p;
  vec3 col;


  int fx = 0;
  
  int NFX=3;
  float DX = 1.0/float(NFX);
  
  fx = int(sin(iTime*0.25)/DX);
  
  // kulka
if(fx==0)
{
   p+=iT;
  float R=0.6;
  float z= sqrt(0.5-p.x*p.x-p.y*p.y);
  float z2= sqrt(0.5+p.x*p.x+p.y*p.y);
  if(d<R)
  {
    uv = p/z;
    col= 4.0*(1.0-d)*texture( texTex2, uv+iT ).rgb;
  }
  else
  {
    uv = p/z2;
    col= 2.0*(d)*texture( texTex2, uv-iT ).rgb;
  }
}
else
  if(fx==1)
    {
  // 2
 float d2 = abs(p.y-0.6);
  float fi = iTime * 0.2;
  mat2 rot = mat2(cos(fi), -sin(fi), sin(fi), cos(fi));
  p = rot*p;
uv = p/d2;
 col= 2.0*(d2)*texture( texTex2, uv-iTime*0.1 ).rgb;
    }
    else
      if(fx==2)
      {
        
  // 3
    float fi = iTime * 0.7;
    mat2 rot = mat2(cos(fi), -sin(fi), sin(fi), cos(fi));
    p = rot*p;
    float a = atan(p.x, p.y);
    uv= vec2(0.3/d, a);
    col= 0.5*(d*d)*texture( texTex2, uv+iTime*0.4 ).rgb;
}	


	out_color = vec4(col,1.0);
}



/*

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}



	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
*/