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
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texLeafs;
uniform sampler2D texRevisionBW;
uniform sampler2D texLynn;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define U gl_FragCoord.xy
#define R vec2(v2Resolution.xy)
#define T fGlobalTime 

#define pi acos(-1.)
#define tau (acos(-1.)*2.)


#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))



// hashes
uint seed = 1251522;
uint hashi( uint x){
    x ^= x >> 16;x *= 0x7feb352dU;x ^= x >> 15;x *= 0x846ca68bU;x ^= x >> 16;
    return x;
}

#define hash_f_s(s)  ( float( hashi(uint(s)) ) / float( 0xffffffffU ) )
#define hash_f()  ( float( seed = hashi(seed) ) / float( 0xffffffffU ) )
#define hash_v2()  vec2(hash_f(),hash_f())
#define hash_v3()  vec3(hash_f(),hash_f(),hash_f())
#define hash_v4()  vec3(hash_f(),hash_f(),hash_f(),hash_f())

// https://www.shadertoy.com/view/XlXcW4
vec3 hash3f( vec3 s ) {
  uvec3 r = floatBitsToUint( s );
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  return vec3( r ) / float( -1u );
}


uint seed_gen(vec3 p){
    return uint(p.x+66341.)*666562+uint(p.y+54324.)*3554+uint(p.z+61441.);
}

vec3 noise(vec3 p){
    vec3 bl_back = hash3f(floor(p));
    vec3 br_back = hash3f(floor(p)+vec3(1,0,0));
    vec3 tr_back = hash3f(floor(p)+vec3(1,1,0));
    vec3 tl_back = hash3f(floor(p)+vec3(0,1,0));
    vec3 bl_front = hash3f(floor(p)+vec3(0,0,1));
    vec3 br_front = hash3f(floor(p)+vec3(1,0,1));
    vec3 tr_front = hash3f(floor(p)+vec3(1,1,1));
    vec3 tl_front = hash3f(floor(p)+vec3(0,1,1));
    return 
    mix(
    mix(
    mix(bl_back, br_back, smoothstep(0.,1.,fract(p.x))),
    mix(tl_back, tr_back, smoothstep(0.,1.,fract(p.x))),
    smoothstep(0.,1.,fract(p.y))
    ),
    mix(
    mix(bl_front, br_front, smoothstep(0.,1.,fract(p.x))),
    mix(tl_front, tr_front, smoothstep(0.,1.,fract(p.x))),
    smoothstep(0.,1.,fract(p.y))
    ),
    smoothstep(0.,1.,fract(p.z))
    )
    ;
}

vec2 sample_disk(){
    vec2 r = hash_v2();
    return vec2(sin(r.x*tau),cos(r.x*tau))*sqrt(r.y);
}

// point projection
ivec2 proj_p(vec3 p){
  // depth of field
  p.xy += sample_disk() * abs(p.z)*0.02;
  
  // convert point to ivec2. From 0 to resolution.xy
  ivec2 q = ivec2((p.xy + vec2(R.x/R.y,1)*0.5)*vec2(R.y/R.x,1)*R);
  if(any(greaterThan(q, ivec2(R))) || any(lessThan(q, ivec2(0)))){
      q = ivec2(-1);
  }
  return q;
}


void store_pixel(ivec2 px_coord, vec3 col){
  // colour quantized to integer.
  ivec3 quant_col = ivec3(col * 1000);
  // no clue why it wants ivec4() here...
  imageStore(computeTex[0], px_coord, ivec4(quant_col.x)); 
  imageStore(computeTex[1], px_coord, ivec4(quant_col.y)); 
  imageStore(computeTex[2], px_coord, ivec4(quant_col.z)); 
}

void add_to_pixel(ivec2 px_coord, vec3 col){
  // colour quantized to integer.
  ivec3 quant_col = ivec3(col * 1000);
  imageAtomicAdd(computeTex[0], px_coord, quant_col.x);
  imageAtomicAdd(computeTex[1], px_coord, quant_col.y);
  imageAtomicAdd(computeTex[2], px_coord, quant_col.z);
}

vec3 read_pixel(ivec2 px_coord){
  return 0.001*vec3(
    imageLoad(computeTexBack[0],px_coord).x,
    imageLoad(computeTexBack[1],px_coord).x,
    imageLoad(computeTexBack[2],px_coord).x
  );
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec4 revis(vec2 p){
      return texture(texRevisionBW,clamp(p*vec2(1,-1),-.5,.5)-.5);
 
  }
vec4 lynn(vec2 p){
      return texture(texLynn,clamp(p*vec2(1,-1),-.5,.5)-.5);  
      
  }
  

  float lum(vec3 c){
    return c.r*0.25+c.g*0.35+c.b*0.4;
    }
void main(void)
{
	vec2 uv = vec2(U.x / R.x, U.y / R.y);
	uv -= 0.5;
	uv /= vec2(R.y / R.x, 1);
  uint baseseed = seed_gen(vec3(U,T*99.99));
  
  
  uint scene = seed_gen(vec3(T))%3;
  
  float accT = texture(texFFTIntegrated,0.2).r*2.;
    float rad = mix(0.3,0.6,texture(texFFTSmoothed,0.2).r*18.);
  if(U.x<60 && scene==0){
    seed = baseseed;
    vec3 po = hash_v3()*2.0-1.0;
    po = floor(po*3.)/3.;
    vec3 qo = po;
    for(int i=0; i<9; i++){
      vec3 p = po;
      po -= normalize(po)*(length(po)-rad);
      p.xy *= rot(accT*.4);
      p.zx *= rot(accT*.7);
      add_to_pixel(proj_p(p), hsv2rgb(vec3(0.5,.6,.05)));
    }
    seed = baseseed;
    qo += sign((hash_v3()*2.0-1.0)*1.0)/3.0;
    for(int i=0; i<9; i++){
      vec3 p = qo;
      qo -= normalize(qo)*(length(qo)-rad);
      p.xy *= rot(accT*.4);
      p.zx *= rot(accT*.7);
      float walk = hash_f();
      add_to_pixel(proj_p(mix(po,p,walk)), hsv2rgb(vec3(walk*0.4+.5,.8,.15)));
    }
  }
  if(U.x<60 && scene==1){
    float t = floor(T*2.0)+1.0-exp(-fract(T*2.0));
    t*=0.8;
    seed = baseseed;
    vec3 po = hash_v3()*2.0-1.0;
    for(int i=0; i<64; i++){
      po.y += pow(po.x+po.z,3.0);
      po.zx -= dot(po.xy*rot(t),vec2(1,1))*.2;
      po.xy += dot(po.yz*rot(t),vec2(1,1))*.1;
      po.zx -= dot(po.xy*rot(-t),vec2(1,1))*.2;
      po.xy += dot(po.yz*rot(-t),vec2(1,1))*.1;
      po = mix(floor(po*4.0),po,0.99);
      po *= 0.95;
      vec3 p=po;
      add_to_pixel(proj_p(p), hsv2rgb(vec3(0.2,.8,(float(i)/64.)*.15)));
    }
  }
  if(U.x<60 && scene==2){
    seed = baseseed;
    for(int i=0; i<9; i++){
      float sides = mix(3.0,6.0,sin(T)*0.5+0.5);
      float ang = floor(hash_f()*sides)/sides;
      vec2 q = vec2(cos(ang*tau),sin(ang*tau))*0.5;
      ang = floor(hash_f()*sides)/sides;
      vec2 r = vec2(cos(ang*tau),sin(ang*tau))*0.5;
      vec3 p=vec3(mix(q,r,hash_f()), pow(hash_f()*2.0-1.0,7.0)*0.5+0.5);
      p += noise(p*3.+T)*0.2;
      p.xy *= rot(-accT);
      p.zx *= rot(sin(accT)*0.1);
      add_to_pixel(proj_p(p), hsv2rgb(vec3(0.0,.8,1.)));
    }
  }
  
  vec3 comp_read = read_pixel(ivec2(U));
  
  float inv = revis(uv*rot(accT)*2.3*(1.0-rad)).r;
  
  vec3 co = comp_read;
  co-=inv;
  
  vec2 glitch = floor(uv*3.0)+8.0;
  seed = uint(glitch.x*9.9+glitch.y*99.99+floor(T)*9999.99);
  if(hash_f()>0.95){
    co = texture(texPreviousFrame,U/R + normalize(hash_v2())*0.01).rgb;
  }
  
  co = mix(co, lynn(uv).rgb, lum(co)*(1.0-length(lynn(uv)-1.0)));
  
  co = 1.0-co;
  
  co = vec3(
  mix(0.001,0.9,pow(co.r,0.7)),
  co.g,
  pow(co.b,1.8)
  );
  co = pow(co,vec3(0.5));
  
	out_color = vec4(pow(co,vec3(.454545)),0);
}