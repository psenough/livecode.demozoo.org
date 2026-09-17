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
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anythings

#define res v2Resolution
#define frag gl_FragCoord
float PI = acos(-1), TAU = PI * 2.0;
float aspect = res.y / res.x;

#define rep(i,n) for(int i = 0; i < n; i++)

float time = fGlobalTime * 170 / 60;
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

vec3 fade(vec3 t){
    return t * t * (3.0 - 2.0 * t);
}

float noise(vec3 p){
    vec3 i = floor(p);
    vec3 f = fract(p);

    vec3 u = fade(f);

    float n000 = hash33(i + vec3(0,0,0)).x;
    float n100 = hash33(i + vec3(1,0,0)).x;
    float n010 = hash33(i + vec3(0,1,0)).x;
    float n110 = hash33(i + vec3(1,1,0)).x;

    float n001 = hash33(i + vec3(0,0,1)).x;
    float n101 = hash33(i + vec3(1,0,1)).x;
    float n011 = hash33(i + vec3(0,1,1)).x;
    float n111 = hash33(i + vec3(1,1,1)).x;

    // trilinear interpolation
    float nx00 = mix(n000, n100, u.x);
    float nx10 = mix(n010, n110, u.x);
    float nx01 = mix(n001, n101, u.x);
    float nx11 = mix(n011, n111, u.x);

    float nxy0 = mix(nx00, nx10, u.y);
    float nxy1 = mix(nx01, nx11, u.y);

    return mix(nxy0, nxy1, u.z);
}

float fbm(vec3 p){
    float v = 0.0;
    float a = 0.5;
    for(int i = 0; i < 5; i++){
        v += a * noise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

mat3 orthBas(vec3 z) {
  z = normalize(z);
  vec3 up = abs(z.y) < 0.999 ? vec3(0, 1, 0) : vec3(0, 0, 1);
  vec3 x = normalize(cross(up, z));
  return mat3(x, cross(z, x), z);
}
 vec3 cyclic(vec3 p, float pers, float lacu) {
   vec4 sum = vec4(0);
   mat3 rot = orthBas(vec3(2, -3, 1));
 
   for (int i = 0; i < 5; i++) {
     p *= rot;
     p += sin(p.zxy);
     sum += vec4(cross(cos(p), sin(p.yzx)), 1);
     sum /= pers;
     p *= lacu;
   }
 
   return sum.xyz / sum.w;
 }


float hash11(float p){
  return hash33(vec3(p,1.0,1.0)).x;
}

vec3 rot(vec3 p, vec3 n, float a){
  return cos(a) * p + (1.0 - cos(a)) * dot(p,n) * n + cross(n,p) * sin(a);
}

float EaseIn(float x, float n){
    return pow(x, n);
}

float EaseOut(float x, float n){
  return 1.0 - pow(1.0 - x, n);
}

vec2 proj(vec3 p){
  vec2 screenPos =p.xy / p.z;
  screenPos.x *= aspect;
  screenPos = screenPos * 0.5 + 0.5;
  return screenPos;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float sdBox( in vec2 p, in vec2 b ) {
  vec2 d = abs(p) - b;
  return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

// kinakomochi x ukonpower
// hutari no chikara de ganbaru zo~~!

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 c = vec3( 0.0 );
  
  float tn = time + hash33( vec3( uv, 0.0 ) ).x * 0.1;
  vec2 texUv = uv;
  for ( int i = 0; i < 8; i ++ ) {
    
    texUv.x = abs( texUv.x );
    texUv.xy = rot( vec3( texUv, 1.0 ), vec3( 0.0, 0.0, 1.0), time * 0.1 ).xy;
    texUv.y = abs( texUv.y );
  }
  texUv.x += EaseOut( fract( tn * 0.5  ), 5.0 );
 
  if(frag.x < 1000.0){
    vec3 p;
    p = hash33(vec3(frag.xy,1.0)) * 5.0 - 2.5;
    
    p += texture( texSessions, texUv ).xyz * 10.0;
    //add(vec3(0.5),proj(p));
    p.y *= 0.05 * sin( tn * 0.9 );
    p.y += cyclic( vec3( p.xy, length( p.xz ) + time * 0.4 ), 1.0, 1.0 ).x;
    
    //p -= tan(p + time);
  
     p = rot( p, vec3( 1.0, 0.0, 0.0 ), time * 0.1 );
    p += cyclic( vec3( p + EaseOut(fract(time),5.0) + floor(time)), 1.0, 1.0 );
    
    p = rot( p, vec3( 0.0, 1.0, 0.0 ), time * 0.1 );
    add(vec3(0.1),proj(p));

   
    for(int i = 0; i < 4; i++){
       p -= tan(p) * 0.1;
       p.x += hash33(hash33(vec3(i)) + floor(time)).x;
       //p.y += hash33(hash33(vec3(i)) + floor(time)).y;
       p = rot( p, hash33(vec3(i)), time * 0.1 );
       add(vec3(0.01),proj(p));
      
    }
    

  } 

  
  vec2 pUV = frag.xy / res.xy;
  c = getCol(pUV);
  
  c += texture( texSessions, texUv ).xyz * (0.1 + smoothstep( 0.5, 1.0, sin( texUv.x * 2.0 + time )) * 0.3);
  
  for(int i = 0; i < 3; i++){
   c.r += texture( texPreviousFrame, texUv + cyclic(vec3(texUv,1.0),1.0,1.0).xy ).x * 0.1;
  }
  
 
  c += smoothstep( 0.005, 0.003, abs( sdBox( uv, vec2( 0.8, 0.4 ) ) ) ) * smoothstep ( 0.0,0.001, sin( (uv.x + uv.y) * 100.0 + time * 6.0)) * 0.5 ;
  
  vec2 A=   (uv) * 3.0 + 0.5;
  c += texture(texShort, clamp((uv * vec2(1.0,-1.0)) * 3.0 + 0.5,0.0,1.0)).xyz * 1.0 * step(A.x,1.0) * step(-A.x,0.0) * step(A.y,1.0) * step(-A.y,0.0);//  * EaseOut(fract(time * 0.5),3.0); 

  //c += texture( texPreviousFrame, texUv).xyz;
	out_color = vec4( c, 1.0 );
  
  
}