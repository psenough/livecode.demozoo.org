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

#define tpi acos(-1.)*2.

float soup(vec2 uv, vec2 o, float d) {
  vec2 dd = vec2(d*2.0, d);
  return step(length(o-uv), d);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

 
  
  float t = fGlobalTime / 60. * 133.;
    
  uv.x += cos(t/2.)*.25;
  
  vec3 e = vec3(0, 0, 0);
  
  
  // Adding Soup
  e += soup(uv, vec2(0., 0.), mod(t, 0.1));
  
  float cc = 0.2;
  
  // Pink
  vec2 rr = vec2(
    0.2 + ((cos(t*2.0)+1.)*0.5)*0.6,
    0.2 + ((cos(t*2.0)+1.)*0.5)*0.2
  );
  float r = 0.08;
  for (int i = 0; i < 8; i += 1) {
    float a = i * (tpi / 8.) + t;
    
    vec2 o = vec2(cos(a), sin(a))*rr;
    float yay = soup(uv, o, mod(t, r));
    e += vec3(yay, yay*cc, yay*cc);
  }
  
  // Blue
  rr *= vec2(1.5, 1.5);
  r *= 0.75;
  for (int i = 0; i < 8; i += 1) {
    float a = i * (tpi / 8.) + t + tpi / 16.;
    
    vec2 o = vec2(cos(a), sin(a))*rr;
    float yay = soup(uv, o, mod(t, r));
    e += vec3(yay*cc, yay*cc, yay);
  }
  
  // Pink
  rr *= vec2(1.5, 1.5);
  r *= 1.25;
  for (int i = 0; i < 8; i += 1) {
    float a = i * (tpi / 8.) + t;
    
    vec2 o = vec2(cos(a), sin(a))*rr;
    float yay = soup(uv, o, mod(t, r));
    e += vec3(yay, yay*cc, yay*cc);
  }
  
  float crt = 0.001;
  e -= step(mod(uv.y+cos(uv.x*8.)*0.05, crt), crt/2.)*((cos(t/8.)+1)*0.5)*0.1;
  
  // Previous Frame
  vec2 puv = vec2(gl_FragCoord.xy/v2Resolution);
  puv.y += 0.01;
  puv.x += cos(t*2.0)*0.0001;
  vec3 p = texture(texPreviousFrame, puv).rgb;
  
  e += p * 0.998;
  
  // Wiper
  e *= step(abs(uv.x - (cos(t)+cos(uv.y*3.0+t*2.)*0.1)), .01)*-1.+1.;
  
  // Frame
  e *= step(abs(uv.y), 0.42);
  
  //e *= 1.8;
  

	out_color = vec4(e, 1.);
}