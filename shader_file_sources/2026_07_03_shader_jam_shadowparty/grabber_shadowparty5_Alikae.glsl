#version 420 core

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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float sdrand(vec3 p, vec3 dir) {
  return length(fract((p + dir) * 10987.));
}
float sdSphere( vec3 p, float r )
{
  return length(p) - r;
}
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float sdscene(vec3 p, vec3 dir) {
  //return sdSphere(p, dir.z);
//  return min(sdfucked(p, dir), sdSphere(p, dir.x));
  for (int i = 0; i < 100; i++) {
    float sd = min(sdSphere(p, 1.), sdTorus(p, vec2(.5, .3)));
    if (sd < .05) {
      return float(i) / 100.;
    }
    p += dir * sd;
  }
  return 1.;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv *= sin(fGlobalTime / 4.);
  vec2 real_uv = uv - .5;
	uv.x += 1.01;
  uv /= 8.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
//  uv.x *= tan(real_uv.x);
//  uv.y *= cos(uv.x) * (sin(uv.y) / tan(fGlobalTime * 2.));
  uv.y *= tan(real_uv.x);
  uv.x *= cos(fGlobalTime * 2. + .5) + 5.;
  uv.x *= fract(uv.y * (103987. + fGlobalTime * 1000.));
  if (length(uv) > .5) {
    uv = sqrt(uv);
  } else {
    uv *= uv;
  }
  if (length(real_uv * 2.) > .5) {
    uv *= sqrt(uv);
  } else {
    uv *= uv;
  }
  float green = fract(uv.x * uv.y * 70.);
  out_color = vec4(uv.x, green, length(uv) * sin(fGlobalTime), 1.);
  if (sdscene(vec3(real_uv, 0. - sin(fGlobalTime) + cos(fGlobalTime)), vec3(0., 0., -1.)) < 0.01) {
    out_color = out_color.brga;
  }
}
