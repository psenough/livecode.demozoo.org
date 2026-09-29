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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(float a) {return mat2(cos(a),sin(a),-sin(a),cos(a));}

float PI = 3.14159265;

float homestuck(vec3 pos) {
  const float W1 = 0.6, H1 = 0.6;
  float cycle = fGlobalTime*2;
  cycle = mod(cycle, 1);
  float sep = 0.1*(1+sin(cycle*PI*2));
  
  vec2 origxy = pos.xy;
  
  // Rotating piece
  float rota = 0;//fGlobalTime*10;
  if(cycle > 0 && cycle < 0.5) {
    rota = (cycle-0)*2;
  }
  rota = rota*rota + 1-(1-rota)*(1-rota);
  rota /= 2;
  rota *= PI*1.5;
  vec2 posxy2 = pos.xy;
  posxy2 -= vec2(-W1/4,H1/4);
  posxy2 *= rot(rota);
  //posxy2 += vec2(-W1/4,H1/4);
  if(abs(posxy2.x) <= W1/4 && abs(posxy2.y) <= H1/4) {
    return 1;
  }
  
  if(pos.x < 0 && pos.x > -sep-W1/2 && pos.y > 0 && pos.y < sep+H1/2) {
    return 0; // cutout for rotating piece
  }
  else {
    if(pos.y < -sep) pos.y += sep;
    else if(pos.y > sep) pos.y -= sep;
    else {
      return 0;
    }
    if(pos.x < -sep) pos.x += sep;
    else if(pos.x > sep) pos.x -= sep;
    else {
      if(pos.y <= H1)
        return 0;
    }
  }
  
  if(pos.y > H1) {
    pos.y -= H1;
    sep = 0.05;
    if(pos.y < sep) return 0;
    pos.y -= sep;
    if(1-abs(origxy.x) - abs(pos.y)*4 > 0) {
      return 1;
    }
    return 0;
  }
  if(pos.y < -H1) {
    return 0;
  }
  if(pos.x > -W1 && pos.x < W1) return 1; else return 0;
}

bool hit(vec3 pos) {
  pos.xz *= rot(fGlobalTime);
  pos.xy *= rot(fGlobalTime*0.9);
  if(abs(pos.z) >= 0.2) return false;
  return homestuck(pos) > 0.5;
}

vec2 spiro(float f, float freq, float radius) {
  f += fGlobalTime;
  return vec2(sin(f*freq),cos(f*freq))*radius;
}

void plot_xy(vec2 xy, float val) {
  xy *= v2Resolution.yy;
  xy += v2Resolution.xy/2;
  
  
  imageStore(computeTex[0],ivec2(xy),uvec4(val*1000));
}

void plot_spiro(float f) {
  
  vec2 uv = vec2(f,f);
  f *= PI*2;
  
  //uv = spiro(f, PI*3, 0.5) + spiro(f, PI*10, 0.15);
  
  {
    float g = f + fGlobalTime/20;
    uv = vec2(sin(g*PI*3),cos(g*PI*3))*0.5;
    float min = sin(fGlobalTime), max = cos(fGlobalTime*1.6);
    uv *= min + (max-min)*(sin(f*PI*13)+1)/2;
    plot_xy(uv, mod(f*PI*5+fGlobalTime, PI*2));
  }
  
  {
    float g = f - fGlobalTime/15;
    uv = vec2(sin(g*PI*5),cos(g*PI*5))*0.5;
    float min = sin(fGlobalTime*1.4), max = cos(fGlobalTime*0.9);
    uv *= min + (max-min)*pow((sin(f*PI*13)+1)/2,2);
    plot_xy(uv, mod(f*PI*7+fGlobalTime*3, PI*2));
  }
}

void main(void)
{
  vec2 uv = (gl_FragCoord.xy - v2Resolution.xy/2)/v2Resolution.yy*2;
  
  /*if(homestuck(vec3(uv,0)) < 0.5) {
    out_color = vec4(uv.x,0,uv.y,1);
  } else {
    out_color = vec4(0,0.8,0,1);
  }
  return;
*/
  
  /*if(gl_FragCoord.x < 1)*/ {
    plot_spiro(gl_FragCoord.y / v2Resolution.y + (gl_FragCoord.x / v2Resolution.x) / v2Resolution.y);
    //imageStore(computeTex[0], ivec2(gl_FragCoord.xy), uvec4(1));
  }
  
  out_color = vec4(0);
  bool hitf = false;
  vec3 pos = vec3(0,0,-2);
  vec3 dir = /*normalize*/(vec3(uv,1));
  for(int i = 0; i < 100; i++) {
    pos += dir*0.05;
    if(hit(pos)) {
      out_color = vec4(0,1-float(i)/100,0,1);
      hitf = true;
      break;
    }
  }
  
  uint ival2 = imageLoad(computeTexBack[1], ivec2(gl_FragCoord.xy)).x;
  if(ival2 != 0 && !hitf) {
    out_color.r = 1;
  }
  vec2 moreCentralPos = (gl_FragCoord.xy-v2Resolution.xy/2)*0.97+v2Resolution.xy/2;
  if(max(abs(int(moreCentralPos.x-v2Resolution.x/2)),abs(int(moreCentralPos.y-v2Resolution.y/2))) > 20) {
    imageStore(computeTex[1], ivec2(gl_FragCoord.xy), imageLoad(computeTexBack[1], ivec2(moreCentralPos)));
  }
  
  uint ival = imageLoad(computeTexBack[0], ivec2(gl_FragCoord.xy)).x;
  if(ival != 0) {
    if(ival < 200) {
      const int w = 0;
      for(int x = -w; x <= w; x++) {
        for(int y = -w; y <= w; y++) {
          imageStore(computeTex[1], ivec2(gl_FragCoord.xy)+ivec2(y,x),uvec4(100000));
        }
      }
    }
    out_color.rgb += 1;
  }
  
  //out_color.r += texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy*0.99).r*0.97;
  
	/*
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = t;*/
}

























































