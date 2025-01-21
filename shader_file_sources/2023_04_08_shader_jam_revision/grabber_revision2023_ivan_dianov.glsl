#version 410 core

uniform float fGlobalTime; // in seconds
#define time fGlobalTime
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform float fMidiKnob;

#define F float
#define W vec3
#define V vec2
#define N normalize
#define L length
#define S(x) sin(x+2*sin(x+4*sin(x)))
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))
#define col(x) (cos(x+vec3(0.,.7,.9))*.5+.5)
#define sfloor(x) (floor(x)+smoothstep(.0,.9,fract(x)))
layout(location = 0) out vec4 o; // out_color must be written in order to see anything

void main(void)
{
	o-=o;
	vec4 B = (texture(texFFT,.05)*10);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	F i=0,d=0,e=1;
	W p, pi, rd=N(W(uv,1.2));
	
	for(;i++<99&&e>.001;){
		pi=p=rd*d;
		p.xz*=rot(S(time*.1)+.05);
		p.xy*=rot(S(time*.13+S(pi.z*.1+time*.1))*.5);
		pi=p;
		p.z+=sfloor(time*.5)+atan(p.y,p.x+.001)/3.14;

		p=fract(p)-.5;
		
		F ss=2.5,s;
		for(F j=0;j++<5;){
			p.z+=.1*sin(pi.z+time);
			ss*=s=(1.4+.2*S(pi.z*.01-time*.01))/dot(p,p);
			p*=s;
			F stp = 1.3+.1*B.x+.3*S(pi.z);
			p=mod(p+stp,2*stp)-stp;
		}
		d+=e=(L(p.xz)-.5*B.x-.01*S(pi.x-time))/ss;
		//F l = (fract(L(pi)*.1)-.5)/ss;
		//o+=.00001/(.01+l);
	}
	o+=8/i;
	o.rgb *= col(d+sfloor(time+L(pi.xy)))*4;
}