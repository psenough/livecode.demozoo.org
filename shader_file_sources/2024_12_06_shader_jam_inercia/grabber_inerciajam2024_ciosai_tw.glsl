#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
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

#define pi acos(-1.)
#define tau (acos(-1.)*2.)
// https://www.shadertoy.com/view/XlXcW4
vec3 hash3f( vec3 s ) {
  uvec3 r = floatBitsToUint( s );
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  return vec3( r ) / float( -1u );
}


float Bayer2(vec2 a) {
    a = floor(a);
    return fract(a.x / 2. + a.y * a.y * .75);
}

#define Bayer4(a)   (Bayer2 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer8(a)   (Bayer4 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer16(a)  (Bayer8 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer32(a)  (Bayer16(.5 *(a)) * .25 + Bayer2(a))
#define Bayer64(a)  (Bayer32(.5 *(a)) * .25 + Bayer2(a))



vec4 getTexture(sampler2D sampler, vec2 uv){
     vec2 size = textureSize(sampler,0);
     float ratio = size.x/size.y;
     return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
}
vec4 getEdge(sampler2D sampler, vec2 uv, float w){
  mat3 k = mat3(
    -1.,-1.,-1.,
    -1., 8.,-1.,
    -1.,-1.,-1.
  );
  vec4 acc;
  for(float i=-1.;i<1.5;i++){
    for(float j=-1.;j<1.5;j++){
      float m = k[int(i)+1][int(j)+1];
      acc += getTexture(sampler, uv+vec2(i,j)*w/textureSize(sampler,0))*m;
    }
  }
  return acc;
}
float lum(vec3 rgb){
  vec3 m = rgb*vec3(.2126, .7152, .0722);
  return m.r+m.g+m.b;
}
mat2 rot(float n){
  return mat2(cos(n),-sin(n),sin(n),cos(n));
}
float box(vec3 p ){
  vec3 q = abs(p);
  return max(q.x,max(q.y,q.z));
  }
float box2(vec2 p ){
  vec2 q = abs(p);
  return max(q.y,q.x);
  }
float heart(vec2 p) {
    float stem = box2((p-vec2(0,.2))*rot(pi/4.))*sqrt(2.);
    float circs = length(abs(p*1.3+vec2(0,.2))-vec2(.4,0.));
    return min(stem, circs)-.1;
}

float plus(vec2 p)
{
  vec2 q = abs(p);
  if(q.y>q.x){ q.xy = q.yx; }
  return box2(q*vec2(1,3.));
}
float shape(vec3 p, int pattern){
  if(pattern<=0){
    return box(p);
  }
  else if(pattern<=1){
    return max(abs(p.z),plus(p.xy*2.)*.3);
  }
  else{
    return max(abs(p.z),heart(p.xy*3.)*.3);
  }
  return 0.;
}
float ease(float n){
  n = smoothstep(0.,1.,n);
  n = smoothstep(0.,1.,n);
  return n;
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float time = fGlobalTime;
  time-=pow(Bayer2(gl_FragCoord.xy)/65.,0.95);
  
  float bass = texture(texFFTSmoothed,.25).r;
  
  vec4 prev_tex = getTexture(texPreviousFrame,uv*vec2(1,-1)*.55);
  vec4 inercia = getTexture(texInerciaLogo2024, uv);
  vec4 inercia_edge = getEdge(texInerciaLogo2024, uv*.5*(1.2-bass*20.), 3.);
  
  float logo = smoothstep(.79,.8,lum(inercia_edge.rgb));
  
  vec3 logo3 = vec3(logo);
  
  vec3 ro = vec3(0.),
       rd = normalize(vec3(uv, 1.)-ro),
       p = ro,
       col = vec3(0.);
  
  //float crawl = texture(texFFTIntegrated,.5).r*10.;
  for(float acc, h, i; i<99.; i+=1.){
    p = ro+rd*acc;
    
    vec3 q = p;
    q.yx *= rot(time*.33);
    q.xz *= rot(sin(time*.4)*.5);
    q.yz *= rot(sin(time*.6)*.5);
    q.z += fract(time);
    
    vec3 seed = floor(q*1.);
    q = fract(q*1.);
    
    q.xy = q.xy*2.-1.;
    
    vec3 curr = hash3f(seed);
    vec3 next = hash3f(seed+floor(time));
    
    q.xy *= rot(mix(floor(curr.x*4.), floor(next.x*4.), ease(fract(time)))*pi/2.);
    
    q.z -= 1.;
    
    h = max(.001,(shape(q,int(curr.y*3.+.5))-(ease(fract(time))*ease(1.-fract(time)))*.6-bass*15.));
    vec3 no = normalize(fwidth(p));
    
    acc += h*.5;
    
    col += (sin(acc*2.+vec3(.0,.2,.4))*.5+.5)*.1/exp(i*i*h);
  }
  
  
  float evap = .9;
  vec3 fading = mix(prev_tex.rgb*evap,logo3,step(.5,logo3.r));
	out_color = vec4(mix(col,vec3(1.-col),logo3),1.);
}