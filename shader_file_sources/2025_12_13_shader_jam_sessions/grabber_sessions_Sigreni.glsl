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
uniform sampler2D texSessions;
uniform sampler2D texShort;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


uint k = 0x456789abu;
const uint UINT_MAX = 0xffffffffu;
uvec3 u = uvec3(1, 2, 3);
vec3 light=normalize(vec3(0.0,0.0,1.0));
vec2 size = vec2(0.015 * 0.02, 0.1 * 2.5);
vec3 sc_three_ro = vec3(0.2, 0.15, 0.5);
const float PI = acos(-1.0);
const float TAU = PI * 2.0;
#define time fGlobalTime
#define SCENE_DURATION 2.0
#define scene(t) mod(floor(t / SCENE_DURATION), 4.)

float getFixedTime(){
  float sc = scene(time);
  if(sc == 0.) return time;
  float cycle = floor(time / (SCENE_DURATION * 4.));
  
  return cycle + 100 * 12.34;
}

float sdBox(in vec2 p, in vec2 b){
  vec2 d = abs(p) - b;
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);;
}


uint uhash11(uint n){
    n ^= (n << 1);
    n ^= (n >> 1);
    n *= k;
    n ^= (n << 1);
    return n * k;
}

uvec2 uhash22(uvec2 n){
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= k;
    n ^= (n.yx << u.xy);
    return n * k;
}

float hash11(float p){
    uint n = floatBitsToUint(p);
    return float(uhash11(n)) / float(UINT_MAX);
}

float hash21(vec2 p){
    uvec2 n = floatBitsToUint(p);
    return float(uhash22(n).x) / float(UINT_MAX);
}

float noise(vec2 p){
  vec2 i = floor(p);
  vec2 f = fract(p);
  
  float a = hash21(i);
  float b = hash21(i + vec2(1., 0.));
  float c = hash21(i + vec2(0., 1.));
  float d = hash21(i + vec2(1.));
  
  return mix(mix(a, b, f[0]), mix(c, d, f[0]), f[1]);
  
}

#define OCTAVES 8
float fbm(vec2 p){
  float value = 0.;
  float amplitude = 0.5;
  
  for(int i=0; i<OCTAVES; i++){
    value += amplitude * noise(p);
    p *= 2.;
    amplitude *= 0.5;
  }
  
  return value;
}


float opExtrusion(in vec3 p, in float sdf, in float h) {
    vec2 w = vec2(sdf, abs(p.z) - h);
    return min(max(w.x, w.y), 0.) + length(max(w, 0.));
}

mat2 rot(float a){
  float s = sin(a), c = cos(a);
  return mat2(c, s, -s, c);
}

vec2 pmod(vec2 p, float r){
  float a = atan(p.x, p.y) + PI / r;
  float n = TAU / r;
  a = floor(a / n) * n;
  
  return p * rot(-a);
}

struct SurfaceInfo{
	vec3 color;
	vec3 position;
	vec3 normal;
};

/*
vec3 getNormal( in vec3 p ) // for function f(p)
{
    const float h = 0.0001;
    const vec2 k = vec2(1,-1);
    return normalize( k.xyy*map( p + k.xyy*h ) + 
                      k.yyx*map( p + k.yyx*h ) + 
                      k.yxy*map( p + k.yxy*h ) + 
                      k.xxx*map( p + k.xxx*h ) );
}
*/

vec3 materialize(SurfaceInfo info, vec3 rd, vec3 bgCol){
    vec3 n = info.normal;
  
    if(isnan(n.x) || isnan(n.y) || isnan(n.z)){
        return bgCol;
    }
    
    float da = pow(abs(dot(n,light)),10.0);
    
    float fresnel = abs(dot(n,rd));
    
    vec3 iceColor = vec3(0., 0.4, 1.0);
    vec3 transparentColor = bgCol * 2.0;
    
    vec3 cf = mix(iceColor, transparentColor, fresnel);
    
    cf = mix(cf, vec3(2.0), da);
    
    return cf;
}

float dTree(vec2 p, float seedtime){
  float d;
  float scale = 0.8;
  vec2 boxSize = size;
  
  // p *= rot(-time * .5);
  
  vec2 q = p;
  d = sdBox(q, boxSize);
  
  for(int i=0; i<7; i++){
    float rndval = hash11(seedtime);
    rndval = rndval * 2. - 1.;
    
    q.x = abs(q.x);
    q -= 0.5 * boxSize.y;
    q *= rot(rndval * PI);
    d = min(d, sdBox(q, boxSize));
    boxSize *= scale;
  }
  
  return d;
}

float snowflake(vec2 p){
  float d;
  float tr = pow(fract(time * 0.5), 0.3);
  float seedtime = getFixedTime();
  seedtime = floor(seedtime * 10.) + 100. * 12.34;
  float seedtime_ = seedtime;
  seedtime_ = floor(hash11(seedtime_) * 5. + 6.);
  // p = pmod(p, 10.);
  p = pmod(p, seedtime_);
  d = dTree(p, seedtime);
  
  return d;
}

float map(vec3 p){
  // return length(p) - 0.25;
  float tr = pow(fract(time * 0.5), 0.3);
  
   float sc = scene(time);
  if(sc == 2.){
    p.xy *= rot(tr);
    p.zx *= rot(tr);
  }
  
  if(sc == 3.){
    p.xz *= rot(3. * tr);
  }
  
  vec3 warpedP = p;
  float noiseFactor = 10.;
  warpedP.x += fbm(p.zy * noiseFactor) * 0.02;
  warpedP.y += fbm(p.xz * noiseFactor) * 0.02;
  warpedP.z += fbm(p.xy * noiseFactor) * 0.02;
  
  float d;
  d = opExtrusion(warpedP, snowflake(warpedP.xy), 0.005);
  
  d -= 0.008;
  
  return d;
}

vec3 getNormal( in vec3 p ) // for function f(p)
{
    const float h = 0.0001;
    const vec2 k = vec2(1,-1);
    return normalize( k.xyy*map( p + k.xyy*h ) + 
                      k.yyx*map( p + k.yyx*h ) + 
                      k.yxy*map( p + k.yxy*h ) + 
                      k.xxx*map( p + k.xxx*h ) );
}

bool raymarching(vec3 ro, vec3 rd, vec3 bgCol, inout SurfaceInfo info){
  float dist, sumDist = 0.;
  
  for(int i=0; i<100; i++){
    vec3 rPos = ro + rd * sumDist;
    dist = map(rPos);
    if(dist < 0.0001){
      info.normal = getNormal(rPos);
      // info.color = vec3(1.);
      info.color = materialize(info, rd, bgCol);
      
      return true;
    }
    sumDist += dist;
  }
  
  return false;
}

#define res v2Resolution
void main(void)
{
  float sc = scene(time);
  float tr = pow(fract(time * 0.5), 0.3);
  vec3 col = vec3(0.);
	vec2 uv = vec2(gl_FragCoord.xy / res);
  vec2 asp = res / min(res.x, res.y);
  vec2 suv = (2. * uv - 1.) * asp;
  vec2 p = suv;
  
  col = vec3(1.) - vec3(step(0.005, snowflake(p)));
  
  
  if(sc >= 2.){
    col = mix(vec3(0.), vec3(0., 0., 0.4), uv.y);
    
    vec3 ro = vec3(0., 0., 1.1);
    
    if(sc == 2.){
      col = mix(vec3(1.), col, tr);
      ro = vec3(0., 0., 1.1 * sin(tr));
    }
    
    if(sc == 3.){
      ro = sc_three_ro;
    }
    
    vec3 rd = normalize(vec3(p, -2.));
    SurfaceInfo info;
    
    if(raymarching(ro, rd, col, info)){
      col = info.color;
      
    }
  }
  vec2 texuv = uv;
  texuv *= 3.;
  texuv.x += 0.05;
  if(sc == 3. && floor(texuv.x) == 2. && floor(texuv.y) == 1.){
    
    // col += texture(texSessions, texuv).rgb;
    float r = texture(texSessions, texuv + vec2(0.1, 0.3) * hash11(floor(time * 10.))).r;
    float g = texture(texSessions, texuv).g;
    float b = texture(texSessions, texuv + vec2(0.3, 0.1) * hash11(floor(time * 5.))).b;
  
    col += vec3(r, g, b);
    
  }
  
  col *= smoothstep(0.8, 0.4, length(uv - 0.5));
  
  
	out_color = vec4(col, 1.);
}