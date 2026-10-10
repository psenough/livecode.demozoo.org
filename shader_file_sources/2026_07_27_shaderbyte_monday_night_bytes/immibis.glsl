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


mat2 rot(float a) {
  a /= 3;
  return mat2(cos(a),sin(a),-sin(a),cos(a));
}

float symmod(float a, float b) {return mod(a+b/2,b)-b/2;}

vec4 hitcol;
vec4 hitnorm;

float sdf(vec4 pos) {
  
  vec4 origpos = pos;
  
  pos.xw *= rot(fGlobalTime);
  pos.yz *= rot(fGlobalTime*1.1);
  pos.wz *= rot(fGlobalTime*1.3);
  pos.xw *= rot(fGlobalTime*1.4);
  
  pos.x -= fGlobalTime*10;
  //pos.x += pos.z;
  
  int which = int((pos.w+10)/20) + int((pos.z+10)/40) + int((pos.y+10)/80);
  which %= 2;
  
 
  pos.w = symmod(pos.w, 20);
  pos.z = symmod(pos.z, 20);
  pos.x = symmod(pos.x, 20);
  pos.y = symmod(pos.y, 20);
  
  float dist;
  
  if(which == 0) {
    hitcol = normalize(pos)*0.5+sin(fGlobalTime);
    hitnorm = normalize(pos);
    dist = length(pos)-5;
  } else {
    pos = abs(pos);
    
    if(pos.x >= pos.y && pos.x >= pos.z && pos.x >= pos.w) {
      hitcol = vec4(0.5+0.5*sin(origpos.z+origpos.y),0,0,0);
      hitnorm = vec4(sign(pos.x),0,0,0);
    } else if(pos.y >= pos.z && pos.y >= pos.w) {
      hitcol = vec4(0,1,0.5+0.5*sin(origpos.x),0);
      hitnorm = vec4(0,sign(pos.y),0,0);
    } else if(pos.z >= pos.w) {
      hitcol = vec4(0.5,0.5+0.5*sin(origpos.w),1,0);
      hitnorm = vec4(0,0,sign(pos.z),0);
    } else {
      hitcol = vec4(1,0,1,0)*(0.5+0.5*cos(origpos.x));
      hitnorm = vec4(0,0,0,sign(pos.w));
    }
    dist = max(pos.x,max(pos.y,max(pos.z,pos.w)))-5;
  }
  
  hitnorm.xw *= rot(-fGlobalTime*1.4);
  hitnorm.wz *= rot(-fGlobalTime*1.3);
  hitnorm.yz *= rot(-fGlobalTime*1.1);
  hitnorm.xw *= rot(-fGlobalTime);
  
  return dist;
}

void main(void)
{
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec4 pos = vec4(0, 0, -20, 0);
  vec4 dir = normalize(vec4(uv,1,0));
  
  pos += dir*10; // minimum distance from camera
  
  out_color = vec4(0,0,0,1);
  hitcol = vec4(1,1,1,1);
  float out_alpha = 1;
  for(int i = 0; i < 300; i++) {
    float dist = sdf(pos);
    if(dist < 0.02) {
      float hitalpha = 0.5;
      out_color += hitalpha * out_alpha * hitcol;
      out_alpha *= 1-hitalpha;
      dir = reflect(dir, hitnorm);
      pos += dir*0.03;
    } else {
      out_alpha *= 0.992;
    }
    pos += dir*dist;
  }
}


















































