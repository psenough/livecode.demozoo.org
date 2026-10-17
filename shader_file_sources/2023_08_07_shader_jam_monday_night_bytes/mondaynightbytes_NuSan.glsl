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

float time = mod(fGlobalTime, 300);
float sec=0;

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float mus(float t) {
  return texture(texFFTSmoothed, fract(t)*0.1+0.01).x;
}

float musi(float t) {
  return texture(texFFTIntegrated, fract(t)*0.1+0.01).x * 0.3;
}

float smin(float a, float b, float k) {
  float h=clamp((a-b)/k*0.5+0.5,0,1);
  return mix(a,b,h)-h*(1-h)*k;
}

vec2 smin(vec2 a, vec2 b, float k) {
  vec2 h=clamp((a-b)/k*0.5+0.5,0,1);
  return mix(a,b,h)-h*(1-h)*k;
}

vec3 rnd(vec3 p) {
  return fract(sin(p*322.342+p.yzx*845.432+p.zxy*452.344)*421.453);
}

float rnd(float a) {
  return fract(sin(a*454.506)*394.453);
}

vec3 eee=vec3(0);
vec3 atm=vec3(0);
float map(vec3 p) {
  
  vec3 bp=p;
  
  p.y -=sin(time*0.1)*3;
  
  for(int i=0; i<4; ++i) {
    float pu=sin(musi(0.05+i*0.1))*0.6+1.0;
    float t=musi(i*0.1)*1.4;
    p.xz *= rot(t*0.2);
    p.xy *= rot(t*0.3);
    //p.yz=abs(p.yz)-(0.2+i*0.2)*pu*1.5;
    p.yz=smin(p.yz,-p.yz,-1.5);

    p.yz-=(0.2+i*0.2)*pu*1.5;
  }
  float d = length(p)-0.8;
  d=smin(d, length(abs(p.xz)-2.0)-0.1+(length(p)-5)*0.05, 1.2);
  d=smin(d, length(abs(p.yz)-2.0)-0.1+(length(p)-5)*0.05, 1.2);
  d=smin(d, bp.y, 1.2+sin(musi(0.02)));
  
  float d2 = length(abs(p.xy)-2.0)-0.1;
  atm += eee * 0.01/(0.01+abs(d2));
  d2=max(d2,0.1);
  d=min(d,d2);
  
  return d;
}

void cam(inout vec3 p) {
  float aa=rnd(sec+0.2)*344.0;
  p.yz *= rot(sin(time*0.1+aa)*0.2-0.4);
  p.xz *= rot(time*0.2+aa);
}

float gao(vec3 p, vec3 n, float d) {
  return clamp(map(p+n*d)/d,0,1)*0.5+0.5;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  vec3 col=vec3(0);
  
  eee = vec3(1,0.2,0.5);
  float t3=rnd(sec*0.9)*100+time*0.1;
  eee.xz *= rot(t3);
  eee.yz *= rot(t3*1.3);
  eee=abs(eee);
  
  vec3 s=vec3(0,0,-15);
  float diag=max(abs(uv.x),abs(uv.y));
  sec = floor(time*0.25-length(uv)*0.2)+floor(time*0.4-diag*0.2);
  s.x += (rnd(sec)-0.5)*10;
  s.y += (rnd(sec)-0.5)*6;
  vec3 r=normalize(vec3(uv,0.3+rnd(sec+0.3)*1.5));
  cam(s);
  cam(r);
  vec3 p=s;
  vec3 alph=vec3(1);
  for(int i=0; i<100; ++i) {
    float d=map(p);
    if(d<0.001) {
      vec2 off=vec2(0.01,0);
      vec3 n=normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
      
      vec3 rv=(rnd(vec3(uv, fract(time)+i))-0.5);
      n=normalize(n+rv*0.1);
      r=reflect(r,n);
      p+=n*0.02;
      float ao = gao(p,n,0.5) * gao(p,n,1) * gao(p,n,0.2);
      col += atm * alph;
      atm = vec3(0);
      alph *= pow(1.-abs(dot(n,r)),3.) * ao;
      d=0.1;
    }
    if(d>100.) break;
    p+=r*d;
  }
  
  col += atm * alph;
  col += pow(abs(r.y),3)*16 * alph;
  vec3 cc=vec3(0.4,0.7,0.2);
  float t2=rnd(sec*0.5)*100;
  cc.xz *= rot(t2);
  cc.yz *= rot(t2*1.3);
  cc=abs(cc);
  float te = mus(floor(abs(atan(r.x,r.z))*20.0)*0.1);
  //col += pow(abs(r.x),6)*cc*10 * alph;
  col += step(abs(r.y),te*4.3) * cc * 2 * alph;
  
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
  
	out_color = vec4(col, 1);
}