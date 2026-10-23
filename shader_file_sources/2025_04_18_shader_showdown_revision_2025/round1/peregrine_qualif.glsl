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

float time = fGlobalTime;
float freq = .5;
float pi = 3.141592653589793;

#define fft(f) texture(texFFT, f).x
#define dot2(x) dot(x, x)
#define sat(x) clamp(x, 0, 1)
#define pos(x) ((x) * .5 + .5)
#define rot(a) mat2(cos(a + vec4(0, 33, 11, 0)))
#define ffti(f) texture(texFFTIntegrated, f).x
#define noise(uv) texture(texNoise, uv).x

vec3 palette(float t) {
  vec3 a = vec3(.5), b = a, c = vec3(1), d = vec3(0., .1, .2);
  return a + b * cos(pi * 2 * (c * t + d));
}

float sdCross(vec2 p) {
  p = abs(p);
  return length(p - .5 * min(p.x + p.y, .4 + .1 * fft(.01))) - .1;
}

float sdRing(vec2 p) {
  return abs(length(p) - .3 - .02 * fft(.01)) - .1;
}

float sdHeart(vec2 p) {
  p *= 1.5;
  p.y += .55;
  p.x = abs(p.x);
  if (p.x + p.y > 1)
    return sqrt(dot2(p - vec2(.25, .75))) - sqrt(2)/4;
  else
    return sqrt(min(dot2(p - vec2(0, 1)),
                    dot2(p - .5 * max(p.x + p.y, 0))))
           * sign(p.x - p.y);
}

float pickShape(vec2 uv, float t) {
  if (t < .25) 
    return sdCross(uv);
  else if (t < .5)
    return sdRing(uv);
  else if (t < .75)
    return sdHeart(uv);
  else
    return 1;
}

float hash21(vec2 p) {
  return fract(sin(dot(p, vec2(15.8989, 14.4535))) * 1234.3455 + mod(.0000001 * time, 20));
}

vec3 quadtree(vec2 uv, float n) {
  vec2 id, idSum = vec2(0);
  float rnd, turn = 0;
  
  for(float i = 0; i < n; i++) {
    uv *= 2;
    id = floor(uv);
    idSum += id + vec2(mod(.0000001 * time, 7), mod(.000001 * time, 13));
    uv = fract(uv) - .5;
    rnd = hash21(idSum);
    turn = mod(floor(rnd * 100), 4);
    uv *= rot(turn * pi/2);
    if (rnd < .5) break;
  }
  
  return vec3(uv, hash21(id + idSum));
}

vec3 render(vec2 uv) {
  vec3 c = vec3(0);
  
  float v = .4 * smoothstep(0, .1 * pow(pos(sin(20. * freq * time)), 50), pickShape(.4 * uv, fract(.5 * freq * time + .1 * ffti(.01))));
  uv = mix(uv, .15 * vec2(noise(8 * uv + noise(10 * vec2(cos(time), sin(time))))), v);
  
  uv *= rot(floor(mod(freq * time, 8.)) * pi/4);
  uv.x += -.1 * time;
  
  vec3 qt = quadtree(uv * 2., mod(freq * time, 3) + 1);
  uv = qt.xy;
  
  vec3 color = palette(.25 * freq * time + qt.z + .1 * ffti(.02));
  if (qt.z < .75) {
  float shape = pickShape(uv, qt.z);
  float glow = smoothstep(0, 1, (.01 + .01 * fft(.01))/shape);
  c = color * ((1 - step(0, shape)) + glow);
  } else {
    c = color * texture(texRevisionBW, qt.xy - .5).xyz;
    }
    return c;
}

void main(void)
{
	vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;
	vec3 c = render(uv);
  out_color = vec4(c, 1);
}