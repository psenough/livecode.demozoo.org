#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
#define TT (fGlobalTime/60*175)
#define T (floor(TT) + smoothstep(0.,1.,fract(TT)))

#define R v2Resolution

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

vec3 campos;
vec3 camtar;
mat3 cam_mat;

uint S;

uint hashi(){
    S ^= S >> 16;
    S *= 0x93846274u;
    S ^= S >> 15;
    S *= 0x93846327u;
    S ^= S >> 16; 
  return S;
}
#define hash_f() float(hashi())/float(0xFFFFFFFFu)

mat3 orthbas(vec3 campos, vec3 camtar){
  vec3 dir = normalize(camtar - campos);
  vec3 right = normalize(cross(vec3(0,1,0), dir));
  vec3 up = normalize(cross(dir, right));
  return mat3(right, up, dir);
}
vec2 samp_circ(){
    vec2 X = vec2(hash_f(), hash_f());
  X.x *= 125.;
  return vec2(sin(X.x),cos(X.x)) * sqrt(X.y);
}

ivec3 proj_p(vec3 p){
  p -= campos;
  p *= cam_mat;
	p /= dot(p,p)*(0.7 - 0.5 * float(mod(T/4.,4.) < 2));
  float focus_tar = 1.;
  float dof_amt = abs(p.z - focus_tar);
  
  float tt = T;
  tt += p.z;
  vec2 dir = vec2(sin(tt),cos(tt+ hash_f()*0.4 + p.z*.3));
  p.xy += dir*0.01*dof_amt;
  p.x += pow(hash_f(),30.)*2.9*dof_amt;
  //p.xy /= p.z;
  p.x *= R.y/R.x;
  p.xy += 0.5;
  return ivec3(p.xy*R,p.z);
}

void splat(vec3 p, vec3 col){
  ivec3 q = proj_p(p);
  uvec3 c = uvec3(col*1000.0);
  imageAtomicAdd(computeTex[0], q.xy, c.x);
  imageAtomicAdd(computeTex[1], q.xy, c.y);
  imageAtomicAdd(computeTex[2], q.xy, c.z);
}

vec3 read(vec2 uv){
  ivec2 q = ivec2(uv*R);
  return vec3(
    imageLoad(computeTexBack[0], q.xy).x,
    imageLoad(computeTexBack[1], q.xy).x,
    imageLoad(computeTexBack[2], q.xy).x
  )/1000.;
}


void main(void){
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 u = vec2(gl_FragCoord.xy)/R;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0);
  
  int id = int(gl_FragCoord.x + gl_FragCoord.y * R.x); 
  S = id + 125125u;
  
  
  campos = sin(vec3(3,2,1) + T*0.2 + sin(T));
  campos *= 2.;
  campos = normalize(campos)*2.;
  camtar =  sin(vec3(3,4,1) + T*0.9 + sin(T))*0.2;
  cam_mat = orthbas(campos,camtar);
  
	if(gl_FragCoord.x<100)
  for(float i = 0.; i < 90.; i++){
    float subid = mod(i + id,450.);
    vec3 p = vec3(0) + sin(vec3(3,2,1)*subid);
    //p +=  mod(float(id),20.)/1.;
		
    p[int(T/4)%3] +=  mod(float(id) + subid + T*45.,30.)/30.;
    
    float md = 2.5;
    p = mod(p,md) - 0.5*md;
    splat(p, sin(vec3(3,2,1) + i)*0.5 + 0.5);
    
  }
  
  col = read(gl_FragCoord.xy/R)*0.5;
  col = col/(col +1);
  col = 1.-col;
  
  col = pow(col,vec3(1.45));
  /*
vec3 campos;
vec3 camtar;
mat3 cam_mat;
*/  //for()
	vec4 pfr = texture(texPreviousFrame, u);
	float fw = fwidth(pfr.x);
	
  col = mix(col, pfr.rgb, smoothstep(0.,1.,fw*(.3 + 3.*smoothstep(1.,0.,fract(T/4)))));
  
	
	out_color = vec4(1.-sqrt(col),0);
}