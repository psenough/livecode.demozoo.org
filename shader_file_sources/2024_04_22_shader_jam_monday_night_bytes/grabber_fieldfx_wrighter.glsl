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

void main(void){
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float dmd = 0.001;
  
  vec2 uvid = floor(uv/dmd*0.1);
  uv = floor(uv/dmd)*dmd;
  vec2 marchu = uv;
  
  vec3 ro = vec3(0,0,-4.);
  vec3 rd = normalize(vec3(uv,3.7));
    
  seed = 2151225;
  seed += hashi(uint(U.x)) + hashi(uint(U.y)*125);
  
  vec3 p = vec3(0);
  
  vec3 col = vec3(0);
  
  vec2 u = uv;
  
  
  TT = floor(T*0.3 + sin(T*0.6));
  ro = normalize(sin((T + TT*111.0)*vec3(0.8,0.3,0.79)))*4.0;
  
  float md = 1/2.0;
  float X = 0.0;
  if(true){
      for(float i = 0.; i < 35.0; i++){
          marchu = floor(uv/md);
          X = h(marchu.x*44.21 + h(marchu.y + 1256.1)*12.5 + floor(T*1)); 
          //X *= 
          
          //if(marchu)
          md *= 0.5;
          if( X > 0.97){
              break;
          }
          X *= exp(-i);
      }
      marchu *= md;
  }  
  
  vec3 tar = sin((T)*vec3(0.8,0.3,0.79)*2.)*0.4;
  
  rd = normalize(vec3(marchu,0.8 + sin(T+sin(T))*0.));
  
  mat3 mat = orth(tar, ro);
  rd = mat * rd;
  
  col = max(col,0.);
  if (false){
      #define has(x) fract(sin(x*125.5)*125.6)
      #define has2(X) has(has(X.x*35.6 +T*0.0 + 4 + floor(T))*415.5 + has(X.y*32.6+T*0.00)*53.6)
      vec2 tmd = 0.5*vec2(1,R.x/R.y);
      vec2 u = vec2(U/R);
      for(float i = 0; i < 20; i++){
        vec2 fluv = floor(u/tmd);
        
        //col = vec3(1)*2.0 - read_pixel(ivec2(fluv*tmd*R))*2.0;
        float X = has2(fluv);
        if(X <0.01 * (length(col))){
          break;
        }
        tmd /= 2.0;
      }
  }
  
      float bpm = 174;
      float tb = T/60*bpm*0.25;
      float tid = mod(floor(tb),3);
      float env = mod(tb,1.);
      env = exp(-env*2.) * smoothstep(0.,0.1,env);
      
      float sz = env;
      if(tb < 0.5){
          sz *= 0.;
      }
  {
    float t = 100.0;
    for(float i = 0.; i < 70.; i++){
        vec3 q = normalize(sin(i*vec3(421.,15.6,120.352)+T*0.1 + env));
        q = mat * q;
        q.xy /= q.z*18.0;
        float sd;
        if(mod(i,8.0) < 3.0){
            sd = length(q.xy - marchu);
            sd -= 0.1*sin(i+T);
        } else {
            q.xy -= marchu;
            q.xy *= rot(i);
            sd = abs((q.xy).x) - 0.001;
        }
        sd -= 0.0001;
        vec3 cc = 0.5 + 0.5 * sin(i) * vec3(1);
        cc = palAppleII[int(16.*cc.x + T + env)%16];
        
        if(mod(i,9) < 2){
          
        } else {
         
        col = mix(col,cc*(1-col),smoothstep(fwidth(sd),0.,sd)); 
        }
    }
  }
  
  if(false){
      float bpm = 174;
      float tb = T/60*bpm*0.25;
      float tid = mod(floor(tb),3);
      float env = mod(tb,1.);
      env = exp(-env*2.) * smoothstep(0.,0.1,env);
      
      float sz = env;
      if(tb < 0.5){
          sz *= 0.;
      }
      for(float i = 0.; i < 3; i++){
      float d = length(uv) - sz*0.2;
        
      if(d < 0.){
          col = 1.-col;
        col *= 0.2;
          //col *= 0.;
      }
          uv = abs(uv) - 0.2;
        uv *= 2.;
      //uv = abs(uv);
      }
        
  }
  
  vec4 prev = texture(texPreviousFrame,U/R);
  vec2 dr = vec2(dFdx((prev.g)),dFdy((prev.g)));
  
  prev = texture(texPreviousFrame,U/R+dr*100);
  //col += dr.xyx*110.4;
  
  float bay = Bayer16(uvid);
  col = max(col,0);
  //col = col/(1+col);
  col = pow(col,vec3(0.554545));
  if(mod(T/4,2.) < 1.0){
    col = mix(col,prev.xyz,(clamp(dot(col,col)*1,0.,1.))*0.99*pow(0.5 + 0.5*sin(T),0.01));
  } else {
    col = mix(col,prev.xyz,(1.-clamp(dot(col,col)*1,0.,1.))*0.99*pow(0.5 + 0.5*sin(T),0.01));  
  }
  float dithmd = 0.2;
  col += (bay*0.5 - 0.5)*dithmd*0.5;
  col = round(col/dithmd)*dithmd;
  //for()
	out_color = vec4(col,0);
}