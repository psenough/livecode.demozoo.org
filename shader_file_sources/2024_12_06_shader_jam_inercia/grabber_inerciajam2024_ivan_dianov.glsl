#version 410 core

uniform float fGlobalTime; // in seconds
#define t fGlobalTime
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform float fMidiKnob;

layout(location = 0) out vec4 o; // out_color must be written in order to see anything

#define F float
#define V vec2
#define W vec3
#define L length
#define N normalize
#define S(x) sin(x+2*sin(x+4*sin(x)))
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define bg (vec4(.2,.2,.5,1)*.6)

F tx = 0;

F bo(W p){
	W sz=W(.6,.5,.7);
	p=abs(p);
	p-=sz;
	return max(p.x,max(p.y,p.z))*.6;
}

F sdf(W p){

	p.z-=3;
	
	//p.x+=sin(p.y*.1)*9;
	//p.z+=sin(p.y*.16)*9;

	p.yz*=rot(-1.+.2*S(t*.2));
	//p.yz*=rot(3.1415/2);
	p.xz*=rot(3*S(t*.01));

	p.y+=t + 2.1 * S(t*.1);
	
	F str = L(abs(abs(abs(abs(abs(p.xz)-2.4)-.9)-.4)-.16)-.03)-.01;
	
	F f=2;
	p.y = sin(p.y*f+t)/f;
	//p.y+=.3*S(+t);
	
	//if(fract(p.y)<.5)tx=1;
	
	p.xz*=rot(.1*t);
	p.xy*=rot(.1*t*.618);
	F b1=bo(p+.2);
	F b2=bo(p-.2);
	b1 = abs(b1)-.1;
	b2 = abs(b2)-.06;
	F z = L(V(b1,b2))-.06;
	
	p.xz*=rot(t*.1);
	p.xy*=rot(t*.16);
	F k=1+.3*sin(p.y+t);
	F b=bo(p*k)/k;
	b=abs(b)-.06+.05*S(p.x*3.);
	F beam = L(V(z,b))-.03;
	return min(str,beam);
}

vec3 normal(vec3 p){
	float d=sdf(p); vec2 e=vec2(0,.01);
	return normalize(vec3(d-sdf(p-e.yxx),d-sdf(p-e.xyx),d-sdf(p-e.xxy)));
}


void main(void)
{
	o=vec4(0);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	F i=0,d=0,e=1;
	W p,P,rd=N(W(uv,1+.01*sin(L(uv)*111)));
	for(;i++<99&&e>.001;){
		p=rd*d;
		d+=e=sdf(p);
	}
	if(d<18&&i<99){
		//o = vec4(4)/i;
		W n = normal(p);
		W l = N(W(1,1,-1));
		o += dot(n,l)*.5+.5;
		o *= sdf(p+n*.3)/.3;
		o += pow(dot(reflect(rd,n),l)*.5+.5,20);
		//if(sin(L(p.z)*1)<0){
			//o.r=1-o.r;
			//o*=.6;
		//}
		//else {
			//o.g = 1-o.g;
		//}
		
		//o.rg *= rot(L(uv)*3-t*.5);
		o=mix(o,bg,smoothstep(10,31,d));
	}
	else{
		o=bg;
	}
	
	o.a=1.;
}