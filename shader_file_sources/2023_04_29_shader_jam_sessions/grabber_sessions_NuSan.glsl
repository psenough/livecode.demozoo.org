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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = 0;

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

vec3 rnd(vec3 p){
  return fract(sin(p*232.454 + p.yzx*545.984 + p.zxy*453.558)*854.834);
}

float rnd(float t) {
  return fract(sin(t*453.945)*457.923);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)), 10));
}

vec3 lp;
float ld;
vec3 amb;
float map(vec3 p) {
  
  
  vec3 p2=p;
  
  for(int i=0; i<3;++i) {
    p.xz*=rot(time*0.2+i+curve(time+i*0.1, 1.4)*3);
    p.yz*=rot(time*0.13+i);
    p.xz=abs(p.xz)-2-i;
  }
  
  
  lp=p;
  lp=abs(lp)-1.5;
  lp=abs(lp)-1;
  ld=box(lp, vec3(0.6,0.1,1));
  
  
  ld=max(ld, -4-p2.y);
  
  
  //d=min(d, box(p2+vec3(0,2,0), vec3(15,0.2,15)));
  float d3=max(length(p2.xz)-15,abs(p2.y+4)-0.2);
  d3 = min(d3, length(p2)-5);
  
  ld+=0.2-d3*0.05;
  
  float d4 = length(p.xz-vec2(1))-0.01;
  amb+=vec3(0.5,0.3,1) * 0.002/(0.001+abs(d4));
  d4=max(d4,0.1);
  ld=min(ld, d4);
  
  
  float d=ld;
  d=min(d, d3);
  
  return d;
}
void cam(inout vec3 p) {
  
  p.yz*=rot(-0.4 + sin(time*0.2)*0.3);
  p.xz*=rot(time*0.3);
  
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time = mod(fGlobalTime, 300) + rnd(floor(fGlobalTime/4))*300;
  
  uv.y -= curve(time, 0.1)*0.05;
  
  vec3 col=vec3(0);
  
  for(int j=0; j<10; ++j) {
    vec3 s=vec3(0,-2,-30);
    s.x += sin(time*0.2)*10;
    if(curve(time+floor(uv.y*13), 0.1)<curve(time, 0.3)*2-1) s.x += (rnd(vec3(uv,j+0.1)).x-0.5)*2.;
    float fov = curve(time, 2.8)*3 + 0.5;
    vec3 r=normalize(vec3(uv, fov));
    
    float dd=0;
    
    cam(s);
    cam(r);
    vec3 p=s;
    
    float alpha=1;
    for(int i=0; i<100; ++i) {
      float d=map(p);
      if(d<0.001) {
        float fog=1-clamp(dd/100, 0,1);
    
        vec3 alp=abs(lp);
        float lm=max(alp.x, max(alp.y,alp.z));
        vec2 buv = lm==alp.z ? lp.xy : (lm==alp.x ? lp.yz : lp.xz);
        if(ld<0.001) {
          col += alpha * fog*texture(texSessions, buv*rot(time*0.1)*vec2(1,2) * 0.5 - 0.5 + time*0.3).x;
        }
        col += alpha * amb;
        
        vec2 off=vec2(0.01,0);
        vec3 n=normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
        vec3 bp=fract(p);
        float rough=step(min(bp.x,min(bp.y,bp.z)),0.2) * 0.05+0.02;
        n=normalize(n+(rnd(vec3(uv,fract(time)+j))-0.5)*rough);
        r=reflect(r,n);
        p+=n*0.1;
        d=0.1;
        alpha*=0.7;
      }
      if(d>100) break;
      p+=r*d;
      dd+=d;
    }
    
    col += alpha*pow(max(vec3(0), sin(r.y*3 + vec3(1,2,3)*0.2 + time)), vec3(3));
  }
  col /= 10;
  
  col=smoothstep(0,1,col);
  col=pow(col, vec3(0.4545));
  
	out_color = vec4(col,1);
}