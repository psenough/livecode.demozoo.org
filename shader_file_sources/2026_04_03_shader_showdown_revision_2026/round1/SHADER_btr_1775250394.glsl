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
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define frag gl_FragCoord
#define T fGlobalTime
#define Res v2Resolution

mat2 rot2d(float a){
  return mat2(cos(a),-sin(a),sin(a),cos(a));
  }

  float sdOcta(vec3 p, float s){
    p=abs(p);
    return (p.x*p.y*p.z-s)*0.5777;
  }
  
  float map(vec3 p, float d){
    
    return sdOcta(p,.15);
  }
  
  void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);

	vec2 m = vec2(cos(T*.2),sin(T*.2));
  float t=0;
  int i;
  for(i=0;i<70;i++)
  {
    vec3 ro=vec3(0,0,3);
    vec3 rd=normalize(vec3(uv,1.));
    float p;
    p=map(ro,t);
    
 }
  uv*=vec2(sin(0.7512),cos(0.66))*10;
  uv/=6.8318;
  vec3 col = vec3(uv*sin(T),1.);
	out_color =vec4(col,1.);
}