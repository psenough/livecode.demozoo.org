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

vec2 m;
float d;
float t;

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time*0.5 + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time*0.1)), c * 0.15, cos( c * 0.1 + time / .1 ) * .25, 1.0 );
}

vec4 ripple(vec2 v, float time)
{
    float c = 0.5 + sin(v.x * 1.0) + cos(sin(time*0.01 + v.y) * 2.0);
    float rippleIntensity = 0.3+(sin(c * 0.2 + cos(time*0.02+d*10.1)*d)) * 0.001;
    float rippleOffset = cos(c * 0.1 + time / 0.01) * 0.25;
    vec2 distortedUV = v + vec2(rippleOffset, 0.0);
    vec4 texColor = texture(texPreviousFrame, distortedUV * 0.5 + 0.5);
    return texColor * rippleIntensity;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  t = fGlobalTime;

	uv -= 0.5;
  if (uv.y < 0.0) uv.y = 0.0-uv.y;
  if (uv.x < 0.0) uv.y = 0.0-uv.y;

	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv*=0.5;
	m.x = atan(uv.x / uv.y) / 1.14;
	m.y = 1 / length(uv) * .7;
	d = m.y;

	float f = cos(texture( texFFTIntegrated, d ).r*0.1)*0.1;
	float f2 = cos(texture( texFFT, d ).r*0.1)*1;
	m.x += sin( f*1. ) * cos(f)*0.1;
	m.y += fGlobalTime * 0.05;

  vec4 t1 = ripple(-m * 3.14, t*0.01) * d*cos(t*0.01)*1.1;
  for(float ff = 0.0; ff < 8.0; ff+=1.0) {
  vec4 t2 = plas(ff*0.1+m+f*cos(f*0.1+t*0.1),t)*d*cos(t1.r*0.1+t*0.2+f*0.1)*cos(t*10.1+d+ff*0.1)*1.;
  t1/=t2*1;
  }
	out_color = vec4(t1.r*1.6,t1.g*1.7,t1.b*1.5,1.0);
	out_color = 0.7*clamp( out_color, t1.r*1.0-d/1., 2.0 )/t1;

}