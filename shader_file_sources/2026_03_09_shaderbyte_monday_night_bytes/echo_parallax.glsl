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

//                        
//        '   '           
//        |\ /| /|        
//        |'^''- /        
//      \__""__""__/      
//        oo    oo        
//                        
// hi monday night bytes! 
//                        
// while we're waiting for the stream to start - 
// I came up with the idea for this shader on my 
// walk back home! no idea if I'll actually get  
// to implementing the main effect or if it'll   
// work, but maybe it'll be interesting to watch!

// ok actually this is not where I expected to wind up AT ALL
// but it's kind of cool

// woo let's go!
const float BPM = 138.f;

// thank you blackle
vec3 erot(vec3 p, vec3 ax, float ro) {
  ax = normalize(ax);
  return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}

const float INFINITY = 1000000;

// returns t-value of intersection with plane at y = ...y
float planeT(vec3 cam, vec3 dir, float y)
{
  // (cam + dir * t).y == y
  float t = (y - cam.y) / dir.y;
  if(t < 0) return INFINITY;
  return t;
}

float heightfield(vec2 xy)
{
  //float t = fGlobalTime * 60.f / BPM;
  //float t2 = t * 3.1415926535 * .125;
  //vec2 v = erot(xy.xyx, vec3(0,0,1), t2).xy; //xy.y * sin(t2) + xy.x * cos(t2);
  //return sin(v.y) * .5 + .5 + pow(texture(texFFT, v.x * .1).r, .9);
  //return sin(xy.y * sin(t2) + xy.x * cos(t2)) * 0.5 + 0.5;
  float s = fract(xy.y + fGlobalTime);
  return (sin(xy.x) * 0.3 + 0.3) + pow(texture(texFFT, pow(s, 4.0)).r, 0.9);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 cam = vec3(0, 0, -3);
  vec3 dir = vec3(uv, 1);
  cam = erot(cam, vec3(1, 0, 0), 0.5);
  dir = erot(dir, vec3(1, 0, 0), 0.5);
  float r = fGlobalTime * 60.f / BPM;
  float r2 = r * 3.1415926535 * .125;
  cam = erot(cam, vec3(0,1,0), r2);
  dir = erot(dir, vec3(0,1,0), r2);
  cam.y += 1;
  
  float minT = planeT(cam, dir, 1);
  float maxT = planeT(cam, dir, 0);
  float t1 = min(minT, maxT);
  maxT = max(minT, maxT);
  minT = t1;
  
  const int nSteps = 64;
  float hT = INFINITY;
  vec3 pos;
  float prevInness = 0;
  float delta = (maxT - minT)/float(nSteps - 1);
  for(int i = 0; i < nSteps; i++){
    float t = minT + delta * float(i);
    pos = cam + t * dir;
    float height = heightfield(pos.xz); // oh geez why did I choose y-up
    float inness = height - pos.y;
    if(inness > 0){
      // ok so we're in the surface, let's try to do linear interpolation here
      // at t, we're `inness` inside the surface
      // at t-delta, we were `prevInness` inside the surface (< 0)
      // so we've got a line of (x0, y0) = (t-delta, prevInness),
      // (x1, y1) = (t, inness)
      // so y - y1 = (y1 - y0)/(x1 - x0) * (x - x1) iirc
      // -> 0 - inness == (inness - prevInness)/delta * (x - t)
      // -> x == t + delta * inness/(prevInness - inness)
      hT = t + delta * inness/(prevInness - inness);
      break;
    }
    prevInness = inness;
  }
  pos = cam + hT * dir;
  //hT = heightfield((cam + minT * dir).xz);
  
  float display = hT;
  
  uvec2 cell = uvec2(fract(pos.xz / 8.0) * 256);
  uint mun = cell.x ^ cell.y;
  uint lim = uint(fract(r) * 128);
  float munch = 1. - (mun - lim) / 8.;
  //if(munch > 1.) munch = 0;
  if(munch < 0.) munch = -.7;
  
  out_color.xyz = vec3(munch, munch, munch) + vec3(0,0.2,1.0)*fract(vec3(0, display, display)) + vec3(0,0.8*pos.y,0);
  // let's do a crt effect, why not
  out_color.xyz *= pow(0.5 + 0.5 * sin(uv.y * 500 + vec3(0, 1.5, 3)), vec3(.5));
}