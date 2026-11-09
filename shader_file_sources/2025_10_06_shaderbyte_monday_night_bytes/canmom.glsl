#version 420 core

//hello reality!
//back from deadline and back to jammin'


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

uint life(ivec2 UV) {
  int left = (UV.x - 1) % int(v2Resolution.x);
  int right = (UV.x + 1) % int(v2Resolution.x);
  int up = (UV.y + 1) % int(v2Resolution.y);
  int down = (UV.y - 1) % int(v2Resolution.y);
  uint current = + imageLoad(computeTexBack[0],UV).x;
  uint living_neighbours = imageLoad(computeTexBack[0],ivec2(left, up)).x
  + imageLoad(computeTexBack[0],ivec2(UV.x, up)).x
  + imageLoad(computeTexBack[0],ivec2(right, up)).x
  + imageLoad(computeTexBack[0],ivec2(left, UV.y)).x
  + imageLoad(computeTexBack[0],ivec2(right,UV.y)).x
  + imageLoad(computeTexBack[0],ivec2(left,down)).x
  + imageLoad(computeTexBack[0],ivec2(UV.x,down)).x
  + imageLoad(computeTexBack[0],ivec2(right,down)).x
  + current;
  
  if (living_neighbours == 3) {
    imageStore(computeTex[0],UV,uvec4(1));
    return 1;
  } else if (living_neighbours > 4) {
    imageStore(computeTex[0],UV,uvec4(0));
    return 0;
  } else {
    return current;
  }
}

uint square_prev(ivec2 UV) {
  int left = (UV.x - 1) % int(v2Resolution.x);
  int right = (UV.x + 1) % int(v2Resolution.x);
  int up = (UV.y + 1) % int(v2Resolution.y);
  int down = (UV.y - 1) % int(v2Resolution.y);
  uint living_neighbours = imageLoad(computeTexBack[0],ivec2(left, up)).x
  + imageLoad(computeTexBack[0],ivec2(UV.x, up)).x
  + imageLoad(computeTexBack[0],ivec2(right, up)).x
  + imageLoad(computeTexBack[0],ivec2(left, UV.y)).x
  + imageLoad(computeTexBack[0],ivec2(right,UV.y)).x
  + imageLoad(computeTexBack[0],ivec2(left,down)).x
  + imageLoad(computeTexBack[0],ivec2(UV.x,down)).x
  + imageLoad(computeTexBack[0],ivec2(right,down)).x
  + 4*imageLoad(computeTexBack[0],ivec2(UV.x,UV.y)).x;
  return living_neighbours;
}



void main(void)
{
  uint l = life(ivec2(gl_FragCoord.xy));
  float fft = texture(texFFT, 0.05).x;
  vec2 offset = vec2(texture(texFFTIntegrated,0.3).x,texture(texFFTIntegrated,0.15).x);
  float noise = step(0.15,12.0*texture(texNoise, 0.5*gl_FragCoord.xy / v2Resolution + offset).x*fft + 0.3*texture(texNoise, 5.0*gl_FragCoord.xy / v2Resolution).x);
  
  float prev = float(square_prev(ivec2(gl_FragCoord.xy)))/9.0;
  
  uint toStore = l | int(noise);
  
  imageStore(computeTex[0],ivec2(gl_FragCoord.xy),uvec4(toStore));
  
	out_color = vec4(vec3(0.1,0.1,0.1)+l*vec3(0.6,0.2,0.6),1.0);
}