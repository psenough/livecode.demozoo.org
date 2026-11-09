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

vec2 rot(vec2 xy, float a)
{
  return vec2(xy.x*cos(a)+xy.y*sin(a), xy.x*sin(a)-xy.y*cos(a));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float ff = texture(texFFT, .1).r;
  float t = fGlobalTime;
  float c  = smoothstep(.1+ff, .2, distance(uv, vec2(0.)));
  float c2 = smoothstep(ff*2, .2, distance(uv, vec2(.3)));
  float c3 = smoothstep(ff*2, .2, distance(uv, vec2(-.3)));
  float c4 = smoothstep(ff*4, .2, distance(uv, vec2(-.5,.3)));
  float c5 = smoothstep(ff*4, .2, distance(uv, vec2(.5,-.3)));
  float sdf = c*c2*c3*c4*c5;
  //vec4 n = vec4(vec3(fract(sin(dot(uv.xy,vec2(12.9898,78.233)))*43758.5453123)), 1.);
  //out_color = c2+c/vec4(rot(uv, t*20-ff*100), sin(t*2.)-.8, 1.);
  out_color = mix(vec4(0., rot(uv, t), 1.), vec4(rot(uv, -t), 0., 1.), sdf);
  
  
}