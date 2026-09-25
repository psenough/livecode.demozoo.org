#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define PI 3.141529
#define rot(k) mat2(cos(k), -sin(k), sin(k), cos(k))
uint seed = 1;
uint rng(uint x){x^=x>>16;x*=0x7feb352dU;x^=x>>15;x*=0x846ca68bU;x^=x>>16;return x;}
float hash(){return float(seed=rng(seed))/float(0xffffffffU);}

float fft() {
   return texture(texFFTIntegrated, .2).r;
}

vec3 palette(float t) {
  return .5 + .5 * cos(2*PI*(t+vec3(.3,.2,.2)));
}

float thingy(vec2 p, float w, float r) {
  p = abs(p);
  return length(p - min(p.x+p.y, w)*.5) - r;
}

vec2 rings(vec2 p) {
  float dist = 1e17;
  float mat = 0;
  float a = .05;
  for(int i = 0; i <= 10; ++i) {
    float an = hash() + .5 * hash() * .5*(fGlobalTime + 1.3*fft());
    p *= rot(an);
    float b = a + min(1, i/4) * .07 * hash() + .01;
    float d = max(length(p) - b, -length(p) + a);
    float pd = abs(atan(p.y, p.x) / PI - hash());
    float z = hash();
    if(d < dist && pd < .8) {
      dist = d;
      mat =  z;
    }
    a = b + min(1., i/4.) * .02 * hash() + .003;
  }
  return vec2(dist, mat);
}

bool flip() {return mod(fGlobalTime, 10.) < 5.;}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution) / v2Resolution.y;
  
  vec3 col = vec3(0);
  
  vec2 g = uv * mix(1.5, 2., uv.x);
  g.x += .2 * .7*(fGlobalTime + fft());
  g.y += .3 * sin(4*g.x) - .1 * fGlobalTime;
  float r = clamp(sin(60*g.y), 0, 1);
  float f = flip() ? mix(.9, .8, r) : mix(.6, .7, r);
  col = palette(f);
  
  vec2 tc = vec2(uv.x + .9, .35 - uv.y * (.9 + .5 * smoothstep(-1., 0., uv.x)));
  vec3 inercia = tc.x > 0 && tc.y > 0 && tc.x < 1 && tc.y < 1 ? texture(texInerciaLogo2024, tc).rgb : vec3(0);
  inercia = sqrt(inercia);
  float lum = .2126 * inercia.r + .7152 * inercia.g + .0722 * inercia.b;
  float mf = smoothstep(0., .2, lum);
  f = flip() ? .3 * lum : .5 - .25 * lum;
  col = mix(col, palette(f), mf);
  
  {
    vec2 g = uv;
    g *= rot(-.1);
    g.y = abs(g.y); g *= rot(.2);
    g.y += .005 * sin(20 * g.x);
    f = flip() ? .05 : .5;
    vec3 bg = palette(f) * (.2*texture(texNoise, 4*uv).rgb + .8);
    col = mix(col, bg, smoothstep(0., .002, g.y - .3));
    g.x += .2 * fGlobalTime;
    float cr = thingy(vec2(mod(g.x+.05, .1) - .05, g.y- .35), .02, .01);
    g.x += .1 * (fft() + fGlobalTime);
    cr = min(cr, thingy(2.*vec2(mod(g.x+.05, .1) - .05, g.y- .4), .02, .01));
    f = flip() ? .2 : .3;
    col = mix(palette(f), col, smoothstep(-.002, 0., cr));
  }
  
  vec2 rings = rings(1.2 *(uv - .6 * vec2(1, -.5)));
  f = flip() ? mix(0., .3, rings.y) : mix(.4, .7, rings.y);
  col = mix(palette(f), col, smoothstep(-.002, 0., rings.x));
  col = mix(vec3(flip() ? 1 : 0), col, smoothstep(0., .002, abs(rings.x)));
  
  out_color = vec4(col, 1);
}