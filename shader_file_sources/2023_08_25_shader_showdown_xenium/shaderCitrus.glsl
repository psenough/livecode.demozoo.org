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

float wihajster(vec2 uv, vec2 offset, float radius)
{
  float dist = length(uv - offset) - radius;
  
	return dist;
}

float rand(float x)
{
    return fract(sin(x) * 43999.109284) * 12451.98512415;
}

vec2 rotate(vec2 uv, float amount) 
{
    uv += 0.5;
    uv *= mat2( sin(amount), -cos(amount),
                cos(amount), sin(amount));
    uv -= 0.5;
    return uv;
}

float starfield(vec2 uv)
{
  if((texture(texTex2, uv).x + texture(texTex2, uv).y +texture(texTex2, uv).z) / 3 > .5)
  {
    return 1.;
  }
  return 0.;
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv *= 3.5;
  

  
	float erf = wihajster(uv, vec2(0.0, 0.0), 0.5 + sin(fGlobalTime) * .2 + .2);
  if(erf > 0)
  {
    if(starfield(uv) == 1.)
    {
      out_color = vec4(1.0);
    }
    
    if(starfield(uv + vec2(0.5)) == 1.)
    {
      out_color = vec4(0, 1, 1, 1.0);
    }
    
    if(starfield(uv+ vec2(0.7)) == 1.)
    {
      out_color = vec4(1, 0, 1, 1.0);
    }
    
    if(starfield(uv+ vec2(0.8)) == 1.)
    {
      out_color = vec4(0, 1, 1, 1.0);
    }
    
    
  }
  else 
  {
    //erf
    vec3 noise = texture(texNoise, uv * 0.3 + vec2(fGlobalTime * 0.2, 0)).xyz;
    if(noise.x < 0.19)
    {
      out_color = vec4(0, 0, 1, 1.0);
    }
    else if(noise.x < .32)
    {
      out_color = vec4(0, 1, 0, 1);
    }
    else if(noise.x < .48)
    {
      out_color= vec4(1,1, 1, 1);
    }    
  }
  //mun
  float mun = wihajster(uv, vec2(sin(fGlobalTime), cos(fGlobalTime)), 0.1 + sin(fGlobalTime) * .2 + .2);
  if(mun < 0)
  {
    out_color = vec4(texture(texNoise, uv + vec2(-sin(fGlobalTime), -cos(fGlobalTime))).xxx, 1);
  }  
  
  
   
}













