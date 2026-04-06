#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float fft(float f)
{
  return texture(texFFTSmoothed, f).r;
}

float ifft(float f)
{
  return texture(texFFTIntegrated, f).r;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec4 ball(vec2 p, vec2 q, float r)
{
  if (length(p - q) < r)
    return vec4(1.,0.,0.,1.);
  else
    return vec4(0.);
}

void main(void)
{
  vec2 nc = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = nc - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float prog = .2+.05*sin(ifft(.01));
  for (float i = -1.; i <= 1.; ++i)
  {
    float r = .2;
    float readpos = .2 + .1*i;
    out_color += ball(uv, vec2((2*r*i)*sin(fGlobalTime), .4*(10.+readpos*20.)*fft(readpos)*sign(i)), .05+1.*fft(.01)).rrra;
  }
  out_color.rg += texture(texPreviousFrame, nc).rr*.9;
  
  
	//out_color += vec4(.5+fft(.01));
}