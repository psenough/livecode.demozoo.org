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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// Can you see? 
// Yeah!
// Enjoy Sessions!

const float TAU = 2.0 * acos(-1.0);
float time;
int intTime;

#define C_HASH 0x20242024u

vec3 hash33(vec3 p){
  uvec3 x = floatBitsToUint(p);
  x = C_HASH * ((x >> 8)^x.yzx);
    x = C_HASH * ((x >> 8)^x.yzx);
    x = C_HASH * ((x >> 8)^x.yzx);
  return vec3(x) / float(-1u);
}

vec2 hash21(float p){
  return hash33(vec3(p,1.0,2.0)).xy;
}
float hash11(float p){
  return hash33(vec3(p,1.0,2.0)).x;
} 

float sdSphere(vec3 p, float r){
  return length(p) - r;
}
float sdBox(vec3 p, vec3 b){
  vec3 q = abs(p) - b;
  return length(max(q,vec3(0))) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 rot(vec3 p, vec3 n, float a){
  return p * cos(a) + sin(a) * cross(n,p) + (1.0 - cos(a)) * dot(p,n) * n;
}

int mIndex;
vec3 lp;

float map(vec3 p){
  mIndex = 0;
  
  p = rot(p, vec3(0,0,1), abs(p.x + 1.0) * 0.05 + time);
  p = rot(p, vec3(1,0,0), abs(p.z + 0.3) * 0.05 + time);
    p = rot(p, vec3(0,1,0), abs(p.y) * 0.01 + time);
  
  if(intTime % 1 == 0) p.xy = mod(p.xy,2.0) -1.0;
  
  p.z = abs(p.z);
 
  float d = sdSphere(p + vec3(0.0,0.5,0.0),0.4);
  
  float d1 = sdBox(p,vec3(1.0));
  d1 = max(-sdBox(p - vec3(0,0,0.2),vec3(0.9)), d1);
  if(d1 < d) mIndex = 1;
  d = min(d1,d);
  
  float d2 = sdBox(p - vec3(0.0,0.88,0.0),vec3(0.4,0.05,0.4));
  if(d2 < d) mIndex = 2;
  d = min(d2,d);
  
  lp = p;
  return d * 0.5;
}

vec3 getNormal(vec3 p){
  vec2 eps = vec2(0.001,0.0);
  return normalize(vec3(
    map(p + eps.xyy) - map(p - eps.xyy),
      map(p + eps.yxy) - map(p - eps.yxy),
      map(p + eps.yyx) - map(p - eps.yyx)
  ));
}

struct Info{
  vec3 p;
  vec3 n;
  vec3 col;
  vec3 emi;
};

bool raymarch(vec3 ro, vec3 rd, inout Info info){
  vec3 pos = ro;
  float d = 0;
  for(int i = 0; i < 100; i++){
    d = map(pos);
    if(d < 0.001){
      info.p = pos;
      info.n = getNormal(pos);
      info.col = vec3(0.8);
      info.emi = vec3(0.0);
      if(mIndex == 1){
        if(lp.x < -0.88) info.col = vec3(1.0,0.2,0.2); 
                if(lp.x > 0.88) info.col = vec3(0.2,1.0,0.2); 
      }
      if(mIndex == 2) info.emi = vec3(2.0,1.8,1.5) * 2.0;
      return true;
    }
    pos += d * rd;
    }
  return false;
}

vec3 worldToLocal(vec3 r,vec3 x, vec3 y, vec3 z){
  return vec3(dot(r,x),dot(r,y),dot(r,z));
}

vec3 localToWorld(vec3 r,vec3 x, vec3 y, vec3 z){
  return vec3(dot(r,vec3(x.x,y.x,z.x)),dot(r,vec3(x.y,y.y,z.y)),dot(r,vec3(x.z,y.z,z.z)));
}

void basis(vec3 n, inout vec3 t, inout vec3 b){
  t = normalize(cross(n, (abs(n.y) < 0.99) ? vec3(0,1,0) : vec3(0,0,-1)));
  b = cross(t,n);
}

vec3 cSample(vec2 xi){
  float theta = acos(1.0 - 2.0 * xi.x) * 0.5;
  float phi = TAU * xi.y;
  return vec3(sin(theta) * cos(phi), cos(theta), sin(theta) * sin(phi));
}

vec3 sSample(vec2 xi,float n){
  float theta = acos(pow(1.0 - xi.x, 1.0 / (1.0 + n)));
  float phi = TAU * xi.y;
  return vec3(sin(theta) * cos(phi), cos(theta), sin(theta) * sin(phi));
}


uint seed;
float rnd1(){
  float s = hash11(float(seed));
  seed = C_HASH * ((seed >> 8)^seed);
  return s;
}

vec3 pathtrace(vec3 ro, vec3 rd){
  vec3 LTE = vec3(0);
  vec3 tp = vec3(1.0);
  for(int i = 0; i < 4; i++){
    Info info;
    if(!raymarch(ro,rd,info)){
      break;
    }
    
    if(length(info.emi) > 0.5){
      LTE = tp * info.emi;
      break;
    }
    
    vec3 n = info.n;
    vec3 t,b;
    basis(n,t,b);
    
    vec3 localwo = worldToLocal(-rd,t,n,b);
    
    vec3 localwi; 
    if(int(floor(intTime * 0.5 + 1.0)) % 1 == 0 ) localwi = cSample(vec2(rnd1(),rnd1()));
    else localwi = reflect(localwi,-sSample(vec2(rnd1(),rnd1()),1000.0));
    
    
    vec3 wi = localToWorld(localwi,t,n,b);
    vec3 bsdf = info.col;
    
    tp *= bsdf;
    ro = info.p + 0.01 * wi;
    rd = wi;
    
    }
  
  return LTE;
}
    
vec3 culc(vec3 ro, vec3 rd){
  vec3 col = vec3(0.0);
  col = pathtrace(ro,rd);
  return col;
}

#define frag gl_FragCoord
#define r v2Resolution

uvec3 pack(vec4 p){
    uvec3 s = uvec3(p.xyz * 255.0);
    s.z = (s.z << 8) | (uint(p.w) & 0xff);
    return s;
}

vec4 unpack(uvec3 s){
    vec4 p;
   p.xy = s.xy / 255.0;
  p.w = float(s.z & 0xff);
  p.z = (s.z >> 8) / 255.0;

    return p;
}

void store(vec4 col, ivec2 idx){
  uvec3 s = pack(col);
  imageStore(computeTex[0],idx,s.xxxx);
  imageStore(computeTex[1],idx,s.yxxx);
    imageStore(computeTex[2],idx,s.zxxx);
}

vec4 load(ivec2 idx){
  uvec3 s = uvec3(
    imageLoad(computeTexBack[0],idx).x,
    imageLoad(computeTexBack[1],idx).x,
    imageLoad(computeTexBack[2],idx).x
  );
  
  return unpack(s);
}
void main(void)
{
  vec2 uv = (frag.xy * 2.0 - r.xy) / r.y;
  vec2 texuv = frag.xy / r.xy;
  ivec2 idx = ivec2(frag.xy);
  
  time = fGlobalTime;
  intTime = int(time);
  
  vec3 col = vec3(0.0);
  vec3 texCol = vec3(0.0);
  
  seed = uint(time * 100.0) * uint(frag.x + r.y * frag.y);
  bool reset = false;
  reset = intTime % 2 != 0;
  
  vec2 offset = hash21(floor(time)) * texture(texFFTSmoothed,0.2).x * 0.5;
  //texuv = texuv * 3.0 * hash21(floor(time * 10.0))  + time;
  texuv *= 3.0;
  if(intTime % 2 == 0){
    
  texCol.x = texture(texSessions,texuv).x;
  texCol.y = texture(texSessions,texuv + offset).x;  
  texCol.z = texture(texSessions,texuv - offset).x;
  }
  else{
      texCol.x = texture(texSessionsShort,texuv).x;
  texCol.y = texture(texSessions,texuv + offset).x;  
  texCol.z = texture(texSessions,texuv - offset).x;
  }
  if(!(texuv.y < 1.0 && texuv.x > 2.0)) texCol = vec3(0.0);
  vec3 ro = vec3(0,0,10);
  vec3 rd = normalize(vec3(uv,-1.0));
  
  if(!reset) time = floor(time);
   col = culc(ro,rd);
   if(intTime % 2 == 0) col += texCol;
  
  vec4 accum = load(idx);
  if(accum.w < 255.0) accum += vec4(col,1.0);
  if(reset) accum = vec4(col,1);
 
  
  store(accum,idx);
  
  col = accum.xyz / accum.w;
  
  
	out_color = vec4(col,1.0);
}