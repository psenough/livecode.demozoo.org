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
uniform sampler2D texLynn;
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

void add(vec2 uv, vec3 c) {
  c*=10000;
  uv*=res.y;
  uv+=res*0.5;
  imageAtomicAdd(computeTex[0], ivec2(uv), int(c.x));
  imageAtomicAdd(computeTex[1], ivec2(uv), int(c.y));
  imageAtomicAdd(computeTex[2], ivec2(uv), int(c.z));
}

vec3 read(vec2 uv) {
  if(fract(time/5)<0.5) uv.x=abs(uv.x-res.x*0.5)+res.x*0.5;
  vec3 c;
  c.x = imageLoad(computeTexBack[0], ivec2(uv)).x;
  c.y = imageLoad(computeTexBack[1], ivec2(uv)).x;
  c.z = imageLoad(computeTexBack[2], ivec2(uv)).x;
  c/=10000;
  return c;
}


vec3 rnd(vec3 p) {
  return fract(sin(p*345.234+p.yzx*654.376+p.zxy*934.623)*435.623);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float fov;

vec3 proj(vec3 p) {
  
  float t=time*0.4;
  p.xy *= rot(t*1.3);
  p.yz *= rot(t);
    
  p.z-=10 + sin(time)*8;
  
  return vec3(p.xy / p.z, p.z);
}

void line(vec3 pa, vec3 pb, vec3 c) {
  vec3 ja=proj(pa);
  vec3 jb=proj(pb);
  float h=0;
  if(ja.z>h || jb.z>h) return;
  vec2 a=ja.xy;
  vec2 b=jb.xy;
  vec2 d=abs(a-b)*res;
  float l=min(1000, max(d.x,d.y));
  for(int i=0; i<l; ++i) {
    add(mix(a,b,i/l),c);
  }
}

float tre=0.1;

float smin(float a, float b, float k) {
  float h=clamp((a-b)/k*0.5+0.5,0,1);
  return mix(a,b,h) - k*h*(1-h);
}

float map(vec3 p) {
  
  for(int i=0; i<3; ++i) {
    float t=time*0.4 + texture(texFFTIntegrated, 0.02).x*0.08;
    p.xz *= rot(t);
    p.yz *= rot(t*0.7);
    p.xz = abs(p.xz)-1 - exp(-fract(time))*2;
  }
  
  float d=length(p)-0.2;
  
  d=smin(d, length(p.xz)-0.8,2);
  
  return d;
}

void reach(inout vec3 p) {
  vec2 off=vec2(0.01,0);
  for(int i=0; i<5; ++i) {
    float d=map(p);
    vec3 n=normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
    p-=n*d;
  }
}

vec3 axe(vec3 p1, vec3 p2, vec3 c) {
  reach(p2);
  if(abs(map(p2))<tre) {
    line(p1,p2,c);
  }  
  return p2;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  time = texture(texFFTIntegrated, 0.01).x*0.3 + fGlobalTime*0.1;
  float rt=rnd(vec3(floor(time/2))).x*300;
  time = mod(time, 300);
  time += rt;
  
  
  vec3 col = vec3(0);
  
  // compute stuff
  vec2 fuv=gl_FragCoord.xy;
  if(fuv.y<6) {
    vec3 p=rnd(vec3(uv, 1))-0.5;
    p*=10;
    if(abs(map(p))<tre) {
      vec3 c=vec3(1);
      vec3 l=p;
      vec3 n=p;
      for(int i=0; i<5; ++i) {
        vec3 s=(rnd(vec3(uv, 2+i))-0.5)*0.01;
        n=l+s+l*0.05;
        float e=0.2;
        n.xz*=rot((0.1+sin(time+p.y*0.2)*e));
        n.xy*=rot((sin(time*0.3+p.x*0.1)*e));
        axe(l,n, c/(i*1+0.1));
        l=n;
      }
    }
    
    
  }
  
  col += read(fuv) * vec3(0.2+abs(uv.y)*2, 0.8,0.3);
  

  vec2 tuv = vec2(uv.x,-uv.y - exp(-fract(time*10))*0.1)+0.5;
  vec4 lynn=texture(texLynn, tuv);
  lynn.xyz*=lynn.w;
  lynn.xyz *= 3;
  
  tuv-=0.5;
  tuv*=rot(time);
  tuv+=0.5;
  vec4 rev=texture(texRevisionBW, tuv);
  
  if(fract(time/3)<0.5) lynn=rev;
  
  lynn.xyz=pow(lynn.xyz, vec3(0.1));
  //col += lynn.xyz*0.1;

  //col += texture(texPreviousFrame, fuv/res).xyz*lynn.xyz*0.96;
  vec3 dec=vec3(1,1,0)*1;
  float g=0.245;
  col += texture(texPreviousFrame, (fuv+dec.xz)/res).xyz*g;
  col += texture(texPreviousFrame, (fuv-dec.xz)/res).xyz*g;
  col += texture(texPreviousFrame, (fuv+dec.zy)/res).xyz*g;
  col += texture(texPreviousFrame, (fuv-dec.zy)/res).xyz*g;
  
  if(fract(time/2)<0.5) col *= lynn.xyz*0.5 + 0.5;
  
  ///*
  float t=time*0.1+fract(time*0.2) + uv.x;
  col.xz*=rot(t);
  col.xz*=rot(t*0.8);

  col=abs(col)*1;
  //*/
	out_color = vec4(col,1);
}