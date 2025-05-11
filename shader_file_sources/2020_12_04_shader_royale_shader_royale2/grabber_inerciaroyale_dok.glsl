#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
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

#define PI2 (2*3.1416)

#define vol 0.001

mat2 rot2(float a) {return mat2(cos(a), -sin(a), sin(a), cos(a));}

float ht(vec2 uv, float a, float v)
{
	uv *= 10;
	uv *= rot2(a);
	uv.x += 0.5 * floor(uv.y);
	return step(length(fract(uv) - 0.5), v / 2);
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy - 0.5 * v2Resolution.xy) / v2Resolution.y;
	vec3 col = vec3(0);
	vec2 sc = uv;
	vec2 pv = uv;
	vec2 tv = uv;
	vec2 cv=  uv;
	
	float circle = length(cv) - fGlobalTime + texture(texFFTIntegrated, 0.01).r * 100 * vol;
	float dist_2 = 2.5 * sin(fGlobalTime / 100.0) * tan(fGlobalTime / 2);
	for (int i= 0 ;i < 10; i++) {
		float a = PI2 * (i/10.0);
		cv.x += dist_2* sin(fGlobalTime + a);
		cv.y += dist_2 * cos(fGlobalTime +a);
	circle = min(circle,
	length(cv) - fGlobalTime + texture(texFFTIntegrated, 0.01).r * 100 * vol
	);
	}
		
	float dist = 1.5;
	tv.x += 0.001 * tan(fGlobalTime);
	tv.x += dist * sin(fGlobalTime);
	tv.y += dist * cos(fGlobalTime);

	/* zoom */
	uv *= mix(0.5, 2.0, 0.5 + 0.5 * sin(fGlobalTime / 10));
	/* roto */
	uv *= rot2(0.0025 * fGlobalTime);

	float speed  = fGlobalTime;
	uv.y += 0.05 * sin(uv.x * 1.0 * PI2+ speed);
	uv.y = fract(uv.y * 10.0);
	col.r = ht(uv, PI2 * sin(fGlobalTime / 10.0), uv.y);

	col.rgb = col.rrr;
	float lsize = 10.0 * (0.5 + 0.5 * sin(fGlobalTime / 10));
	col.rgb *= step(mix(0.4, 0.4, 0.5 + 0.5 * sin(vol * texture(texFFTIntegrated, 0.01).r)), fract(length(tv * lsize)));
	if (fract(circle) < 0.5)
		col.rgb = col.rgb;
	else
		col.rgb = 1.0 - col.rrr;

	
	if ((texture(texFFTIntegrated, 0.01).r * vol) > 0.8)
		col.rgb = 1.0 - col.rgb;

	vec2 off;
	off.x += dist * sin(fGlobalTime / 10);
	off.y += dist * cos(fGlobalTime / 10);

//	sc = vec2(length(sc), atan(sc.x,sc.y)/PI2));
	if (ht(sc+off, 0, length(sc)) > 0.5)
		col = 1.0 - col;

	out_color = vec4(col, 1.0);
}