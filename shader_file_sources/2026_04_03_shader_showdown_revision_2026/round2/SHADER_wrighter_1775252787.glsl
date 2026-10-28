#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


#define pi acos(-1)
#define R v2Resolution
float T = fGlobalTime/60 * 126 / 2;


uint seed = 125124124u;
uint seedb = 125152524u;

uint hash_u(){
    seed ^= seed << 11u;
  seed *= 1111111111u;
    seed ^= seed << 11u;
  seed *= 1111111111u;
    seed ^= seed << 11u;
  seed *= 1111111111u;
  return seed;
}
float hash_f(){
    return float(hash_u())/float(-1u);
  }

uint hash_u_b(){
    seedb ^= seedb << 11u;
  seedb *= 1111111111u;
    seedb ^= seedb << 11u;
  seedb *= 1111111111u;
    seedb ^= seedb << 11u;
  seedb *= 1111111111u;
  return seedb;
}
float hash_f_b(){
    return float(hash_u_b())/float(-1u);
  }
  
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))  
  
vec3 projp(vec3 p){
  
  float t = T*0.3;
  
  t += floor(t*4);
  
  p.xz *= rot(t + fGlobalTime*0.6);
  p.yz *= rot(t);
  
  p.z += 3. + sin(T)*5;
  p.xy /= p.z;
  p.x /= R.x/R.y;
  p.xy += 0.5;
  p.xy *= R.xy;
  //p.xy /= R.xy;
  return p;
}  

vec2 samp_circ(){
    vec2 Q = vec2(hash_f()*1000, hash_f());
  return vec2(sin(Q.x),cos(Q.x))*sqrt(Q.y);
}

vec2 samp_circ_b(){
    vec2 Q = vec2(hash_f()*1000, hash_f());
  return vec2(sin(Q.x),cos(Q.x))*pow(Q.y,2.5);
}
void splat(vec3 p, vec3 c, float aa){
    vec3 q = projp(p);
    
    q.xy += aa * samp_circ()*R.y;
    q.xy += smoothstep(0.8,1.5,abs(p.z-0.5)) * samp_circ()*R.y*0.5 * smoothstep(0.,1.,fract(T));
    
    if(hash_f()<0.6){
        q.xy += samp_circ_b()*R.y*0.02;
    }
    for(int i = 0; i < 3; i++){
      imageAtomicAdd(computeTex[i], ivec2(q.xy), int(1000.0*c[i]) );
    }
    
}

vec3 get(ivec2 q){
    vec3 c;
  for(int i = 0; i < 3; i++){
      c[i] = float(imageLoad(computeTexBack[i], q))/1000.;
  }
  return c;
}

vec3 cube(){
    return vec3(
    hash_f_b(),
    hash_f_b(),
    hash_f_b()
  ) - 0.5;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  ivec2 id = ivec2(gl_FragCoord.xy);
  seed += id.x + id.y*10000;
  
  
  T = floor(T) + smoothstep(0,1,fract(T)); 
  
  
  //splat(vec3(0), vec3(1), 0.1);
  
  vec3 pa = vec3(-1,-1,0);
  vec3 pb = vec3(1,1,0);
  
  if(sin(T) < -0.6){
    pa.xz *= rot(floor(hash_f()*14));
    
  }
  if(sin(T*4) < -0.6){
    
    T += floor(hash_f()*15);
  }
  
  
  
  
  for(float i = 0.; i < 15. - 8 * float(sin(T) > 0.8); i++){
      
    vec3 midp = mix(pa,pb,0.5 + sin(i + T*0.3)*1.);
    vec3 tan = vec3(
      -midp.y,
      midp.x,
      midp.z
    );
    
    tan.xz *= rot(hash_f_b()*5);
    
    if(hash_f_b() < 0.5){
      tan = -tan;
    }
    
    tan = mix(tan,length(tan)*normalize(cube()),0. + floor(hash_f_b()*2));
    
    midp += tan*(0.1 + float(sin(T) < 0.5));
    
    
    if(hash_f() < 0.5){
        pa = midp;
      seedb += 124124u;
    } else {
        pb = midp;
      seedb += 5224u;
    }
    
    vec3 c = 0.5 + 0.5 * sin(vec3(3,2,1) + T + i);
    
    if(i > 0)
    splat(mix(pa,pb,hash_f()), c*19, 0.0001);
    splat(midp,vec3(1),0.02 * sin(i + hash_f_b()*1 + T*4));
  }
  
  
  vec3 c = vec3(0);
  c = get(id);
  c *= 0.002;
  c = c/(1+c);
  
  float md = 0.02;
  if(mod(T/md,1) < 0.1 && mod(T/md*10,1) < 0.1){
        c = 1.-c;
  }
  c = smoothstep(0,1,c);
  c = sqrt(c);
	out_color = vec4(c,1);
}









