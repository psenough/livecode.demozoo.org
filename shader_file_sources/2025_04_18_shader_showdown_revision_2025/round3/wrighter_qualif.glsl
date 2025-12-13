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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


// THIS KBD IS FUCKED 
// THIS KBD IS FUCKED 
// T R U pi tau rot

#define TT (fGlobalTime/60*138)
#define T (floor(TT) + smoothstep(0.,1.,fract(TT)))
#define R v2Resolution.xy
#define U gl_FragCoord.xy
#define pi acos(-1.)
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))


uint seed;
uint hashu(){
	seed ^= seed << 16u;
	seed *= 0x11111111u;
	seed ^= seed << 15u;
	seed *= 0x11111111u;
	seed ^= seed << 16u;
	return seed;
}
#define hash_f() float(hashu())/float(-1u)
#define hash_v2() vec2(hash_f(), hash_f())


vec2 circ(){
	vec2 X = hash_v2();
	X.x *= pi*2; 
	return vec2(cos(X.x),sin(X.x))*sqrt(X.y);
}
// projp splat read
ivec3 projp(vec3 p){
	
	p.xz *= rot(T*sign(sin(T)));
	
	p.yz *= rot(sin(T)*0.4);
	
	p.z -= 3.5;

	float focusd = -3.5 + sin(T)*0.3;
	
	p.xy /= p.z*0.2;
	
	p.xy += abs(p.z - focusd)*circ()*0.04;
	
	p.x /= R.x/R.y;
	p.xy += 1;
	p.xy /= 2;
	p.xy *= R.xy;
	return ivec3(p);
}
void splat(vec3 p, vec3 col){
	ivec3 q = projp(p);
	for(int i = 0; i<3; i++){
		imageAtomicAdd(computeTex[i], q.xy, int(col[i]*1000));
	}
}
vec3 read(ivec2 q){
	vec3 c;
	for(int i = 0;i<3; i++){
		c[i] = float(imageLoad(computeTexBack[i], q.xy).x);
	}
	return c;
}

// map getnorm
float map(vec3 p){
	float d=  1000.;
	for(float i = 0.; i < 3 + mod(T/2,3);i++){
		p = abs(p) - 0.15;
		p.yz *= rot(1.3 + floor(T/2) + T*0.02);
		p.xz *= rot(1.3 + floor(T/2));
	}
	
	d = min(d,length(p) - 0.1);
	d = min(d,length(p.xy) - 0.02);
	d = min(d,length(p.yz) - 0.02);
	d = min(d,length(p.xz) - 0.02);
	return d;
}

vec3 get_norm(vec3 p){
	vec2 t = vec2(0.001,0);
	return normalize(vec3(
		map(p + t.xyy) - 	map(p - t.xyy),
		map(p + t.yxy) - 	map(p - t.yxy),
		map(p + t.yyx) - 	map(p - t.yyx) 
	));
}

vec3 ball(){
	return normalize(vec3(hash_f(),hash_f(),hash_f()) - 0.5);
}

void main(void)
{

	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	seed = uint(U.x + U.y * R.x) + 1252143u;
	vec3 p = vec3(4,0,0);
	
	float lid = floor(T/2) + T *0.02;
	for(int i = 0; i < 20; i++){
		if(hash_f() < 0.5 || i == 3){
			p = -p;
			p.yz *= rot(lid);
			p.xz *= rot(lid);
		}
	}
	p *= 0.2;
	
	vec3 tar = vec3(0);
	bool laser = mod(T,6) > 3;
	//laser = true;
		if(laser){
		} else {
			tar += ball()*0.1;
			p += ball()*0.02;
		}
	vec3 rd = normalize(tar - p);
	
	
	float wv = hash_f()*0.2;
	
	vec3 thr = 0.5 + 0.5 * sin(vec3(3,2,1) + wv + floor(T/2) + T * 0.6);
	
	thr = pow(thr,vec3(1,1.2,1.7)*1);
	
	//if(U.x < 800)
	for(float bnc = 0; bnc < 5; bnc++){
		bool hit = false;
		float side = sign(map(p));
		
		for(float i = 0; i < 50; i++){
			float d = map(p)*side;
			
			if(laser){
				splat(p,thr);
				p += rd * 0.1;
			} else {
				p += rd * d;
			}
			
			if(d < 0.0002){
				hit = true;
				break;
			}
		}
		
		if(hit){
			vec3 n = get_norm(p)*side;
			if(!laser){
				splat(p, thr);
			}
			thr *= 0.1;
			float ior = mix(0.1,1.,wv);
			ior *= 2.;
			//ior = 1./ior;
			vec3 refr = refract(rd, n, ior);
			
			if(refr == vec3(0)){
				rd = reflect(rd, n);
				p += n * 0.002;
			} else {
				rd = refr;
				p -= n * 0.002;
			}
			
		}
	}
	
	
	vec3 col = vec3(0);
	col = read(ivec2(U.xy))*0.001;
	col = col/(1 + col);
	col = sqrt(col);
	if(abs(uv.y)  > 0.3){
		col -= col;
	}
	out_color = vec4(col,0);
}