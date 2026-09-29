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
#define R v2Resolution
#define U gl_FragCoord.xy
#define pi acos(-1.)
#define tau (acos(-1.)*2.)


#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))


// hashes
uint seed = 12512;
uint hashi( uint x){
    x ^= x >> 16;x *= 0x7feb352dU;x ^= x >> 15;x *= 0x846ca68bU;x ^= x >> 16;
    return x;
}

#define hash_f_s(s)  ( float( hashi(uint(s)) ) / float( 0xffffffffU ) )
#define hash_f()  ( float( seed = hashi(seed) ) / float( 0xffffffffU ) )
#define hash_v2()  vec2(hash_f(),hash_f())
#define hash_v3()  vec3(hash_f(),hash_f(),hash_f())
#define hash_v4()  vec3(hash_f(),hash_f(),hash_f(),hash_f())

vec2 sample_disk(){
    vec2 r = hash_v2();
    return vec2(sin(r.x*tau),cos(r.x*tau))*sqrt(r.y);
}
vec3 mul3( in mat3 m, in vec3 v ){return vec3(dot(v,m[0]),dot(v,m[1]),dot(v,m[2]));}

vec3 oklch_to_srgb( in vec3 c ) {
    c = vec3(c.x, c.y*cos(c.z), c.y*sin(c.z));
    mat3 m1 = mat3(
        1,0.4,0.2,
        1,-0.1,-0.06,
        1,-0.1,-1.3
    );

    vec3 lms = mul3(m1,c);

    lms = pow(lms,vec3(3.0));

    
    mat3 m2 = mat3(
        4, -3.3,0.2,
        -1.3,2.6,-0.34,
        0.0,-0.7, 1.7
    );
    return mul3(m2,lms);
}
float TT;


mat3 orth(vec3 tar, vec3 or){
    vec3 dir = normalize(tar - or);
    vec3 right = normalize(cross(vec3(0,1,0),dir));
    vec3 up = normalize(cross(dir, right));
    return mat3(right, up, dir);
}

#define h(x) fract(sin(x*25.67)*125.6)



//layout(r32ui) uniform coherent uimage2D[3] computeTex;
//layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

mat3 getOrthogonalBasis(vec3 direction){
    direction = normalize(direction);
    vec3 right = normalize(cross(vec3(0,1,0),direction));
    vec3 up = normalize(cross(direction, right));
    return mat3(right,up,direction);
}

float cyclicNoise(vec3 p){
    float noise = 0.;
    
    // These are the variables. I renamed them from the original by nimitz
    // So they are more similar to the terms used be other types of noise
    float amp = 1.;
    const float gain = 0.6;
    const float lacunarity = 564.5;
    const int octaves = 8;
    
    const float warp = 4.3;    
    float warpTrk = 1.2 ;
    const float warpTrkGain = 1.5;
    
    // Step 1: Get a simple arbitrary rotation, defined by the direction.
    vec3 seed = vec3(-1,-2.,0.5);
    mat3 rotMatrix = getOrthogonalBasis(seed);
    
    for(int i = 0; i < octaves; i++){
    
        // Step 2: Do some domain warping, Similar to fbm. Optional.
        
        p += sin(p.zxy*warpTrk - 2.*warpTrk)*warp; 
    
        // Step 3: Calculate a noise value. 
        // This works in a way vaguely similar to Perlin/Simplex noise,
        // but instead of in a square/triangle lattice, it is done in a sine wave.
        
        noise += sin(dot(cos(p), sin(p.zxy )))*amp;
        
        // Step 4: Rotate and scale. 
        
        p *= rotMatrix;
        p *= lacunarity;
        
        warpTrk *= warpTrkGain;
        amp *= gain;
    }
    
    
    #ifdef TURBULENT
    return 1. - abs(noise)*0.5;
    #else
    return (noise*0.25 + 0.5);
    #endif

}

 vec3 cyclic(vec3 p, float pers, float lacu) {
   vec4 sum = vec4(0);
   mat3 rot = orth(vec3(0),vec3(2, -3, 1));
 
   for (int i = 0; i < 5; i++) {
     p *= rot;
     p += sin(p.zxy);
     sum += vec4(cross(cos(p), sin(p.yzx)), 1);
     sum /= pers;
     p *= lacu;
   }
 
   return sum.xyz / sum.w*1.2;
 }

vec2 sample_circ(){
	vec2 X = hash_v2();
	X.x *= 1000;
	return vec2(sin(X.x),cos(X.x))*sqrt(X.y);
}
vec2 sample_circ_perim(){
  float X = hash_f();
	X *= 1000;
	return vec2(sin(X),cos(X));

}
#define Tt (fGlobalTime/60*149/2)
#define T (floor(Tt) + smoothstep(0.,1.,fract(Tt)))


float sdBox(vec2 p ,vec2 s){
	p = abs(p) - s;
	return max(p.x, p.y);
}




void splat(vec2 u, uint s){
		u.x *= R.y/R.x;
		u *= 0.1;
		u += 1.;
		u /= 2;
		ivec2 q = ivec2(u*R);
		//q = (q+R)%ivec2(R);
    imageAtomicAdd(computeTex[0],q,s);
}
float read(ivec2 u){
    return float(imageLoad(computeTexBack[0],u).x);
}




void main(void){
	vec2 uv = (U - 0.5*R)/R.y;
  vec3 col = vec3(0);
	
	//uv *= 11115. + sin(T);
	
	
	seed = uint(
    U.x + U.y *1225 
  ) + 125251124;
  
  float tid = mod(U.x,1611);
	//tid += U.y*15;
	tid = floor(tid);
	
	uint s = uint(uint(tid)*14210u + 12521421u + uint(U.y));
	
  vec2 p = vec2(hash_f_s(s), hash_f_s(s+45121u));
  p -= 0.5;
	p *= 0.4;
	
	float circs = 3 + cyclic(vec3(T),0.2,0.6).x*2. ;
	
	float r = pow(hash_f_s(s+124),0.6)*circs;
	//r = floor(r);
//	r += 1;
	
	r = log(r*5)*(2.5 + cyclic(vec3(T)*0.5 + 124.0,2.2,0.6).x*2.);
	//r = exp(r*0.2)*.2;
	
	
	// r 0 - 10
	
	float perim = tau * r * 2;
	
	
	float subdivs = floor(	perim );
	//subdivs = 5;
	float a = floor(
		hash_f_s(s + 5114u) * subdivs
	);
	
	float arg = a/subdivs*tau;
	
	arg += sin(r + T*0.1);
	p = r * vec2( sin( arg ), cos( arg ) );
	
	s += 12455u;
	//p -= p;
	
	float circ_rad = perim/subdivs*0.5*sin(T+r + a*0.2);
	//circ_rad = 0.5;
	for(float i = 0.; i <126; i++){
		vec2 s = sample_circ_perim();
		vec2 q = p + s*circ_rad;
		//q += sample_circ()*1.;
		
		q += (cyclic(vec3(arg,r,0. + T + sin(T+r*0.9)), 1.5, .1).xy)*114.5;
		
		q += cyclic(vec3(q*3,0.5 + T + sin(T+r*0.9)) + sin(mod(U.y,5))*2, 0.2, 0.2).xy*.7;
		
		q += cyclic(vec3(q*13,0.5 + T + sin(T+r*0.9)) + sin(mod(U.y,5))*2, 2.2, 0.2).xy*.52;
		
		splat(q*.4 - vec2(-0,10.),10);
	}
	
	
	
	col = read(ivec2(U.xy)).xxx*0.002;
	col = col/(1+col);
  col = pow(col,vec3(1.4545));
  
	if(
		//true
		false
	)
	{
		col = 1.-col;
		col = pow(col,vec3(1.0545));
	}
  
  
	uv = (U)/R;
  uv -= 0.5;
  //uv *= rot(sin(T*0.3));
  uv *= .99;
  uv += 0.5;
  //uv *= 2.;
  //uv = fract(uv);
  
  //uv*= rot(sin(T));
  vec4 prev = texture(texPreviousFrame,uv);
  //uv.xy += vec2(dFdx(prev.x), dFdy(prev.x))*3.;
  
  //col.r += 
  prev -= prev;
  float its = 4.;
  for(float i = 0.; i < its; i++){
    
    for(int k = 0; k < 3; k++){
      vec2 u = uv - 0.5;
      prev[k] += texture(texPreviousFrame,u 
        * mix(float[](1.01,1.04,0.1)[k]
        ,2., i/its * (1. + 0.02*cyclic(vec3(T)*0.5 + 124.0 + float(k),6.2,0.6).x*4.)
        ) + 0.1
      )[k]/its;
    
    }
    
  }
  
  col = mix(col,prev.rgb,pow(1.-length(col.rgb),1.)*0.9 + .5 + 0.2*float(sin(floor(T)) < 0.5));
  col = fract(col*1.);
  col = pow(col,vec3(.2,0.,1.9));
  //for()
	//col = pow(col,vec3(0.4545));
  col *=0.95;
  col = 1.-col;
	out_color.rgb = vec3(col);
}




