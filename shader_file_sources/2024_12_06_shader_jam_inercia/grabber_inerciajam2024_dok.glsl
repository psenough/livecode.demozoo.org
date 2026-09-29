#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
const float bps = 135./60.;
vec4 s=bps*time/vec4(1,4,16,64), t=fract(s);
const float pi = asin(-1);
#define r2(a) mat2(cos(a),-sin(a),sin(a),cos(a))




// greetings to cookie collective
// thanks to the Inercia party orga :)
// one should not chase the electric dream
// this is not #unix_surrealism btw
// ...
// prahou... guess what !?
// you're cute






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
vec4 tex(sampler2D s, vec2 uv, float r) {
	vec2 size = textureSize(s, 0);
	uv *= vec2(1,-1*(size.x/size.y));
	uv = clamp(uv,0,r);
	return texture(s, uv);
}

float sdb(vec3 p, vec3 e)
{
	p=abs(p)-e;
	return length(max(p,0.));//+min(max(p.x,max(p.y,.p.z)),0));
}

float min2(inout float tm, inout float m, float f, float t)
{
	if (f < m) {
		tm = t;
		m = f;
		return m;
	}
	return m;
}

vec2 map(vec3 p)
{
	float d=1e9;
	float ty= 2;
	{
		vec3 q = p;
		vec2 id;
	q=p;
	q.xz -= id = clamp(round(p.xz),-10,10);
	q.x += 0.25 * sin(t.x+id.x);
	q.y += 0.25 * sin(t.x+id.y+4);
	q.y += 10 * fract(-t.w*abs(id.x*id.y));
		min2(ty,d,length(q)-.01,1);
	}
	
	{
		vec3 q =p;
		q.yz = abs(q.yz);
		q.xz *= r2(s.y+pow(t.z,4));
		q.yz = abs(q.yz);
		q.yz *= r2(s.y+pow(t.y,3));
		q.yz = abs(q.yz);
		q.yxz += 0.02*sin(q.x*5)*sin(q.y*5)*sin(q.z*5);
		q.yxz += 0.01*sin(q.x*10+s.w)*sin(q.y*10+s.w)*sin(q.z*10+s.w);
		
		min2(ty,d,sdb(q,vec3(.5))-.1,2);
	}

	{
		vec3 q =p;
		q.xz *= r2(pi*t.y);
		q.xz -= clamp(round(q.xz),-1,1);
		q.y+=asin(sin(2*pi*t.z));
		min2(ty,d,sdb(q,vec3(.125)),1);
	}
	

	return vec2(d,ty);
}

vec3 nrm(vec3 p) {
        vec2 e=vec2(5e-4,-5e-4);
	float tt;
        return normalize(
                e.xyy*map(p+e.xyy).x+
                e.yyx*map(p+e.yyx).x+
                e.yxy*map(p+e.yxy).x+
                e.xxx*map(p+e.xxx).x
                );
}


vec3 rm(vec3 ro, vec3 rd)
{
	vec3 col = vec3(1);
	float N=130.;
	float f,i,r,d,h;
	vec3 n, p;
	float ty;
	float tint=1;
	r=h=f=0.;
	for(i=0;i<N;i++) {
		p=ro+r*rd;
		ty=1;
		vec2 rr = map(p);
		d=rr.x;
		ty=rr.y;
		if (abs(ty-2)<0.1&&d<1e-3&&h<20) {
			n=nrm(p);
			ro=p+d*rd;
			rd=reflect(rd,n);
			f+=r+d;
			r=5e-3;
			tint*=.8;
			h++;
			continue;
		}
		r+=d*.9;
		if(r>1000||d<1e-4)break;
		
	}
	f+=r;
	tint = exp(tint*tint-0.001);
	col = mix(vec3(0),col*tint,exp(f*f*f*-.01));
	col = pow(col.rgb,vec3(mix(.1,.3,t.x)));
	col += pow(0.1*i/N,0.75);
	return clamp(col,0,1);
}
void main(void)
{
	vec2 uv = (gl_FragCoord.xy - .5 * v2Resolution) / min(v2Resolution.x,v2Resolution.y);
	vec3 col = vec3(0);
	vec3 ro = vec3(2*cos(s.z),2.1,2*sin(s.z));
	float fv = 0.5;
	if (t.w > .5) 
	{
		ro = vec3(2*cos(2*pi*t.y),2*sin(2*pi*t.y),2);
		fv = .9;
	}
	vec3 cf = normalize(-ro),
	cs=normalize(cross(cf,vec3(0,1,0))),
	cu=normalize(cross(cs,cf)),
	rd=mat3(cs,cu,cf)*normalize(vec3(uv,fv));
	col = rm(ro,rd);
//	vec4 it = tex(texInerciaLogo2024,8*uv+vec2(.5,2.0)+0.1*sin(uv.y+s.x)*cos(uv.x+s.y), 1);
//	col = mix(col, it.rgb, smoothstep(0.,.4,dot(vec3(1),it.rgb)));
	out_color = vec4(col, 1);
}