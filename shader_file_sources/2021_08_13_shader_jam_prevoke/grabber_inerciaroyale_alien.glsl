#version 410 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
//Hello, Névoke!!!

#define iTime fGlobalTime
#define one_bpm 0.48
#define beat(a) tick(iTime / (one_bpm*a))
#define cumbeat(a) iTime+beat(a)
float tick(float t) {
  return fract(t);
}


mat2 rot(float a) {return mat2( cos(a), sin(a), -sin(a), cos(a) ) ; }

float sphere(vec3 p, float r) {
  return length(p) - r;
}


float box2(vec2 p, vec2 b){
  vec2 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

float torus(vec3 p, vec2 t){
  float a = length(p.xz ) - t.x;
  p.x += 2*cumbeat(8);
  a += sin(p.z);
  
  vec2 q = vec2(a , p.y );
  return length(q) - t.y;
}


float map(vec3 p) {
  float final = 0;
  
  vec3 pp = p;
  
  if(beat(8) < 0.5)
    p.xy *= rot(0.1*cumbeat(16));
  if(beat(16) < 0.5)
    p.xy *= rot(-0.1*cumbeat(16));
  
  float y = p.y - cumbeat(32);
  p.z -= 10;
  p.x *= atan(p.y, p.z);
  
  p.z -= 10.0;
  p.xz *= vec2(0.1, 0.5);
  
  for(int i = 0; i < 4; i++){
    final += box2(p.xz, vec2(5*i));
    p.z -= 10 + beat(4);
    p.x *= 2;
    p.xz *= rot(0.2*float(i)*y);
    p.z = cos(p.x * 2.0 +sin(p.z*2.0));
    
    if(beat(16) < 0.8)
      p.xz *= rot(0.8 - p.y);
  }
  
  float denum = 22;
  if(beat(8) < 0.5)
    denum = 15+beat(8);
  final = final / denum;
  
  pp.z += 15;
  
  
  
  float sp = sphere(pp, 15 + beat(4)) ;
  final = min(final, sp);
  
  pp.xz *= rot(iTime*0.5);
  pp.xz *= rot(2.6);
  pp.xy *= rot(0.4);
  
  float tor = torus(pp, vec2(24, 2 + beat(8)));;
  
  
  final = min(final, tor);
  
  return final;
}

vec3 march(vec3 ro, vec3 rd) {
  float t = 0;
  float a;
  int steps = 64;
  if(beat(8) < 0.2) steps = 32;
  for(int i = 0; i < steps; i++){
    a = map(ro+rd*t);
    if(a < 0.01) break;
    if(t > 100.) break;
    t+=a;
  }
  
  float ret = a;
  if(beat(16) < 0.1)
    ret *= t/8;
  
  return vec3(ret);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv1 = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0, 5, -55);
  if(beat(16) < 0.5) ro.z = -75;
  vec3 rd = normalize(vec3(uv, 1));
  
  if(beat(32) < 0.1)
    rd.xy *= rot(0.2);
  vec3 color = vec3(0);
  
  color = march(ro, rd);
  color *= 1.75;
  if(beat(16) < 0.5)
    color *= vec3(0.8, 0.2, 0.3);
  
  if(beat(32) < 0.5)
    color = 1-color;
  
  
  bool mask;
  float b = beat(64);
  if(b< 0.1)
    mask =  uv1.x < 0.5;
  else if(b < 0.2)
    mask =  false;
  else if(b < 0.3)
    mask =  uv1.y < 0.5;
  else if(b < 0.4)
    mask = true;
  else if(b < 0.5)
  mask = length(uv) < 0.2 + beat(8);  
  else if(b < 0.6)
    mask = false;
  else if(b < 0.8)
    mask = fract(uv.x * 10*beat(8)) < 0.5;
  else if(b < 1.){
    
    uv *= rot(iTime);
    uv = fract(uv*100*beat(16));
    mask = uv.x < 0.5 && uv.y < 0.5; 
  }
  
    
    
  
  
  
     
 
  
  if(mask)
    color = 1-color;
  
  color = mix(color, texture(texPreviousFrame, uv1).rgb, 0.9);
  
  
  
	out_color = vec4(color, 1.0);
}