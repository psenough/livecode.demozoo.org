#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time;
vec2 res=v2Resolution;

vec3 rnd(vec3 p) {
  return fract(sin(p*453.356+p.yzx*543.634+p.zxy*864.834)*634.233);
}

void add(vec2 uv) {
  uv*=res.y;
  uv+=res*0.5;
  
  imageAtomicAdd(computeTex[0], ivec2(uv), 1);
}

float read(vec2 uv) {
  return imageLoad(computeTexBack[0], ivec2(uv)).x;
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float map(vec3 p ) {
  
  vec3 bp=p;
  for(int i=0; i<3; ++i ){
    float t=time*0.01 + texture(texFFTIntegrated, 0.02).x*0.1;
    p.xz*=rot(t*0.7+i);
    p.yz*=rot(t);
    p.xy=abs(p.xy)-0.7-sin(time)*0.4-exp(-fract(time/5))*1;
  }
  
  float d=length(p)-0.6-sin(time*0.3)*0.4;
  
  float s=0.01-sin(time*0.1+dot(p,vec3(0.01)))*0.1;
  d=min(d, length(p.xy)-s);
  d=min(d, length(p.xz)-s);
  d=min(d, length(p.zy)-s);
  
  float d2=length(bp)-2;
  d2=max(d2, length(p)-1);
  d=min(d, d2);
  
  float rev=texture(texRevisionBW, p.xy/10).x;
  //d=(rev-0.5)*0.1;
  
  return abs(d);
}

vec2 proj(vec3 p) {
  float t=time*0.4;
    p.xy*=rot(t);
    p.zx*=rot(t*1.3);
  p.x+=sin(time*0.01)*5;
  p.z-=15 + sin(time*0.1)*8;
  
  return p.xy/p.z;
}

void line(vec3 pa, vec3 pb) {
  vec2 a=proj(pa);
  vec2 b=proj(pb);
  vec2 d=abs(a-b)*res;
  float l=min(1000, max(d.x,d.y));
  
  for(int i=0; i<l; ++i) {
    add(mix(a,b,i/l));
  }
}
void axe(vec3 p1, vec3 dir) {
  vec3 p=p1+dir;
  vec2 off=vec2(0.01, 0);
  float d=map(p);
  vec3 n=normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
  p-=d*n;
  if(map(p)<0.1) {
    line(p1,p);
  }
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col=vec3(0);
  
  
  
  time = texture(texFFTIntegrated, 0.01).x*0.3;
  time += rnd(vec3(floor(time/6))).x*300;
  
  vec2 fuv=gl_FragCoord.xy;
  
  if(fuv.y<40) {
    
    vec3 p=rnd(vec3(uv, 1))-0.5;
    p*=10;
    float grid=0 + rnd(floor(p*0.3-time*0.2)).x*5;
    p=floor(p*grid)/grid;
    if(map(p)<0.1) {
      float s=1/grid + max(0, sin(time));
      axe(p, vec3(1,0,0)*s);
      axe(p, vec3(0,1,0)*s);
      axe(p, vec3(0,0,1)*s);
      axe(p, -vec3(1,0,0)*s);
      axe(p, -vec3(0,1,0)*s);
      axe(p, -vec3(0,0,1)*s);
    }
  }
  
  fuv.y+=exp(-fract(time))*0.2;
  
 // col += rnd(vec3(floor(abs(uv.x)*10-time*3))).x;
  col += read(fuv) * vec3(0.3 + abs(uv.y)*0.3, 0.6, 1) * (0.1+fract(time)*0.01);
  col += texture(texPreviousFrame, fuv/res-uv*0.01).xyz * vec3(0.95,0.6,0.9);
	out_color = vec4(col, 1);
}