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
}// point projection
ivec2 proj_p(vec3 p, float t, out float z){
  // arbitrary camera stuff
  float tt = t*0.25;
  //p.xy -= 0.5;
  float s = hash_f_s(uint(tt));
  float sb = hash_f_s(uint(tt + 125));
  
  p.yz *= rot(sin(tt*1.7 + sin(tt))*1.0 + floor(T*0.3));
  p.y -= -0.2;
  p.z += 0.4;
  p.xz *= rot(sin(tt*0.7)*0.3);
  //p.xz *= rot(sin(tt));
  /*
  p.xz -= 0.5;
  p.xz *= rot(tt*(s*2. - 1.0)*0.5 + sb);
  p += sin(vec3(1.1,0.78,0.6)*tt*0.5)*0.02;
  p += sin(vec3(1.1,0.78,0.6)*tt*2.7)*0.02;
  p.xz *= rot(sin(tt*0.125 + sin(tt*0.125) + sb)*0.4);
  p.xy *= rot(sin(tt*0.53 + sb)*0.2*0.4);
  
  //p.z -= -0.4 + s*0.;
  p.y -= 0.2 - s*0.;
  //p.x -= 0.5;
  p.z += 0.8;
  p.yz *= rot(-0.46 + sin(sb*1.5)*0.2);
  */
  
  z = p.z;
  // perspective proj
  p.xy /= p.z*.6;
  
  // depth of field
  float dof_pow = pow(abs(p.z - 0.7 + sin(tt*0.45 + sin(tt*0.4))*0.2)*1.0,2.);
  
  p.xy += sample_disk() * (dof_pow *0.1 + 0.0);
  // convert point to ivec2. From 0 to resolution.xy
  ivec2 q = ivec2((p.xy + vec2(R.x/R.y,1)*0.5)*vec2(R.y/R.x,1)*R);
  if(any(greaterThan(q, ivec2(R))) || any(lessThan(q, ivec2(0)))){
      q = ivec2(-1);
  }
  return q;
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


mat3 orth_mat(vec3 or, vec3 tar){
    vec3 dir = normalize(tar - or);
    vec3 right = normalize(cross(vec3(0,1,0),dir));
    vec3 up = normalize(cross(dir, right));
    return mat3(right, up, dir);
}

void main(void){
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  vec3 ro = vec3(0,0,-4.);
  vec3 rd = normalize(vec3(uv,0.7));
    
  seed = 2151225;
  seed += hashi(uint(U.x)) + hashi(uint(U.y)*125);
  
  vec3 p = vec3(0);
  
  ivec2 id = ivec2(gl_FragCoord.xy);
  if(gl_FragCoord.x < 800){
     
     for(float i = 0.; i < 20; i++){
        float X = hash_f();
       
        if(X < 0.5){
          for(float i = 0.; i < 2; i++){
              p = abs(p) - 0.4;
              p.xz *= rot(0.5 + T*0.02);
              p.yz *= rot(1.8*0.2);
              p *= 1.0;
          } 
        } else {
           p = sin(p*1.6);
        }
        vec3 c = oklch_to_srgb( vec3(1.0,0.1,dot(p,p)*4.0));
       float z = 0.;
       ivec2 q = proj_p(p, T, z);
       add_to_pixel(q, c);
     }
  }
  
  //imageStore(computeTex[0], ivec2(U), uvec4(t*1000));
  
  //imageStore(computeTex[0], ivec2(U), uvec4(t*1000));
  //col = vec3(1);
  vec3 col = vec3(1)*2.0 - read_pixel(ivec2(U))*2.0;
  
  float md = 0.04;
  
  vec2 u = uv;
  
  
  
  col = max(col,0.);
  {
    #define has(x) fract(sin(x*125.5)*125.6)
    #define has2(X) has(has(X.x*35.6 +T*0.01)*415.5 + has(X.y*32.6+T*0.001)*53.6)
      vec2 tmd = 0.5*vec2(1,R.x/R.y);
      vec2 u = vec2(U/R);
      for(float i = 0; i < 20; i++){
        vec2 fluv = floor(u/tmd);
        
        col = vec3(1)*2.0 - read_pixel(ivec2(fluv*tmd*R))*2.0;
        float X = has2(fluv);
        if(X <0.02 * (length(col))){
          break;
        }
        tmd /= 2.0;
      }
  }
  {
      float md = 0.05;
      vec2 u = uv;
      u = mod(u,md) - 0.5*md;
    float d = abs(u.x);
    d = min(d,abs(u.y));
    d -= 0.001;
    //col = mix(col,vec3(0),smoothstep(fwidth(d),0,d)*0.2);
  }

  col = max(col,0);
  col = col/(1+col);
  col = pow(col,vec3(0.454545));
  if(floor(T) == 4.)
  col = 1.-col;
  
  
  //for()
	out_color = vec4(col,0);
}