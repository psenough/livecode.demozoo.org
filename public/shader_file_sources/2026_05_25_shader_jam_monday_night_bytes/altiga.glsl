// Heavily inspired by xor's "Phosphor" breakdown.

#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime;  // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is
                          // higher / treble freq
uniform sampler1D
    texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

float t = fGlobalTime;
vec2 r = v2Resolution;
vec4 FC = gl_FragCoord;

vec2 ep = vec2(0.002, 0);

layout(location =
           0) out vec4 o; // out_color must be written in order to see anything

mat2 rot(float ang) {
  float s = sin(ang), c = cos(ang);
  return mat2(c, -s, s, c);
}

float sdf(vec3 p) {
  float oct = 2.;
  p.z -= 5.;
  p.yz *= rot(t);
  for (int i = 0; i < 5; i++) {
    p.yx *= rot(t);
    p.xz *= rot(t); // mix(3,sin(t),sin(t)));
    p += sin(p * oct).yzx / oct;
    oct *= 1.;
  }

  return (length(p) - 2.) * .1;
}

void main(void) {
  vec2 uv = (gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
  vec3 z = normalize(vec3(uv, .4));
  vec4 hue = vec4(1, 4, 3, 0);

  float totalDist = 0., stepDist = 0.;

  o = vec4(0.);

  for (float i = 0; i < 80.; i++) {
    vec3 p = totalDist * z;
    stepDist = sdf(p);
    totalDist += stepDist;
    if (totalDist > 100.)
      break;
    o += (cos(hue + stepDist * 10.) + 1.) / 80. / totalDist;
  }
  o = normalize(o);
}