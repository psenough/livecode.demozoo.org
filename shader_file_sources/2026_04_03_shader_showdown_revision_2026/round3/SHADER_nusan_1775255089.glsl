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

float time = mod(fGlobalTime, 300);
vec2 res = v2Resolution;

void add(vec2 uv, vec3 c) {
  uv=uv*res.y+res*0.5;
  c*=10000;
  imageAtomicAdd(computeTex[0], ivec2(uv), int(c.x));
  imageAtomicAdd(computeTex[1], ivec2(uv), int(c.y));
  imageAtomicAdd(computeTex[2], ivec2(uv), int(c.z));
}

vec3 read(vec2 uv) {
  vec3 c;
  c.x = imageLoad(computeTexBack[0], ivec2(uv)).x;
  c.y = imageLoad(computeTexBack[1], ivec2(uv)).x;
  c.z = imageLoad(computeTexBack[2], ivec2(uv)).x;
  return c/10000;
}

vec3 rnd(vec3 p) {
  
  return fract(sin(p*523.612+p.yzx*343.723+p.zxy*634.812)*273.634);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

vec3 mat;
float map(vec3 p) {
  
  mat = vec3(1,0.2,0.5);
  
  vec3 bp=p;
  
  float t=time*0.05;
  for(int i=0; i<3; ++i){
    p.xz *= rot(t);
    p.yz *= rot(t*0.7);
    p.xy = abs(p.xy)-2;
  }
  
  float d=length(p)-1;
  
  float d2=length(bp)-3;
  if(d2<d) {
    d=d2;
    mat=vec3(0.7,0.5,1) * 0.1;
  }
  
  vec3 p2=abs(p)-5;
  float cs=0.5;
  float d3=length(p2.xy)-cs;
  d3=min(d3, length(p2.xz)-cs);
  d3=min(d3, length(p2.yz)-cs);
  if(d3<d) {
    d=d3;
    mat=vec3(0.1,1,0.8)*0.3;
  }
  
  return d;
}

float scale;
vec2 proj(vec3 p) {
  
  float t=time*0.2;
  p.xy *= rot(t);
  p.yz *= rot(t*1.3);
  
  p.x += sin(time*0.06)*4;
  p.y += sin(time*0.07)*2;
  
  p.z += 15 + sin(time*0.03)*10;
  scale=res.y/p.z;
  return p.xy/p.z;
}

void circ(vec3 p, float r, vec3 c) {
  vec2 pp=proj(p);
  r=min(500,r*scale);
  float s=r*6.2831*2;
  for(float i=0; i<s; ++i) {
    float a=i/2;
    add(pp + vec2(cos(a), sin(a))*r/res.y, c);
  }
}

void line(vec3 p1, vec3 p2, vec3 c) {
  vec2 pp1 = proj(p1);
  vec2 pp2 = proj(p2);
  vec2 diff=abs(pp1-pp2)*res.y;
  float s=min(2000, max(diff.x, diff.y));
  for(int i=0; i<s; ++i) {
    add(mix(pp1, pp2, i/s), c);
  }
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col=vec3(0);
  
  time += rnd(vec3(floor(fGlobalTime/3))).x*300;
  
  vec2 fuv=gl_FragCoord.xy;
  if(fuv.y<60) {
    vec3 pos=(rnd(vec3(uv, 0.1))-0.5) * 30;
    float d=map(pos);
    if(d<0) {
      //add(proj(pos), vec3(1,0.2,0.5));
      circ(pos, abs(d), mat);
      line(pos, vec3(0), vec3(0.2*exp(-fract(time)*10)));
    }
  }
  
  if(fuv.y<1) {
    vec3 p=vec3(0,0,-15);
    vec3 r=normalize(vec3(0,sin(time*0.3)*0.3,1) + (rnd(vec3(uv, 0.2))-0.5)*0.3);
    
    vec3 bp=p;
    for(int i=0; i<15; ++i) {
      float d=abs(map(p));
      if(i>0)circ(p, d, vec3(1,0.4,0.4) * 0.02);
      p+=r*d;
    }
    line(p, bp, vec3(0.5,1,0.7)*0.02);
  }
  
  col += read(fuv);
  
  float mi=0.9;
  add(uv, col*mi);
  
  float t2=time*0.0;
  
  col.xy *= rot(abs(uv.x)*0.5 + t2);
  col.yz *= rot(uv.y*0.6 + t2*0.7);
  col=abs(col);
  
  col *= 0.1;
  
  col=smoothstep(0,1, col);
  col=pow(col, vec3(0.4545));
  
	out_color = vec4(col, 1);
}