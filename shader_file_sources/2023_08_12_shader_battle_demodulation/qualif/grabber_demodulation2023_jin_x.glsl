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

#define PI 3.14159265358979
#define rot(x) mat2(cos(x), -sin(x), sin(x), cos(x))

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float t = fGlobalTime * 0.5;
  
  int d = 0;
  for (; d < 100; ++d) {
    int i = 0;
    vec2 j = uv * (5+float(d)/10) * 0.5;
    vec2 p = vec2(cos(t), sin(t)) * 0.7;
    for (; i < 64 && length(j) < 4; ++i) {
      j = vec2(j.x*j.x - j.y*j.y + p.x, 2*j.x*j.y + p.y);
    }
    if (d > i) { break; }
  }

  //vec3 col= vec3(0);
  //col = clamp(vec3(float(d) / 64), 0, 1);
  
  vec3 q = vec3(uv, dot(uv,uv));
  for (int j = 0; j < 12; ++j) {
    q.xz *= rot(t);
    q.yz *= rot(t*0.7);
    q = q.gbr - 1/(length(q) - q.grb);
  }
  
  vec3 f = vec3(1, 0.5, 0);
  vec3 col;
  float w = clamp(float(d) / 20., 0, 1);
//  if (d < 64) col =  * vec3(0.5, 1, 0.2);
//  else col = q;
  vec3 c = 0.5+0.5*cos(2*PI*(w+vec3(0,0.333,0.667)));
  col = c * (w) + clamp(q,0,0.5f) * (1-w);
  
	out_color = vec4(col, 0);
}