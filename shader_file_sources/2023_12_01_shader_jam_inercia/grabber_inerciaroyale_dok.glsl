#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

#define texI texInerciaBW
#define texF texFFTSmoothed
#define time fGlobalTime
#define gain 5.5

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a));}
#if 1
vec3 s2(vec2 uv) {
	uv -= 0.5;
uv *= rot2(time);
	uv+=0.5;
	uv = abs(uv - 0.5) * 2.0;
	
	uv = 1.0-uv;
	uv.x = max(
	step(0.2, uv.x) * step(0.95, uv.y),
	step(0.2, uv.y) * step(0.95, uv.x))
	;
	return vec3(uv,0);
}
#endif
vec3 s1(vec2 uv,float w){
	uv = abs(uv - 0.5);
	uv = step(mix(0.1,0.8,w), uv);
	uv *= uv.x * uv.y;
	return vec3(uv,0);
}
#if 1
float s3(vec2 uv) {
	uv.x += (tan(uv.y) / 3.1416)*abs(uv.y)*sin(time/4.0)*11.0;
	uv *= rot2(time * 0.1);
	uv *= 4.0;
	uv = floor(uv*32.0)/32.0;
//	uv = fract(uv);
	uv *= 3.0;
	uv *= rot2(mix(0.4, 1.8, 0.5+0.5*sin(time/10.)));uv=abs(uv);
	uv.x += 0.5;
	uv *= rot2(mix(1.3, -2.5, 0.5+0.5*sin(time/7.0)));uv=abs(uv);
	uv.x += 4;
	//uv *= rot2(mix(0.1, 0.4, sin(time)));uv=abs(uv);
	uv.y += 1;
	uv *= rot2(mix(1.7, 0.2, 0.5+0.5*sin(time/3.0)));uv=abs(uv);
	uv.x -= time * (120./60.0);

	return step(0.8, fract(uv.x));
}
#endif
#if 1
vec2 sI(vec2 uv) {
	float r = mix(64.0,1024.0,sin(time/10.0));
	uv = floor(uv*r)/r;
	uv.y = -uv.y;
	uv.x += time*0.1;
	uv.y += sin(uv.x*4-time) / 10.0;
	return texture(texI, uv.xy).ra;
}
#endif
void main(void)
{
	vec2 UV = vec2(gl_FragCoord.xy - 0.5 * v2Resolution) / v2Resolution.y;
        vec3 col = vec3(0);
//	UV = fract((fract(UV * 10) -0.5)* rot2(0.3+sin(time)));

	col.rg = s1(fract((fract(UV*8)-0.5)*rot2(0.3+sin(time))), texture(texF,0.01).r*gain).rg;
	
	col.r = mix(col.r, 1.0-col.r, s2(fract(UV*8.0)).r);
	//col.r = mix(col.r, 1.0-col.r, s3(UV));
	col.r = max(col.r, s3(UV));
	col.rbg = col.rrr;
	//float i = sI(UV / mix(1,1.4,texture(texF, 0.01).r*gain)).r;
	vec2 t = sI(UV+0.5);
	col.rgb = mix(col.rgb, t.rrr, smoothstep(0.0,0.001,t.r));
	//float j = sI(UV).r;
	//col.rgb *= mix(1.0-j, 1.0,smoothstep(0.0, 0.001,i));
	//col.rg = s2(UV).r;
	//col.r = s3(UV);
	out_color = vec4(col,1);
}