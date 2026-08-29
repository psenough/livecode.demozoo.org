#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
layout(location = 0) out vec4 o; // out_color must be written in order to see anything

#define time fGlobalTime
#define tx texPreviousFrame
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define B (noise(time))
#define BB (noise(time*8))
#define rnd(x) fract(1.1e4*sin(mod(111.1*(x),3.14)+.1))

float noise(vec3 p) {
  vec3 ip=floor(p),s=vec3(7,157,113); p-=ip; p=smoothstep(0.,1.,p);
  vec4 h=vec4(0,s.yz,s.y+s.z)+dot(ip,s);
  h=mix(fract(sin(h)*43758.5), fract(sin(h+s.x)*43758.5),p.x);
  h.xy=mix(h.xz,h.yw,p.y);
  return mix(h.x,h.y,p.z);
}

float noise(float x){
	return noise(vec3(x));
}


void main(void)
{
	o=vec4(0);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec2 uvI=uv;

	vec2 uvT = gl_FragCoord.xy/v2Resolution;
	uvT-=.5;
	uvT*=.93;
	uvT.x+=(rnd(time*33)-.5)*.01;
	uvT.y+=(noise(time*44+99.)-.5)*.01;
	uvT*=rot((rnd(time*8)*.1-.05)*.1);
	uvT+=.5;
	o=texelFetch(tx,ivec2(uvT*v2Resolution),0);
	
	
	
	uv*=rot(rnd(time*8+length(uv)*8)-.5);
	uv=abs(uv);
	if(rnd(time*88)<.1){
		if(uv.x<.01&&uv.y<.1){
			o=vec4(int(o.a)^1);
		}
	}
	
	float i=0,d=0,e=1.;
	uv = uvI;
	vec3 p,gl=vec3(0);
	for(;i++<50.&&e>1e-3;){
		p=normalize(vec3(uv,1))*d;
		p.xz*=rot(time*sign(o.a-.5));
		p.z-=4.-time*2*sign(o.a-.5);
		p = abs(fract(p*.5)*2.-1.)-.5;
		p.xz*=rot(B*8);
		p.yz*=rot(B*8*.618);
		if(o.a>.5){
			p=abs(p);
			p-=B*.3;
			p.zx=(p.z<p.x)?p.xz:p.zx;
			p.yx=(p.y>p.x)?p.xy:p.yx;
			d+=e=length(p.xz)-B*.01;
		}
		else{
			d+=e=length(p)-B*.4;
		}
	}
	o.rgb=mix(o.rgb,vec3(9./i),.4)+gl;
	o.rb=((o.rb)*rot(time+o.a*3.14))*.5+.5;
	o.rb+=(9./i);
	//o.r=o.a;
}