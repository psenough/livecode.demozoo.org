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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texTex5;
uniform sampler2D texTex6;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define iTime fGlobalTime

#define one_bpm 60./140.
#define beat(a) fract(iTime/(one_bpm*a))

mat2 rot(float a) {return mat2(cos(a), -sin(a), sin(a), cos(a));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 nuv = uv;
  if(beat(1.0) < 0.5) {
    uv *= rot(0.8);
  }
  
  if(beat(2.0) < 0.5) {
    uv *= fract(uv * 4.0);
    uv = abs(uv);
  }
  
  if(beat(16.) > 0.9) {
    uv += 0.5;
  }
  

  vec3 color = vec3(0);
  vec2 uvv = uv;
  vec2 uu = uv;
  if(beat(4) < 0.5) {
    
  uvv.x += beat(4.0)*0.2;
  }
  else {
    uvv.y += beat(4.0)*0.2;
  }
  float b = texture(texTex6, uvv).a;
  
  if(beat(4.0) < 0.5) {
    
    //uvv *= fract(uv * 4.0 );
  }
  uv *=  0.8 + beat(4.) * .4;
  vec2 uv1 = uv;
  vec2 uv2 = uv;
  uv1 *=  0.8 + beat(4.) * .4;
  uv2 *= rot(beat(2.0));
  uv1 *=  0.8 + beat(2.) * .4;
  uv1 *= rot(-beat(4.0));
  uv1 -= 0.5;
  uv2 -= 0.5;
  
  float m1 = step(length(uv1+0.5) - 0.25, 0.0);
  float m2 = step(length(uv2 + 0.5) - 0.5, 0.0) * 1.-step(length(uv2 + 0.5) - 0.3, 0.0);
  
  if(beat(8.0) < 0.5) {
   // m1 = 1;
//    m2 = 1;
   uv2 *= 2.0;
    uv1 *= 2.0;
  }
  
  if(beat(2.0) < 0.5) {
    uv2 *= 20.0;
    uv1 *= 20.0;
  }    
  
  vec3 t1 = texture(texRevisionBW, uv1).xxx * m1;
  vec3 t2 = texture(texRevisionBW, uv2).xxx * m2;
  
  
  
  
  color = t1+t2;
  color *= b;

  
    
    //color*= vec3(beat(2.0), beat(4.0), 0.9);
  
   

  
  
  color = mix(texture(texPreviousFrame, uvv).xyz, color, 0.8 );
 
  float a = step(fract(uu.x * 5.0 + beat(4.)), 0.8);
  //color *= vec3(a);
  
  
  
  
  
  
  color = beat(1) < 0.5 ? color : 1.-color;
  
  
  //vec2 tt = texture();
  
  
    
  
  if(beat(32.0) < 0.5) {
    color = t1+t2;
  }
  if(beat(8.0) < 0.5) {
    vec2 n=  texture(texNoise, uv).xy;
    n.x += iTime;
    color *= texture(texChecker, n).xyz;
  }
  
  if(beat(4.0) < 0.5 || true) {
    vec2 n=  texture(texNoise, uv).xy;
    n.x += iTime*0.2;
    n.y *=color.x;
    color /= texture(texChecker, n).xyz;
  }
  
  vec2 s = step(fract(uv*2.0), 0.5 + vec2(beat(1.0)));
    color *= min(s.x, s.y);
  
  if(beat(32) > 0.5) {
    color = 1.- color;
  }
  
  if(beat(16.0) < 0.5 || true) {
    color = mix(color, texture(texPreviousFrame, uv).xyz, 0.5);
  }
  if(beat(32.0) < 0.5) {
    color *= fwidth(color)*20.0;
  }
  if(beat(16) <0.4) {
    
    color *= t1+t2; 
  }
  
  
  color *= color;
  color.xz *= pow(color.xy, uvv);
  
  
  
  
	out_color = color.xyzz;
}