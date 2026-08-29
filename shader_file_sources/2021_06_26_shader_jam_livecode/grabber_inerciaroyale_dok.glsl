#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform float fmknobB1;
uniform float fmknobB2;
uniform float fmknobB3;
uniform float fmknobB4;
uniform float fmknobB5;
uniform float fmknobB6;
uniform float fmknobC1;
uniform float fmknobC2;
uniform float fmknobC3;
uniform float fmknobC4;
uniform float fmknobC5;
uniform float fmknobC6;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI 3.1416
#define TAU (2.0*PI)

float fft(float f) { return clamp(0.0, 0.0, 0.000000000000000001*texture(texFFTSmoothed, f).r); }

mat2 rot2(float a){ return mat2(sin(a),-cos(a), cos(a), sin(a));}

vec3 sp(vec2 uv, vec2 p, vec2 h, float f) {
	float p1 = p.x + fGlobalTime;
	float p2 = p.y + fGlobalTime;
	float i  = (uv.y * h.x) - (0.5 + 0.5 * sin(uv.x * f * TAU + p1));
	float j  = (uv.y * h.y) - (0.5 + 0.5 * sin(uv.x * f * TAU + p2));
	float s = sign(i * j);
	float d = s * min(abs(i), abs(j));

	return vec3(s,d, uv.x);
}

float ht(vec2 uv) {
	float c = length(fract(uv * 10.0)-0.5);
	float rc = mix(0.2, 0.1, fft(0.001));
	c = step(rc, c);
	return 1.0 - c;
}
/* THANKS !!!! THANKS THANKS THANKS */
/* NICE entries ! Good job every one */
/* Thanks for the mix lug00ber */
void main(void)
{
	vec3 col;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	uv *= 4;

	float c = 0;
	float z = mix(0.1, 0.5, 0.5+0.5*sin(fGlobalTime / 30.0) + 100.0*fft(0.04));
	for (float i = 0.0; i < 1.0; i += 0.1) {
		vec3 vv = sp(z * uv * rot2(i*PI), vec2(9.0, 5.0) * i, vec2(1)+fft(0.02)*20, 0.025);
		vv.y = fract(vv.y * 1.0 - fGlobalTime);
		c += ht(vv.yz);
	}
	col = vec3(c / mix(4.0, 2.0, fft(0.05)));

	float l = 0;
	for (float i = 0.0; i < 1.0; i += 0.05) {
		vec3 vv = sp(uv * rot2(i * TAU), vec2(i, 5.0) * i, vec2(0.9) * i, 0.01);
		l = max(l, 1.0 - step(mix(0.01, 0.02, fft(0.03)), abs(vv.y)));
	}

	float d = 1000;
	float rd = 0.5;
	float dd = mix(0.0, 3.0, sin(fGlobalTime / 20));
	for (float i = 0.0; i < 1.0; i += 0.1) {
		vec2 dv = vec2(dd + i*fft(0.01)) * rot2(i * TAU - fGlobalTime);
		d = min(d, length(uv - dv));
	}
	if (0.5*d < rd)
		l = 1.0 - l;

	if (fft(0.005) > 0.8)
		col *= l;
	else
		col *= 1.0 - l;

	if (d < rd)
		col = 1.0-col;

	out_color = vec4(col, 1);
}