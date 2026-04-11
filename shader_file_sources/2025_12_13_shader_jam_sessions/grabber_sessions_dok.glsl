#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define r2(a) mat2(cos(a),-sin(a),sin(a),cos(a))
const float bpm=142/60.;
const float pi=acos(-1);
vec4 s=time*bpm/vec4(1,4,8,32),t=fract(s);

vec4 tex(sampler2D t, vec2 uv)
{
	vec2 s = textureSize(t, 0);
	return texture(t, uv*vec2(1,s.x/s.y));
}

float sdb(vec3 p, vec3 e)
{
	p = abs(p) - e;
	return length(max(p,0))+min(0,max(p.x,max(p.y,p.z)));
}

vec3 erot(vec3 p, vec3 x, float a)
{
	return mix(dot(x,p)*x,p,sin(a))+cross(x,p)*cos(a);
}

int hashi(int x){
	const int c = int((1.-(sqrt(5)/2.))*-1u)|1;
	x^= x>>16;
	x *= c;
	x^=x>>15;
	x *= c;
	x^= x>>16;
	return x;
}

float hashf(vec4 p){
	int x;
	x = hashi(floatBitsToInt(p.w));
	x = hashi(x+floatBitsToInt(p.z));
	x = hashi(x+floatBitsToInt(p.y));
	x = hashi(x+floatBitsToInt(p.x));
	return x / float(-1u);
}

float map(vec3 p)
{
	float d = 1e9;
	{
		vec3 q = p;
		q.xz -= clamp(round(q.xz/8),-2,2)*8;
		q.z = abs(q.z);
		q = erot(q, normalize(vec3(.8,.1,0)), (pow(t.w,.8)+floor(s.w))*pi*2);
		q.y = abs(q.y)-.5;
		q = erot(q, normalize(vec3(cos(s.x),0,sin(s.x))), (pow(t.z,.5)+floor(s.z))*pi*2);
		q.x -= sin(q.y*0.2+time);
		q.xz *= r2((pow(t.y,0.5)+floor(s.y))*pi*2+q.y*0.1);
		d = sdb(q, vec3(.5,10,.5));
	}
	return d;
}
vec3 nrm(vec3 p)
{
	float h = 5e-3;
	vec2 e=vec2(-1,1);
	return normalize(
	e.xyy*map(p+e.xyy*h)+
	e.yxy*map(p+e.yxy*h)+
	e.yyx*map(p+e.yyx*h)+
	e.xxx*map(p+e.xxx*h));
}

float seed= 1;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	vec2 tv = uv;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec3 col = vec3(0);
	
	vec3 at = vec3(0,2,0);
	vec3 ro = vec3(0,10,10);

		ro = vec3(0,10,10);
	if (fract(s.w/3.) >.25)
		ro = vec3(0,1,10);
	if (fract(s.w/3.) >.50)
		ro = vec3(0,20,25);
	if (fract(s.w/3.) >.75) {
		ro = vec3(10,-5,0);
		}
	
	ro.xz *= r2(t.z);
	float fv = .85;
	fv += 0.2*pow(t.x,.1);
	vec3 cz = normalize(at-ro),
	cx = normalize(cross(cz,vec3(0,1,0))),
	cy = normalize(cross(cx,cz));
	vec3 rd = mat3(cx,cy,cz)*normalize(vec3(uv,fv));
	
	float r,h,i,j;
	float d;
	vec3 p;
	vec3 _ro;
	_ro = ro;
	col.r = 0;


	for (j=0;j<4;j++) {
		rd = mat3(cx,cy,cz)*normalize(vec3(uv+
		pow(t.z,1.5)*0.05*(0.5-
		vec2(hashf(vec4(gl_FragCoord.xy,seed++,time)),hashf(vec4(gl_FragCoord.xy,seed++,time)))
		)
		,fv));
		ro = _ro;
	for (i=0,h=10,r=0;i<100;i++) {
		p = ro+r*rd;
		d = map(p);
		r+=d*(1.+0.2*(.5-hashf(vec4(gl_FragCoord.xy,seed++,time))));
		if (d<1e-4&&h-->0) {
			p = ro+r*rd;
			vec3 n = nrm(p);
			rd = reflect(rd,n);
			ro=p+n*0.1;
			r=0;
			continue;
		}
		if (d<1e-4||r>1e4)break;
	}
	col.r += i/100;
	}
	col.r /= j;
	col.r += hashf(vec4(gl_FragCoord.xy,seed++,time))*0.01;
	col.r = pow(col.r*2,1.5);
	col.r = pow(col.r,1.5);
	col = col.rrr;

	if (fract(t.w*2)>.5) {
		vec2 uu = .5+clamp(0.5+(tv*vec2(1,-1)),0.,0.1234);
		if (fract(t.y*2)>.25)
			uu= .5+clamp((tv*vec2(1,-1)),-0.,0.25);
		if (fract(t.y*2)>.5)
			uu= .5+clamp(.5-(tv*vec2(1,-1)),0.25,0.5);
		if (fract(t.y*2)>.75)
			uu= .5+clamp((tv*vec2(1,-1)),-1.,0.5);

		vec4 tt = tex(texSessions, uu);
		col += tt.rgb * tt.a * pow(fract(t.x),.5);
	}

	if (t.w>.7) {
		vec3 pre = texture(texPreviousFrame, .5+(tv*.99)).rgb;
		col = mix(pre,col,(4.-pre.r)*pow(t.x,.5));
	}
	
	{
		vec3 pre = texture(texPreviousFrame, .5+(tv*.9)).rgb;
		col = mix(pre,col,mix(.3,.9,pow(t.y,0.76)));
	}
	col.r = pow(col.r,mix(1.0,1.8,t.w));
	col.g = pow(col.g,mix(1.1,1.2,t.z));
	col.b = pow(col.b,mix(1.0,1.6,t.w));
	
	out_color = vec4(col, 1);
}