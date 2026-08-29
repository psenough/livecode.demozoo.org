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
}

float TT;


mat3 orth(vec3 tar, vec3 or){
    vec3 dir = normalize(tar - or);
    vec3 right = normalize(cross(vec3(0,1,0),dir));
    vec3 up = normalize(cross(dir, right));
    return mat3(right, up, dir);
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

vec3 ro;
mat3 mat;

// point projection
ivec2 proj_p(vec3 p){
  p -= ro;
  p *= mat;
  
  p.xy /= p.z*1.;
  
  // depth of field
  p.xy += sample_disk() * abs(p.z - 5. + sin(T))*0.003;
  
  if(p.z < 0){
    return ivec2(-1);
  }
  ivec2 q = ivec2((p.xy + vec2(R.x/R.y,1)*0.5)*vec2(R.y/R.x,1)*R);
  return q;
}


vec3 erot(vec3 p, vec3 ax, float ro) {
    return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}
vec3 cyclic(vec3 p, float pers, float lacu) {
    vec4 sum = vec4(0);
    //mat3 rot = orthBas(vec3(2, -3, 1));

    for(int i = 0; i <1; i++) {
        //p *= rot;
        p = erot(p,normalize(vec3(1)),14.);
        p += sin(p.zxy + sin(T*0.3))*1.5;
        sum += vec4(cross(cos(p), sin(p.yzx)), 0.8);
        sum /= pers;
        p *= lacu;
    }

    return sum.xyz / sum.w;
}
float map(vec3 p){
  p.xz *= rot(p.y + T + sin(T + p.y*2.));
  p -= cyclic(p*2., 1.4, 1.)*3.;
  
  float d = length(p.xz) - 1.5 + (clamp(abs(p.y)*0.4,0.,1.)) ;
  
  return d;
}

vec3 get_normal(vec3 p){ 
  vec2 t = vec2(0.001,0.);
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
  
  vec4 t_prev = texture(texPreviousFrame,vec2(gl_FragCoord.xy / v2Resolution.xy));
  vec2 off = vec2(dFdx(t_prev.x),dFdy(t_prev.x));
  
  vec2 marchu = uv;
  
  ro = vec3(0,0,-4.);
  vec3 rd = normalize(vec3(uv,0.7));
    
  seed = 2151225;
  seed += hashi(uint(U.x)) + hashi(uint(U.y)*125);
  
  vec3 p = vec3(0);
  
  vec3 col = vec3(0);
  
  
  vec2 u = uv;
  
  
  
  //TT = floor(T*0.3 + sin(T*0.6));
  
  //ro = normalize(sin(T*vec3(0.8,0.3,0.79)))*4.0;
  float tt = T;
  tt += floor(T/5);
  ro = vec3(
    sin(tt*0.2),
    sin(tt*0.15),
    cos(tt*0.2)
  )*3.;
  vec3 tar = sin((T)*vec3(0.8,0.3,0.79)*2.)*0.1;
  
  rd = normalize(vec3(marchu,1));
  
  mat = orth(tar, ro);
  rd = mat * rd;
  ro += sin(vec3(3,2,1)*T*0.2)*0.2;
  ro += sin(vec3(3,2,1)*T*1.2)*0.02;
  col = vec3(1);
  
  bool hit = false;
  if(gl_FragCoord.x < 50){
    //vec3 p = vec3(sample_disk(),0);
    
    
    for(float i = 0; i < 92; i++){
      float idx =hash_f()*0.1 * sin(gl_FragCoord.y)*3.;
      vec3 p = cyclic(vec3(1,4.4,idx*2. + (mod(gl_FragCoord.y,140.)*4.)), 4., .8)*3.;
      
      vec3 q = vec3(p);
      
      vec3 n = cyclic(p, 0.4, 0.8);
      //p += n*1.2;
      
      ivec2 pp = proj_p(q);
      pp += ivec2( sample_disk()*4.* sin(p.z*5. + T*5));
      add_to_pixel(pp, vec3(pow(0.5 + 0.5*sin(idx*50. + T)*0.5,2.))*5550);
    }
  }
  
  p = ro;
  float t = 0.;
  for(int i = 0; i < 425; i++){
    float d = map(p)*0.02;
    if(d < 0.001){
      hit = true;
      break;
    }
    if(t > 5.){
      break;
    }
    p = ro + rd * (t+=d);
  }
  if(hit){
    vec3 n = get_normal(p);
    //
    #define A(a) smoothstep(0.,1.,map(p + a)/a)
    float ao = A(0.3) * A(0.05) * A(0.2) * A(0.1); 
    //ao *= dot(n,normalize(vec3(1)));
    //col -= step(ao,0.4);
    col.rg -= smoothstep(0.4,0.,ao)*6.;
    //col += n;
  }

  vec3 s = read_pixel(ivec2(gl_FragCoord.xy))*0.1;
  
  if(hit){
   s *= 0.0001;  
  }
  col -=s;
  col *= 2.;
  col = max(col,0);
  col = col/(1+col);
  col = pow(col,vec3(0.454545));
  
  col = hsv2rgb(col); 

  //col.r += floor(T)*0.2;
  col.g *= 0.5;
  col = rgb2hsv(col);
  
  col = rgb2hsv(col);
  col.r += floor(T)*0.2;
  col.r = mod(col.r,6);
  col = hsv2rgb(col); 

  //col = 1.-col;
  
  uv = vec2(gl_FragCoord.xy / v2Resolution.xy);
  uv +=off*0.002;
  t_prev = texture(texPreviousFrame,uv);
  
  //uv += fwidth();
  //col = 1.-col;
  
  col.rgb = mix(col.rgb,t_prev.rbg,vec3(0.1,0.7,0.9)*0. + 0.95*smoothstep(1.,0.,fract(T*0.3)));
  if(abs(uv.x + sin(floor(T))) < 0.2){
      col = 1.-col;
  }
  
  //for()
	out_color = vec4(col,0);
}