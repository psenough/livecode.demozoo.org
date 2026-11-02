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

#define res v2Resolution
#define frag gl_FragCoord
float PI = acos(-1), TAU = PI * 2.0;
float aspect = res.y / res.x;

#define rep(i,n) for(int i = 0; i < n; i++)

float time = fGlobalTime * 160 / 60;
float bfr = fract(time);
float bfo = floor(time);
int bfoi = int(bfo);

void add(vec3 c, vec2 idx){
  ivec2 id = ivec2(idx * res) ;
  imageAtomicAdd(computeTex[0], id, uint(c.x * 255.0));
  imageAtomicAdd(computeTex[1], id, uint(c.y * 255.0));
  imageAtomicAdd(computeTex[2], id, uint(c.z * 255.0));
}

vec3 getCol(vec2 idx){
  ivec2 id = ivec2(idx * res);
  vec3 col;
  col.x = float(imageLoad(computeTexBack[0], id).x) / 255.0;
  col.y = float(imageLoad(computeTexBack[1], id).x) / 255.0;
  col.z = float(imageLoad(computeTexBack[2], id).x) / 255.0;
  
  return col;
}

#define C_HASH 0x20252025u
vec3 hash33(vec3 p){
  uvec3 x = floatBitsToUint(p);
  x = C_HASH* ((x >> 8u)^(x.yzx));
    x = C_HASH* ((x >> 8u)^(x.yzx));
    x = C_HASH* ((x >> 8u)^(x.yzx));
  return x / float(-1u);
}

vec3 rot(vec3 p, vec3 n, float a){
  return cos(a) * p + (1.0 - cos(a)) * dot(p,n) * n + cross(n,p) * sin(a);
}

float EaseOut(float x, float n){
  return 1.0 - pow(1.0 - x, n);
}

float dot2(vec2 p){
  return dot(p,p);
}

float sdLove(vec2 p )
{
    p.x = abs(p.x);

    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}

vec2 proj(vec3 p){
  p = rot(p, vec3(1,0,0), 10.0);
  vec2 screenPos =p.xy / p.z;
  screenPos.x *= aspect;
  screenPos = screenPos * 0.5 + 0.5;
  return screenPos;
}

float sdSphere(vec3 p, float r){
  return length(p) - r;
}

float extrude(float d, float h, float z){
  vec2 w = vec2(d, abs(z) - h);
  return min(max(w.x,w.y),0.0) + length(max(w,0.0));
}

float map(vec3 p){
  vec3 p1 = p;
  if(hash33(vec3(bfoi)).x > 0.7) p1 = rot(p1, normalize(hash33(vec3(bfo))), time * 0.1);
  if(bfoi % 2 == 0) p1 = mod(p1, 2.0) - 1.0;
  float d = sdSphere(p1,1.0);
  if(hash33(vec3(bfoi)).x < 0.7)d = extrude(sdLove(p1.xy),10.0,p1.z);
  return d;
}
  
vec3 getNormal(vec3 p){
  vec2 eps = vec2(0.01,0.0);
  return normalize(
  vec3(
    map(p + eps.xyy) - map(p - eps.xyy),
    map(p + eps.yxy) - map(p - eps.yxy),
    map(p + eps.yyx) - map(p - eps.yyx)  
  )
  );
}

vec3 mh(vec3 x){
  return x * 2.0 - 1.0;
}

void main(void)
{
	vec2 uv = (frag.xy * 2.0 - res.xy) / res.y;
  vec2 uv2 = uv;
  vec2 texUV = frag.xy / res.xy;
  
  uv.x = tan(length(uv) + time * 0.1);
  vec3 col = vec3(0.0);
  vec2 heartUV = uv;
  heartUV.y += EaseOut(bfr,2.0) + bfo;
  heartUV = mod(heartUV,2.0) - 1.0;
  heartUV.y += 0.5;
  float d = sdLove(heartUV);
  // col = vec3(smoothstep(0.01,0.00,d));
  
  if(frag.x < 300.0){
    vec3 p;
    p = hash33(vec3(frag.xy,1.0)) * 5.0 - 2.5;
    
    float n = 10.0;
    rep(i,n){
      if(bfoi % 3 == 1) p = rot(p, vec3(0,1,2), time);
      if(bfoi % 2 == 0) p -= tan(p + time * 0.1);
      p -= mix(vec3(0.0), getNormal(p) * map(p), pow(sin(fract(time * 0.05) * TAU),2.0));
      p = rot(p, vec3(0,1,1), p.z + time);
      if(bfoi % 5 == 3) p += bfoi % 5;
      
      // p = rot(p,mh(hash33(vec3(i + 1))),EaseOut(bfr,2.0) + bfo);
      // p -= getNormal(p) * map(p) * 1.0;
      // p += mh(hash33(p)) * pow(length((p - cpos) * 5.0),0.01) * 0.01;
      
     

      add(vec3(sin(i), cos(i) + sin(bfoi % 5) + 0.3, 1.0) * 0.2, proj(p));
    }
    //p -= tan(p * 0.1);

  }
  
  col += getCol(texUV);
  
  vec3 back = vec3(0.0);
  float n = 5.0;
  rep(i,n){
    vec2 offset = length(uv2) * normalize(uv2) * 0.1 * i * texture(texFFT,0.2).x * 2.0;
    back.x += texture(texPreviousFrame,texUV + offset * 0.5).x;
    back.y += texture(texPreviousFrame,texUV + offset * 0.2).y;
    back.z += texture(texPreviousFrame,texUV + offset * 0.1).z;
 }
 back *= vec3(0.3,0.4,1.0);
 back /= n;
 
 col = mix(col, back, 0.8);
 //if(bfoi % 2 == 0) ;
 col += texture(texFFTSmoothed, (sin(uv2.x / uv2.y) - time * 2.0) + length(uv2) * 10.0).xxx * pow(length(uv2) * 0.5,5.0);
 
	out_color = vec4(col,1.0);
}