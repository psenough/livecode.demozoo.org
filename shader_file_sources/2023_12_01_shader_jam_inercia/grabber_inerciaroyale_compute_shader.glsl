#version 420 core

/****
Radio bonzo

Credit: 
 fw-pathtrace.glsl 
****/

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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


#define U gl_FragCoord.xy
#define R vec2(v2Resolution.xy)
#define T fGlobalTime 

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

// point projection
ivec2 proj_p(vec3 p, float t){
  // arbitrary camera stuff
  float tt = t*2;
  p += sin(vec3(1.1,0.78,0.6)*tt*0.3)*0.1;
  p += sin(vec3(1.1,0.78,0.6)*tt*1.)*0.1;
  p.xz *= rot(tt*0.25 + sin(tt*0.25));
  p.xy *= rot(sin(tt*0.3)*0.2);
  p.z -= -4.;
  
  // perspective proj
  p.xy /= p.z*0.8;
  
  // depth of field
  //p.xy += sample_disk() * abs(p.z - 5. + sin(T))*0.01;
  
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

float sd_box(vec3 p, vec3 s){
  p = abs(p) - s;
  return max(p.x,max(p.y,p.z));
}

float map(vec3 p){
  float d = 1000;
  
  for(float i = 0; i < 5; i++){
    p = abs(p) - 0.2;
    p.xz *= rot(0.25);
    p.yz *= rot(0.5 + T*0.);
  }
  d = sd_box(p, vec3(0.2));
  return d;
}
vec3 get_normal(vec3 p){
  vec2 t = vec2(0.01,0);
  return normalize(vec3(
    map(p + t.xyy) - map(p - t.xyy),
    map(p + t.yxy) - map(p - t.yxy),
    map(p + t.yyx) - map(p - t.yyx)
  ));
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
void main(void){
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  // Init hash
	seed = 215125125;
  seed += hashi(uint(U.x)) + hashi(uint(U.y)*125);
	
  
  vec3 col = vec3(0);
  
  // choose random hue
  float hue = hash_f();
  vec3 att = hsv2rgb(vec3(hue*1,1,1));
  
  // time envelopes
  float t = T*1.4;
  float env_a = floor(t) + pow(fract(t),14);
  t*=1.2;
  float env_b = floor(t) + pow(fract(t),14);
  
  // Only run for the first 100 horizontal pixels
  if(gl_FragCoord.x < 200){
    // light pos
    vec3 p = vec3(1);
    p = normalize(sin(vec3(3.4,2.2,1.2)*(env_a)*0.5));
    
    if(gl_FragCoord.x < 50){
      p = normalize(sin(vec3(3.1,2.1,1.5)*(env_b)*0.4));
    }
    if(gl_FragCoord.y < R.y*0.5){
      p = -p;
    }
    
    p*=0.1;
    if(hash_f() < 1.0){
      p *= 15.;
    }
    // aim towards middle of screen
    vec3 rd = normalize((hash_v3()-0.5)*(0.01 + 3. * float(gl_FragCoord.y<30 || gl_FragCoord.y > R.y - 30)) - p);
    
    // side is 1 outside and -1 inside
    float side = sign(map(p));
    
    const float max_bounces = 17;
    float dith = hash_f();
    
    // raymarch/refract 
    for(float bnc = 0; bnc < max_bounces; bnc++){
      p += rd * 0.06*dith;
      bool hit = false;
      float d = 0;
      for(float i = 0.; i < 100; i++){
        p += rd * min(d,0.01);
        
        d = map(p) * side;
        
        if(d < 0.001){
          hit = true;
          break;
        } else if(i == 99){
          break;
        }
        // draw
        ivec2 q = proj_p(p, T);
        add_to_pixel(q, att);
      }
      if(hit){
          // refraction/reflection logic
          att *= 0.7;
          vec3 n = get_normal(p) * side;
          float ior = 1.5;
          ior = mix(ior,1.7,hue);
         
          vec3 prev_rd = rd;
          if(side > 0){
            rd = refract(rd,n,ior);
          } else {
            rd = refract(rd,n,1/ior);
          }
          // total internal reflection
          if(rd == vec3(0)){
            rd = reflect(prev_rd,n);
            p += n*0.002;
          } else{
            p -= n * 0.02;
            side *= -1.;
          }
      } else {
        break;
      }
    }
    
  }
  
  
  // display prev frame's image
  vec3 s = read_pixel(ivec2(gl_FragCoord.xy))*0.01;
  
  // tonemap stuff
  s = s/(1+s*1.);
  s = mix(s,smoothstep(0.,1.,s),0.);
  col = max(s,0.);
  col = pow(col,vec3(.45454));
  
  
	out_color = vec4(col,0);
}