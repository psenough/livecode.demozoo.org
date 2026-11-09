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
float sdfOcta(vec3 pos, float radius) {
  pos = abs(pos);
  return max(0, (pos.x+pos.y+pos.z)-radius); // not sure if accurate
}

// sdf value is (object id, position)
vec2 sdfmin(vec2 a, vec2 b) {
  if(a.y < b.y) return a; else return b;
}

vec2 sdf(vec3 pos) {
  
  vec3 pos_polar = vec3(atan(pos.x, pos.y), length(pos.xy) /*+ texture(texFFTSmoothed, pos.z/100.0).x*10.0*/, pos.z);
  pos = mix(pos, pos_polar, abs(sin(fGlobalTime/3)));
  
  //pos += 15;
  vec3 gridcell = floor(pos/30);
  vec3 gridwise_pos = fract(pos/30)*30;
  gridwise_pos -= 15;
  //pos -= 15;
  
  pos -= 15;
  vec3 gridwise_pos2 = fract(pos/30)*30;
  gridwise_pos2 -= 15;
  
  rotate(gridwise_pos.xz, (fGlobalTime*0.8 + gridcell.z));
  rotate(gridwise_pos.yz, (fGlobalTime*0.7 + gridcell.x));
  rotate(gridwise_pos.xy, (fGlobalTime*0.5 + gridcell.y));  
  //rotate(pos.yz, -fGlobalTime*1.3);
  
  float cube = sdfCube(gridwise_pos, 5.0);
  float octa = sdfOcta(gridwise_pos, 10.0);
  vec2 sdf = vec2(0.0, mix(cube, octa, sin(fGlobalTime)*0.5+0.5));
  //if(sdf > 5) sdf = 5-1/(sdf-5);
  
  sdf = sdfmin(sdf, vec2(1.0, sdfAnticube(gridwise_pos, 0.5)));
  sdf = sdfmin(sdf, vec2(2.0, sdfAnticube(gridwise_pos2, 0.5)));
  return sdf;
}
vec3 normal(vec3 pos) {
  vec2 delta=vec2(0.1,0);
  return normalize(vec3(sdf(pos+delta.xyy).y,sdf(pos+delta.yxy).y,sdf(pos+delta.yyx).y)-sdf(pos).y);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 pos = vec3(0,0,-70);
  vec3 dir = normalize(vec3(uv,1));
  dir.y = abs(dir.y);
  //dir.x = abs(dir.x);
  
  pos += dir*20; // skip objects near camera
  
  float time2 = fGlobalTime + slidestep(fGlobalTime*1.45,0.3)*0.8;
  time2 = fract(time2/4096)*4096; // don't know if needed to avoid precision loss in numerical normal calc?
  
  out_color = vec4(0,0,0,1);
  for(int i = 0; i<100 && dir.z < 1e6; i++) {
    vec3 pos_ = pos;
    rotate(pos_.xz, time2*0.2);
    rotate(pos_.xy, time2*0.1);
    pos_.z += time2*50;
    vec2 sdfhere = sdf(pos_);
    if(sdfhere.y < 0.1) {
      vec3 normal_ = normal(pos_);
      float c = sin(-normal_.z) + sin(normal_.y)*0.3;
      vec4 blue = vec4(c,c,c*0.5+0.5,1);
      vec4 red = vec4(c*0.5+0.5,c,c,1);
      out_color = mix(red, blue, sin(fGlobalTime+sdfhere.x*2)*0.5+0.5);
      break;
    }
    pos += dir*sdfhere.y;
  }
}
