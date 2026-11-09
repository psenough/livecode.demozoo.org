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

const float pi = 3.141592653;
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

float sdf_sphere(vec3 pos, float radius) {
  return length(pos) - radius;
  //return length(pos) - (50 + 30*texture(texFFTSmoothed, atan(pos.x, pos.z)).r); // not a real SDF
}

float cube_radius(vec3 pos) {
  return max(max(abs(pos.x),abs(pos.y)),abs(pos.z));
}
float sdf_cube(vec3 pos, float size) {
  return cube_radius(pos)-size;
}

void center_mod(inout vec3 pos, vec3 gridsize) {
  pos += gridsize/2;
  pos = mod(pos, gridsize);
  pos -= gridsize/2;
}

int jumps;
float sdf(vec3 pos) {
  
  for(int iter = 0; iter < 3; iter++) {
    
    //rotate(pos.xy, 2);
    //rotate(pos.yz, 1);
    //pos = mod(pos, 1);
  }
  
  //pos.x -= texture(texFFTSmoothed, pos.y/4000).r*400;
  switch(jumps % 3) {
    case 0: pos.xy += pos.z / 4; break;
    case 1: pos.xy += int(pos.z); break;
    case 2: break;
  }
  center_mod(pos, vec3(35));
  
  float sdf;
  switch((jumps) % 2) {
    case 0: sdf = sdf_sphere(pos, 5); break;
    case 1: sdf = sdf_cube(pos, 5); break;
    //case 2: sdf = (sdf_cube(pos, 5) + sdf_sphere(pos, 5))/2; break;
  }
  
  //float sdf = (sdf_cube(pos, 5) + sdf_sphere(pos, 5))/2;
  //sdf = min(sdf, 5);
  return sdf;
  //return sdf_cube(pos, 20) - 10;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
float maxdist;
void plot(vec3 pos, bool dim) {
  //pos.z -= maxdist/2;
  
  float jumptime = fGlobalTime + floor(fGlobalTime)*2;
  
  pos.z += 50;
  rotate(pos.xy, (fGlobalTime/6 + jumps));
  pos.xyz = -pos.yzx;
  pos.x += 50*sin((fGlobalTime/2 + jumps*3));
  pos.y += 50*cos((fGlobalTime/4 + float(mod(int(jumps)*int(jumps), 50)))) + 20;
  //rotate(pos.xz, (pi/6)*sin(fGlobalTime)+pi/4);
  //rotate(pos.xy, (pi/6)*cos(fGlobalTime));
  //rotate(pos.xz, fGlobalTime);
  //rotate(pos.yz, fGlobalTime/3);
  //if(pos.z < 0) return; // trippy on Intel drivers due to uninitialized tesxture data
  bool ortho = false;
  if(pos.z >= 0 || ortho) { // what we really meant was to disable only this block
    vec2 ipos = pos.xy;
    ipos /= 300;
    if(!ortho) ipos /= (pos.z / 100); // comment for orthographic, uncomment for perspective
    //ipos /= (pos.z / 50) + 2; // wrong order, also trippy
    ipos.y *= v2Resolution.x/v2Resolution.y;
    ipos += 0.5;
    ipos *= v2Resolution.xy;
    
    //float brightness = max(0.3,-pos.z/50) * brightness_multiplier;
    //float brightness = brightness_multiplier;
    //imageAtomicMax(computeTex[0], ivec2(ipos), uint(brightness * 65536));
    if(!dim) {
      imageAtomicMax(computeTex[0], ivec2(ipos), uint(65536));
    } else {
      imageAtomicAdd(computeTex[0], ivec2(ipos), 4096);
    }
  }
}
void main(void)
{
	jumps = int(floor(fGlobalTime/2));
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	//uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv *= 2;
  
  //maxdist = mod(fGlobalTime/3,1)*200-50;
  //maxdist = cos(fGlobalTime)*75+25;
  //float gridsize = 0.006-mod(fGlobalTime/3,1)*0.005;
  
  if(false) {
    float gridsize = -cos(fGlobalTime)*0.0025+0.0035;
    uv -= mod(uv, gridsize);
  }
  
  vec3 pos = vec3(uv, -1)*100;
  vec3 dir = vec3(0, 0, 1);
  
  

  maxdist = 100;
  for(int step = 0; step < 100 && pos.z < maxdist; step++) {
    float sdf_here = sdf(pos);
    if(sdf_here < 0) {
      plot(pos, false);
      //break;
      sdf_here = 20;
    }
    pos += dir*sdf_here;
    plot(pos, true);
  }
  
  //plot(pos, false);
  
  
  
  
  float myval = float(imageLoad(computeTexBack[0], ivec2(gl_FragCoord.xy)).x) / 65536.0;
  out_color.rgb = vec3(myval);
  //out_color.rgb = vec3(abs(myval / 200.0));
  out_color.a = 1;
  
  
  
  // now to spend the last 5 minutes adding trans flag colours
  if(true) {
    uv = gl_FragCoord.xy / v2Resolution;
    float fftx = abs(uv.x - 0.5)/10;
    uv.y += texture(texFFTSmoothed, fftx).r * fftx * 40 * -sign(uv.y-0.5);
    int section = int(uv.y * 5);
    switch(section) {
    case 0: case 4: out_color.rg /= 2; out_color.b += 0.5; out_color.rg += 0.2; break;
    case 1: case 3: out_color.g /= 2; out_color.rb += 0.2; out_color *= 1.3; break;
    case 2: out_color *= 3; break;
    }
    // dang. still 4 minutes left. tweak the colours some more. and add FFT.
  }
}




























































