#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI 3.1416
#define PI2 (2.0*PI)
#define gain 1.0

vec2 pol2(vec2 uv) {
	return vec2(length(uv), fract(atan(uv.x,uv.y)/PI2));
}
mat2 rot2(float a) { return mat2(cos(a), sin(a), -sin(a), cos(a));}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy - 0.5 * v2Resolution) / v2Resolution.y;
	vec3 col = vec3(0);
	float ef = fGlobalTime/2.0;
	vec2 ev = pol2(uv + vec2(sin(ef), cos(ef)) * 0.1);
	vec2 cv = pol2(uv);
	vec2 lv = ev;
	vec2 UV = uv;
	uv.y += mix(0.95, 0.85, abs(sin(fGlobalTime+2.0*texture(texFFTIntegrated, 0.1).r))) * sign(uv.y);
	vec2 pv = pol2(uv);
	
	float ff = texture(texFFTSmoothed, 0.1).r * gain;
	float ey = step(pv.x, 1.0);
	float ni = ey;
	float nl = mix(10, 15, ff);
	float pr = mix(0.25, 0.05, 5.0*ff);
	ni = ni * step(pr, ev.x) + (1-ni)*step(fract(nl*pv.x), mix(0.1, 0.05, ff));
	
	float li = step(fract(25.0*lv.y + sin(50*(lv.x) - fGlobalTime)), mix(0.05, 0.1, ff));
	float ci = step(fract(50.0*cv.y + sin(10*(cv.x) - fGlobalTime)), mix(0.05, 0.1, ff));
	col.r = ni + ey * li + ci * li;
	col.r += 2*texture(texFFT, pv.x).r;

	float r = 0;
	for (float i = 0; i < 1.0; i += 0.1) {
		float rr = mix(0.5, 0.75, sin(fGlobalTime/4));
		r += step(pol2(UV + vec2(rr,0)*rot2(fGlobalTime + i*PI2)).x, 0.05+ff);
	}
	if (sign(UV.y) > 0)
		col.r += r;

	r = 0;
	for (float i = 0; i < 1.0; i += 0.1) {
		float rr = mix(0.5, 0.75, sin(fGlobalTime/4));
		r += step(pol2(UV + vec2(rr,0)*rot2(-fGlobalTime + i*PI2)).x, 0.05+ff);
	}
	if (sign(UV.y) < 0)
		col.r += r;


	float sp= fGlobalTime/2.0;
	vec2 sv = UV+vec2(sin(sp),cos(sp))*0.04;
	r = 0;
	for (float i = 0; i < 10.0; i += 0.11) {
		float rr = mix(0.2, 1.0, sin(i+fGlobalTime/4));
		r += step(pol2(sv + vec2(rr,0)*rot2(-fGlobalTime + i*PI2)).x, 0.01+ff);
	}
	if (r > 0)
		col.r = 1.0 - col.r;

	
	col.rgb = col.rrr;

	out_color = vec4(col, 1);
}