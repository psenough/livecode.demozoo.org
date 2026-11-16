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

#define T (fGlobalTime/60*112*0.5)
#define pi 3.14159265
#define iterations 4

vec3 function(vec3 x){
    vec3 ca = vec3(0.722,0.918,1.000)*cos(x.xxx)+vec3(1.000,0.902,0.859)*cos(x.yyy);
    vec3 cb = vec3(0.898,1.000,0.922)*cos(x.zzz*1.5);
    return ca*cb-cb;
}

mat2 ROT(float ang)
{
    return mat2(cos(ang), sin(ang), -sin(ang), cos(ang));
}

#define SCALE 1.44
#define SHIFT vec3(2.3, -5.2, 1.0)

vec3 fractal(vec3 x){
    x *= pi;
    vec3 v = vec3(0.0);
    float d = length(x);
    x*=3.0;
    float a = 1.5;
    mat2 rmZ = SCALE*ROT(0.9);
    mat2 rmX = SCALE*ROT(0.46);
    for (int i = 0; i < iterations; i++){
        vec3 F =function(x); 
        v += a*F;
        x.xy = rmZ*x.xy;
        x += 0.6*(F + F.zxy);
        x.yz = rmX*x.yz;
        x += SHIFT;
        a /= 1.05;
    }
		
		//return v*3.;
    return 0.5*v*v*exp(-1000.*max(d - 3.0, 0.0));
}

#define tau 6.28

// --- Hash ---
uint seed;
uint hashi(uint x){
    x ^= x >> 16;
    x *= 0x7feb352dU;
    x ^= x >> 15;
    x *= 0x846ca68bU;
    x ^= x >> 16;
    return x;
}
float hash_f(){ uint s = hashi(seed); seed = s; return float(s) / float(0xffffffffU); }
vec2  hash_v2(){ return vec2(hash_f(), hash_f()); }
vec3  samp_sphere(){ float z=1.-2.*hash_f(); float r=sqrt(max(0.,1.-z*z)); float phi=tau*hash_f(); return vec3(r*cos(phi),r*sin(phi),z); }


float hash_f_s(uint s){
    return ( float( hashi(s) ) / float( 0xffffffffu ) );
}
// --- GGX microfacet sample ---
vec3 ggx(vec3 rd, vec3 n, float rgh, vec2 rand){
    float s  = -1.+2.*step(0.,n.z);
    float a  = -1./(s+n.z);
    float b  = n.x*n.y*a;
    mat3  cs = mat3(vec3(1.+s*n.x*n.x*a,s*b,-s*n.x), n, vec3(b,s+n.y*n.y*a,-n.y));
    float th = .5*pi*atan((rgh*sqrt(rand.x))/sqrt(1.0-rand.x));
    vec3 reflection          = normalize(transpose(cs)*rd);
    vec3 normal_distribution = vec3(cos(tau*rand.y)*sin(th), cos(th), sin(tau*rand.y)*sin(th));
    return normalize(cs*reflect(reflection, normal_distribution));
}

vec3 erot(vec3 p, vec3 ax, float ro) {
    return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}

#define tri(x) (3.14*0.5 - abs(mod((x) + 3.14*0.5, 3.14*2.0) - 3.14))

mat3 getOrthogonalBasis( vec3 z ) {
  z = normalize( z );
  vec3 up = abs( z.y ) < 0.99 ? vec3( 0.0, 1.0, 0.0 ) : vec3( 0.0, 0.0, 1.0 );
  vec3 x = normalize( cross( up, z ) );
  return mat3( x, cross( z, x ), z );
}

vec3 cyclicNoise( vec3 p, float pump ) {
  vec4 sum = vec4( 0.0 );
	
	float t = T*0.25;
	p = erot(p, vec3(0,1,0), (floor(t) + pow(smoothstep(0.,1.,fract(t)),50.))*0.01);
  mat3 basis = getOrthogonalBasis( vec3( -1.0, 2.0, -3.0 ) );
  for( int i = 0; i < 5 + 0.*int(3.*hash_f_s( 124124124 + uint(fGlobalTime))); i++ ) {
    p *= basis;
    //p += asin(sin( p.yzx ));
    p += tri(p.yzx);
		sum += vec4( cross( cos( p ), sin( p.zxy ) ), 1.0 );
    sum *= pump;
    p *= 1.5;
  }
  return sum.xyz / sum.w;
}

vec2 NNN;
float map(vec3 p){

	//p.xz *= ROT(0.5 + sin(fGlobalTime*0.2));
	//p -= fractal(p)*0.001;
	//float T = fGlobalTime;
	float t = T*0.5;
	p -= cyclicNoise( p + 3*vec3(NNN - 0.5,0) + 0.5*vec3(0,0,floor(t) + pow(smoothstep(0.,1.,fract(t)),1.)), 0.4)*0.3;
	return mix(-p.z,length(p) - 0.4,0.4);
	//return p.z;
}

vec3 get_norm(vec3 p){
	vec2 t = vec2(0.001,0);
	return normalize(vec3(
		map(p+t.xyy) - map(p-t.xyy),
		map(p+t.yxy) - map(p-t.yxy),
		map(p+t.yyx) - map(p-t.yyx)
	));
}


mat3 get_orth_mat(vec3 origin, vec3 target) {
	vec3 dir = normalize(target - origin);
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), dir));
	vec3 up = normalize(cross(dir, right));
	return mat3(right, up, dir);
}

vec2 trace(inout vec3 p, vec3 rd, bool shad, bool first){
	bool hit = false;
	vec3 ro = p;
	float t= 0.;
	for(float i = 0.; i < 50 + 250 * float(first) - 50 * float(shad); i++){
		float d = map(p);
		
		if(d < 0.001){
			hit = true;
			break;
		} else if (t > 2 - 2 * float(shad)) {
			break;
		}
		d *= 0.2;
		t += d;
		p += rd*d;
	}
	return vec2(length(p - ro),hit);
}
vec2 hash21(float p)
{
    vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

vec2 noise21(float x)
{
	 x *= 0.125;
    float i = floor(x);
    float f = fract(x);

		
    // smooth value-noise interpolation
    
		f = f * f * (3.0 - 2.0 * f);

		f = pow(f,7.);
    vec2 a = hash21(i);
    vec2 b = hash21(i + 1.0);

    return mix(a, b, f);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	
	seed = uint(gl_FragCoord.x) + uint(gl_FragCoord.y)*10000 + 124124u;
	seed += uint(fGlobalTime*10000)*1125000;
	vec3 col = vec3(1,0,0);
	
	col -= col;
	
	float sss = 3.;
	
	for(float ss = 0; ss < sss; ss++){
	
	vec3 ro = vec3(0,0,-1);
	vec3 tar = vec3(0,0,1);
	
	vec3 rd = normalize(vec3(uv,1));
	
	rd = get_orth_mat(ro,tar)*rd;
	
	
	NNN = noise21(T);
	vec2 sunn = noise21(T*8. + 124);
	
	vec3 p = ro;
	
	
	
	
	vec3 thr = vec3(1);
	
			
		for(float bn = 0; bn < 3.; bn++){
			vec2 res = trace(p,rd,false,bn == 0? true : false);
			bool hit = res.y > 0.;
			
			if(hit){
				vec3 n = get_norm(p);
				p += n*0.01;
				
				vec3 shp = p;
				vec3 sun_dir = normalize(vec3((sunn - 0.5)*5,-0.2));
				float dd = max(dot(n,sun_dir),0);
				
				vec3 alb = n*0.5 + n*0.5;
				alb = pow(alb,vec3(0.9));
				
				alb = sin(vec3(4,5,1) + n.x*1)*0.5 + 0.5;
				alb = pow(alb,vec3(0.5 - n.x,1.5,1));
				
				alb = vec3(0.4);
				if(dd > 0.){
					vec2 res = trace(shp,sun_dir,true,false);
				
					
					if(res.y < 0.5){
						//col += 1111;
						col += alb*dd;
					}
				}
				rd = ggx(rd, n, 0.5, hash_v2());
				//col += n*0.5 + 0.5;
				
				thr *= alb;
			}else{
				break;
			}
		}
	}
	
	col /= sss;
	
//	col += thr * vec3(1)*5.*(fract(T) - 0.5);
	
	col = pow(col,vec3(0.4545));
	col = col/(1+col);
	col = smoothstep(0.,1.,col*1.2);
	vec3 prev = texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy).rgb;
	
	col = mix(col,prev,0.6);
	out_color = vec4(col,1);
}