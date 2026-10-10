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
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

#define time fGlobalTime

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


float sdb(vec3 p, vec3 e) {
	p=abs(p)-e;
	return length(max(p,0))+min(max(max(p.x,p.y),p.z),0);
}
const float pi = acos(-1);
const float bps = 137/60.;
#define r2(a) mat2(cos(a),-sin(a),sin(a),cos(a))

float map(vec3 p) {
	float d = 1e9;
	{
		vec3 q = p;
		float id;
		q.xy=abs(q.xy);
		q.xy -= 5;
		q.xy=abs(q.xy);
		q.x -= 2;
		q.z -= pow(fract(time*bps/4),4) + (time/bps);
		q.z -= id = round(q.z);
		q.xy *= r2(0.25*pi+id*0.1);
		q.y += 0.1*sin(time+id);
		q.x += 0.2*sin(q.y)*pow(fract(time*bps/2),2);
		d= sdb(q, vec3(0.05,mix(1,100,pow(.5+.5*sin(time*bps*pi/8),4)),0.05));
	}

	return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec3 col = vec3(1);
	vec3 ro = vec3(0.5*sin(time),0,3);
	float vv = (abs(uv.x) + abs(uv.y) - time*bps/2);
	float fv = mix(0.2,0.5,round(fract(vv/2)));
	
	vec3 cf = normalize(-ro),
	cs = normalize(cross(cf,vec3(0,1,0))),
	cu=normalize(cross(cs,cf)),
	rd=mat3(cs,cu,cf)*normalize(vec3(mix(uv,.5*uv,round(fract(vv/2))),
	fv
	));
	float r,d,n=123,i;
	vec3 p;
	for (i=r=0;i<n;i++) {
		d=1e9;
		p = ro+rd*r;
		d = map(p);
		if (d>.0) r+=d*.8;
		if (r>1e3||d<1e-4)break;
	}
	col *= 1/(r*.1);
	{
		float r = texture(texFFTSmoothed, vv).r*10;
		col = mix(col, 1.-col, clamp(r,0,1));
	}
	if (fract(time/bps/16)>.5)col = 1.-col;
	if (texture(texFFTSmoothed, 0.01).r > 0.01)col = 1.-col;

	out_color = vec4(col, 1);
}