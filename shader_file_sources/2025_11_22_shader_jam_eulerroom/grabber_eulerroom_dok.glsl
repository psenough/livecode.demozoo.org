#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define time fGlobalTime

float sd_box(vec3 p, vec3 e)
{
	p = abs(p)-e;
	return length(max(p,0)) + min(0,max(p.x,max(p.y,p.z)));
}

const float bpm=142/60;
vec4 s = time*bpm/vec4(1,4,8,16),t=fract(s);
#define r2(a) mat2(cos(a),-sin(a),sin(a),cos(a))
const float pi = acos(-1);
#define sin2(x)  (.5+.5*sin(x))

uint hash(uint x){
	const uint c = int((1.-sqrt(5)/2)*-1u)|1;
	x ^= x >> 16;
	x *= c;
	x ^= x >> 15;
	x *= c;
	x ^= x >> 16;
	return x;
}

uint rnd(ivec3 p)
{
	return hash(hash(hash(p.x)+p.y)+p.z);
}

float rnd(vec2 p)
{
	return hash(floatBitsToUint(p.y)+hash(floatBitsToUint(p.x)))/float(-1u);
}

vec3 rnd3(float v)
{
	uint x = hash(floatBitsToUint(v));
	uint y = hash(x+floatBitsToUint(v));
	uint z = hash(y+floatBitsToUint(v));
	return vec3(x,y,z)/float(-1u);
}
uint seed = 1;
float rnd(float x)
{
	return rnd(ivec3(seed+++floatBitsToUint(x), gl_FragCoord.xy))/float(-1u);
}
vec3 rndunit(float x) {
	return normalize(tan(rnd3(x)*2.-1.));
}
vec3 erot(vec3 p, vec3 x, float a)
{
	return mix(dot(x,p)*x,p, cos(a))+cross(x,p)*sin(a);
}

vec2 sdf(vec3 p) {
	vec2 r=vec2(1e9,0);
	{
		float d;
		vec3 q = p;

		q = erot(q, normalize(vec3(1,1,0)), pi*(floor(s.x/2.0)+pow(fract(s.x/2.0),.5)));
		q.xz *= r2(pi*s.w);
		q.xz -= clamp(round(q.xz/4),-2,2)*4;

		q.y = abs(q.y)-2.;
		q.xz *= r2(q.y*pi*mix(0.1,0.25,t.z));

		q.xy *= r2(0.125*pi);
		q.zy *= r2(-0.15*pi);

		float dy= 20*pow(t.y,.5);
		d = sd_box(q,vec3(.5,4.*t.x,.5));
		if (d < r.x) { r.x = d; r.y = 1; }
	}
	if (false)
	{
		vec3 q = p.yxz;
		float d = 1e9;
		
		q = erot(q, normalize(vec3(1,1,0)), pi*(floor(s.x/2.0)+pow(fract(s.x/2.0),.5)));
		q.xz *= r2(pi*s.w);

		q.y = abs(q.y)-2.;
		q.xz *= r2(q.y*pi*mix(0.1,0.25,t.z));

		q.xy *= r2(0.5*pi);
		d = sd_box(q,vec3(.2,10.,.2));
		if (d < r.x) { r.x = d; r.y = 2; }
	}
	return r;
}

vec3 nrm(vec3 p)
{
	vec2 e = vec2(1,-1);
	float h = 5e-3;
	return normalize(
	e.xyy*sdf(p+e.xyy*h).x+
	e.yxy*sdf(p+e.yxy*h).x+
	e.yyx*sdf(p+e.yyx*h).x+
	e.xxx*sdf(p+e.xxx*h).x
	);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 tv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec3 col = vec3(0);
	float fv = .5;
	vec3 at = vec3(0,0,0);
	vec3 ro = vec3(0,0,4);

	fv = mix(0.1,0.5,pow(t.y,0.25));
	fv += pow(t.x,.4)*0.2;
	vec3 cz = normalize(at-ro),
	cx=normalize(cross(cz,vec3(0,1,0))),
	cy=normalize(cross(cz,cx)),rd;
	float j,i,h, d, r;
	vec3 p;
	float si = 1;
	vec3 _ro = ro;

	for (j=0;j<2;j++) {
		rd=mat3(cx,cy,cz)*normalize(vec3(uv+.001*vec2(rnd(j+time),rnd(j-time)),fv));
		ro=_ro;
	for (i=0,r=0,h=4; i<64; i++) {
		p = rd*r+ro;
		vec2 rr = sdf(p);
		rr.x *= (1.-rnd(time)*.2);
		r+=d=rr.x*.9;
		if (d<1e-3 && rr.y ==1 && h-->0){
			vec3 n = nrm(p=rd*r+ro);
			rd = mix(reflect(rd, -n), rndunit(p.x+p.y+p.z),.03);
			ro = p + .1*n;
			r = 0;
			continue;
		}
		if (d<1e-3 ||r>1e3)break;
	}
	col.r += i/64;
	}
	col.r = pow(col.r/j + (rnd(time)+rnd(time))/64., 1.2);
	col.r = pow(col.r,mix(2.,1.5,t.x));
	col.rgb = col.rrr;

	{
		vec3 pre = texture(texPreviousFrame, .5+(tv-.5)*.99).rgb;
		col = mix(pre, col, .99*pow(t.x,.5));
	}

	{
		vec2 id = floor(tv*100.0);
		vec3 pre = texture(texPreviousFrame, .5+(id/100.0-.5)).rgb;
		col = mix(pre, col, step(0.2,rnd(id.x+rnd(id.y))));
	}

	out_color = vec4(col, 1);
}

