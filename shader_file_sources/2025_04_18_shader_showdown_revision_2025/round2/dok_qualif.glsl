#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
#define time fGlobalTime
const float bpm=148/60;
vec4 s=time*bpm/vec4(1,4,8,16),t=fract(s);

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

const float pi = acos(-1);
#define r2(a) mat2(cos(a),-sin(a),sin(a),cos(a))

// hello revision ppl

vec2 m2(vec2 dm, float m, float d){
	if (d<dm.x)dm=vec2(d,m);
	return dm;
}

float
sdb(vec3 p, vec3 e)
{
	p = abs(p)-e;
	return length(max(p,0));
}

vec2 map(vec3 p)
{

	vec2 dm = vec2(1e9,0);
	float d;
	{
		vec3 q = p;
		q-= clamp(round(q/4)*4,-10,10);
		d = length(q)-.5;
		dm=m2(dm,1,d);
	}
	{
		vec3 q = p;
		q.xz=abs(q.xz);
		q.xz-=10;
		
		q.xz *= r2(pow(t.x,.45));		
// 		q-= clamp(round(q/10)*10,-20,20);
		
		d = sdb(q, vec3(1));
		dm=m2(dm,2,d);
	}

	return dm;
}

vec3 nrm(vec3 p)
{
	float h=1e-3;
	vec2 e=vec2(-1,1);
	return normalize(e.xyy*map(p+e.xyy*h).x+
	e.yxy*map(p+e.yxy*h).x+
	e.yyx*map(p+e.yyx*h).x+
	e.xxx*map(p+e.xxx*h).x
	);
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec3 col = vec3(0);
	float fv = .5;
	vec3 ro = vec3(0,0,mix(10,20,.5+.5*sin(t.w*pi)));
	ro.xz *= r2(time);
	ro.yz*=r2(t.w*pi);
	vec3 cf = normalize(-ro),
	cs = normalize(cross(cf,vec3(0,1,0))),
	cu = normalize(cross(cs, cf)),
	rd = mat3(cs,cu,cf)*normalize(vec3(uv, fv));
	float d=0,i;
	vec2 r=vec2(0);
	vec3 p,n;
	float h=4;
	for (i=100;i-->0;)
	{
		p = ro+rd*d;
		r = map(p);
		d+=r.x;
		n = nrm(p);
		if(r.x<1e-3&&r.y==2&&h-->0) {
			rd=  reflect(n,rd);
			ro = p;
			d=0;
			continue;
		}
		if (d>1e3||r.x<1e-3)break;

	}
	if (r.y==1) 
	{
		col.r = fract((1-i/100)*10);
		col.r = pow(col.r,mix(1.,10.,t.x));
	}
	
	col.rgb = col.rrr;
	
	vec3 pre= texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).rgb;
	col=mix(pre,col,max(mix(.1,.4+t.x*.10,col.r),0));
	//if (step(.75,t.x*4)>.95)col=1-col;
//	if (step(.75,t.x*4)>.95)col=1-col;
	if(abs(uv.y)>mix(.5,.4,t.y))col-=col;
	
	out_color = vec4(col,1);
}