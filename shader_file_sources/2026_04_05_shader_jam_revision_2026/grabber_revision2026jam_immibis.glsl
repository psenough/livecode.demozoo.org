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

// UTILITIES
void cput(ivec2 pixel, uvec3 value) {
  imageStore(computeTex[0], pixel, value.xxxx);
  imageStore(computeTex[1], pixel, value.yyyy);
  imageStore(computeTex[2], pixel, value.zzzz);
}
uvec3 cget(ivec2 pixel) {
  return uvec3(imageLoad(computeTexBack[0], pixel).x, imageLoad(computeTexBack[1], pixel).x, imageLoad(computeTexBack[2], pixel).x);
}
void cputf(ivec2 pixel, vec3 value) {cput(pixel, uvec3(value * 65536.0));}
vec3 cgetf(ivec2 pixel) {return vec3(cget(pixel)) / 65536.0;}
void cputff(vec2 coord, vec3 value) {cputf(ivec2(coord * v2Resolution.yy/2 + v2Resolution.xy/2 + 0.5), value);}
void rotate(inout vec2 v, float a) {v = vec2(v.x*cos(a)+v.y*sin(a), v.y*cos(a)-v.x*sin(a));}
float slidestep(float f, float fraction) {float i=floor(f); f-=i; if(f<fraction) f/=fraction; else f=1.0; return i+f;}

// SDFs
float sdfCube(vec3 pos, float radius) {
  return max(max(abs(pos.x),abs(pos.y)),abs(pos.z))-radius; // not accurate
}
float sdfAnticube(vec3 pos, float radius) {
  pos = abs(pos);
  return max(max(min(pos.x,pos.y), min(pos.x, pos.z)), min(pos.y, pos.z))-radius; // not accurate
  // how to exclude one dimension
  //return max(max(min(pos.x,pos.y), min(pos.x, pos.z)), pos.y)-radius;
}
float sdfSphere(vec3 pos, float radius) {
  return length(pos) - radius;
}
//vec3 reflect(vec3 v, vec3 normal) {return v - 2*dot(v,normal)*normal;} // GLSL builtin but here's the formula

float globalFlicker;

mat2 rot(float a) {return mat2(cos(a),sin(a),-sin(a),cos(a));}

float sceneSDF(vec3 pos) {
  //return 1;
  //pos = mod(pos, 5);
  float sdf;
  {
    vec3 pos_ = pos;
    pos_ += vec3(5,5,-25);
    
    //if(mod(globalFlicker,1) < 0.5)
      //pos_ = mod(pos_, 20);
    pos_.xz *= rot(fGlobalTime);
    pos_.yz *= rot(fGlobalTime*0.5);
    if(mod(globalFlicker,1) < 0.5)
      pos_.yz = mod(pos_.yz, 20);
    if(mod(globalFlicker,2) < 1)
      pos_.x = mod(pos_.x, 20);
    sdf = sdfAnticube(pos_,1);
  }
  sdf = min(sdf, sdfSphere(mod(pos,vec3(30))-vec3(10,10,-25+sin(fGlobalTime)*10), 2));
  return sdf;
}

void plot(vec3 pos, int value) {
  pos.x += sin(fGlobalTime*0.2)*50;
  pos.y += cos(fGlobalTime*0.2)*50;
  if(true) {
  switch(int(fGlobalTime/2) % 3) {
    case 0:
      pos.xyz = pos.zxy;
      pos.xz *= rot(fGlobalTime*1.5);
      break;
    case 1:
      pos.xz *= rot(fGlobalTime*1.5);
      pos.z = -pos.z;
      break;
    case 2:
      pos.z += sin(fGlobalTime);
      pos.xyz = pos.yzx;
      pos.z = -pos.z;
      break;
  }
}
  
  //pos.xz *= rot(sin(fGlobalTime));
  //pos.z += 10;
  //pos.z += 50;
  //pos.z -= 25;
  if(pos.z < 0) return;
  pos.xy /= pos.z;
  
  pos.xy *= 0.3;
  pos.xy *= v2Resolution.xx;
  pos.xy += v2Resolution.xy/2;
  
  if(mod(globalFlicker, 2) < 0.2) {
    cput(ivec2(pos.xy), uvec3(30));
  } else {
    imageAtomicMax(computeTex[0], ivec2(pos.xy), value);
  }
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
  vec2 uv = (gl_FragCoord.xy-v2Resolution.xy/2)/v2Resolution.xy;
  globalFlicker = fGlobalTime + sin(fGlobalTime*7) + uv.x*uv.y;
  //vec4 
  //cput(ivec2(gl_FragCoord*(3+sin(fGlobalTime))), uvec3(10000,0,0));
  
  vec3 pos = vec3(uv*200,-50);
  vec3 dir = normalize((vec3(uv, 1)));
  for(int i = 0; i < 20; i++) {
    float sdf = sceneSDF(pos);
    //float sdf = sdfCube(pos-vec3(2),1);
    
    if(sdf < 0.05) {
    //if(pos.x + pos.y + pos.z > 10) {
      plot(pos, 20);
      //out_color = vec4(0,abs(sin(fGlobalTime*5+gl_FragCoord.x/30)),0,1);
      break;
      
    }
    //plot(pos+dir*sdf*mod(fGlobalTime, 1), i);
    plot(pos, i);
    pos += dir*sdf;
    
  }
  
  
  
  vec2 pos2 = gl_FragCoord.xy;
  //pos2 -= v2Resolution.xy/2; pos2 /= v2Resolution.xx;
  //pos2 = normalize(pos2)/length(pos2)*0.05;
  //pos2 *= v2Resolution.xx; pos2 += v2Resolution.xy/2;
  
  uint i = imageLoad(computeTexBack[0], ivec2(pos2)).x;
  out_color = vec4(vec3(i).xxx/30.0,1);
  float gamma = 1.0;
  out_color = pow(out_color + (pow(texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution),vec4(1/gamma))-out_color)*0.2, vec4(gamma));
}