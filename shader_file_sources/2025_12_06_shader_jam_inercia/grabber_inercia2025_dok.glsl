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
const float pi = acos(-1);
float bpm=130/60.;
vec4 s = time*bpm/vec4(1,4,8,16), t=fract(s);
float
sdb(vec3 p, vec3 e)
{
	p=abs(p)-e;
	return length(max(p,0.0))+min(0.,max(p.x,max(p.y,p.z)));
}

uint
hashi(uint x)
{
	uint c = int((1.-(sqrt(5)/2.0))*-1u)|1;
	x ^= x >> 16;
	x *= c;
	x ^= x >> 15;
	x *= c;
	x ^= x >> 16;
	return x;
}

vec3 erot(vec3 p, vec3 x, float a)
{
	return mix(dot(p,x)*x,p,sin(a))+cross(p,x)*cos(a);
}
#define r2(a)mat2(cos(a),sin(a),sin(-a),cos(a))
float map(vec3 p) {
	float rd = 1e9;
	float d;
	{
		vec3 q = p;
		vec2 id;
		q.xz -= clamp(id = round(q.xz/2.),-10.,10.)*2.;
		float f;
		q.y -= f = sin((length(id)*0.4-time*pi));
		d = sdb(q, vec3(mix(.25,.5,f)));
		rd = min(rd, d); 
	}

	{
		vec3 q = p;
		vec2 id;
		q.xz -= clamp(id = round(q.xz/15.),-1.,1.)*15.0;
		q.y -= 5.0;
		q.xz = abs(q.xz)-.1;
		q = erot(q, normalize(vec3(1,1,0)),(pow(t.z,.25)+floor(s.z))*pi*2);
		q.x += sin(q.y*0.1)*0.5;
		q.yz = abs(q.yz)-.1;
		q = erot(q, normalize(vec3(.1,1,1)),(pow(t.w,.25)+floor(s.w))*pi);

		d = sdb(q, vec3(1.,mix(.1, 2.,pow(t.x,.5)),8.));
		rd = min(rd, d); 
	}

	
	return rd;
}

vec3 nrm(vec3 p)
{
	float h = 5e-3;
	vec2 e = vec2(1,-1);
	return normalize(
		map(p+e.xyy*h)*e.xyy+
		map(p+e.yxy*h)*e.yxy+
		map(p+e.yyx*h)*e.yyx+
		map(p+e.yyy*h)*e.yyy);
}

float seed = 1;
float rnd(vec4 p)
{
//	hashi(floatBitsToInt(gl_FragCoord.x))
	return hashi(floatBitsToInt(p.w)+hashi(floatBitsToInt(p.z)+hashi(floatBitsToInt(p.y)+hashi(floatBitsToInt(p.x))))) / float(-1u);
}

void main(void)
{
	vec2 tv;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	tv=uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec3 col = vec3(0);
	
	float i,d;
	float fv = .7;
	fv -= .2*pow(t.y,0.5);
	vec3 at = vec3(0,5,0);
	at.y *=sin(t.w*pi*2); 
	vec3 ro = vec3(0,6,12);
	ro.z = 8*cos(s.y);
	ro.x = 8*sin(s.y);
	vec3 cz = normalize(at-ro),
	cx=normalize(cross(cz, vec3(0,-1,0))),
	cy=normalize(cross(cz,cx));
	vec3 rd= mat3(cx,cy,cz)*normalize(vec3(uv,fv));
	vec3 p;
	float r =0,h, j;
	vec3 _ro = ro;
	for (j=0;j<4.;j++) {
		ro = _ro;
		rd=mat3(cx,cy,cz)*normalize(vec3(uv
		+pow(.5+.5*sin(t.z*2.*pi),1.5)*.0125*(.5-vec2(rnd(vec4(seed++,gl_FragCoord.xy,0)),rnd(vec4(seed++,gl_FragCoord.xy,0))))
		,fv));
	for (r=0,h=10,i=0;i<100;i++){ 
		p = rd*r+ro;
		float d = map(p);
		d *= 1.+mix(-1.,1.,rnd(vec4(seed++,gl_FragCoord.xy,0)))*0.2*t.x;
		r+=d*0.9;
		if (d<1e-3&&h-->0) {
			vec3 n = nrm(p);
			rd = reflect(rd,-n);
			ro=p+n*.1;
			r=0;
			continue;
		}
		if (d<1e-3||r>1e4)
			break;
	}
	col.r+=i/100.0;
	}
	col.r/=j;
	col.r+=rnd(vec4(seed++,gl_FragCoord.xy,0))/100.0;
	col.r=pow(col.r,1.8);
	col.r=pow(col.r,1.2);
	
	{
		vec3 pre = texture(texPreviousFrame, .5+((tv-.5)*.95)).rgb;
		col =mix(pre,col,mix(.8,1.,pow(1.-t.y,.5)));
	}
	col = col.rrr;
	
	out_color = vec4(col, 1);
}