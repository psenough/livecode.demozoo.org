#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI=acos(-1);
float e,ee,eee;
vec4 D=vec4(99);

#define t fGlobalTime
#define Z 166
#define I 133

#define V(a,b,c) mix(clamp(abs(fract(a+vec3(1,2,3)/3)*6-3)-1,0,1),vec3(1),b)*c
#define S(a,b,c) -log(exp(-c*a)+exp(-c*b))/c
#define W(a,b) cos(b)*a+sin(b)*vec2(-a.y,a.x)
#define B(a,b) (length(a)-b)
#define C(a,b) max(max(a.x-b.x,a.y-b.y),a.z-b.z)
#define F(a,b) (a.x+a.y+a.z-b)/3
#define E(a,b,c) max(length(a.xy)-b,a.z-c)
#define H(a,b,c) max(max(a.x*.5+a.y,a.x+a.y*.5)-b,a.z-c)


vec2 Y(vec2 p, float b)
{
	vec2 a=W(p,-PI/(b*2));
return W(p,floor(atan(a.x,a.y)/PI*b)*(PI/b));
}







float M(vec3 p)
{
	float a=length(p)*.05;
	
	D.y=-B(p,17+sin(p.x+t*.1+e*.3)+cos(p.y+t*.13+e*.23)+sin(p.z+t*.16+e*.27));

	D.x=B(p,2);

	p.xz=W(p.xz,PI*sin(t*.1+e*.3-a));
	p.yz=W(p.yz,PI*cos(t*.13+e*.23-a));
	p.xy=W(p.xy,PI*sin(t*.16+e*.27-a));
	
	p.xz=Y(p.xz,3+2*sin(t*.1+e*.3));
	p.yz=Y(p.yz,3+2*cos(t*.1+e*.3));

	D.x=
			S(
				S(
					S(
						D.x,
						E(abs(p),.1,5),
						7
					),
					H(abs(p-vec3(0,0,5)),.2,.2),
					3
				),
				F(abs(p-vec3(0,0,6)),.75),
				3
			)
	;
	
	
	
return .5*
min(
	D.x,
	D.y
)
;
}






//#####################################################################







float M2(vec3 p)
{
	float
		a=floor(p.z/20),
		b=-E(abs(p),17,100000000),
		c=H(abs(p),1,100000000)
	;
	
	D.x=c;
	
	
	p.xy=W(p.xy,PI*sin(t*.16+e*.5-a*1.7-length(p.xy)*.05));
	
	p.xy=Y(p.xy,3+.5*floor(4*sin(a*1.7)));

	p.z=mod(p.z,20)-10;
	
	D.x=
			S(
				S(
					S(
						D.x,
						H(abs(p),3,1),
						1
					),
					H(abs(p.zxy),.8,17),
					3
				),
				b,
				.5
			)
	;
	
	
	
return .4*
	D.x
;
}








//#####################################################################







float M3(vec3 p)
{
	D.x=B(p,2);
	
	p.xz=W(p.xz,PI*sin(t*.16+e*.5-length(p.xy)*.02));
	p.yz=W(p.yz,PI*cos(t*.13+e*.4-length(p.xy)*.02));
	p.xy=W(p.xy,PI*sin(t*.17+e*.3-length(p.xy)*.02));
	
	p.xz=Y(p.xz,4);
	p.yz=Y(p.yz,4);

	D.x=
			S(
				S(
					D.x,
					H(abs(p.xyz),.3-.2*sin(length(p)*1.5+t+e*7),17),
					3
				),
				-C(abs(p),vec3(19,19,19)),
//				-B(p,19),
				.5
			)
	;
	
	
	
return .4*
	D.x
;
}




//#####################################################################







float M4(vec3 p)
{

	D.x=F(abs(p),2);
	
	p.xz=W(p.xz,PI*sin(t*.16+e*.15-length(p.xy)*.03));
	p.yz=W(p.yz,PI*cos(t*.13+e*.14-length(p.xy)*.03));
	p.xy=W(p.xy,PI*sin(t*.17+e*.13-length(p.xy)*.03));
	
	p.xz=Y(p.xz,8);
	p.yz=Y(p.yz,8);

	D.x=
		S(
			S(
				S(
					D.x,
					E(abs(p.xyz),.01-.005*sin(length(p)*.1+t+e*7),17),
					9
				),
//				-C(abs(p),vec3(19,19,19)),
				-B(p,19),
				.5
			),
//			B(p-vec3(0,0,mod(t*9+atan(p.x,p.y),19)),.3),
//			B(p-vec3(0,0,mod(t*9,19)),.3),
			B(abs(p-vec3(0,0,mod(t*7,19))),.1),
			3
		)
	;
	
	
	
return .4*
	D.x
;
}











//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

e = texture( texFFTIntegrated, .007 ).r*.5;
ee = texture( texFFTSmoothed, .4 ).r * 100;
eee = texture( texFFT, .4 ).r * 100;

int i=0,j=1;

float d,z,f,g=0,
	tt=mod(e,16),
//	T=mod(t,8)
	T=mod(t,16)
//	T=13
;

vec3 c=vec3(0);



if(T<4)
{
vec3
	r=normalize(vec3(uv,1)),
	p=vec3(0,0,-11+5*sin(t*.1+e*.3)),
	l=vec3(.7,.5,-1),
	ll=vec3(-.7,-.5,-1),
	q=p,
	n
;

p+=r;

r.xz=W(r.xz,.5*sin(t*.1+e*.5));
r.yz=W(r.yz,.3*cos(t*.13+e*.4));



f=sign(M(p));

while(++i<I&&z<Z)
{
//	d=f*M(p);
	p+=d*r*j;
	p+=d*r;
	z=length(p-q);
	
	g+=exp(-d);
	
if(d<.01)
{
	n=f*normalize(vec3(
		M(vec3(p.x+.01,p.y,p.z)),
		M(vec3(p.x,p.y+.01,p.z)),
		M(vec3(p.x,p.y,p.z+.01))
	)-M(p));



	c+=
		(
			(
				D.x<D.y
//					?V(e*.1,.2,.3)
					?mix(V(e*.1,-.2,.6),V(e*.1+.5,.2,.4),length(p)*.2)
					:V(e*.1+.5,.2,.1)
			)
			*mix(clamp(dot(n,l),0,1),clamp(dot(n,ll),0,1),.5)
			+pow(clamp(dot(normalize(l-r),n),0,1),222)*V(.6,.5,1)
			+pow(clamp(dot(normalize(ll-r),n),0,1),222)*V(.85,.5,1)
		)
		*(1-z/Z)
	;
	
	

	
	
	
if(++j>5)break;

	f=-f;
//	r=refract(r,n,.57);
	r=refract(r,n,.7);
	p+=r;
}
}


}
else
if(T<8)
{

//----------------------------------------------------------------------------------

float a=(tt<8?10:27)+5*sin(t*.1+e*.3);
//float a=10+5*sin(t*.1+e*.3);

vec3
	r=normalize(vec3(uv,1)),
	p=vec3(
		a*sin(t*.1+e*.3),
		a*cos(t*.1+e*.3),
		t*3+e*6
	),
	l=vec3(.7,.5,-1),
	ll=vec3(-.7,-.5,-1),
	q=p,
	n
;

p+=3*r;

r.xz=W(r.xz,sin(t*.1+e*.3));
r.yz=W(r.yz,cos(t*.1+e*.3));



f=sign(M2(p));

while(++i<I&&z<Z)
{
	d=f*M2(p);
//	p+=d*r;
	p+=d*r*j;
	z=length(p-q);
	
	g+=exp(-d);
	
if(d<.01)
{
	n=f*normalize(vec3(
		M2(vec3(p.x+.01,p.y,p.z)),
		M2(vec3(p.x,p.y+.01,p.z)),
		M2(vec3(p.x,p.y,p.z+.01))
	)-M2(p));



	c+=
		(
			(
					mix(V(p.z*.005,-.1,.5),V(p.z*.005+.5,.5,.3),length(p.xy)*.1)
			)
			*mix(clamp(dot(n,l),0,1),clamp(dot(n,ll),0,1),.5)
			+pow(clamp(dot(normalize(l-r),n),0,1),222)*V(.6,.5,1)
			+pow(clamp(dot(normalize(ll-r),n),0,1),222)*V(.85,.5,1)
		)
		*(1-z/Z)
	;
	
	

	
	
	
if(++j>5)break;

	f=-f;
//	r=refract(r,n,.57);
	r=refract(r,n,.7);
	p+=r;
}
}


}
else
if(T<12)
{

//----------------------------------------------------------------------------------

float a=(tt<8?10:33)+5*sin(t*.3+e*.7);
//float a=10+5*sin(t*.1+e*.3);

vec3
	r=normalize(vec3(uv,1)),
	p=vec3(
		0,
		0,
		-a
	),
	l=vec3(.7,.5,-1),
	ll=vec3(-.7,-.5,-1),
	q=p,
	n
;

p+=r;

r.xz=W(r.xz,.5*sin(t*.1+e*.17));
r.yz=W(r.yz,.3*cos(t*.13+e*.13));



f=sign(M3(p));

while(++i<I&&z<Z)
{
	d=f*M3(p);
//	p+=d*r;
	p+=d*r*j;
	z=length(p-q);
	
	g+=exp(-d);
	
if(d<.01)
{
	n=f*normalize(vec3(
		M3(vec3(p.x+.01,p.y,p.z)),
		M3(vec3(p.x,p.y+.01,p.z)),
		M3(vec3(p.x,p.y,p.z+.01))
	)-M3(p));



	c+=
		(
			(
				mix(V(e*.1,-.1,.5),V(e*.1+.5,.5,.3),length(p.xy)*.05)
			)
			*mix(clamp(dot(n,l),0,1),clamp(dot(n,ll),0,1),.5)
			+pow(clamp(dot(normalize(l-r),n),0,1),222)*V(.6,.5,1)
			+pow(clamp(dot(normalize(ll-r),n),0,1),222)*V(.85,.5,1)
		)
		*(1-z/Z)
	;
	
	

	
	
	
if(++j>5)break;

	f=-f;
//	r=refract(r,n,.57);
	r=refract(r,n,.7);
	p+=r;
}
}


}

else
//if(T<12)
{

//----------------------------------------------------------------------------------














//float a=(tt<8?10:33)+5*sin(t*.3+e*.7);
float a=10+5*sin(t*.1+e*.3);

vec3
	r=normalize(vec3(uv,1)),
	p=vec3(
		0,
		0,
		-a
	),
	l=vec3(.7,.5,-1),
	ll=vec3(-.7,-.5,-1),
	q=p,
	n
;

p+=r;

r.xz=W(r.xz,.5*sin(t*.1+e*.17));
r.yz=W(r.yz,.3*cos(t*.13+e*.13));



f=sign(M4(p));

while(++i<I&&z<Z)
{
	d=f*M4(p);
//	p+=d*r;
	p+=d*r*j;
	z=length(p-q);
	
	g+=exp(-d);
	
if(d<.01)
{
	n=f*normalize(vec3(
		M4(vec3(p.x+.01,p.y,p.z)),
		M4(vec3(p.x,p.y+.01,p.z)),
		M4(vec3(p.x,p.y,p.z+.01))
	)-M4(p));



	c+=
		(
			(
				mix(V(e*.1,-.1,.5),V(e*.1+.5,.5,.3),length(p.xy)*.1)
			)
			*mix(clamp(dot(n,l),0,1),clamp(dot(n,ll),0,1),.5)
			+pow(clamp(dot(normalize(l-r),n),0,1),222)*V(.6,.5,1)
			+pow(clamp(dot(normalize(ll-r),n),0,1),222)*V(.85,.5,1)
		)
		*(1-z/Z)
	;
	
	

	
	
	
if(++j>5)break;

	f=-f;
//	r=refract(r,n,.57);
	r=refract(r,n,.7);
	p+=r;
}
}


}













c=mix(c,pow(c,vec3(99)),.5);

c+=pow(g,2)*V(.1,.1,eee*.00025);


//out_color = vec4(pow(c,vec3(.45)),1);
//out_color = vec4(pow(c,vec3(.7)),1)*(1-pow(dot(uv,uv),3));
out_color = 
mix(
	1.5*vec4(pow(c,vec3(.7)),1)*(1-pow(dot(uv,uv),3)),
	texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution),
	.9
);


}