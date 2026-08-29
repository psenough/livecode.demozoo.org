#version 420 core

//hello fieldfx! let's have a fun jam~
//let count: 3

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

void Add(ivec2 u, vec3 c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  imageAtomicAdd(computeTex[1], u,q.y);
  imageAtomicAdd(computeTex[2], u,q.z);
}

void AddPressure(ivec2 u, vec3 c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
}

vec3 Read(ivec2 u){       //read pixel from compute texture
  return 0.001*vec3(      //unsquish int to float
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  );
}

#define fft(x) texture(texFFTSmoothed, x+3.5/1024)
#define ffti(x) texture(texFFTIntegrated, x+3.5/1024)
#define MAX_DIST 20.0
#define STEPS 100
#define THRESHOLD 0.00001
#define MAX_LAYER 10.0
#define INV_MAX 1.0/MAX_LAYER
#define t fGlobalTime
#define PI 3.14159265358979323846264

void main(void) {
  vec2 uv = gl_FragCoord.xy/v2Resolution.y - vec2(0.5*v2Resolution.x / v2Resolution.y, 0.5);
  float angle = texture(texNoise,uv).r*2*PI+texture(texFFTIntegrated,0.2).r;
  float beat = 5.0*texture(texFFT, 0.1).r;
  float treble = 5.0*texture(texFFT,0.5).r;
  float r2 = dot(uv,uv);
  float circle = smoothstep(0.1+beat,0.0,r2)+0.5*smoothstep(0.05+treble,0.0,r2);
  vec3 source = Read(ivec2(gl_FragCoord.xy));
  float pressure = source.r;
  pressure += 0.3 * circle;
  vec2 velocity = source.gb;
  vec2 pressure_gradient = vec2(dFdx(pressure), dFdy(pressure));
  vec2 circle_gradient = vec2(dFdx(circle),dFdy(circle));
  vec2 total_force = -10.0*pressure_gradient + 0.2 * vec2(cos(angle), sin(angle));
  velocity += total_force * (1.0/60.0);
  source = vec3(pressure, velocity);
  Add(ivec2(gl_FragCoord.xy + velocity), source*vec3(0.2,1.0,1.0));
  AddPressure(ivec2(gl_FragCoord.xy + velocity+vec2(1,0)), 0.2*source);
  AddPressure(ivec2(gl_FragCoord.xy + velocity+vec2(0,1)), 0.2*source);
  AddPressure(ivec2(gl_FragCoord.xy + velocity+vec2(-1,0)), 0.2*source);
  AddPressure(ivec2(gl_FragCoord.xy + velocity+vec2(0,-1)), 0.2*source);
  
  out_color = vec4(mix(vec3(0.0,0.1,0.1),vec3(1.0,0.3,0.1)+100.0*vec3(circle_gradient.y,0.0,circle_gradient.x),source.r),1.0);
}