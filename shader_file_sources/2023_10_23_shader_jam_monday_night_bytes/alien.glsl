#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D c1;
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define iTime fGlobalTime

#define bpm 140.
#define one_bpm 60./bpm
#define beat(a) fract(iTime/(one_bpm*a))

mat2 rot(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a));}


void main(void)
{
  float fft = texture(texFFTSmoothed, 0.1).x * 100;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 vv = uv;
  vec2 uu = uv;
  uv.x += sin(iTime*0.5+fft);
  uv.y += cos(iTime*0.5 + sin(0.4*iTime));
  
  uu.x += sin(iTime*0.1);
  uu.y += cos(iTime*0.8 + sin(0.2*iTime));
  
  
  
  uv *= 10.0;
  uv.y += iTime;
  uv = fract(uv + fft);
  uv -= 0.5;
  uv*= rot(0.4*iTime);
  uu *= rot(0.9);
  uu = fract(uu);
  uu -= 0.5;
  
  
  float rad = texture(texFFT, uv.x * 1.0).r * 10;
	float c = smoothstep(0.99, 1.0, length(uv) + 0.5 + texture(texFFTSmoothed, 0.07).r*5.);
  vec3 color1 = c * texture(texNoise, uu*uv*fft).xyz * vec3(2.8, 0.2+fft, 0.1) * 2.0;
  float cc = smoothstep(0.99, 1.0, length(uu) + 0.5 + sin(uv.y * uv.y));
  
  c = c * cc;
  

  
  vec4 fc = mix(vec4(c), texture(texPreviousFrame, vv), fft);
  if(beat(4.0) < 0.0) {
    fc = 1.-fc;
  }
  if(beat(2.0) < 0.5) {
    fc = color1.xyzz;  
  }
  
  
	out_color = fc;
}