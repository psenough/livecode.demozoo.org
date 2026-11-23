#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t = 0.0;

vec4 getTexture(sampler2D sampler, vec2 uv){
     vec2 size = textureSize(sampler,0);
     float ratio = size.x/size.y;
     return texture(sampler,uv*vec2(1.,-1.*ratio)-.5)*0.2;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec4 pf = texture(texPreviousFrame,uv+cos(t*1.+uv.y*2.)*cos(t*10.+uv.x));
  t = 10+mod(fGlobalTime*1.,16.0);

  
	float d = 0.1 / length(uv+cos(t+uv.y)*pf.r*0.9)*t;

	float f = texture( texFFT, t*0.5+d*1 ).r * 1;
  d-=f*100.;
  f/=uv.x;
  f*=pf.r*cos(t*uv.x+d)*10;
	vec4 c = vec4(0.0);
  uv.x+=f*1.;
  for (float ff=0.0;ff<16.0;ff+=1.0) {
    
    c+=getTexture(texInerciaLogo2024,vec2(t*0.5,cos(t+cos(uv.x+ff*0.1))*0.2)+uv*0.8+vec2(ff+f*0.1,ff*0.01+f*0.01))*1.+vec4(abs(f+tan(cos(cos(ff*0.1+d+t))*0.1)),0.1* abs(f*cos(ff/cos(t*0.001))*5.),abs(f*1.*fract(abs(f+ff*0.1))),0.0)*0.1;
  }
	out_color =clamp(pf.rgba*0.2+vec4(c.r/cos(pf.g*1.+d*0.1),c.g*0.81+cos(pf.b*1.)*0.1,c.b*0.7/cos(pf.b*1.)*2.0,1.0),0.0,1.0)*0.9;
}