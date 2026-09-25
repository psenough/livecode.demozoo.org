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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float T = fGlobalTime/60*135;

#define pi acos(-1)
#define R v2Resolution.xy

#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

uint seed = 124124124u;
uint seedb = 124124124u;

uint hash_u(){
	seed ^= seed << 16u;
	seed *= 1111111111u;
	seed ^= seed << 16u;
	seed *= 1111111111u;
	seed ^= seed << 16u;
	return seed;
}
uint hash_u_b(){
	seedb ^= seedb << 16u;
	seedb *= 1111111111u;
	seedb ^= seedb << 16u;
	seedb *= 1111111111u;
	seedb ^= seedb << 16u;
	return seedb;
}

float hash_f(){
	return float(hash_u())/float(-1u);
}
float hash_f_b(){
	return float(hash_u_b())/float(-1u);
}

vec3 projp(vec3 p){
	float t = T;
	t *= 0.3;
	t += floor(T/4)*8.;
	p.xz *= rot(t + sin(t));
	t += 0.5;
	p.xy *= rot(t + sin(t));
	p.z += 2. + sin(t);
	p.xy *= 0.2;
	p.xy *= 2. + sin(T);
	//p.xy /= p.z;
	p.x /= R.x/R.y;
	p.xy += 0.5;
	return vec3(p.xy*R,p.z);
}

vec2 samp_circ(){
	vec2 Q = vec2(hash_f()*1000,hash_f());
	return vec2(sin(Q.x),cos(Q.x))*sqrt(Q.y);
}
vec2 samp_circb(){
	vec2 Q = vec2(hash_f()*1000,hash_f());
	return vec2(sin(Q.x),cos(Q.x))*pow(Q.y,1.6);
}

void splat(vec3 p, vec3 c, float aa){
	vec3 q = projp(p);
	q.xy += samp_circ()*aa*R.y;
	
	q.xy += samp_circ() * smoothstep(0.4,1.,abs(p.z - .5))*R.y*0.1;
	if(hash_f()>0.5)
	q.xy += samp_circb()*R.y*0.1;
	//q.xy = mod(q.xy,R);
	for(int i = 0; i < 3; i++){
		imageAtomicAdd(computeTex[i], ivec2(q.xy), int(c[i]));
	}
}
vec3 read(ivec2 q){
	vec3 c;
	for(int i = 0; i < 3; i++){
		c[i] = float(imageLoad(computeTexBack[i], ivec2(q.xy)))/float(1000);
	}
	return c;
}

vec3 samp_cube(){
	return normalize(vec3(
		hash_f_b(),
		hash_f_b(),
		hash_f_b()
	) - 0.5);
}
vec2 hash23(vec3 p3)
{
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	vec2 u = gl_FragCoord.xy/R.xy;
	
	
	float md = 2;
	
	seed = int(T) + 1251251u;
	vec2 fr = vec2(gl_FragCoord.xy)/R;
	
	vec2 fid = vec2(0);
		
		bool circ = mod(floor(T)/4,1) < 0.5;

	if(circ){
		md *= floor(hash_f()*10);
		fid = floor(u*md);
		fr = fract(u*md);
		u = fid/md;		
	} else {
		vec2 fid = vec2(length(uv - 0.5)*md*10 + T);
		fid = floor(fid);
		
	}
	
	u -= 0.5;
	u *= 1. - fract(T)*0.1;
	u += 0.5;
	
	
	
	vec2 X = hash23(vec3(fid, floor(T)));
	
	
	T += X.x;
	
	T += floor(T);
	
	X -= 0.5;
	
	if(circ){
	
		u += X * smoothstep(0.,1.,fract(T))*0.1;
	
		u += fr/md;
	
	} else {
		u += (hash23(vec3(fid,1)).xy - 0.5)*0.2 * float(sin(T) < 0.);
	}
	
	
	
	
	
  ivec2 id = ivec2(u*R);
	
	//seed = floor(T);
	
	
	float rt = T;
	T = floor(rt) + smoothstep(0.,1.,fract(rt));
	
	seed += id.x + id.y*100000;
	
	
	seedb += int(T/4);
	hash_u();
	hash_u();
	hash_u();
	
	seedb += int(hash_f()*20)*1000;
	//T += int(hash_f()*9)*10;
	
	vec3 pa = vec3(1,1,0);
	vec3 pb = vec3(-1,-1,0);
	
	float its = 12;
	
	
	its -= 10 * X.x;
	
	for(float i = 0.; i < its; i++){
		
		vec3 midp = mix(pa,pb,0.9 + sin(T*0.2+float(i)));
		
		vec3 dir = pa - pb;
		vec3 tan = vec3(-dir.y, dir.x, dir.z);
		
		tan = mix(tan,samp_cube()*length(tan),.9);
		
		if(hash_f_b()<0.5){
			tan = -tan;
		}
		{
			midp += tan*.2;
		
		}
		
		if(hash_f() < 0.4){
			pa = midp;
			seedb += 124124124u;
		} else {
			pb = midp;
			seedb += 124124u;
		}
		
		if(i > 1){
		  //splat(pa,vec3(5),0.0001);
			
			vec3 c = sin(vec3(3,2,1) + i*0.2 + T + floor(T))*0.5 + 0.5;
			c = pow(c,vec3(1,0.8,1.));
			splat(mix(pa,pb,hash_f()), vec3(10)*c,0.000);
				
		}
			
	}
	
	vec3 c= vec3(0);
	c = read(id);
	
	c *= 1.;
	
	c = sqrt(c);
	
	if(X.x > fract(T)){
		//c = 1-c;
		//c = pow(c,vec3(14));
	}
	
	vec3 prev =texture(texPreviousFrame, vec2(id)/R).rgb;
	
	seed = int(T*100) + 125125215u;
	if(hash_f() < 0.1){
		
		prev = 1.-prev;
		prev = pow(prev,vec3(3));
	}
	float mix_fac = (1.-length(c));
	
	if(sin(T)<0.){
		mix_fac = length(c)*5;
	}
	prev = rgb2hsv(prev);
	prev.x *= 10;
	prev.y *= 10;
	//prev.x = mod(prev.x, 0.1);
	prev.x +=  + floor(T);
	prev.x = mod(prev.x,1.);
	
	prev *= smoothstep(0.9,0.,length(uv));
	prev *= 1 + sin(T);
	prev = hsv2rgb(prev);
	
	//if()
	c = mix(c, prev*0.9,02. * mix_fac);
	
	prev =texture(texPreviousFrame, vec2(id)/R).rgb;
	
	id += ivec2(vec2(dFdx(prev.x),dFdy(prev.x))*100);
	
	prev =texture(texPreviousFrame, vec2(id)/R).rgb;
	
	
	c = mix(c,1.-prev, float(mod(floor(T),4.) < 0.5)/max(length(c),0.5));
	
	out_color = vec4(c,1);
}