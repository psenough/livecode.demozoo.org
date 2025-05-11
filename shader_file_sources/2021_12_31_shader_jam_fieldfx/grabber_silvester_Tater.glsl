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
#define MDIST 350.0
#define STEPS 128.0
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define pmod(p,x) (mod(p,x)-0.5*(x))

#define fft1 texture(texFFTSmoothed,0.3).x
#define fft2 texture(texFFTSmoothed,0.1).x

vec3 pal(float t, vec3 a, vec3 b, vec3 c, vec3 d){
  return a+b*cos(2.0*3.14159265*(c*t+d));
}  
vec3 spec(float a, float b){
  return pal(a,vec3(0.5),vec3(0.5)*1.3,vec3(1.0),vec3(0,0.33,0.66));
  
}

//blackle dist
float ldist(vec3 p, vec3 a, vec3 b){
  float k = dot(p-a,b-a)/dot(b-a,b-a);
  return distance(p,mix(a,b,clamp(k,0,1)));
}
float dibox(vec3 p, vec3 b, vec3 rd){
  vec3 dir = sign(rd)*b*0.5;
  vec3 rc =(dir-p)/rd;
  return rc.z+0.01;
}

vec2 path (float p){
  return vec2(sin(p*0.075)*10,sin(p*0.05)*10);
  
}
float glow = 0.;
vec3 rdg = vec3(0);

float prot = 0.05;

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return max(d.x,max(d.y,d.z));
}

vec2 map(vec3 p){
  vec3 po = p;
  float t = mod(fGlobalTime,999.0);
  vec2 a = vec2(1);
  a.x = length(p)-1.;
  vec2 b = vec2(2);
  float m = 1.5;
  float id = floor(p.z/m)-0.5;
  p.z = pmod(p.z,m);
  
  
  
  
  vec2 path = path(id*m);
  p.xy-=path;
  
  p.y+=sin(id*0.1+t*3.)*2.;
  
  float len = 8. +sin(id*0.3+t*3.)*2.+fft1*300.;
  

  
 float sep = max(sin(t),0.)*20.;

  p.x = abs(p.x)-abs(len*2.)*0.25-sep;
  p.xy*=rot(path.x*prot);
  p.xy*=rot(sep*0.2*smoothstep(2.0,3.0,sep));

  a.x = ldist(p,vec3(-len,0,0),vec3(len,0,0))-0.5;
  
  float c = dibox(p,vec3(m),rdg);
  
  p = po;
  p-=vec3(path.x,path.y+10,t*25.+20.);
  po = p;
  p.xy*=rot(id*0.2);
  p = abs(p)-25.-fft2*500.;

  b.x = length(p.xy)-2.;
  p = po;
  
  for(float i = 0.; i<3; i++){
    p = abs(p)-1.;
    p.xy*=rot(i*0.3+t*1.5);
    p.yz*=rot(i*0.3+t*3.);
    p.zx*=rot(i*0.3+t*0.1);
    
  }
  
  
  b.x = min(b.x,box(p,vec3(1,1,15)));
  a = (a.x<b.x)?a:b;
  
  glow+=0.1/(0.1+a.x*a.x);
   

  a.x = min(a.x,c);
  a.y = id;
  return a;
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col = vec3(0.);
  float t = mod(fGlobalTime,999)*25.;
  float off = 12;
  vec3 pr = vec3(path(t-off),t-off);
  vec3 pl = vec3(path(t+off),t+off);
  pr.x*=0.7;
  uv*=rot(-pr.x*prot*0.2);
  
  vec3 ro = pr+vec3(0,4,-0)*2.;
  vec3 lk = pl+vec3(0,4,0);
  vec3 f = normalize(lk-ro);
  vec3 r = normalize(cross(vec3(0,1,0),f));
  vec3 rd = normalize(f*(0.4)+uv.x*r+uv.y*cross(f,r));
  
  rdg = rd;
  
  vec3 p = ro;
  float shad = 0.;
  vec2 d = vec2(0);
  float rl = 0;
  for(float i =0; i<STEPS; i++){
    p = ro+rd*rl;
    d = map(p);
    rl+=d.x;
    if(d.x<0.005){
      shad = i/STEPS;
      break;
    }
    if(rl>MDIST||i>STEPS-2.){
      d.y = 0.;
      rl = MDIST;
      break;
    }
  }
  
  col += vec3(shad)*0.1;
  col+=glow*0.08*spec(fract(d.y*0.1)*0.4+0.2+t*0.001,1.0);
 
  

	out_color = vec4(col,0);
  //HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
  //:DDDDDD
  
  // \o/         \o/          \o/          \o/
  
    // \o/         \o/          \o/          \o/
      // \o/         \o/          \o/          \o/
        // \o/         \o/          \o/          \o/
}

/*
  _    _ ______ _      _      ____                             
 | |  | |  ____| |    | |    / __ \                            
 | |__| | |__  | |    | |   | |  | |                           
 |  __  |  __| | |    | |   | |  | |                           
 | |  | | |____| |____| |___| |__| |                           
 |_|__|_|______|______|______\____/_____ _______ ______ _____  
  / ____|_   _| |\ \    / /  ____|/ ____|__   __|  ____|  __ \ 
 | (___   | | | | \ \  / /| |__  | (___    | |  | |__  | |__) |
  \___ \  | | | |  \ \/ / |  __|  \___ \   | |  |  __| |  _  / 
  ____) |_| |_| |___\  /  | |____ ____) |  | |  | |____| | \ \ 
 |_____/|_____|______\/   |______|_____/   |_|  |______|_|  \_\
*/





