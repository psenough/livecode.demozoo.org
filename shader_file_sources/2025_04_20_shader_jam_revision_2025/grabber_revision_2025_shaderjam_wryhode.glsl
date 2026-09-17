// haii revision :3
// gonna "borrow" some code from ingo iquilezles
// also sorry for the batshit insane code im sorry... 

#version 420 core
#define PI 3.141
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
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float sdSphere(vec3 p, float r) {
  return length(p) - r;
}

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(b) - b;
  return length(max(q, 0.)) + min(max(q.x,max(q.y,q.z)), 0.);
}

float field(vec3 p) {
  return sdSphere(p, 1.);
}

float ray(vec3 ro, vec3 rd) {
  float od = 0.;
  
  for (int i = 0; i < 100; i++) {
    vec3 p = ro + rd * od;
    float d = field(p);
    od += d;
    
    if (od < 0.01 || od > 100.) {
      break;
    } 
  }
  return od;
}

void main(void)
{
  vec2 texUv = vec2(gl_FragCoord.xy) / v2Resolution;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv *= 2.;
  uv -= 1.;
  float time = texture(texFFTIntegrated, 0.05).r * 0.5;
  float x = time / 50. * 2 * PI * 3 + uv.x * 3;
  vec3 rainbow = vec3(sin(x), sin(x + (2*PI/3)), sin(x + (4*PI/3)));
  
  // raymarching cause yeahhhhhh!!!!!
  vec3 c = vec3(0., 0., 0.);
  vec3 ro = vec3(0., 0., mod(time, 20));
  vec2 camOffset = vec2(texture(texNoise, vec2(fGlobalTime / 50)).r, texture(texNoise, vec2(fGlobalTime / 60)).r) * 5 + .1;
  vec3 rd = normalize(vec3(uv.x + camOffset.x, uv.y + camOffset.y, 1.));
  float d = ray(ro, rd) / 1000.; // weird fix??!?!?!??!?? (surely this wont come back to bite me)
  
  float t = mod(time / 3, 3);
  if(t < 1) {
    c = texture(texRevisionBW, texUv + fGlobalTime + sin(uv.x) + cos(uv.y + time) * tan(uv.x)).rgb * sin(uv.x * PI + PI / 2 + 1 / d) * 0.8;
  }
  else if (t < 2) {
    c = texture(texAcorn1, texUv + fGlobalTime + sin(uv.x) + cos(uv.y + time) * tan(uv.x)).rgb * sin(uv.x * PI + PI / 2 + 1 / d) * 0.8;
  }
  else if (t < 3) {
    c = texture(texAcorn2, texUv + fGlobalTime + sin(uv.x) + cos(uv.y + time) * tan(uv.x)).rgb * sin(uv.x * PI + PI / 2 + 1 / d) * 0.8;
  }

  float v = texture(texFFT, texUv.x / 5).r;
  if (uv.y < 5*v - 1.) {
    c = mix(v * rainbow * 3, c, 0.1);
  }
  
  for (int y = 0; y < 5; y++) {
    float w = 0.1;
    float ty = 0.5 + sin(texUv.x * 10 + time) * 0.1 + y / 10;
    
    if (texUv.y < ty + w && texUv.y > ty - w) {
      //c.r = 1.;
    }
  }  
	out_color = mix(texture(texPreviousFrame, texUv+vec2(0., -.01)), vec4(c, 0.), .6-texture(texFFTSmoothed, 0.02).r*1.2);
}