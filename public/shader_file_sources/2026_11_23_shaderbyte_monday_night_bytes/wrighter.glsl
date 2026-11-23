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
 
float T = fGlobalTime;

#define Tt (T/60*174*0.5)
//#define T (floor(Tt/2) + smoothstep(0.,1.,fract(T/2)))

#define T Tt

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

vec3 erot(vec3 p, vec3 ax, float ro) {
    return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
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
	vec3 q = projp(p*3.);
	q.xy += samp_circ()*aa*R.y;
	
	
	q.xy += samp_circ() * smoothstep(0.2,1.,abs(p.z - 0.1 + 0.*sin(T + sin(T))))*R.y*0.1*sin(T+cos(T));
	
	//q.xy *= 2.;
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

float sdb(vec3 p, vec3 s){
	p = abs(p) - s;
	return max(p.x, max(p.y,p.z));
}

float map(vec3 p){
	
	vec4 q = vec4(p,1);

	float d = 1000.;
	
	for(float i = 0.; i < 5.; i++){
		q.rgb = erot(q.rgb, normalize(vec3(1)),0.5 + i*0.2 + T*0.2);
		
		q.rgb -= 0.2;
		
		float ld = sdb(q.rgb/q.w, vec3(0.1));
		
		q.rgb = abs(q.rgb) - 0.5 + sin(T+i)*0.2;
		
		q *= 1.2;
		d = min(d, ld);
	}

	return d;
}
vec3 get_normal(vec3 p){
    const float h = 0.4;
    const vec2 k = vec2(1,-1);
    return normalize(
        k.xyy * map(p + k.xyy*h).x +
        k.yyx * map(p + k.yyx*h).x +
        k.yxy * map(p + k.yxy*h).x +
        k.xxx * map(p + k.xxx*h).x
    );
}

float curv(in vec3 p, in float w) {
  vec2 e = vec2(-1., 1.)*w;   
  float t1 = map(p + e.yxx), t2 = map(p + e.xxy) ,t3 = map(p + e.xyx), t4 = map(p + e.yyy);
  return .25/e.y*(t1 + t2 + t3 + t4 - 4.0*map(p));
}

float curv2(in vec3 p, in float w) {
  // return curv(p,w); // ?
  vec3 e = vec3(w, 0, 0);
  float t1 = map(p + e.xyy), t2 = map(p - e.xyy), t3 = map(p + e.yxy), t4 = map(p - e.yxy), t5 = map(p + e.yyx), t6 = map(p - e.yyx);
  return .25/e.x*(t1 + t2 + t3 + t4 + t5 + t6 - 6*map(p));
}

vec3 rgb_to_yuv(vec3 c) {
    float y = dot(c, vec3(0.299, 0.587, 0.114));
    return vec3(y, 0.492 * (c.b-y), 0.877 * (c.r-y));
}
vec3 yuv_to_rgb(vec3 c) {
    float r = c.x + c.z/0.877, b = c.x + c.y/0.492;
    return vec3(r, (c.x-0.299*r-0.114*b)/0.587, b);
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  ivec2 id = ivec2(gl_FragCoord.xy);
	
	seed += id.x + id.y*100000;
	
	seedb += int(T/4);
	hash_u();
	hash_u();
	hash_u();
	
	seedb += int(hash_f()*20)*1000;
	//T += int(hash_f()*9)*10;
	
	
	
	vec3 p = vec3(0);
	
	p += vec3(hash_f(), hash_f(), hash_f()) - 0.5;
	
	//p = normalize(p);
	p *= 0.9 + sin(T/2)*0.5;
	vec3 op = p;
s
	float q = 0.3;
	if (gl_FragCoord.x/R.x < q)
	for(float i = 0.; i < 52; i++){
		
		vec3 dir = normalize(vec3(0,1,0));
		
		
		vec3 n = get_normal(p);
		
		
		n = normalize(-n + normalize(p)*0.);
		
		
		n = erot(n,vec3(1),0.2 + T);
		
		float cu =  curv(p - n*0.02, 0.03 + length(p)*0.8);
		
		
		cu = -abs(cu);
		
		//cu = max(cu,0.05);
		p += n * cu*.3*sin(T+ sin(T));
		
		vec3 c = sin(vec3(3,2,1) + float(id)*0.0 + i*0.1 + T*0.2)*0.5 + 0.5;
		c = pow(c,vec3(1,0.2,1.));
		splat(p, vec3(4)*c,0.000);
			
		/*
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
			
			vec3 c = sin(vec3(3,2,1) + i + T)*0.5 + 0.5;
			c = pow(c,vec3(1,0.8,1.));
			splat(mix(pa,pb,hash_f()), vec3(10)*c,0.000);
				
		}
		*/
			
	}
	
	vec3 c= vec3(0);
	c = read(id);
	
	c /= q;
	
	c *= 1.;
	c = sqrt(c);
	c = max(c,0.1);
	c = min(c,0.9 + sin(T*4.)*0.4);
	c *= 1.4;
	{
	
		vec2 uv = gl_FragCoord.xy/R;
		vec3 prev = texture(texPreviousFrame, uv).rgb;
	
	vec3 yuv = rgb_to_yuv(prev);
	
	
	yuv.x *= 1.;
	// yuv.y += 0.5;
  yuv += vec3(0.2,1.2,9.9 + sin(T)*10.);
	yuv.y *= 0.4;
	yuv.z *= 0.03;
	
	vec2 uvv = uv - 0.5;
	yuv.yz *= rot(-0.5 + yuv.x*2.4  + sin(T + dot(uvv,uvv)*3.)*0.2);
	
	prev = yuv_to_rgb(yuv);
		vec3 curr = c;
		
		c = mix(c,prev*0.5, 0.1 + smoothstep(0.,1.,abs((fract(T*0.5) - 0.5)*2))*0.5);
	}
	
	out_color = vec4(c,1);
}