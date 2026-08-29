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
#define T fGlobalTime
#define R v2Resolution
#define U gl_FragCoord.xy
#define pi acos(-1.)
#define tau (acos(-1.)*2.)


#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

vec3[4*4] palAppleII = vec3[](
    vec3(217, 60, 240)/255.,
    vec3(64, 53, 120)/255.,
    vec3(108, 41, 64)/255.,
    vec3(0, 0, 0)/255.,

    vec3(236, 168, 191)/255.,
    vec3(128, 128, 128)/255.,
    vec3(217, 104, 15)/255.,
    vec3(64, 75, 7)/255.,

    vec3(191, 180, 248)/255.,
    vec3(38, 151, 240)/255.,
    vec3(128, 128, 128)/255.,
    vec3(19, 87, 64)/255.,

    vec3(255, 255, 255)/255.,
    vec3(147, 214, 191)/255.,
    vec3(191, 202, 135)/255.,
    vec3(38, 195, 15)/255.
);


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

float Bayer2(vec2 a) {
    a = floor(a);
    return fract(a.x / 2. + a.y * a.y * .75);
}

#define Bayer4(a)   (Bayer2 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer8(a)   (Bayer4 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer16(a)  (Bayer8 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer32(a)  (Bayer16(.5 *(a)) * .25 + Bayer2(a))
#define Bayer64(a)  (Bayer32(.5 *(a)) * .25 + Bayer2(a))


void get(out vec4 C, vec2 u, float tt){
    vec2 uv = (u - 0.5*R.xy)/R.y;
    
    C = vec4(0);

    float md = 0.02;
    
    vec2 puv = vec2(atan(uv.y,uv.x),length(uv));
    
    //float tt = T;
    puv.y += (tt+sin(tt))*0.1;
    //puv.y += 0. + clamp((puv.x + 2.5)*5.,0.,1.0)*0.025;
    //puv.y-= 0. + clamp((puv.x - .3)*5.,0.,1.0)*0.025;
    float id = floor(puv.y/md);
    
    float offs = id + T + sin(T + id*0.1);
    
    uv.xy *= rot(id + offs);
    puv.x = atan(uv.y,uv.x);
    
    
    //#defien pmod()
    
    
    
    
    
    puv.y = mod(puv.y,md);
    
    C += 1.-clamp(mod(id,2.),0.,1.0);
    
    if(puv.x < pi/2.0){
        C = 1.-C;
    }
    
}


//layout(r32ui) uniform coherent uimage2D[3] computeTex;
//layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

int sc = 4;

void splat(ivec2 u){
    imageAtomicAdd(computeTex[0],u,1);
}
float read(ivec2 u){
    return float(imageLoad(computeTexBack[0],u/sc).x);
}

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

void main(void){
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float dmd = 0.4;
  
  vec2 uvid = floor(uv/dmd*0.1);
  uv = floor(uv/dmd)*dmd;
  vec2 marchu = uv;
  
  vec3 col = vec3(0);
  vec4 prev = texture(texPreviousFrame,U/R);
  //vec2 dr = vec2(dFdx((prev.g)),dFdy((prev.g)));
  
  //col += dr.xyx*110.4;
  
  float bpm = 128.;
  float t = T / 60. * bpm;
  
  float env = floor(t);
  env += pow(smoothstep(0.,1.,fract(t)),2.);
  if(U.x < 40.*(sin(env)*0.5 + 0.5)){
      float h = fract(sin(U.y*32. + U.x*532.532)*215.125+env*0.01);
      float hb = fract(sin(sin(U.y*325.)*532.+sin(U.x*326.6423)+env*0.0001)*21.125);
      vec2 q = vec2(h,hb) - 0.5;
      q = sign(q) * pow(abs(q),vec2(0.8))*1.7;
      q = mix(q,vec2(sin(q.x*7.+env),cos(q.y*7.-env))*hb,0.5 + 0.5 * sin(env));
      //q = abs(q) * sign(q);
      for(float i = 0.; i <6 + sin(U.y + env)*630; i++){
          float n = cyclicNoise(vec3(q*7.,h*205. + env*0.1 + i))*sin(hb*15.+env);
          q += vec2(sin(n*16.8+sin(i*0.4)*0.6*n+env),cos(n*6.9+sin(i*0.3)*5.0*n+env))*0.001*sin(hb*5.+ env);     
        //vec2 q = vec2(sin(i*35. + R.y),cos(i*532. + R.y + T));
          //q = sin(vec2(h,hb)*14.)*0.5;
        //q = h;
          //q.x *= R.x/R.y;
          vec2 j = q;
          
          j.x = abs(j.x)*sign(j.x);
          j += 0.5 ;
          //j.x += fract(env);
          //j = mod(j,1.0);
          
          splat(ivec2(j*R/sc));


          //ivec2 j = q 
      }
  }
  
  
  vec2 uu = U;
  float ct = read(ivec2(uu));
  
  
  vec2 grad = vec2(  
    read(ivec2(uu + vec2(1,0))) - read(ivec2(uu - vec2(1,0))),
    read(ivec2(uu + vec2(0,1))) - read(ivec2(uu - vec2(0,1)))
  );
  uu -= grad*3.*sin(env);
  prev = texture(texPreviousFrame,(uu)/R);
  
  //ct = read(ivec2(U));
  
  float bay = Bayer16(ivec2(U));
  //col = max(col,0);
  //col = col/(1+col);
  col -= col;
  col = ct.xxx*0.05;
  
  if(fract(env/4) < 0.5)
    col = 1.-col;
  
  col = pow(col,vec3(0.554545));
  prev.xyz = mix(prev.xyz,palAppleII[int(dot(prev,prev)*11. + env)%16],0.2);
  //col = mix(col,prev.xyz*2.6,(clamp(dot(col,col)*1,0.,1.))*0.998*pow(0.5 + 0.25*sin(env),0.0001));
  col = mix(col,prev.xyz*1.0,0.9);
  if(fract(env/8.)<0.01){
      col = 1 - col;
  }
  //col = *1.0;
  //col = clamp(col,0.,1.0);

  float dithmd = 0.01 + mod(dot(col,col)*0.6*sin(env*3.14),1.);
  col += (bay*0.5 - 0.5)*dithmd*0.5;
  col = round(col/dithmd)*dithmd;
  //for()
	out_color = vec4(col,0);
}