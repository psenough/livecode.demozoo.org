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

float time = mod(fGlobalTime, 300);

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float rnd(float t) {
  return fract(sin(t*342.854)*745.654);  
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)), 10));
}

float curvei(float t, float d) {
  t/=d;
  return mix(floor(t)+rnd(floor(t)), floor(t)+1+rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)), 10))*d;
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

vec3 atm=vec3(0);
float rev=0;
float map(vec3 p) {
  
  vec3 uu;
  
  rev=0;
  p.yx *= rot(sin(time*0.2)*0.7);
  p.zx *= rot(time*0.3);

  vec3 bp=p;
  
  for(int i=0; i<5; ++i) {
    p.yx *= rot(sin(curvei(time,1.7+i*0.1)*0.3)*0.7 + p.x*0.1);
    p.zx *= rot(curvei(time,0.9+i*0.3)*0.4 + p.y*0.1);
    
    p.xz = abs(p.xz)-1+curve(time, 0.3)-curve(time, 1.3)*2 - 1;
  }
  
  float d=length(p)-0.3;
  
  atm+= vec3(1,0.5,0.3) * 0.001 / (0.01+abs(d));
  
  float d2=abs(length(p.xz)-0.0);
  atm+= vec3(0.2,0.5,1.3) * 0.02 / (0.45+abs(d2));
  d=min(d,d2);
  
  d=min(d, length(p.yx));
  
  float d3=length(bp)-3;
  
  d=min(d, d3);
  
  float ss=0.7;
  vec3 rp=(fract(p/ss-0.5)+0.5);
  float d4 = box(rp,vec3(ss*0.1));
  d-=d4*0.3;
  
  rev= texture(texRevisionBW, clamp(bp.xy/5+0.5, 0, 1)).x;
  atm += rev*0.02;
  
  return abs(d)*0.1;
  
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time = mod(fGlobalTime, 400);
  time *= 128/120.0;
  
  time += rnd(floor(time-length(uv)/3 - 0.1*floor(pow(abs(uv).x,0.2)*10-time)))*300;
  
  time *= 0.3;

  vec3 s=vec3(0,0,-20);
  s.x += (curve(time, 4.5)-0.5)*15;
  vec3 r=normalize(vec3(uv, 0.3+curve(time, 4)));
  
  float d=10000;
  vec3 p=s;
  for(int i=0; i<200; ++i) {
    d=abs(map(p));
    if(d<0.001) d=0.1;
    if(d>100) break;
    p+=r*d;
  }
  
  vec3 col=atm/3.0;
    
  if(abs(uv.y)<0.1*curve(time, 40)+0.2 - d/3) {
    col += 0.3;
    col.yz *= rot(time*0.2 + abs(uv.x));
    
    
  }
  
  
  //col=mix(col,(1-col)*sin(uv.x*10)*10, clamp(rev/2,0,1));
  //col += rev*vec3(0.3,0.4,1.2) * 1;
  
	out_color = vec4(col, 1);
}