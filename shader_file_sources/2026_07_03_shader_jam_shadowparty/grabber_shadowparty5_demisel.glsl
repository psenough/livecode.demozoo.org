#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;

float rectDist(vec2 uv, float h, float w){
  vec2 rec = vec2(h,w);
  if(abs(dot(uv,rec))<0.01)
    return 0;
  return length(uv-rec);
}


float jspOnVaVoir(vec2 uv, float param, float param2lol){
  return 1.;
 
}

float rand(float salt){
  return fract(cos(salt) / 95381937.);
}

mat2 rotation(float angle){
  float s = sin(angle), c = cos(angle);
  return mat2(c,-s,s,c);
}

#define fft(f) texture(texFFTSmoothed, f).x
#define ffth(f) texture(texFFT, f).x

#define PI acos(-1)

void main(void)
{
	//vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvR = gl_FragCoord.xy/v2Resolution;
  vec2 uv = uvR;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv0 = uv;
  vec4 color = vec4(0.);
  
  float dist = rectDist(uv, .1, .1);
  
  color = vec4(
    step(.2,sin(uv.x)),
    step(.2, sin(uv.y)),
    step(.5, jspOnVaVoir(uv, .5, .5)),
    1.
  );
  
  
  
  uv = uv0;
  uv *= rotation(time+fft(.5)*100);
   
  vec4 fbc = texture(texPreviousFrame, uv);
  
  color = mix(color, fbc, .3);
  
  
  
  
  
	out_color = color;
}