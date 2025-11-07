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

#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))

float sdf_box(vec3 p, vec3 s) {
  vec3 q = abs(p) - s;
  return max(q.x, max(q.y, q.z));
}

float map(vec3 p) {
  p.xy *= rot(t);
  p.yz *= rot(t);
  p.xz *= rot(t);
  
  float c = sdf_box(p, vec3(texture(texFFTSmoothed, .0) * 5. + 1.));
  return c;
}

void main(void)
{
	vec2 uv = 2. * (gl_FragCoord.xy - .5 * v2Resolution.xy) / v2Resolution.yy;
  vec3 c = vec3(0.);
  vec3 ro = vec3(0., 0., -4.);
  vec3 rd = normalize(vec3(uv, 1.));
  vec3 p = ro;
  vec3 acc = vec3(0.);
  float d;
  
  for (int i = 0; i < 128 && distance(ro, p) < 100.; i++) {
    d = map(p);
    if (d < 0.01) {
      c = vec3(1.);
      break;
    }
    acc += 1. - clamp(d/.8, 0., 1.);
    p += d * rd;    
  }
  c += acc;
	out_color = vec4(c, 1.);
}