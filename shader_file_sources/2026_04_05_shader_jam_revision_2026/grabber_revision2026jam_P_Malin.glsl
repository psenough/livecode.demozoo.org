#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

/*
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
*/

mat2 Rotate(float t)
{
  return mat2(cos(t), -sin(t), sin(t), cos(t));
  
}

vec3 Pal(float f)
{
  
  f = abs(f - 0.5) * 2.0;
  
    vec3 col;
  col.r = f;
  col.g = f * f;
  col.b = f * f * f * f * f;
return col;
  }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 oUV =uv;
  
  float am = (sin(fGlobalTime * 0.2) * 0.5 + 0.5);
  am = am * am * 2.0;
  uv += sin(uv.yx * 3.0 + fGlobalTime) * am;
  
  uv += sin(uv.yx * 6.123 + fGlobalTime) * am * 0.4;
  
  uv += sin(uv.yx * 8.653 + fGlobalTime) * am * 0.2;
  
  	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  
	float f = texture( texFFT, m.y ).r * 0.02;
	float f2 = texture( texFFT, 0.5 ).r;
  
  for(int i=0; i<5; i++)
  {
     uv *= Rotate(fGlobalTime + sin(fGlobalTime * 2.0) * 1.5 + f);
    
     uv.x = abs(uv.x);
     uv.y = abs(uv.y);
     uv *= 0.9 + sin(fGlobalTime * 1.3521) * 0.1;
    
    
    uv -= 0.3 + sin(fGlobalTime * 0.5) * 0.5;
  }
  
  vec3 col = vec3(uv.xxy);
  float l = length(uv) * 5.;
  
  col = Pal(fract(l - fGlobalTime));
  
  if(fract(f) > 0.2)
  {
    col = col.gbr;
  }
  
  
  if(fract(fGlobalTime * 0.1) > 0.9)
  {
    col = col.gbr;
  }
  
  if(fract(fGlobalTime * 0.1) < 0.5)
  {
    col = col.grb;
  }
  
  col *= clamp(1.0-length(oUV) * 0.25,0.,1.);
  
  col += texture(texRevisionBW, uv *3.0 + vec2(fGlobalTime * 0.5, 0)).r * 0.25;// * sin(fGlobalTime * vec3(1,2,0));
 

  if(fract(fGlobalTime * 0.01) < 0.1)
  {
    if(fract(fGlobalTime * 0.5) < 0.5)
    {
       if(fract(oUV.x * 2 + fGlobalTime) > 0.5)
       {
         col = 1.-col;
       }
    }
    if(fract(fGlobalTime * 1.0) < 0.5)
    {
       if(fract(oUV.y * 2 + fGlobalTime * 2.0) > 0.5)
       {
         col = 1.-col;
       }
    }
  }
  col = pow(col, vec3(1.0) + f2);
  
 
  out_color = vec4(col, 1);
  /*
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
}