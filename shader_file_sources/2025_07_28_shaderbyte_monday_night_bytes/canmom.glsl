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

#define ffts(x) texture(texFFTSmoothed, x)

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void Add(ivec2 u, int q, int plane){//add pixel to compute texture
  imageAtomicAdd(computeTex[0], u,q);
}

uint Read(ivec2 u, int plane){       //read pixel from compute texture
  return imageLoad(computeTexBack[plane],u).x;
}

int cellular_automaton(ivec2 uv, int adjust) {
  uint top_left = Read(uv+ivec2(-1, 1), 0);
  uint top = Read(uv+ivec2(0, 1), 0);
  uint top_right = Read(uv+ivec2(1,1),0);
  bool top_row = uv.y == v2Resolution.y-1;
  if (top_row) {
    top_left, top, top_right = 0;
  }
  uint left = Read(uv+ivec2(-1,0),0);
  uint middle = Read(uv+ivec2(0,0),0);
  uint right = Read(uv+ivec2(1,0),0);
  uint bottom_left = Read(uv+ivec2(-1,-1),0);
  uint bottom = Read(uv+ivec2(0,-1),0);
  uint bottom_right = Read(uv+ivec2(1,-1),0);
  bool bottom_row = uv.y <= 1;
  //int decay = 1;
  int ret = 0;
  uint fall_threshold = 255;
  //bool falling = bottom < fall_threshold || bottom_left < fall_threshold || bottom_right < fall_threshold;
  bool falling = bottom < fall_threshold;
  if (bottom_row) {
    falling = false;
  }
  bool above_falling = falling || middle < fall_threshold;
  if (!falling) {
    ret += int(middle);
  }
  if (above_falling) {
    ret += int(top);
  }
  
  return clamp(ret-1,0,255);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  ivec2 iuvs = ivec2(gl_FragCoord.xy);
  
  Add(iuvs, int(cellular_automaton(iuvs, 0)), 0);
  Add(iuvs, 256*int(step(0.35,texture(texNoise, uv+vec2(texture(texFFTIntegrated, 0.4))).x + ffts(0.1).x)), 0);
  float colour = float(Read(iuvs,0))/255.0;
  
  out_color=vec4(colour);
}