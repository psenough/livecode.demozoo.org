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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = mod(fGlobalTime, 300);


void add(vec2 pos, vec3 v) {
  v*=10000;
  imageAtomicAdd(computeTex[0], ivec2(pos), int(v.x));
  imageAtomicAdd(computeTex[1], ivec2(pos), int(v.y));
  imageAtomicAdd(computeTex[2], ivec2(pos), int(v.z));
}

vec3 read(vec2 pos) {
  vec3 c=vec3(0);
  c.x += imageLoad(computeTexBack[0], ivec2(pos)).x;
  c.y += imageLoad(computeTexBack[1], ivec2(pos)).x;
  c.z += imageLoad(computeTexBack[2], ivec2(pos)).x;
  return c/10000.0;
}


float rnd(float t) {
  return fract(sin(t*452.312)*921.424);
}
vec2 rnd(vec2 t) {
  return fract(sin(t*452.312+t.yx*332.714)*921.424);
}
vec3 rnd(vec3 t) {
  return fract(sin(t*452.312+t.yzx*332.714+t.zxy*324.147)*921.424);
}

vec2 circ(vec2 seed) {
  vec2 rr = rnd(seed);
  rr.x*=6.28;
  rr.y=sqrt(rr.y);
  return vec2(cos(rr.x)*rr.y,sin(rr.x)*rr.y);
}

void line(vec2 a, vec2 b, vec3 c, float seed) {
  vec2 mpos = mix(a,b,rnd(seed));
  add(mpos, c);
}

void line2(vec2 a, vec2 b, vec3 c) {
  float dd=ceil(max(abs(a.x-b.x),abs(a.y-b.y)));
  dd=min(dd,600);
  vec2 perp=normalize(b-a).yx*vec2(-1,1);
  int width=2;
  for (int i=0; i<dd; ++i) {
    vec2 mpos = mix(a,b,i/dd);
    for (int j=-width; j<=width; ++j) {
      add(mpos + perp*j, c);
    }
  }
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float smin(float a, float b, float h) {
  float k=clamp((a-b)/h*0.5+0.5,0,1);
  return mix(a,b,k) - k*(1-k)*h;
}

vec3 smin(vec3 a, vec3 b, vec3 h) {
  vec3 k=clamp((a-b)/h*0.5+0.5,0,1);
  return mix(a,b,k) - k*(1-k)*h;
}

float camx;
float camy;
float camdist;
float fov;
vec3 camoff;

float map(vec3 p) {
  
  vec3 bp=p;
  
  float d = 10000;
  
  for (int i=0; i<3; ++i) {
    p.xz *= rot(time*0.2+i);
    p.yz *= rot(time*0.3+i*0.7);
    //p=abs(p)-0.4;
    p=-smin(p,-p,vec3(0.4));
    p-=0.5;
    d=smin(d, abs(length(p.xz)-0.3), 0.3);
    d=smin(d, abs(length(p.yz)-0.3), 0.3);
  }
  
  d=smin(d, 5-sin(time*0.2)*2-length(bp + sin(p.yzx+time) + sin(p.zxy*1.3+time)), 2.6);
  
  d=smin(d, length(bp)-6, -1.6);
  
  
  d=smin(d, length(p) - 0.8, 0.6);
  
  return d;
}

vec3 toscreen(vec3 p) {
  p+=camoff;
  p.yz *= rot(camy);
  p.xz *= rot(camx);
  
  float proj=fov/(camdist+p.z);
  
  return vec3(p.xy*proj, p.z);
}

vec2 tobuf(vec3 p) {
  return toscreen(p).xy*v2Resolution.y+v2Resolution.xy*0.5;
}

vec3 reach(vec3 p) {
  //return p;
  for(int i=0; i<4; ++i) {
    vec2 off=vec2(0.01, 0);
    float d=map(p);
    vec3 n=normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
    p-=n*d;
  }
  return p;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float sec = floor(fGlobalTime*0.2) + floor(fGlobalTime*0.14);
  //sec = 19.;
  time = mod(fGlobalTime,300) + rnd(sec)*300;
  
  //camx = time*(rnd(sec+0.01)-0.5);
  camx = time * 0.07;
  camy = time*0.2;
  
  camdist = 20 + 12*sin(time*0.04);
  fov = 2+sin(time*0.3);
  camoff = (rnd(vec3(sec, 0.7,0.2))-0.5)*5;
  
  // compute
  
  if (gl_FragCoord.x<20 && gl_FragCoord.y<20) {
    vec3 voxpos = rnd(vec3(gl_FragCoord.xy, 0.2))-0.5;
    float gridsize = 8;
    float gridrange = 10;
    
    voxpos *= gridsize;
    voxpos = floor(voxpos-0.5)/gridsize;
    voxpos *= gridrange;
    
    float voxmap = abs(map(voxpos));
    
    float viscap = 0.3;
    if(abs(voxmap)<viscap) {
      
      voxpos = reach(voxpos);
      float push = 0.1+0.16*(abs(voxmap)/viscap);
      
      for (int j=0; j<4; ++j) {
        vec3 rdir = normalize(rnd(vec3(gl_FragCoord.xy,0.7+j*0.3))-0.5);
                
        vec3 linecol = rnd(vec3(gl_FragCoord.xy,0.4+j*0.7)) * 0.2 * 3;
        
        for(int i=0; i<20; ++i) {
          vec3 secpos = voxpos + rdir*push;
          secpos = reach(secpos);
          float twi=floor((0.5+sin(time)*0.5)*5)/2;
          rdir = normalize(secpos-voxpos + (rnd(vec3(gl_FragCoord.xy,0.3+i+j*0.9))-0.5+0.3*sin(time)*sin(time*0.7)*sin(time*0.5))*twi);
          line2(tobuf(voxpos), tobuf(secpos), linecol);
          voxpos=secpos;
        }
      }
    }
  }
  
  // raymarch

  vec3 s=vec3(0,0,-camdist);
  vec3 r=normalize(vec3(uv, fov));
  
  s.xz *= rot(-camx);
  s.yz *= rot(-camy);
  s-=camoff;
  r.xz *= rot(-camx);
  r.yz *= rot(-camy);
  
  vec3 p=s;  
  
  vec3 col = vec3(0);
  
  for(int i=0; i<100; ++i) {
    float d=abs(map(p)+0.02);
    if(d<0.001) d=0.1; //break;
    if(d>100.0) break;
    col += vec3(0.3,0.9,.7) * 0.01 * 0.3/(0.01+d);
    p+=r*d;
  }
  
  col *= 0.03;
  
  col += read(gl_FragCoord.xy);

  add(gl_FragCoord.xy+vec2(1,0)*sin(time+gl_FragCoord.y/2)*20, min(col,1)*1.1*exp(-fract(fGlobalTime/4)));
  col *= 0.5;
  
  col *= 1.2-length(uv);
  
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
  
	out_color = vec4(col, 1);
}