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
uniform sampler2D texInerciaLogo2024;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

  vec4 getTexture(sampler2D sampler, vec2 uv){
      vec2 size = textureSize(sampler,0);
      float ratio = size.x/size.y;
      return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
  }

void main(void)
{
  vec2 uv = (gl_FragCoord.xy/v2Resolution-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  vec2 R2D = uv*R2D(fGlobalTime/8.);
  float BPM = 135.;
  float Luv = length(uv);
  vec3 col = .5+.5*cos(fGlobalTime+uv.xyx+vec3(0,2,4));
  float frac = fract(fGlobalTime*BPM/60.);
  float T8 = fGlobalTime*8.;
  vec3 Fog = vec3(.1)/Luv*4.;
  vec4 COL = vec4(0.);
  COL = getTexture(texInerciaLogo2024,R2D*2.-fGlobalTime/8);
  
  float pattern = ceil(length(sin(R2D-R2D*50./frac))-.2/Luv*frac);
  float pattern2 = ceil(length(sin(T8-(R2D*frac*R2D*50.)))-.2/Luv*frac);
  float pattern3 = ceil(sin(fGlobalTime*20.+R2D.x-frac/Luv/Luv*5./sin(fGlobalTime/8.)*2.));
  float pattern4 = ceil(length(sin(T8-(R2D.y*50.)))-.2/Luv/Luv+frac);
  float pattern5 = ceil(sin(T8-Luv*Luv/R2D.x*50.-frac));
  float pattern6 = ceil(sin(T8-uv.x*50./R2D.x*Luv-frac));
  
  float final = 0.;
  float modu = mod(fGlobalTime,24.);
  
  
  if(modu <= 4.){
  final = pattern;
  }else if(modu <= 8.){
  final = pattern2;
  }else if(modu <= 12.){
  final = pattern3;
  }else if(modu <= 16.){
  final = pattern4;
  }else if(modu <= 20.){
  final = pattern5;
  }else if(modu <= 24.){
  final = pattern6;
  }
  
  vec4 final2 = vec4(final*Fog*col,1.);
  vec4 final3 = sqrt(COL);
  vec4 final4 = max(final2,final3);
  
	out_color =vec4(final4*final2);
}