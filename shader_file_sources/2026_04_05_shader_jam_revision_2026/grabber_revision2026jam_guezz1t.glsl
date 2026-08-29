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

float ckr(vec2 uv) {
  vec2 s = sign(fract(uv)-.5);
  return s.x * s.y;
}

mat2 rot(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c,s,-s,c);
}

float de(vec3 p) {
 float s = 1.;
//  p.x = fract(p.x * s + .5 * s) / s - .5 * s; 
  
  return max( length(p.xz) - 0.05, abs(p.y) -.2) ; 
}

const float Far = 20.;

float march(vec3 o, vec3 d) {

  float t = 0.;
  for (int i =0; i < 100; ++i) {
    vec3 p = o + t * d;
    float d = de(p);
    if (d < 0.001)
      return t;
    t += d;
    if (t > Far) break;
  }
  return Far;
}

vec3 nrm(vec3 p) {
  vec2 e = vec2(0.001,0.);
  return normalize(vec3(
    de(p+e.xyy)-de(p-e.xyy),
    de(p+e.yxy)-de(p-e.yxy),
    de(p+e.yyx)-de(p-e.yyx) ));
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float l = sign(fract(gl_FragCoord.y * .5) - .5) * .5 + .5;
  
  vec3 o = vec3(0., 0., 2.);
  vec3 d = normalize(vec3(uv,0.)-o); 

  
  float pixy = floor((uv.y + .5) / 0.2) * 0.2;
  uv.x += (texture(texFFTSmoothed, pixy * .2 + .5).r-.007) * 20.;
  
  out_color = vec4(0.);
  float f = 10., p = 0., cr0 = 0., cr1 = 0.;
  for (int i = 0; i < 5; ++i) {
    p += sin(fGlobalTime * .1);
    vec3 c = vec3(0.2,0.1,0.1);
    c.xy *= rot(cr0);
    c.yz *= rot(cr1);
     
    float m = ckr(rot(fGlobalTime + p) * uv * f * (2 + .5 * sin(fGlobalTime)));
    out_color += l * vec4(c * m, 1.);
    cr0 += sin(fGlobalTime * 0.7);
    cr1 += sin(pixy * 2. + fGlobalTime * 0.6);
    f /= 2.7;
  }
  
  float t = march(o,d);
  if (t < Far) {
      //out_color = vec4(nrm(o + d * t) * .5 + .5, 1.);
  }

}
