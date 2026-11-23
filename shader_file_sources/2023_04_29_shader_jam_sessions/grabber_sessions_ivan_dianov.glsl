#version 410 core

uniform float fGlobalTime; // in seconds
#define time fGlobalTime
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
#define B (texture(texFFTSmoothed,.001)*5)
#define BB (texture(texFFT,.001)*5)
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform float fMidiKnob;

layout(location = 0) out vec4 o; // out_color must be written in order to see anything

#define F float
#define V vec2
#define W vec3
#define N normalize
#define L length
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))
#define S(x) sin(x+2*sin(x))
#define col(x) (cos((x+W(0,.3,.4))*6.28)*.5+.5)

void main(void)
{
	o-=o;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	F i=0,d=0,e=1;
	W p,pI, rd=N(W(0,0,1));
	rd.zy*=rot(uv.y*2.);
	rd.xz*=rot(-uv.x*2.5+S(time*.3)*8+.3*S(time+uv.x*2));
	F c;
	for(;i++<99&&e>.0001;){
		pI=p=d*rd;
		F sz=.25*BB.x;
		sz = max(sz,.1);
		p.z+=(time*.5)+B.x*.1;
		p.zy=p.yz;
		F s,ss=1;

		//p.xz*=rot(S(time*.4));
		 c=0;
		for(F j=0;j++<4;){
		p.xz*=rot(time+S(time*.4*1.61+pI.z*1+j));
			ss*=s=3.;
			p*=s;
			p.y+=.5+j/10;//+B.x;
			p.y=fract(p.y)-.5;
			p=abs(p)-.5-B.x*.1;
			if(p.z<p.x)p.xz=p.zx;
			if(p.y>p.x)p.xy=p.yx;
			c+=L(p)*.01;
		}
		
		p-=clamp(p,-sz,sz);
		d+=e=(L(p.xz)-.0001)/ss;
	}
	o.rgb += 12/i*col(log(d)*.8+c*20+time*.1);
}