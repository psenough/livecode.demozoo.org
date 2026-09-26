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

const float tuPi = radians(360.0);

void cosPalette(in float t, in vec3 offset, in vec3 amp, in vec3 coeffs, in vec3 phases, out vec3 outRGB) {
  outRGB = offset + amp * cos(tuPi * t * coeffs + phases);
}

void rainbuwu(in float t, out vec3 outRGB) {
  vec3 off = vec3(.5),
       amp = vec3(.5),
       cff = vec3(3),
       phi = vec3(0,1,3)/3.0;
       //phi = vec3(0+sin(fGlobalTime/7+radians(22.5)),3*sin(fGlobalTime/5),9*cos(fGlobalTime/13))/3.0;
  
  cosPalette(t,off,amp,cff,phi,outRGB);
}

void rotatoPotato(in float theta, in vec2 p, out vec2 np) {
  //remember, column first
  mat2 rot = mat2(cos(theta),-sin(theta), sin(theta), cos(theta) );

  np = rot*p;  
}


//sdf via inigo Quilez

float dot2(vec2 a) {
  return dot(a,a);
}

float sdHeart( in vec2 p )
{
    p.x = abs(p.x);

    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}

void main(void) {
  int idx,jdx;
  float p[2];
  vec2 uv = gl_FragCoord.xy/v2Resolution.y; //noncentered
  vec2 uvCentered = (gl_FragCoord.xy*2.0-v2Resolution)/v2Resolution;
  vec3 curRGB;
  vec3 finalRGB;
  vec4 prev = fract(texture(texPreviousFrame,uv));
  vec4 dirty = texture(texTex2,uv/7);
  float beat = texture(texFFTSmoothed,0.01).r*50;
  
  rotatoPotato(radians(45.0)-fGlobalTime/16-radians(15.0)*cos(fGlobalTime)*beat/7, uv, uv);
  for(idx = 0; idx < 2; idx ++) {
    // we want to alternate drawing based on x vs y
    p[0] = uv.x; p[1] = uv.y;
    for(jdx = 0; jdx <2; jdx++) {
      rainbuwu(p[jdx] + cos(length(uvCentered)) - fGlobalTime/16, curRGB);
      curRGB = 0.01/curRGB;
      finalRGB += curRGB;
    }
    rotatoPotato(radians(180.0)+radians(15.0)*sin(fGlobalTime)*beat/5,uv, uv);
  }

  finalRGB /= 4;
  
  out_color = vec4(finalRGB,1.0);
  
  out_color/=(dirty*4);
  
  out_color /= sdHeart(uvCentered+vec2(0,0.5));
  
  out_color += texture(texFFT,gl_FragCoord.y/v2Resolution.y).r*vec4(1);
  out_color += texture(texFFT,gl_FragCoord.x/v2Resolution.x).r*vec4(1);
  out_color += texture(texFFT,1-gl_FragCoord.y/v2Resolution.y).r*vec4(1);
  out_color += texture(texFFT,1-gl_FragCoord.x/v2Resolution.x).r*vec4(1);
  
  out_color = clamp(out_color-prev, vec4(0.0),vec4(1.0));
}