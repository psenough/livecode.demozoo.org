#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
#define time fGlobalTime
uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void Add(ivec2 u, vec3 c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  imageAtomicAdd(computeTex[1], u,q.y);
  imageAtomicAdd(computeTex[2], u,q.z);
}
vec3 Read(ivec2 u){       //read pixel from compute texture
  return 0.001*vec3(      //unsquish int to float
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  );
}
vec2 m2(vec2 a, vec2 b) { return a.x < b.x ? a : b; }
float sdb(vec3 p, vec3 e){
	p = abs(p)-e;
	return length(max(p,0.))+min(max(max(p.x,p.y),p.z),0.);
}
#define r2(a) mat2(cos(a),-sin(a),sin(a),cos(a))
const float pi = acos(-1);
vec2 map(vec3 q)
{
	float d;
	vec2 r;
	{
		vec3 p = q;
		float s = texture(texFFTSmoothed, .01).r*.5;
		p -= clamp(round(p),-1.,1.);
		float e = mix(.1,1.5,s);
		float h = mix(.1,1.5,s)*2;
		p.xz*=r2(p.y+pow(.5+.5*sin(time),4));
		d = sdb(p,vec3(e,h,e));
		r=vec2(d,1);
	}
	{
		vec3 p = q;
		d=1e9;
		for (float i=0;i<2;i+=.2) {
			float a = i*pi+time;
			vec3 o = vec3(sin(a),0,cos(a))*2;
			o.xy*=r2(.25);
			o=p-o;
			o.yz*=r2(.12+a+time);
			d = min(d, sdb(o,vec3(.1)));
		}
		r = m2(r, vec2(d,2));
	}
	{
		vec3 p = q;
		p=abs(p);
		p.xy-=2;
		p.xy*=r2(0.5);
		d=sdb(p, vec3(1,.1,1));
		r = m2(r, vec2(d,3));
	}
	return r;
}
vec3 nrm(vec3 p) {
	vec2 e=vec2(1e-4,0);
	return normalize(vec3(map(p+e.xyy).x-map(p-e.xyy).x,
	map(p+e.yxy).x-map(p-e.yxy).x,
	map(p+e.yyx).x-map(p-e.yyx).x
	));
}
vec4 raym(vec3 rd, vec3 ro, out float om) {
	float i,d,r=0,N=42;
	vec3 col = vec3(1);
	float s = sign(map(ro+rd*r).x);
	float m;
	for (r=i=0; i<N;i++) {
		vec3 p = ro+rd*r;
		vec2 rr = map(p);
		d = rr.x*s;
		m = rr.y;
		if (d>0.)r+=d;
		if (d<1e-4&&m==1.0) {
			p = ro+rd*r;
			vec3 n = nrm(p);
			ro = ro+rd*r;
			rd = refract(rd,n,1.-.1*s);
			r=1e-4;
			s=-s;
			continue;
		}
		if (d<1e-4&&m==2.0) {
			p = ro+rd*r;
			vec3 n = nrm(p);
			ro = ro+rd*r;
			rd = reflect(rd,n);
			r=1e-4;
			continue;
		}

		if (d<1e-4||r>1e5)break;
	}
	om = m;
	return vec4(ro+rd*r,r);
}
float gt(vec2 uv) {
	uv*=r2(pi*.25);
	uv=abs(uv);
	return max(uv.x,uv.y);
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution.xy) / v2Resolution.y;
	vec3 col = vec3(1);
	float bps= 123/60.;
	float s = time/bps;
	float t = fract(s/16);
	float fv = .75;
	vec3 ro = vec3(.5+0.5*cos(time),.5+.5*sin(time),2.5);
	if (t>.5)
		ro = vec3(.5+0.5*cos(time),5+pow(.5+.5*sin(time),4),2.5);
	if (t>.75)
	{ ro = vec3(4+cos(time),1,2.5); fv = mix(.75, .2, pow(t,4)); }
	vec3 cf = normalize(-ro),
	cl=normalize(cross(cf,vec3(0,1,0))),
	cu=normalize(cross(cf,cl)),
	rd=mat3(cl,cu,cf)*normalize(vec3(uv,
	.75));
	float m;
	vec4 p = raym(rd,ro, m);
	if (p.w<1e4) {
		if (m < 3) {
			col *= max(0, dot(nrm(p.xyz),-vec3(0,1,0)));
		}
	} else {
		col *=0;
	}

	col = mix(col, 1-col, step(.5,fract(gt(uv*1.5)-time*.1)));

	out_color = vec4(mix(col,texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy).xyz,.2), 1);
}