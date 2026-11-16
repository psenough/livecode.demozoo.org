//
// Greetings to Chipzel, author of Super Hexagon's iconic soundtrack and
// whom I was lucky enough to see perform it live at Square Sounds Tokyo
// in 2016; the Japanese demoscene: 0b5vr, 0x4015, Falken, FL1NE, gyabo,
// gam0022, hole, i-saint, Kamoshika, kemas, Kioku, notargs, q, Setsuko,
// got, Renard, sp4ghet, tomohiro, ukonpower, and others I am forgetting
// to mention.
// I wish I could still greet mog and ultrasyd. I miss them dearly.
//
// -- 
// Zavie
// Ctrl-Alt-Test
// 2026
//

#version 410 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t = fGlobalTime;
const float PI = acos(-1.);

// https://www.shadertoy.com/view/XlXcW4
vec3 hash33(uvec3 x) {
  const uint k = 1103515245U;  // GLIB C
  x = ((x >> 8U) ^ x.yzx) * k;
  x = ((x >> 8U) ^ x.yzx) * k;
  x = ((x >> 8U) ^ x.yzx) * k;

  return vec3(x) * (1.0 / float(0xffffffffU));
}

const int numPatterns = 9;
const int patternLength = 19;
const float pattern[] = float[6 * patternLength * numPatterns](
  //  C C C
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 1, 1, 1, 1, 1,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 1, 0, 1, 1,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 1, 1, 1, 1, 1,

  // = - = - = #
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 1, 0, 1, 0, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 0, 1, 0, 1, 0,  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 1, 0, 1, 0, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 0, 1, 0, 1, 0,  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 1, 0, 1, 0, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 1, 0, 1, 0, 1,  0, 1, 0, 1, 0, 1,

  // -- -- --
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 1, 1, 0, 1, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 0, 1, 1, 0, 1,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 0, 1, 1, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 1, 1, 0, 1, 1,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 0, 1, 1, 0, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 0, 1, 1, 0,

  // E3
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 1, 1, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 1, 1, 1,
  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 1, 1, 1, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 1, 1, 1,
  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 1, 1, 1, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 1, 1, 1,

  // LJLJ
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 0, 1, 1, 0,
  1, 0, 0, 1, 0, 0,  1, 0, 0, 1, 0, 0,  1, 0, 1, 1, 0, 1,  1, 0, 0, 1, 0, 0,  1, 0, 0, 1, 0, 0,  1, 1, 0, 1, 1, 0,
  1, 0, 0, 1, 0, 0,  1, 0, 0, 1, 0, 0,  1, 0, 1, 1, 0, 1,  1, 0, 0, 1, 0, 0,  1, 0, 0, 1, 0, 0,  1, 1, 0, 1, 1, 0,

  // -----> <-----
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 1, 1, 1, 1,  1, 0, 0, 1, 1, 1,  1, 0, 0, 0, 1, 1,
  1, 0, 0, 0, 0, 1,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 1, 1, 1, 1, 0,  1, 1, 1, 1, 0, 0,
  1, 1, 1, 0, 0, 0,  1, 1, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 1, 1, 1, 1,

  // Spiral
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 1, 1, 0, 1, 1,  0, 1, 1, 0, 1, 1,  0, 0, 1, 0, 0, 1,  0, 0, 1, 0, 0, 1,  1, 0, 0, 1, 0, 0,
  1, 0, 0, 1, 0, 0,  0, 1, 0, 0, 1, 0,  0, 1, 0, 0, 1, 0,  0, 0, 1, 0, 0, 1,  0, 0, 1, 0, 0, 1,  1, 0, 0, 1, 0, 0,
  1, 0, 0, 1, 0, 0,  0, 1, 0, 0, 1, 0,  0, 1, 0, 0, 1, 0,  0, 0, 1, 0, 0, 1,  0, 0, 1, 0, 0, 1,  1, 0, 1, 1, 0, 1,

  // W M
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 1, 1, 1, 1, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,
  1, 1, 0, 0, 0, 1,  1, 1, 1, 0, 1, 1,  1, 1, 1, 0, 1, 1,  1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0,  1, 0, 0, 1, 0, 0,
  1, 0, 1, 1, 1, 0,  1, 0, 1, 1, 1, 0,  1, 0, 0, 1, 0, 0,  1, 0, 0, 1, 0, 0,  1, 1, 0, 0, 0, 1,  1, 1, 0, 0, 0, 1,

  // Clock
  0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  0, 1, 1, 1, 1, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 0, 1, 1, 1, 1,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 0, 1, 1, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 1, 0, 1, 1,
  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 1, 1, 0, 1,  0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  1, 1, 1, 1, 1, 0
);

// BEGIN
vec4 toUVidVTunnel(vec2 uv) {
  uv.x *= sqrt(0.75);
  uv.y *= 0.5;

  float v = abs(uv.y * 2.);
  float u = (uv.x + uv.y) / v;
  float i = 0.;
  if (v < abs(uv.x + uv.y)) {
    v = abs(uv.x + uv.y);
    u = (uv.x - uv.y) / v;
    i = 1.;
  }
  if (v < abs(uv.x - uv.y)) {
    v = abs(uv.x - uv.y);
    u = 1-(uv.x + uv.y) / v;
    i = 2.;
  }
  if (uv.x < -uv.y) {
    u = fract(-u);
    i += 3.;
  }

  float dv = fwidth(v);

  return vec4(u, v, i, dv);
}
// GAME OVER

// BEGIN
vec2 rotate(vec2 uv, float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, s, -s, c) * uv;
}
// GAME OVER

// BEGIN
vec2 tilt(vec2 uv, float angle, float f) {
  float c = cos(angle);
  float s = sin(angle);

  float d = c - uv.y * s / f;
  return uv * vec2(c, 1.) / d;
}
// GAME OVER

// BEGIN
float getRotationAngle(float x) {
  float fractx = fract(x);
  float prevScale = sin((x     - fractx) * 117);
  float nextScale = sin((x + 1 - fractx) * 117);
  float offset = 2. * (mix(prevScale, nextScale, fractx) * 0.5 + 0.5);
  float baseRotation = abs(fract(x / 2.) * 2. - 1.) * 2. - 1.;
  return offset + 3. * baseRotation;
}
// GAME OVER

// BEGIN
float getPattern_discontinuous(vec4 uvidv) {
  vec3 hash = hash33(uvec3(uvidv.y));
  float patternId = floor(hash.x * numPatterns);
  float rotDir = hash.y > 0.5 ? 1. : -1.;
  float rotation = hash.x * 6;
  float i = mod(uvidv.z * rotDir + rotation, 6);
  float j = mod(floor(uvidv.y * patternLength), patternLength);
  return pattern[int(i + 6 * (j + patternLength * patternId))];
}
// GAME OVER

// BEGIN
float getPattern_smooth(vec4 uvidv) {
  float dw = uvidv.w * patternLength;
  float w = smoothstep(-dw, +dw, fract(uvidv.y * patternLength + 0.5) - 0.5);

  vec4 uvidv0 = uvidv;
  uvidv0.y = floor(uvidv.y * patternLength - 0.5) / patternLength;
  float pattern0 = getPattern_discontinuous(uvidv0);

  vec4 uvidv1 = uvidv;
  uvidv1.y = (uvidv.y * patternLength + 0.5) / patternLength;
  float pattern1 = getPattern_discontinuous(uvidv1);
  return mix(pattern0, pattern1, w);
}
// GAME OVER

// BEGIN
vec3 getColor(float odd, float pattern) {
  vec3 base = vec3(1, mix(0.2, 0.8, sin(t) * 0.5 + 0.5), 0);
  return base * mix(mix(0.25, 0.4, odd), mix(0.9, 1., odd), pattern);
}
// GAME OVER

// BEGIN
float fftSize = float(textureSize(texFFT, 0));
float getBeat() {
  //if (gl_FragCoord.y / v2Resolution.y > 0.5) return texture(texFFTSmoothed, 1./256.*gl_FragCoord.x / v2Resolution.x).r;

  float beat = 0.;
  const int samples = 4;
  for (int i = 0; i < samples; ++i){
    float u = (float(i) * fftSize + 0.5) / fftSize;
    beat += texture(texFFTSmoothed, u).r;
  }
  beat /= float(samples);
  return sqrt(beat);
}
// GAME OVER

// BEGIN
void main(void)
{
  // LINE
  vec2 uvScreen = vec2(gl_FragCoord.xy / v2Resolution.xy);
  uvScreen = (uvScreen - 0.5) * vec2(v2Resolution.x / v2Resolution.y, 1);

  // TRIANGLE
  float rotation = getRotationAngle(0.2*t);
  float tiltAngle = mix(0., 0.7, sin(t*.2)*.5+.5);
  float progress = 0.25 * t;
  float beat = getBeat();
  float zoom = mix(1., 3.0, beat);
  vec2 uvWorld = uvScreen;

  // SQUARE
  float warp = smoothstep(0.7, 0.75, abs(fract(t*.02) * 2. - 1.));
  uvWorld /= mix(1., length(uvScreen), warp);
  uvWorld = tilt(uvWorld, mix(tiltAngle, 0., warp), 1.);
  uvWorld = rotate(uvWorld, rotation) / zoom;

  // PENTAGON
  vec4 uvidvTunnel = toUVidVTunnel(uvWorld);
  uvidvTunnel.w *= mix(1., 5., beat);
  float center = smoothstep(uvidvTunnel.w, -uvidvTunnel.w, uvidvTunnel.y - 0.1);
  float inner = smoothstep(-uvidvTunnel.w, uvidvTunnel.w, uvidvTunnel.y - 0.085 );

  // EXCELLENT
  uvidvTunnel.y += progress;
  float pattern = mix(getPattern_smooth(uvidvTunnel), inner, center);
  float odd = mix(fract(uvidvTunnel.z/2. + floor(t*1.5)/2.) * 2., inner, center);

  // HEXAGON
  vec3 color = getColor(odd, pattern);
  out_color = vec4(color, 1.0);
}
// GAME OVER
