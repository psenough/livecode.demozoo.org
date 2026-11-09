#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI = acos(-1);
const float TWO_PI2 = 2*PI;

//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void Add(ivec2 u, vec3 c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  imageAtomicAdd(computeTex[1], u,q.y);
  imageAtomicAdd(computeTex[2], u,q.z);
}
vec3 Read(ivec2 u){       //read pixel from compute texture
  return 0.001*vec3(      //unsquish int to float
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  );
}

// http://eiserloh.net/noise/SquirrelNoise5.hpp
// SquirrelNoise5 - Squirrel's Raw Noise utilities (version 5) by Squirrel Eiserloh released as (CC-BY-3.0 US)
uint sq_noise(int x, uint s)
{
  uint r = uint(x);
  r *= 0xd2a80a3f;
  r += s;
  r ^= r >> 9;
  r += 0xa884f197;
  r ^= r >> 11;
  r *= 0x6C736F4B;
  r ^= r >> 13;
  r += 0xB79F3ABB;
  r ^= r >> 15;
  r *= 0x1b56c4f5;
  r ^= r >> 17;
  return r;
}
uint sq_noise2(int x, int y, uint s) { return sq_noise(x+198491317*y, s); }
uint sq_noise3(int x, int y, int z, uint s) { return sq_noise(x+198491317*y+6542989*z, s); }
float noise(int x, uint s) { return sq_noise(x, s) / float(-1u); }
float noise2(int x, int y, uint s) { return sq_noise2(x, y, s) / float(-1u); }
float noise3(int x, int y, int z, uint s) { return sq_noise3(x, y, z, s) / float(-1u); }

mat2 rotm(float a)
{
  vec2 cs = vec2(cos(a), sin(a));
  return mat2(cs.x, cs.y, -cs.y, cs.x);
}

vec3 rainbow(float x)
{
  x = fract(x);
  return max(vec3(sin(x*PI*2.0), sin((x+1.0/3.0)*PI*2.0), sin((x+2.0/3.0)*PI*2)), vec3(0.0));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = ((gl_FragCoord.xy + 0.5) / v2Resolution) * 2.0 - 1.0;
  uv.x *= v2Resolution.x / v2Resolution.y;
  
  float t = fGlobalTime;
  float b = fGlobalTime * 146.0/60.0;
  
  vec3 c = vec3(0.0);
  vec2 p = vec2(atan(uv.x, uv.y), length(uv));
  
  {
    mat2 rr = rotm(PI/2.0);
    vec2 uuv = rr * uv;
    uuv.x += sin(uuv.y*64) * sin(t) * texture(texFFT, 0).r * 0.1;
    //c = mix(c, 1-c, sin(uuv.x*16)*.5+.5);
  }
  //if(fract(uv.x*16)<0.5) c.g = 1-c.g;
  
  int rng = 1234;
  if(false)
  for(int i=0; i<16; ++i)
  {
    float a = t * (1+noise(rng++, 0)) * 0.5 * ((sq_noise(rng++, 0)&1)*2-1) + noise(rng++, 0)*PI*2;
    mat2 r = rotm(a);
    vec2 uuv = r * uv;
    //vec3 ci = rainbow(noise(rng++, 0));
    uuv.x += sin(uuv.y*64)*0.1;
    uint ci = sq_noise(rng++, 0)%3;
    if((uuv.x + sin(1.0*t*(1+noise(rng++, 0)))) > 0.0)
    {
      c[ci] = 1.0-c[ci];
    }
  }
  
  //if((int(b)&1)==0) c = 1-c;
  
  //if(uv.y < -0.8) c = vec3(1);
  
  c *= 0.2;
  
  {
    vec2 uuv = uv*0.01;
    uuv.y += sin(b*PI);
    uuv *= 0.5-p.y;
    float sd = distance(uuv, vec2(0.0));
    sd += t;
    sd += sin(p.x*10)*0.2*sin(b*PI);
    vec3 cc = rainbow(sd*4-t);
    c = mix(c, cc, max(sin(sd*16), 0.0));
  }
  
  if(false)
  for(int i=0; i<16; ++i)
  {
    float tt = (2*t-i*0.1);
    vec2 u = tt * vec2(1.0, 1.1315) * 0.2;
    u = abs(fract(u)-0.5)*2;
    u = vec2(abs(fract(tt*0.2)-0.5)*2, abs(sin(tt*2))*0.8);
    u = u*2-1;
    u.x *= v2Resolution.x/v2Resolution.y;
    vec2 tuv = (uv-u+vec2(0.125))*2;
    if(all(equal(fract(tuv), tuv))) c = mix(c, rainbow(t*0.5-i*0.1)*0.5+0.5, texture(texRevisionBW, tuv).r*max(1.0-i*0.1, 0.0));
  }
  
  out_color = vec4(c, 1.0);
}