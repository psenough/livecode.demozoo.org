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
uniform sampler2D texInerciaLogo2024;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 rotZ(vec2 p, float rad) {
	 				return mat2(cos(rad),sin(rad),-sin(rad),cos(rad))*p;
}

float rand(float a) {
  return fract(sin(a)*100000.);
}

float rand2(vec2 a) {
  return fract(sin(dot(a, vec2(12.3435, 32.2346)))*53001.43);
}

float noise_1s(float a) {
  float i = floor(a);
  float f = fract(a);

  return mix(rand(i), rand(i+1.), smoothstep(0.,1.,f));
}

float noise_2s(vec2 hv) {
  vec2 i = floor(hv);
  vec2 f = fract(hv);

  float a = rand2(i);
  float b = rand2(i+vec2(1.,0.));
  float c = rand2(i+vec2(0.,1.));
  float d = rand2(i+vec2(1.,1.));

  vec2 u = smoothstep(0.,1.,f);

  return mix(
       mix(a, b, u.x),
       mix(c, d, u.x), u.y);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec4 finlanColor(vec2 hv)
{
  vec4 white = vec4(.9, .8, .7, .5);
  vec4 blue = vec4(0.2,0.2,.5,.5);
  vec4 bg = vec4(0.);
  
  if (abs(hv.x) > .7 || abs(hv.y) >.4)
    return bg;
  if (hv.x < -.2 && hv.x > -.4 || abs(hv.y) <.1)
    return mix(blue, texture(texInerciaLogo2024, (rotZ(floor((hv+fGlobalTime)/.01)*.01, .01*noise_1s(fGlobalTime)))), .5);
  return white;
}

vec2 fOffset(vec2 qv)
{
  return vec2(0., 0.1*sin(qv.x*5.+fGlobalTime*2.)+.3*noise_2s(qv+fGlobalTime));
}

vec4 skyColor(vec2 qv)
{
  vec4 sun = vec4((1.*texture(texFFTSmoothed, .05).x)/length(qv))*vec4(1.,.7,.3,0.);
  float w = 0.02;
  float d = 0.001;
  float barx = ceil(abs(qv.x/w)+1)*d;
  float barh = texture(texFFTSmoothed, barx).x * (.01+barx) * 100;
  vec4 barcolor = vec4(10.*barh,10.*barh,.6, qv.y < barh ? .3 : 0.);
  return mix(
    mix(vec4(.9,.4,.2,1.), mix(vec4(.7,.2,.2,1.), vec4(.1,.01,.2,1.), abs(qv.y*1)), clamp(length(qv)-.01, 0., 1.)) + sun,
    barcolor, barcolor.a);
}

vec4 bgColor(vec2 qv)
{
  vec4 c = skyColor(qv);
  if (qv.y < 0.) {
    c = skyColor(qv + noise_2s((qv/(.01+qv.y*.7))*3+fGlobalTime*4)*.2) -.04;
  }
  return c;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  // aaaa
  vec2 qv = uv;
  vec2 offset = fOffset(qv);
  float e = .01;
  vec2 dOffset = vec2(length(fOffset(qv+vec2(e,0.))-offset)/e, length(fOffset(qv+vec2(0.,e))-offset)/e);
  qv -= offset;
  qv.y += .2;
  float shadow = dOffset.y*3 + noise_2s(qv*3.+noise_2s(qv*10.)+fGlobalTime)*.5;
  vec4 color = finlanColor(qv);
  color -= 2.*vec4(offset.yyy,0.)*vec4(shadow, shadow, shadow, shadow);
	out_color = mix(bgColor(uv), color, color.a);
}