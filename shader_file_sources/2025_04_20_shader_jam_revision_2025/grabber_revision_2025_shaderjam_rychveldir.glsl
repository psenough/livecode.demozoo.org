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

vec2 vel1(const vec2 v_in, const float freq, const float dt)
{
  vec2 z = freq * v_in;
  return dt * vec2(sin(z.y), -sin(z.x));
}

vec2 vel2(const vec2 v_in, const float freq, const float dt)
{
  vec2 z = freq * v_in;
  const float a = 1./sqrt(3.);
  float f = sin(2. * a * z.x);
  float g = sin(z.y + a * z.x);
  float h = sin(z.y - a * z.x);
  float fx = 2. * a * cos(2. * a * z.x);
  float gx = a * cos(z.y + a * z.x);
  float hx = -a * cos(z.y - a * z.x);
  //float fy = 0.;
  float gy = cos(z.y + a * z.x);
  float hy = cos(z.y - a * z.x);
  return dt * vec2(f*gy*h + f*g*hy, -(fx*g*h + f*gx*h + f*g*hx));
}
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
  float f1 = 0.5 + 0.4 * sin(texture(texFFTIntegrated, 0.7).r);
  float f2 = 0.5 + 0.4 * sin(texture(texFFTIntegrated, 0.3).r);
  float f3 = 0.5 + 0.4 * sin(texture(texFFT, 0.9).r);
  
	vec2 uv = (1. + 3*f3) * f2 * vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5 + f1;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;

	float f = texture( texFFT, m.y ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

float d = 0.;
float w = 0.5 + 0.7 * sin(1.f * texture(texFFTIntegrated, 0.1).r);
float dt = 0.05 + 0.4 * sin(texture(texFFT, 0.1).r);
for (int ii = 0; ii < 150; ii++)
  {
    vec2 v = w * vel2(uv, 13., dt) + (1. - w) * 0.5 * vel1(uv, 13., dt) + 0.5 * (1. - w) * vel1(uv, 39., 0.53*dt);;
    d += length(v);
    uv += v;
  }
  vec4 c0 = vec4(0.9, 0.6, 0.2, 1.);
	vec4 t = 0.5 + 0.5 * vec4(1 * sin(1*d), 0.8 * sin(d), 0.4 * sin(d), 1.);
	t = clamp( t, 0.0, 1.0 );
	out_color = t;
}