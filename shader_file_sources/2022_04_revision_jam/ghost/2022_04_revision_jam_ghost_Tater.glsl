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
uniform float md1;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define fft texture(texFFTSmoothed,0.1).x

#define STEPS 90.0
#define MDIST 1500.0
#define pi 3.14159265
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define pmod(p,x) (mod(p,x)-0.5*(x))
#define time mod(fGlobalTime,300)
float h21(vec2 a){
  return fract(sin(dot(a,vec2(12.9898,78.233)))*43644.45345);
  
}
float dibox(vec3 p, vec3 b, vec3 rd){
  vec3 dir = sign(rd)*b*0.5;
  vec3 rc = (dir-p)/rd;
  return min(rc.x,rc.z)+0.1;
}
float dibox2(vec3 p, vec3 b, vec3 rd){
  vec3 dir = sign(rd)*b*0.5;
  vec3 rc = (dir-p)/rd;
  return (rc.z)+0.1;
}
float box(vec3 p, vec3 b){
  vec3 q = abs(p)-b;
  return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}
float lim(float p, float s, float lima, float limb){
  return p-s*clamp(round(p/s),lima,limb);
  
}
vec3 spiral(vec3 p, float R){
  p.xz*=rot(p.y/R);
  vec2 s = sign(p.xz);
  p.xz=abs(p.xz)-R*0.5;
  p.xz*=rot(time*pi/3);
  float poy = p.y;
  p.y=0.;
  p.yz*=rot(mix(0.,pi/4.,1./(R*0.5+1.5)))*-sign(s.x*s.y);
  p.y=poy;
  return p;
}
float torus(vec3 p, vec2 q){
  return length(vec2(length(p.xz)-q.x,p.y))-q.y;
  
}
float anim = 0;
vec3 rdo = vec3(0);
vec3 glow = vec3(0);
vec2 map(vec3 p){
  vec3 rd2 = rdo;

  float speed = 70;
  
  float rotation = tanh(sin(time*2)*8)*0.0005;
  p.xy*=rot(p.z*rotation);
  rd2.xy*=rot(p.z*rotation);
  float rotation2 = tanh(cos(time*3)*8)*0.0005;
  if(anim>0.5)
    rotation2 =0.0005;
  p.zy*=rot(p.z*rotation2);
  rd2.zy*=rot(p.z*rotation2);
    vec3 po2 = p;

  vec2 a = vec2(0);
  p.z+=speed*time;
    vec3 po = p;

  float m2 =60;
  //p.y = pmod(p.y,m2);
  //p.y+=40;
  float bsize = 16.;
  float m = 20;
  
  vec2 id = floor(p.xz/m);
  
  p.xz = pmod(p.xz,m);
  float sideBox = 12;
  //p.x = lim(p.x-m/2,m,-sideBox/2,sideBox/2);
  
  p.y+=tanh(sin(time+floor(h21(id)*pi*4.))*8.)*(40.+anim*20);
  a.x = box(p,vec3(bsize*0.5,4,bsize*0.5))-0.3;
  vec3 glowCol = vec3(0.8,0.7,0.2)*(64/STEPS);
  glowCol.xy*=rot(sin(time)*0.5+0.5+h21(id)*2-1.);
  glow+=exp(-a.x)*glowCol*0.1;
  
 // if(abs(id.x)<sideBox/2+1) 
  a.x = min(a.x,dibox(p,vec3(m),rd2));
 // else
  //a.x = min(a.x,dibox2(p,vec3(m),rd2));
  
  p = po2;
  p.zy*=rot(pi/2);
  vec2 b = vec2(1);
  //p.xy = abs(p.xy)-20;
  //p.x = abs(p.x)-40;
  p = spiral(p,110 + texture(texFFTSmoothed,0.1).x*900);
  p = spiral(p,10);
 // p = spiral(p,15);
  //p = spiral(p,8);

  //p = spiral(p,10);
  //p = spiral(p,5);

  b.x = length(p.xz)-2;
  b.x*=0.7;
  glow+=exp(-b.x)*vec3(0.8,0.7,0.2)*0.1;

  a.x = min(a.x,b.x);
  p = po;
  float m3 = 40;
  float id3 = floor(p.z/m3);
  p.z = pmod(p.z,m3);
  b.x = torus(p.xzy,vec2(134.+texture(texFFTSmoothed,mod(id3,3)*0.1).x*1000,5));
  
  glow+=exp(-b.x)*glowCol*0.1;
  

  a.x = min(a.x,b.x);

  return a;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  anim = sin(time*0.4)*0.5+0.5;
  if(anim>0.5)
    anim = 1;
  
  vec3 col = vec3(0);
  vec3 ro = vec3(0,0,-10)*3;
  if(anim>0.9){
    ro = vec3(0,40,-50)*8;
  }
  vec3 lk = vec3(0,0,0);
  vec3 f = normalize(lk-ro);
  vec3 r = normalize(cross(vec3(0,1,0),f));
  vec3 rd = normalize(f*(0.7)+uv.x*r+uv.y*cross(f,r));
  rdo = rd;
  vec3 p = ro;
  vec2 d = vec2(0);
  float rl = 0;
  float shad = 0;
  
  for(float i = 0; i <STEPS; i++){
    p = ro+rd*rl;
    d = map(p);
    rl+=d.x;
    if(rl>MDIST){
      break;
    }
  }

  //col = vec3(shad);
  col+=glow*0.25;
  
  col = pow(col,vec3(0.45));
	out_color = vec4(col,0);
}