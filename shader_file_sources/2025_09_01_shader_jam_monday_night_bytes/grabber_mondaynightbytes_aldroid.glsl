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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


void setVec3(ivec2 index, vec3 val) {  
  ivec3 quant_val = ivec3((val+100) * 1000);
  
  imageStore(computeTex[0], index, ivec4(quant_val.x)); 
  imageStore(computeTex[1], index, ivec4(quant_val.y)); 
  imageStore(computeTex[2], index, ivec4(quant_val.z)); 
}

vec3 readVec3(ivec2 index){
  return 0.001*(vec3(
    imageLoad(computeTexBack[0],index).x,
    imageLoad(computeTexBack[1],index).x,
    imageLoad(computeTexBack[2],index).x
  ))-100;
}

vec3 getParticle(int pi) {
  return readVec3(ivec2(pi,0));
}

void updateParticle(float pi) {
  vec3 pp = readVec3(ivec2(pi,0));
  vec3 pv = readVec3(ivec2(pi,1));
  if (abs(pp.x) > 11 ) {
    pp = (vec3(
      texture(texNoise,vec2(fGlobalTime, sin(pi+fGlobalTime))).x,
      texture(texNoise,vec2(fGlobalTime, sin(4*pi+fGlobalTime))).x,
      texture(texNoise,vec2(fGlobalTime, sin(7*pi+fGlobalTime))).x)-.25)*10;
    pv = (vec3(
      texture(texNoise,vec2(fGlobalTime, sin(pi+fGlobalTime))).x,
      texture(texNoise,vec2(fGlobalTime, sin(4*pi+fGlobalTime))).x,
      texture(texNoise,vec2(fGlobalTime, sin(7*pi+fGlobalTime))).x)-.25)*10;
  
  }
  if (abs(pp.x) > 10) pv.x = -pv.x;
  if (abs(pp.y) > 10) pv.y = -pv.y;
  if (abs(pp.z) > 10) pv.z = -pv.z;
  pp += pv * 0.05;
  setVec3(ivec2(pi,0),pp);
  setVec3(ivec2(pi,1),pv);
}

int maxParticles = 40;

float map(vec3 p) {
  float res = 1e7;
  for (int i=0;i<maxParticles; ++i) {
    vec3 tp = getParticle(i);
    res = min(res,length(p-tp)-.4-6.8*texture(texFFT,float(i+1)/float(maxParticles)).x);
  }
  return res;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  return normalize(map(p) - vec3(map(p-e.xyy), map(p-e.yxy), map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ruv = uv;
  uv.x += sin(fGlobalTime/1)*0.01;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

 if (gl_FragCoord.y > 1 && gl_FragCoord.x < maxParticles) {
   updateParticle(gl_FragCoord.x);
 }
 vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
 float t=0,d;
 
 float walt = 0;
 
 for (int i=0;i<50;++i) {
   vec3 p = ro+rd*t;
   d = map(p);
   if (d<0.01) break;
   t += d;
   if (abs(p.x)>11) {
     ro = p;
     rd.x = -rd.x;
     walt += 1;
   }
   if (abs(p.y)>11) {
     ro = p;
     rd.y = -rd.y;
     walt += 1;
   }
   if (abs(p.z)>11) {
     ro = p;
     rd.z = -rd.z;
     walt += 1;
   }
   
   if (t > 50) break;
 }
 
 float dtz = smoothstep(0.3,0.31,length(fract(uv*10)-0.5));
 
 //walt *= dtz;
 
 vec3 col = mix(texture(texPreviousFrame,ruv+vec2(0.001,0)).xyz*0.8,vec3(.1*walt), dtz+.1);
 
 vec3 ld = normalize(vec3(1,2,-3));
 
 if (d<0.01) {
   vec3 p = ro+rd*t;
   vec3 n = gn(p);
   col = vec3(1)*floor(dot(ld,n)*4)/4;
 }
 uv.x += 0.6*fGlobalTime-texture(texFFTIntegrated,0.1).x;
 out_color.rgb=col+vec3(sin(uv.x*4),sin(uv.x*7),0)*0.1;
}