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

void rotate(inout vec2 v, float a) {v = vec2(v.x*cos(a)+v.y*sin(a), v.y*cos(a)-v.x*sin(a));}


int beat;

float height2(vec2 xy) {
  int octaves = ((beat / 2)) % 4 ;
  float amount = 0;
  if(octaves >= 3)
  amount += (texture(texNoise, xy/100).x - 0.2)/8;
  if(octaves >= 2)
  amount += (texture(texNoise, xy/200).x - 0.2)/4;
  if(octaves >= 1)
  amount += (texture(texNoise, xy/300).x - 0.2)/2;
  //if(octaves >= 0)
  amount += texture(texNoise, xy/400).x;
  
  //float fftpos = mod((xy.y+xy.x)/3000,0.02);
  //amount += texture(texFFTSmoothed, fftpos).x*fftpos*50;
  
  /*xy /= 5;
  vec2 unitcell = mod(xy + 1.0, 2.0);
  float unitcell2 = max(abs(unitcell.x),abs(unitcell.y))-0.5;
  amount += unitcell2*0.1;*/
  
  return amount*30 - 2;
}

bool is_lava;
float height(vec2 xy) {
  float h = height2(xy/2);
  is_lava=false;
  if(h > 5) {
    h = 10 - h;
    is_lava=true;
  }
  return h * 2;
}

vec3 normal(vec2 xy) {
  vec2 delta = vec2(0,0.01);
  float nn = height(xy);
  float np = height(xy+delta.xy);
  float pn = height(xy+delta.yx);
  //float pp = height(xy+delta.yy);
  float dzdx = (pn - nn) / delta.y;
  float dzdy = (np - nn) / delta.y;
  float scale = 0.5;
  dzdx *= scale; dzdy *= scale;
  return vec3(dzdx, dzdy, 1-length(vec2(dzdx,dzdy)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  beat = int(fGlobalTime*130/60);
  
  /*switch((beat / 8) % 4) {
    case 0: case 1: break;
    case 2: uv.y = abs(uv.y); break;
  }*/
  
  vec3 pos = vec3(0, fGlobalTime*20, 0);
  vec3 dir = normalize(vec3(uv.x, 1, uv.y));
  
  float minstep = 0;
  bool kaleido = false;
  switch((beat / 8) % 2) {
  //switch(0) {
    case 0:
      pos.x = cos(fGlobalTime/3)*100;
      //pos.z = max(15, (height(pos.xy) + height(pos.xy + vec2(0,3)) + height(pos.xy + vec2(0,1)))/3 + 5);
      pos.z = 12;
      rotate(dir.yz, sin(fGlobalTime/3)*0.1 + 0.3);
      //rotate(dir.xy, sin(fGlobalTime/3));
      minstep = 0.7;
      kaleido = ((beat / 16) % 2) == 0;
      break;
    case 1:
      pos.z = 30;
      pos.x = fGlobalTime*0.0314159;
      rotate(dir.yz, sin(fGlobalTime/3)*0.2 + 0.6);
      rotate(dir.xy, cos(fGlobalTime/3)* ((beat / 16) % 2 == 0 ? -1.0 : 1.0));
      minstep = 0.3;
      break;
  }
  vec3 start = pos;
  
  out_color = vec4(0,0,0,1);
  bool water = false;
  float waterdist = 0;
  for(int step = 0; step < 120; step++) {
    float stepdist = max(minstep, pos.z - height(pos.xy) - 3.5);
    pos += dir * stepdist;
    //dir.z += stepdist*0.0015;
    vec3 sensepos = pos;
    
    sensepos -= start;
    if(kaleido) {
      /*sensepos.x = abs(sensepos.x);
      sensepos.y = abs(sensepos.y);*/
    } else {
      /*if((beat / 16) % 4 == 0) {
        sensepos.x += texture(texFFTSmoothed, mod(sensepos.y/300,0.02)).x*10;
      }*/
    }
    //rotate(sensepos.yz, (sensepos.y - start.y) / 200);
    sensepos += start;
    
    float height_here = height(sensepos.xy);
    if(sensepos.z < (is_lava ? 5 : 7) && !water) {
      water = true;
      rotate(dir.xy, texture(texNoise, sensepos.xy/25+fGlobalTime/10).x*4);
    }
    
    if(water) waterdist += stepdist;
    if(pos.z < height_here && length(sensepos - start) > 5) {
      vec3 normal = normal(sensepos.xy);
      //out_color = vec4(normal, 1);
      if(water) {
        out_color = vec4(0,waterdist/10,waterdist/5,1);
        if(is_lava)
          out_color.rb = out_color.br;
        //out_color.rb = out_color.br * 1;
      } else {
        out_color = vec4(0,normal.y + normal.x,0.05,1);
      }
      if(water && min(mod(sensepos.x,3),mod(sensepos.y,3)) < 0.1) {
        if(water) out_color.gb=vec2(1);
        else out_color.g=1;
      }
      break;
    }
  }
  
  // reduce visible banding at the cost of motion blur
  out_color += (texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy)-out_color)*0.75;
}






















































