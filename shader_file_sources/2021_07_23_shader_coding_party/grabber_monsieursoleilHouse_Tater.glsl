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

#define STEPS 164.0
#define MDIST 200.0
#define time fGlobalTime
#define pmod(p,x) (mod(p,x)-(x)*0.5)
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define pi 3.1415926535
float g1 = 0.0;
float anim(){
  return fract(time*0.15);
}
float smin(float a, float b, float k){
  float h = max(0,k-abs(a-b));
  return min(a,b)-h*h*0.25/k;
}

float smax(float a, float b, float k){
  float h = max(0,k-abs(a-b));
  return max(a,b)-h*h*0.25/k;
}

float gy(vec3 p){
  return dot(sin(p.xyz),cos(p.yzx));
}
float box(vec3 p, vec3 s){
  vec3 d = abs(p)-s;
  return max(d.x,max(d.y,d.z));
}
vec2 map(vec3 p){
  vec3 po = p;
  float streamfft = 1.4;
  float t = mod(time,300.0);
  vec2 a = vec2(0);
  vec2 b = vec2(1);
  //bottom plane gyroid
  b.x = gy(p*2.0+(t*2.0+5*texture(texFFTIntegrated,0.2).x)*vec3(1,-1,0));
  b.x*=0.55;
  //bottom plane
  a.x = p.y+1.0-sin(p.x*2.5+t)*0.15-sin(p.z*2.5+t)*0.05;
  
  a.x = max(b.x,a.x);
  
  float voff = texture(texFFTSmoothed,0.1).x*streamfft;
  voff=clamp(voff,0.0,12.0/500.0);
  //ball gyriod
  float ballsize = 1.5;
  if(anim()>0.6){
    //p.xz = pmod(p.xz,30.0);
    ballsize = 3.0+voff*500.0;
    
  }
  ballsize = clamp(ballsize,1.5,15.0);
  b.x = abs(abs(gy(-p*3.0+t+8*streamfft*texture(texFFTIntegrated,0.5).x))-0.6)-0.2;
  b.x*=0.4;
  //ball
  
  //p.y = pmod(p.y+sin(t)*3.0,10.0);
  p.xz*=rot(t);
  //p.yz*=rot(t);
  float ballcut = box(p-vec3(0,voff*125.0,0),vec3(ballsize));
  p = po;
  ballcut = mix(ballcut, length(p-vec3(0,voff*125.0,0))-ballsize,sin(time*2.0)*0.5+0.5);
  b.x = smax(b.x,ballcut,0.4);
  p = po;
  
  a = (a.x<b.x)?a:b;
  t*=0.5;
  float tt = pow(fract(t),3.0)+floor(t);
  
  tt*=pi/2.0;
  
  b.y = 2.0;
  p.xy*=rot(tt);
  
  float moddist = 20+voff*500.0;
  p.xz = pmod(p.xz,moddist);
  b.x = length(p.xz)-1.5-clamp(sin(p.y*1.5),0.0,0.2);
  a = (a.x<b.x)?a:b;
  p = po;
  
  p.xy*=rot(tt);
  p.xy = pmod(p.xy,moddist);
  b.x = length(p.xy)-1.5-clamp(sin(p.z*1.5),0.0,0.2);
  a = (a.x<b.x)?a:b;
  
  p = po;
  
  p.xy*=rot(tt);
  p.yz = pmod(p.yz,moddist);
  b.x = length(p.yz)-1.5-clamp(sin(p.x*1.5),0.0,0.2);
  a = (a.x<b.x)?a:b;
  p = po;
  
  float fft = texture(texFFTIntegrated,0.1).x;
  p-=vec3(0,t+fft*0.01,0);
  p=pmod(p,moddist);
  
  b.x = length(p)-2.0;
  g1+=0.01/(0.01+b.x*b.x);
  a = (a.x<b.x)?a:b;
  
  
  return a;
}
vec3 norm(vec3 p){
  vec2 e = vec2(0.01,0.0);
  return normalize(map(p).x - vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col= vec3(0.0);
  float t = time;
  vec3 ro = vec3(0,3,-15);
  vec3 rd = normalize(vec3(uv,1.0));
  if(anim()>0.5){
    ro = vec3(0,100,0);
    uv.xy*=rot(time);
    rd = normalize(vec3(uv,1.0));
    rd.yz*=rot(-pi/2.0);
    
  }
else{
  rd.yz*=rot(-0.25);
   ro.xz*=rot(t*0.4);
  rd.xz*=rot(t*0.4);
}

  
  
 
  float shad,dO;
  vec2 d;
  vec3 p = ro;
  bool hit = false;
  for(float i = 0.0; i <STEPS; i++){
    
    p = ro+rd*dO;
    d = map(p);
    d.x = max(-(length(p-vec3(ro))-5.0),d.x);
    dO+=d.x*0.85;
    
    if(d.x<0.01){
      shad = i/STEPS;
      hit = true;
      break;
    }
    if(dO>MDIST){
      break;
    }
    if(i == STEPS-1.0){
      hit = true;
    }
  }
  vec3 al = vec3(0);
  vec3 n = norm(p);
  vec3 ld = normalize(vec3(1));
  vec3 h = normalize(ld-rd);
  float spec = pow(max(dot(n,h),0.0),20.0);
  
  
  if(hit){
    if(d.y == 0.0){
      al = vec3(0.1,0.3,0.9);
      col+=spec*0.2;
      shad = 0.8-shad*4.0;
    }
    if(d.y == 1.0){
      al = vec3(0.9,0.1,0.1);
      col+=spec*0.3;
      shad = 0.7-shad*4.0;
    }
    if(d.y == 2.0){
      al = vec3(0.7,0.7,0.9)*0.6;
      shad = 1.0-shad;
     
    }
    
  col += vec3(1.0-shad)*al;
  
  col = pow(col,vec3(0.8));
     }
  col+=g1*vec3(0.3,0.3,0.8)*0.3;
  col = mix(clamp(col,0.0,1.0),vec3(0.4,0.0,0.0),(dO/MDIST));
  //uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  //col+=texture(texPreviousFrame,uv*0.5+0.5).rgb*0.3;
	out_color = vec4(col,0.0);
}
