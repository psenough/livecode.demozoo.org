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
  for (int i=0; i<dd; ++i) {
    vec2 mpos = mix(a,b,i/dd);
    add(mpos, c);
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

float camx;
float camy;
float camdist;
float fov;
vec3 camoff;

float map(vec3 p) {
  
  vec3 bp=p;
  
  for (int i=0; i<3; ++i) {
    p.yz *= rot(sin(time*0.1)+i*1.7);
    p.xz *= rot(sin(time*0.17+i));
    p.xy=abs(p.xy)-0.9 - sin(time*0.3+bp.x*0.3)*0.4;
  }
  float d=box(p, vec3(0.8));
  
  p=abs(p)-1;
  float cl = min(0., sin(fGlobalTime*0.7 - length(p)*0.1));
  d=min(d, length(p.xz)-cl);
  d=min(d, length(p.zy)-cl);
  d=min(d, length(p.xy)-cl);
  
  d=min(d, length(p)-0.2);
  
  d=max(d, 3-length(bp));
  
  //d=min(d, length(bp)-2);
  
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
  
  float sec = floor(fGlobalTime*0.5) + floor(fGlobalTime*0.6);
  time = mod(fGlobalTime,300) + rnd(sec)*300;
  
  camx = time*(rnd(sec+0.01)-0.5);
  camy = time*0.2;
  
  camdist = 15 + 10*sin(time*0.04);
  fov = 2+sin(time*0.3);
  camoff = (rnd(vec3(sec, 0.7,0.2))-0.5)*5;
  
  // compute
  
  vec3 voxpos = rnd(vec3(gl_FragCoord.xy, 0.2))-0.5;
  float gridsize = 18;
  float gridrange = 10;
  voxpos *= gridsize;
  voxpos = floor(voxpos-0.5)/gridsize;
  voxpos *= gridrange;
  
  float voxmap = abs(map(voxpos));
  
  float bright = 1000000.0/(v2Resolution.x*v2Resolution.y);
  
  float viscap = 0.3;
  if(abs(voxmap)<viscap) {
    
    vec3 nx = voxpos+vec3(1,0,0)*gridrange/gridsize;
    vec3 ny = voxpos+vec3(0,1,0)*gridrange/gridsize;
    vec3 nz = voxpos+vec3(0,0,1)*gridrange/gridsize;
    
    vec3 nx2 = voxpos-vec3(1,0,0)*gridrange/gridsize;
    vec3 ny2 = voxpos-vec3(0,1,0)*gridrange/gridsize;
    vec3 nz2 = voxpos-vec3(0,0,1)*gridrange/gridsize;
    
    voxpos = reach(voxpos);
    
    vec3 screen = toscreen(voxpos);
    vec2 buf = tobuf(voxpos);
    vec2 rdof = rnd(vec3(gl_FragCoord.xy,0.7)).xy*vec2(1, 6.283);
    vec2 dof = sqrt(rdof.x)*vec2(cos(rdof.y),sin(rdof.y)) * 0.003;
    add((screen.xy+dof)*v2Resolution.y+v2Resolution.xy*0.5, vec3(0.3, 0.6,1)*10.0);
    
    vec3 linecol = vec3(0.3, 0.6, 1) * 0.002;
    
    /*
    nx=reach(nx);
    ny=reach(ny);
    nz=reach(nz);
    
    nx2=reach(nx2);
    ny2=reach(ny2);
    nz2=reach(nz2);
    
    */
    if(abs(map(nx))<viscap) line2(buf, tobuf(reach(nx)), linecol);
    if(abs(map(ny))<viscap) line2(buf, tobuf(reach(ny)), linecol);
    if(abs(map(nz))<viscap) line2(buf, tobuf(reach(nz)), linecol);
    
    if(abs(map(nx2))<viscap) line2(buf, tobuf(reach(nx2)), linecol);
    if(abs(map(ny2))<viscap) line2(buf, tobuf(reach(ny2)), linecol);
    if(abs(map(nz2))<viscap) line2(buf, tobuf(reach(nz2)), linecol);
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
    float d=abs(map(p)+0.2);
    if(d<0.001) break;
    if(d>100.0) break;
    p+=r*d;
    col += vec3(0.8,0.5,.9) * 0.01 * 0.3/(0.01+d);
  }
  
  col *= 0.3;
  
  col += read(gl_FragCoord.xy) * bright;

  add(gl_FragCoord.xy, min(col,1)*vec3(1.3, 0.6, 1)*max(0, sin(time*0.3)*0.7+0.3));
  
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
	out_color = vec4(col, 1);
}