#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texRevision;
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T fGlobalTime
#define FFT(x) (texture(texFFT, x).r)
#define FFTS(x) (texture(texFFTSmoothed, x).r)
#define FFTI(x) (texture(texFFTIntegrated, x).r)

uint hash(float val) {
	uint v = uint(val);
	v ^= v << 13u;
	v ^= v >> 17u;
	v ^= v << 5u;
	return v;
}

uvec2 uhash(vec2 uv, float o) {
	return uvec2(hash(hash(uv.x) + uv.y), hash(hash(uv.x + o) + uv.y + o));
}
float hmix(uvec2 h, int s) {
	return mix(0, 1, (h.y >> s) & 1u) - mix(0, 1, (h.x >> s) & 1u);
}

float m(vec2 uv, float t, float dens) {
	uvec2 h0 = uhash(uv * 100, 0.5);
	uvec2 h1 = uhash(uv.yx * 120, 0.2);
	uvec2 h2 = uhash(uv.xx * dens, 0.2);
	
	float pat = hmix(h0, 10) + hmix(h1, 17);
	float c = 1 - fract(uv.y * 0.3 + t * 0.3 + ((h2.x >> 6u) & 0xffu) / 250.0);
	return pow(c, 10) * pat;
}

vec2 rot(vec2 uv, float r) {
	return mat2(sin(r), cos(r), -cos(r), sin(r)) * uv;
}


float mr(vec2 uv, float ri, float ro, float a0, float a1) {
	float r = (atan(-uv.x, -uv.y) / 3.141592) * 180.0 + 180.0;
	float d = length(uv);
	return (step(a0, r) - step(a1, r)) * (step(ri, d) - step(ro, d));
}


float rev(vec2 uvA, vec2 uvB, vec2 uvC) {
  float c = 0;

  c += mr(uvA, 0.04, 0.085, 0, 360);
  c += mr(uvA, 0.04, 0.155, 290, 350);

  c += mr(uvA, 0.225, 0.265, 0, 360);
  c += mr(uvA, 0.19, 0.265, 0, 108);
  c += mr(uvA, 0.19, 0.265, 120, 210);
  c += mr(uvA, 0.19, 0.265, 225, 285);
  c += mr(uvA, 0.13, 0.265, 20, 65);
  c += mr(uvA, 0.13, 0.265, 137, 175);
  c += mr(uvA, 0.13, 0.265, 250, 265);

  c += mr(uvB, 0.38, 0.435, 0, 360);
  c += mr(uvB, 0.33, 0.435, 45, 55);
  c += mr(uvB, 0.33, 0.435, 73, 91);
  c += mr(uvB, 0.33, 0.435, 152, 163);
  c += mr(uvB, 0.33, 0.435, 180, 205);
  c += mr(uvB, 0.33, 0.435, 265, 325);
  c += mr(uvB, 0.33, 0.435, 350, 360);
  c += mr(uvB, 0.33, 0.435, 0, 20);
  c += mr(uvB, 0.38, 0.46, 93, 150);
  c += mr(uvB, 0.38, 0.46, 315, 325);


	float cb = 0.6;
	c += mr(rot(uvC, T), cb, cb + 0.01, 0, 270);
	c += mr(rot(uvC, -T), cb + 0.02, cb + 0.025, 0, 150);
	c += mr(rot(uvC, -T), cb + 0.02, cb + 0.025, 170, 300);
	c += mr(rot(uvC, -T * 1.3), cb + 0.04, cb + 0.065, 0, 40);
	c += mr(rot(uvC, -T * 1.3), cb + 0.04, cb + 0.065, 80, 140);
	c += mr(rot(uvC, -T * 1.3), cb + 0.04, cb + 0.065, 180, 340);
	
  return c;
}

void main(void)
{
	vec2 ouv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uvc = ouv - 0.5;
	uvc.x += sin(uvc.y * 200 + T * 2) * 0.05 * smoothstep(2, 10, FFT(0.6) * 1000);
	uvc *= 1.3;
	
	vec2 uv = ouv / vec2(v2Resolution.y / v2Resolution.x, 1);
	uvc /= vec2	(v2Resolution.y / v2Resolution.x, 1);

		
	float p = 0;
	for (float i = 1; i <= 8; i++) {
		vec2 uvt = vec2(uv.x + FFTI(0.7) / i, uv.y);
		uvt.x += sin(uvt.y * 500 + T * 2) * 0.05 * smoothstep(3, 10, FFT(0.7) * 1000);
		p += m(uvt * i, T * 0.3, 20 + (5 * i)) / i;
	}
	
	float integ = texture(texFFTIntegrated, 0.01).r * 0.1;
	vec2 uvm = uvc * (1.5 - FFT(0.1) * 6);
	
	vec3 col = vec3(0);
	for (int i = 1; i < 8; i++) {
		vec2 uvr = uvm * i * 0.25;
		float r = rev(rot(uvr, integ), rot(uvr, -integ), uvr * 1.5);
		col += vec3(0, 0.3, 0.7) * (r / i) * 0.1;
	}
	
	float r = rev(rot(uvm, integ), rot(uvm, -integ), uvc * 1.5 * (FFT(0.3) * 20 + 0.8));
	col += vec3(0, 0.3, 0.7) * r;
	
	col += vec3(0, 1, 1) * p * 0.5;
	col += FFT(ouv.x) * 10 * (1-ouv.y) * vec3(0, 0, 1);
	col += FFT(1-ouv.x) * 10 * ouv.y * vec3(0, 0, 1);

	out_color = vec4(col, 1);
}