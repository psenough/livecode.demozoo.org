#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

/*    '     '       
 *    |\___/|       
 *    | '^' '--.|   
 *    |        |/   
 * .  '||----||   . 
 *  "------------"  
 *    o        o    
*/                  
//
// hi!!!!!!!!!!!!!!!

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

// oh lol it's r32
vec4 loadColor(int idx, ivec2 p) {
  uint foo = imageLoad(computeTexBack[idx], p).r;
  vec4 result;
  for(uint i = 0; i < 4; i++){
    result[i] = float(foo % 256) / 255.0;
    foo = foo >> 8;
  }
  return result;
}

void storeColor(int idx, ivec2 p, vec4 col) {
  uint result;
  for(int i = 3; i >= 0; i--){
    result = (result << 8) | int(clamp(col[i], 0.0, 1.0) * 255.0);
  }
  imageStore(computeTex[idx], p, uvec4(result));
}


layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

// thank you blackle
vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}

#define EPS 0.001

#define INFINITY 10000000.0

float sphereIntersection(vec3 o, vec3 d, vec3 spherePos, float radius) {
  // || o + d t - spherePos|| ^2 == radius ^2
  o -= spherePos;
  // ||o||^2 + 2<o, d> t + ||d||^2 t^2 == radius^2
  // -> ||d||^2 t^2 + 2<o, d> t + ||o||^2 - radius^2
  float a = dot(d, d);
  float b = 2 * dot(o, d);
  float c = dot(o, o) - radius * radius;
  float det = b * b - 4 * a * c;
  if(det < 0) {
    return INFINITY;
  }
  
  // there's two intersections! take the first one that's > 0
  float sqrtDet = sqrt(det);
  float t = (-b - sqrtDet) / (2 * a);
  if(t > EPS) { 
    return t;
  }
  t = (-b + sqrtDet) / (2 * a);
  if( t > EPS){
    return t;
  }
  return INFINITY; // sphere behind you
}

float planeIntersection(vec3 o, vec3 d, float planeZ){
  float t = (planeZ - o.z) / d.z;
  if(t < 0) t = INFINITY;
  return t;
}

vec3 mainImage(){
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv.y *= -1.0;
  
  // vec3 col = vec3(uv, 0.0);
  
  vec3 camera = vec3(0.0, -5.0, 0.0);
  vec3 dir   = normalize(vec3(uv.x, 1.0, -uv.y));
  
  float rot = fGlobalTime; // texture(texFFTIntegrated, 0.0).r;
  
  camera = erot(camera, vec3(0.0, 0.0, 1.0), 0.125 * rot);
  dir = erot(dir, vec3(0.0, 0.0, 1.0), 0.125 * rot);
  
  vec3 o = camera;
  vec3 d = dir;
  
  vec3 col;
  
  float tPlane = planeIntersection(o, d, -1.0);
  float tSphere = sphereIntersection(o, d, vec3(0), 1.0);
  float tMin = min(tPlane, tSphere);
  vec3 pos = o + d * tMin;
  if(tMin >= INFINITY){
    col = vec3(mod(pos, 1.0));
  }
  else if(tMin == tPlane) {
    vec2 cell = floor(pos.xy);
    col = vec3(float((int(cell.x) & 1) ^ (int(cell.y) & 1)));
  }
  else {
    vec3 n = normalize(pos);
    col = n;
  }
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float asdf = m.y;

	float f = texture( texFFT, asdf ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 xt = plas( m * 3.14, fGlobalTime ) / asdf;
	xt = clamp( xt, 0.0, 1.0 );
	vec3 oc = (f + xt).xyz;
  
  oc = mix(oc, col, vec3(1.0));
  
  if(gl_FragCoord.y / v2Resolution.y < 5.0 * texture(texFFT, gl_FragCoord.x / v2Resolution.x).r) {
    oc = vec3(1.0, 0.2, 0.5);
  }
  
  return oc;
}
// Random number generation using pcg32i_random_t, using inc = 1. Our random state is a uint.
uint stepRNG(uint rngState)
{
  return rngState * 747796405 + 1;
}

// Steps the RNG and returns a floating-point value between 0 and 1 inclusive.
float stepAndOutputRNGFloat(inout uint rngState)
{
  // Condensed version of pcg_output_rxs_m_xs_32_32, with simple conversion to floating-point [0,1].
  rngState  = stepRNG(rngState);
  uint word = ((rngState >> ((rngState >> 28) + 4)) ^ rngState) * 277803737;
  word      = (word >> 22) ^ word;
  return float(word) / 4294967295.0f;
}

void main(void)
{
  // every once in a while, store to the compute tex
  vec3 scene = mainImage();
  ivec2 px = ivec2(gl_FragCoord.xy);
  
  vec2 uv2 = gl_FragCoord.xy / v2Resolution.xy;
  // once the stream comes back up, so sorry about that crash
  float fakeRNG = sin(uv2.y * 8.0) * mix(1.0, texture(texFFTSmoothed, 0.5).r, 0.1);
  
  int phase = int(floor((fGlobalTime + fakeRNG) * 60)) % 16;
  
  uint rngState = uint(px.x + 2048 * px.y);
  
  
  // no rng!! it crashes
  
  if(phase == 0){
    storeColor(0, px, vec4(scene, 1.0));
  }
  else{
    int flipbit = 1;
    while((phase & flipbit) == 0){
      flipbit = flipbit << 1;
    }
    
    vec4 mine = loadColor(0, px);
    vec4 theirs = loadColor(0, ivec2(px.x ^ flipbit, px.y));
    // uh this will do something!!!
    if((mine.x < theirs.x) == ((px.x & flipbit) == 0)){
      mine = theirs;
    }
    storeColor(0, px, mine);
    scene = mine.xyz;
  }
  
  out_color = vec4(scene, 1.0);
}