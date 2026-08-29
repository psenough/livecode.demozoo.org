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
  float tt = t*1;
  p += sin(vec3(1.1,0.78,0.6)*tt*0.3)*0.1;
  p += sin(vec3(1.1,0.78,0.6)*tt*1.)*0.1;
  p.xz *= rot(tt*0.25 + sin(tt*0.25));
  p.xy *= rot(sin(tt*0.3)*0.2);
  p.z -= -3.;
  
  // perspective proj
  p.xy /= p.z*1.0;
  
  // depth of field
  p.xy += sample_disk() * abs(p.z - 3.5 + sin(T)*0.5)*0.008;
  
  // convert point to ivec2. From 0 to resolution.xy
  ivec2 q = ivec2((p.xy + vec2(R.x/R.y,1)*0.5)*vec2(R.y/R.x,1)*R);
  if(any(greaterThan(q, ivec2(R))) || any(lessThan(q, ivec2(0))) || p.z < 0){
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
    vec3 q = p;
    float d = 10000;
    for(int i = 0; i < 5 + (uint(T/4))%3; i++){
      p = abs(p) - 0.15;
      p.xz *= rot(0.6);
      p.yz *= rot(0.2 + T*0.2 + i + sin(T*0.1));
    }
    d = length(p) - 0.1;
    d = max(d,-sd_box(p, vec3(0.2,0.05,0.1)));
    if(uint(T/3) % 3 == 0){
      d = sd_box(p, vec3(0.04,0.06,0.4));
    }
    //d = min(d,abs(q.y) - 0.1);
    return d;
}

mat3 get_orth_mat(vec3 ro, vec3 tar){
  vec3 dir = normalize(tar - ro);
  
  vec3 right = normalize(cross(vec3(0,1,0), dir));
  vec3 up = normalize(cross(dir, right));
  
  
  return mat3(right, up, dir);
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

vec3 get_normal(vec3 p){
  vec2 t = vec2(0.01,0);
  return normalize(vec3(
    map(p + t.xyy) - map(p - t.xyy),
    map(p + t.yxy) - map(p - t.yxy),
    map(p + t.yyx) - map(p - t.yyx)
  ));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  // Init hash
	seed = 215125125;
  seed += hashi(uint(U.x)) + hashi(uint(U.y)*125);
	
  vec3 col = vec3(0);
  
  ivec2 id = ivec2(U);
  
  vec3 cam_pos = vec3(4,0,0);
  
  float hue = hash_f();
  
  float sat = 1.0;
  if(hash_f() < 0.){
    cam_pos.xz *= rot(0.7 + T);
    cam_pos.xy *= rot(3.7-T);
    hue = pow(hue,0.05); hue += 0.7;
    hue += sin(T*0.1+sin(T)*0.1 + uv.y)*0.1;
    sat *= 0;
  } else {
  
    hue = pow(hue,4.);
  }
  vec3 att = hsv2rgb(vec3(hue*1,sat,1));
  
  vec3 tar = vec3(0);
  
  mat3 cam_mat = get_orth_mat(cam_pos, tar);
  
  
  float fov = 1.0;
  if(uint(T)%5 < 2){
    //fov = 0.005;
  }
  for(int k = 0; k < 1; k++){
    uv += (hash_v2()*2. - 1.)/R;
    vec3 rd = cam_mat * normalize(vec3(uv,fov));
    
    vec3 start_p = cam_pos + rd*0.;
    start_p *= 0.7 + sin(T)*0.;
    
    if(uint(T)%5 < 2){
    //  start_p *=0.01;
    }
    
    vec3 ro = start_p;
    vec3 p = ro;
    bool hit = false;
    float side = sign(map(p));
    
    for(int bnc = 0; bnc < 4; bnc++){
      
      float d;
      for(float i = 0.; i < 30; i++){
        d = map(p)*side;
        //d = sign(d) * min(abs(d),0.1);
        p += rd*d*1.0;
        ivec2 pproj = proj_p(p,T);
        //add_to_pixel(pproj, att*0.01);
        if(d < 0.005){
          hit = true;
          ivec2 pproj = proj_p(p,T);
          if(pproj.x >= 0){
            add_to_pixel(pproj, att);
          } 
          break;
        
        }
      }
      
      if(hit){
          // refraction/reflection logic
          att *= 0.7;
          vec3 n = get_normal(p) * side;
          float ior = 1.;
          ior = mix(ior,1.8,hue);
         
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
  
  
  
  col += read_pixel(id);
  //vec3 rd = 
  col*=0.6;
  col = col/(1+col);
  col = pow(col,vec3(0.454545));
  
	out_color = vec4(col,1);
}