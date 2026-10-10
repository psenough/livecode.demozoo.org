#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define beat (time * 154.8 / 60.)
#define PI acos(-1)
#define TAU (2*PI)
#define beatTau (beat*TAU)
#define saturate(x) clamp(x,0,1)

int id = 1;
int id2 = 0;

float hash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float sdBox(vec2 p, vec2 b) {
  vec2 q = abs(p) - b;
  return length(max(q, 0.)) + min(max(q.x,q.y),0.);
}

 vec4 getTexture(sampler2D sampler, vec2 uv){
    vec2 size = textureSize(sampler,0);
    float ratio = size.x/size.y;
    return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
}

vec3 quadtree(vec2 uv) {
  vec2 p = uv;
  int depth = 0;
  int MAX_DEPTH = 4;
  vec2 prev = vec2(0);
  float rnd = 0.0;
  
  for (depth = 0; depth < MAX_DEPTH; depth++) {
    vec2 cell = floor(p);
    if (id2 == 0) rnd = hash(cell + prev + floor(beat));
    if (id2 == 1) {
      vec2 center = 3. * vec2(cos(beatTau / 16.), sin(beatTau / 16.));
      rnd = (abs(length(cell - (center)) - 2.0));
    }
    if (rnd >= 0.5 || depth >= MAX_DEPTH) break;
    p *= 2.;
    prev = cell;
  }
  
  vec2 local = fract(p) - 0.5;
  float inside = smoothstep(0.0, -0.01, sdBox(saturate(local * 2.), vec2(0.45)));
  
  vec3 col = vec3(0);
  
  if (id == 0) col = mix(col, rnd < 0.6 ? vec3(0.5) : vec3(0.1), inside);
  if (id == 1) {
    if (depth % 3 == 0) col = getTexture(texInercia2025, local).rgb;
    if (depth % 3 == 1) col = getTexture(texInerciaBW, local).rgb;
    if (depth % 3 == 2) col = getTexture(texInerciaID, local).rgb;
  }
  
  if (rnd > 0.9) {
    float emi = (1. - smoothstep(0.0, -0.01, sdBox(local, vec2(0.4))));
    col += emi * vec3(1, 1, 0.1) * saturate(cos(beatTau / 4. + (rnd-0.9)*10.*TAU));
  }
  return col;
  
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  id = (int(beat) / 4) % 2;
  id2 = (int(beat) / 8) % 2;
  //id2 = 1;
  
  vec3 col = vec3(0);
  
  col += quadtree(uv * 8.);
  //col += getTexture(texInercia2025, uv * 2.).rgb;
  
	out_color = vec4(col, 1);
}