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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define frag gl_FragCoord
#define res v2Resolution
float Pi = acos(-1);
float time = fGlobalTime;
float tb = floor(time);
float tf = fract(time);

#define C_HASH 1919191919
vec3 hash33(vec3 p){
  uvec3 x = floatBitsToUint(p);
  x = C_HASH* ((x >> 8u)^(x.yzx));
    x = C_HASH* ((x >> 8u)^(x.yzx));
    x = C_HASH* ((x >> 8u)^(x.yzx));
  return x / float(-1u);
}


float Ease(float x, float n){
  return pow(x,n);
}

void Add(vec3 c, vec2 p){
  ivec2 idx = ivec2(p * res);
  imageAtomicAdd(computeTex[0], idx, uint(c.x * 255.0));
  imageAtomicAdd(computeTex[1], idx, uint(c.y * 255.0));
  imageAtomicAdd(computeTex[2], idx, uint(c.z * 255.0));
}

vec3 Get(vec2 p){
  ivec2 idx = ivec2(p * res);
  vec3 col;
  col.x = float(imageLoad(computeTexBack[0], idx).x) / 255.0;
  col.y = float(imageLoad(computeTexBack[1], idx).x) / 255.0;
  col.z = float(imageLoad(computeTexBack[2], idx).x) / 255.0;
  
  return col;
}

vec2 Proj(vec3 p){
  vec2 s = p.xy / p.z;
  s = s * res.y / res.x;
  s = s * 0.5 + 0.5;
  return s;
}

vec3 rotate(vec3 p, vec3 n, float angle){
  return cos(angle) * p + (1.0 - cos(angle)) * dot(p,n) * n + cross(n,p) * sin(angle);
}
void main(void)
{
	vec2 uv = (frag.xy * 2.0 - res.xy) / res.y;
  
  vec2 texUv = frag.xy / res.xy;
  vec3 col = texture(texTex1,texUv).xyz;
  
  vec2 t = frag.xy / res.xy;
  if(uv.x < 0.5){
    vec3 p = hash33(vec3(uv,1.0)) * 2.0 - 1.0;
    p -= tan(p);

    for(int i = 0; i < 10; i++){
      if(int(tb) % 1 == 0) p -= tan(p);
      vec3 axis = vec3(0,0,1);
      if(int(tb) % 2 == 0) axis = vec3(1,0,0);
      p = mod(p, vec3(hash33(vec3(tb)).x * 10.0)) - 1.5;
      //if(int(tb) % 2 == 0) axis = normalize(hash33(vec3(tb)) * 2.0 - 1.0);
      p = rotate(p, axis, time + p.z);
      //p = rotate(p, vec3(1.0), length(p));
      Add(vec3(sin(i), cos(i), 1.0) * 0.1,Proj(p - vec3(0.0)));
    }

  }

  
  vec3 back = vec3(0.0);
  for(int i = 0; i < 5; i++){
    vec2 offset = length(uv) * normalize(uv) * 0.1 + i * texture(texFFT,0.2).x;
    back.x += texture(texPreviousFrame, texUv + offset * 0.5).x;
        back.y += texture(texPreviousFrame, texUv + offset * 0.2).y;
        back.z += texture(texPreviousFrame, texUv + offset * 0.1).z;
  }
  col = Get(t);
  col += back * Ease(tf,2.0) * 0.2;
  
	out_color = vec4(col, 1.0);
}