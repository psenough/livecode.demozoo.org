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

#define STEPS 128.0
#define MDIST 250.0
#define pi 3.1415926535
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define pmod(p,x) (mod(p,x)-0.5*(x))
#define lr 90.0
vec3 gl = vec3(0);
vec3 gl2 = vec3(0);
vec2 path(float t){
  return vec2(sin(t),cos(t));
}


vec2 map(vec3 p){
  vec2 a = vec2(9999);
  vec2 b = vec2(9999);
  float t = mod(fGlobalTime,1000);
  vec3 po = p;
  
  float ffti = texture(texFFTIntegrated,0.0).x;
  float fft = texture(texFFTSmoothed,0.1).x;
  float fft2 = texture(texFFTSmoothed,0.7).x;
  
  p.yz*=rot(-ffti*0.2);
  
  float th = atan(p.y,p.z);
  th*=80.0;
  float r = length(p.yz)-lr;
  p.y = r;
  p.z = th;
  
  
  //INNER SPIRAL
  p.xy-=path(p.z*0.2)*4.0;
  
  vec3 p2 = p;
  p.xy*=rot(-p.z);
  p.x = abs(p.x)-1.0;
  b.x = length(p.xy)-0.5;
  
  
  b.y = 1.0;
  a=(a.x<b.x)?a:b;
  p = p2;
  
  //MIDDLE SPIRAL
  p.xy-=path(p.z*0.2)*min(3.0+fft*250.0,6.0);
  
  vec3 p3 = p;
  p.xy*=rot(sin(p.z));
  p.xy = abs(p.xy)-1.4;
  vec2 d2 = abs(p.xy)-1.0;
  
  float cut = max(d2.x,d2.y);
  
  p = p3;
  
  b.x = length(p.xy)-1.0;
  b.x = max(-cut,b.x);
  
  
  b.y = 2.0;
  a=(a.x<b.x)?a:b;
  
  //OUTER SPIRAL
  p.xy-=path(p.z*0.2)*min(3.0+fft*250.0,6.0);
  b.x = length(p.xy)-1.0;
  
  b.y = 3.0;
  
  gl2 +=0.1/(0.01+b.x*b.x)*vec3(0,0.1,1.0);
  a=(a.x<b.x)?a:b;
  
  //OUTER BOXS TUBES
  p = po;
  p.y = r;
  p.z = th;
  
  p.xy*=rot(p.z*0.01*sin(t));
  p.xy = abs(p.xy)-20.0;
  
  for(float i = 0.0; i<4.0; i++){
    p.xy = abs(p.xy)-1.5;
    p.xy*=rot(p.z*0.1-t*2.0);
    
  }
  
  vec2 d = abs(p.xy)-1.0;
  b.x = max(d.x,d.y);
  b.y = 4.0;
 
  a=(a.x<b.x)?a:b;
  
  //LASERS
  
  p = po;
  p.y = r;
  p.z = th;
  
  p.xy = abs(p.xy)-20.0;
  p.xy*=rot(pi/4.0);
  p.xy = abs(p.xy)-5.0;;
  
  b.x = length(p.xy);
  
  gl+=0.1/(0.01+b.x*b.x)*vec3(0,1.0,0.5)*max(sin(p.z*0.05+t*10.0)*0.5+0.4,0);
  b.y = 0.0;
  a=(a.x<b.x)?a:b;
  
  //MIDDLE BALL THINGS
  p = po;
  p.y = r;
  p.z = th;
  
  p.xy*=rot(-t*5.0);
 
  p.z = pmod(p.z,20.0);
  
  p.yz*=rot(t*4.0);
  p.yx*=rot(t*4.0);
  p.xy = abs(p.xy)-1.5-fft2*300.0;
  b.x = length(p)-0.6;
  b.y = 7.0;
  
  gl+=(0.0004/(0.01+b.x*b.x))*vec3(0,1,1);
  a=(a.x<b.x)?a:b;
  
  
  //BOX THINGYS
  p = po;
  p.y = r;
  //p.z = th;
  
  //p.xy = abs(p.zy)-7.0+fft2*20.0;
  //p.xy*=rot(ffti*5.0);
  //p.xy = abs(p.xy);
  //p.xy*=rot(pi/4.0);
  
  p.z-=5.0;
  p.xy*=rot(-t*0.75);
  p.xy = abs(p.xy)-5.5-fft2*1200.0;
  p.xy*=rot(pi/4.0);
  p.xy*=rot(ffti);
  p.xy = abs(p.xy);
  p.xy*=rot(pi/4.0);
  vec3 d3 = abs(p)-vec3(4.0,0.75,0.75);
  b.x = max(d3.x,max(d3.y,d3.z));
  b.y = 9.0;
  a=(a.x<b.x)?a:b;
  
  
  
  return a;
}

vec3 norm(vec3 p){
  vec2 e = vec2(0.01,0);
  return normalize(vec3(map(p).x-vec3(
  map(p-e.xyy).x,
  map(p-e.yxy).x,
  map(p-e.yyx).x)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float t = mod(fGlobalTime,1000);
  uv*=rot(t*0.75);
  vec3 col = vec3(0);
  
  vec3 ro = vec3(0,lr,0);
  vec3 rd = normalize(vec3(uv,0.6));
  
  float shad, dO;
  vec2 d;
  vec3 p = ro;
  bool hit = false;
  float bnc = 0.0;
  for(float i = 0.0; i<STEPS; i++){
    p = ro+rd*dO;
    d = map(p);
    if(d.x>1.0)d.x = sqrt(d.x);
    
    
    if(d.x<0.01){
      if(d.y==7.0&&bnc==0.0){
        vec3 n = norm(p);
        ro = p+n*0.5;
        rd = n;
        dO = 0.0;
        bnc = 1.0;
      }
      else{
        if(d.y == 3.0){
          d.x = 0.1;
        }
        else{
          shad = i/STEPS;
          hit = true;
          break;
        }
    }
    }
    if(dO>MDIST){
      p = ro+rd*MDIST;
      break;
    }
    dO+=d.x*0.6;
  }
  vec3 al;
  if(hit){
    
    vec3 n = norm(p);
    vec3 ld = normalize(vec3(0.25,0.25,-1.0));
    vec3 h = normalize(ld-rd);
    float spec = pow(max(dot(n,h),0),20.0);
    
    
    
    col = vec3(1.0-shad);
    if(d.y ==4.0) d.y = floor(mod(p.z*0.3,3.0))+1.0;
    
    if(d.y==1.0) al = mix(vec3(0,0.2,1.0),vec3(0,1.0,0.2),0);
    if(d.y==2.0) al = vec3(0,0.5,0.5)*1.5;
    if(d.y==3.0) al = mix(vec3(0,0.2,1.0),vec3(0,1.0,0.4),1);
    if(d.y==7.0) al = vec3(0,1.0,1.0);
    if(d.y==9.0) al = vec3(0.5,0.9,0);
    col*=al;
    col+=spec*0.2;
  }
  col = mix(col,vec3(0.05,0,0.15),dO/MDIST);
  col+=gl*0.6;
  col+=gl2*0.05;
  col = pow(col,vec3(0.75));
	out_color = vec4(col,0);
}