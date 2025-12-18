#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform float fMidiKnob;

#define col(c) (cos((c+vec3(.0,.2,.3))*2.*3.1415)*.5+.5)
layout(location = 0) out vec4 o; // out_color must be written in order to see anything

#define rnd(x) fract(1.1e4*sin(mod(111.1*(x),3.14)+.1))
#define F float
#define N normalize
#define L length
#define V vec2
#define W vec3
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define time fGlobalTime
#define S(x) sin(x+2*sin(x+4*sin(x)))
//#define 

float sigmoid(float x) {
	return clamp((x*(2.51*x+0.03))/(x*(2.43*x+0.59)+0.14),0.,1.);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	o=vec4(0);
	
	F i=0,d=0,e=1;
	W p,rd=N(W(uv,1)),ro=W(0,0,0),pI;
	W pCol;
	for(;i++<99&&e>.0001;){
		p=rd*d+ro;
		p.xz*=rot(S(time*.1)*.2);
		p.yz*=rot(S(time*1.68*.1)*.2);
		pI = p;
		p.x+=7;
		p.z+=time+pI.z*.1;
		p/=7.;
		p=abs(fract(p*.5)*2.-1.)-.5;
		p*=7.;
		
		F j=0,ss=1.2,s;
		W sz=W(
			S(time+pI.z*.1)*.5+1.5,
			S(time+L(pI)*.1)*.2+.5,
			1);
		
		W pp = p;
		F res=9999.;
		W pgl;
		for(;j++<3.;){
			if(j==1)pCol=p;
			if(j==2)pgl=p;
			p-=clamp(p, -sz, sz)*2.;
			s = 12.*clamp(.3/min(dot(p,p),1.),0.,1.);
			p*=s; ss*=s;
			p+=.3*pp;
			p.xz*=rot(time*.3+pI.z*.1);
			p.yz*=rot(time*.323+pI.z*.12);
			p=p.zxy;
			res = min(res,(L(p.yz)+.1*(sin(pI.z*2.))-2.1+.3*S(time*1-pI.z*.5))/ss);
		}
		//F gl=(L(p.xy)-1.1)/ss;
		e=res;
		//o.r+=.03*exp(-i*i*e);
		//e=min(e,gl);
		d+=e;
		}
	o+=1-i/99;
	o.rgb*=col(S(L(pCol.xy)*.02));
	o.r=sigmoid(o.r);
	o.g=sigmoid(o.g);
	o.b=sigmoid(o.b);
	o.g+=.1;
}