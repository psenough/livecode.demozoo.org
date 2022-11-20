#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI=acos(-1);
vec4 D=vec4(99.);
float e,ee,eee;



#define t fGlobalTime
#define tt 0//int(fGlobalTime*.2)%2
#define Z 222
#define I 222
#define V(a,b,c) mix(clamp(abs(fract(a+vec3(1,2,3)/3)*6-3)-1,0,1),vec3(1),b)*c
#define S(a,b,c) -log(exp(-c*a)+exp(-c*b))/c
#define W(a,b) cos(b)*a+sin(b)*vec2(-a.y,a.x)
#define C(a,b) max(max(abs(a.x)-b.x,abs(a.y)-b.y),abs(a.z)-b.z)
#define B(a,b) (length(a)-b)



float M(vec3 p)
{

if(tt==0)
{

//11111111111111111111111111111111111111

	float
		a=1,
		b=.5,
		c=2
	;

	vec3 pp=vec3(mod(p.xy+6,12)-6,p.z);
	
	pp.x+=sin(t*.7-e*2.57+p.z*.43)+sin(t*.4-e*3.64+p.z*.17)+sin(t*.4+e*4.57+p.z*.43);
	pp.y+=sin(t*.6+e*2.75+p.z*.33)+sin(t*.5+e*3.79+p.z*.31)+sin(t*.8-e*4.30+p.z*.33);
	
	pp.xy=W(pp.xy,PI*sin(t+e*.05+p.z*.03));
	
	D.y=
		S(
			C(pp,vec3(1,.2,10000000)),
			C(pp,vec3(.2,1,10000000)),
			3
		)
	;

	p=mod(p,12)-6;
	
	D.x=
		S(
			S(
				min(
					C(p,vec3(a,a,100000000)),
					C(p,vec3(b,c,100000000))
				),
				min(
					C(p,vec3(a,10000000,a)),
					C(p,vec3(b,10000000,c))
				),
				1
			),
				min(
					C(p,vec3(100000000,a,a)),
					C(p,vec3(100000000,c,b))
				),
			1
		)
	;
}
// 2222222222222222222222222222222222222222222
else
if(tt==1)
{
	vec3 ppp=p;

//	ppp.xz=W(ppp.xz,t*.3+e*.3);
//	ppp.yz=W(ppp.yz,t*.4+e*.5);
	
//	vec3 pp=p;
	vec3 pp=mod(p+6,12)-6;
	p=mod(p,12)-6;

	D.x=
//		(int(pp.x/12)+int(pp.y/12)+int(pp.z/12))%2==0
		max(
			B(p,3),
			-C(p,vec3(1,1,1))
		);

	D.y=
		max(
			C(pp,vec3(2,2,2)),
			-B(pp,1.5)
		)
	;
	
}
//3333333333333333333333333333333333333333333333333
else
if(tt==2)
{
	p.x+=3*sin((p.z/6)*.3+t*.7+e*.33);
	p.y+=3*cos((p.z/6)*.4+t*.5+e*.55);

	p.z=mod(p.z,12)-6;

	D.y=
		max(
			C(p,vec3(19,19,1)),
			-C(p,vec3(9,9,10002))
		);
}

return
min(
	D.x,
	D.y
)
;
}



void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);


e = texture( texFFTIntegrated, .007 ).r;
ee = texture( texFFTSmoothed, .4 ).r * 100;
ee = texture( texFFT, .4 ).r * 100;

int i=0,j=1;
float d,z,f,ccc=1;

vec3
	r=normalize(vec3(uv,1)),
	c=vec3(0,0,0),
	p=vec3(4*sin(t+e*.1),4*cos(t+e*.1),t*5+e*3),
	l=vec3(.5,.7,-1),
	ll=vec3(-.5,-.7,-1),
	q=p,
	n
;

f=sign(M(p));

r.xz=W(r.xz,.7*sin(t*.7+e*.47));
r.yz=W(r.yz,.7*cos(t*.8+e*.25));
r.xy=W(r.xy,.7*sin(t*.5+e*.33));

while(++i<I&&z<Z)
{
	d=f*M(p);
	p+=d*r;
	z=length(p-q);
	


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
					?V(t*.1,.5,.01)
					:V(t*.1+(floor((p.x+6)/12)+floor((p.y+6)/12))*.17878,.2,1+ee)
			)
			*mix(clamp(dot(n,l),0,1),clamp(dot(n,ll),0,1),.5)
			+pow(clamp(dot(n,normalize(l-r)),0,1),99)*V(.6,.5,1)
			+pow(clamp(dot(n,normalize(ll-r)),0,1),333)*V(.1,.5,1)
		)
		*(1-z/Z)
		*ccc
	;

if(++j>5)break;
	
//if(D.x<D.y)
//{
	f=-f;
	r=refract(r,n,.57);
	p+=r;
/*}
else
{
	r=reflect(r,n);
	p+=r*.02;
	ccc=.1;
}*/
}
}


c=mix(c,pow(c,vec3(9)),.5);

out_color = vec4(pow(mix(c,V(t*.1+.5,.5,.15),z/Z),vec3(.45)),1)*(1-pow(dot(uv,uv),3));
}