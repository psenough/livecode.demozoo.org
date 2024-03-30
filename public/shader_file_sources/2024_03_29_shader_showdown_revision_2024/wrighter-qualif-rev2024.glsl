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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T fGlobalTime
#define R v2Resolution 
#define pi acos(-1.)
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

uint seed = 12354u;

uint hashi(uint x){
    x ^= x >> 16;
    x *= 0x85763927u;
    x ^= x >> 16;
    x *= 0x85763927u;
    x ^= x >> 16;
    return x;
}

#define hf() float(seed = hashi(seed))/float(0xFFFFFFFFu)
#define hfs(x,y,z) float(hashi(uint(x*125 + y*632 + z*754)))

vec2 samp_circ(){
    vec2 X = vec2(hf(),hf());
  return vec2(cos(X.x*pi*2),sin(X.x*pi*2))*sqrt(X.y);
}

ivec2 proj_p(vec3 p){
  float sc = floor(0.5*T/60*174);
  p.xz *= rot(T + sc);
  
  p.yz *= rot(T); 
  
  p.z += 2.5;
  
  float z = p.z;
  
  p.xy /= p.z;
  float dof_amt = 0.04;
  float dof_foc = 2.6 + sin(T + sin(T))*0.2;
  
  vec2 dof = samp_circ();
  p.xy += (p.z - dof_foc)*dof_amt*dof;
  
  ivec2 q = ivec2(-1);
  if(z > 0.){
      q = ivec2((p.xy+0.5)*vec2(R.y/R.x,1)*R);
  }
  return q;
}

#define U gl_FragCoord.xy

void add(ivec2 q, vec3 col){
    uvec3 qcol = uvec3(col*1000);
    imageAtomicAdd(computeTex[0],q,qcol.x);
    imageAtomicAdd(computeTex[1],q,qcol.y);
    imageAtomicAdd(computeTex[2],q,qcol.z);
}
vec3 fetch(ivec2 q){
    return vec3(
      imageLoad(computeTexBack[0],q).x,
      imageLoad(computeTexBack[1],q).x,
      imageLoad(computeTexBack[2],q).x
    )/1000.0;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec3 col = vec3(0);
  
  seed = hashi(uint(U.x *1025.125 + U.y*316135 + 18235));
  
  vec3 p = vec3(hf(),hf(),hf());
  
  
  for(float i = 0.; i < 10; i++){
    float X = hf();
    if(X < 0.5){
      p.yz *= rot(1.7);
      p = abs(p) - .3;
      p.xz *= rot(0.7 +T);
      p /= dot(p,p)*1.;
    } else {
      p = sin(p.zxy*1.4);
      p += sin(p.zxy*5.);
    }
    ivec2 q = proj_p(p);
    
    vec3 C = 0.5 + 0.5 * sin(vec3(3,2,1)*dot(p,p)*1);
    C = pow(C,vec3(0.4));
    if(all(greaterThan(q,ivec2(0)))){
        add(q, C);
    } 
    
  }
  
  ivec2 id = ivec2(U);
  
  uv = U.xy/R;
  col = fetch(id);
  vec2 md = 0.5*vec2(R.x/R.y,1);
  for(float i = 0.; i < 20.; i++){
    vec2 fluv = floor(uv/md);
    ivec2 iuv = ivec2(fluv/md*R);
    float X = hfs(fluv.x,fluv.y,T);
    if(X > 0.05){
      //col = fetch(iuv);
      break;
    }
    md/= 2.0;
  }
  
  col *= 0.5;
  col = max(col,0);
  col = col/(col + 1);
  
  col = 1.-col;
  col = pow(col,vec3(0.4545454545));
  out_color = vec4(col,1);
}




