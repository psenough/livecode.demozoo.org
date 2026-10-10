#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;

uniform float fMidiKnob;
#define iTime fGlobalTime
#define bpm 135
#define one_bpm bpm/60.
#define beat(a) fract(one_bpm*iTime*a)

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// Hello from the infodesk team :)
mat2 rot(float a) {return  mat2(cos(a), sin(a), -cos(a), sin(a));};
void main(void)
{
		
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv2 = uv;
	uv2.y = 1.-uv2.y;
	
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec2 uv3 = uv;
	
	vec4 color = vec4(fract(uv.x * 50.0 + beat(0.4)));
	vec2 uu = uv;
	uu *= 2.5;
	uu.y = 1.-uu.y;

	
	if(beat(0.25)  < 0.5) {	
		
		if(beat(0.5)  < 0.5) {	
			uu *= rot(0.5);
			uu.y += sin( 4000*  uv.y) ;
		}
		if(beat(0.75)  < 0.5) {	
			uu *= rot(0.5);
			uu.y += sin( 4000*  uv.x) ;
		}
		
		uu.y += sin( 4000*  uv.x) ;
	}
	else if(beat(0.5)  < 0.5) {	
		
		for (int i = 0; i <6 ; i++) {
			uu *= rot(0.29);
			uu.x *= color.x*2.0;
			uu.x+=float(i*beat(2.0));
		}
		uu.x += iTime;
	}
	vec4 ine = texture(texInercia, uu ) ;
	
	if(beat(0.5+fract(uv.x)) < 0.5) {
		 ine = texture(texInerciaBW, uu ) ;
	}
	
	color = mix(ine, color, sin(iTime*ine));
	
	
	if(beat(0.5) < 0.5) {
		color *= texture(texInercia, uv2+uu);
	}
	color += texture(texInercia,uv2+beat(uv.x+uu.y)).xxxx*0.3;
	
	uv3 = fract(uv3*20.0+ beat(0.5));
	uv3 -= 0.5;
	
	vec2 uvv = uv2;
	
	
	
	
	
	vec4 ttt = texture(texInercia, uvv);
	
		uv2 *= rot(beat(0.5));
		uv2.y += beat(0.75)*0.5;
	
	
	
	vec4 tt = texture(texInercia, uv2);
	float s = length(uv3) + 0.5 + 0.1*beat(1.0)*uv2.x;
	
	float ss = smoothstep(0.98, 1.0, s)  ;

	color += mix(tt, color, ss) ;
	
	
	float s1 = length(uv3) + 0.5 + 0.1*beat(1.0)*uv2.x;
	float ss2 = smoothstep(0.98, 1.0, s1) ;
	color += mix(ttt, color, ss2);
	
	out_color = vec4(color);

	
	
//	out_color = texture(texInercia, uv);
}