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
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
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
  uv = uv*res.y+res*0.5;
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
  return fract(sin(p*562.237+p.yzx*523.834+p.zxy*645.723)*534.771);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);  
}

vec2 proj(vec3 p) {
  
  float l = length(p.xy);  
  if(l<0.33) p.z += sin(time*0.3*4)*0.2;
  if(l<0.13) p.z += sin(time*0.5*4)*0.2;
  
  float t=time*0.1;
  p.xy *= rot(sin(t*0.4)*sin(t*0.5)*sin(t*0.3)*20);
  p.xz *= rot(t * 5);
  
  p.x += sin(time*0.04)*0.2;
  p.x += sin(time*0.04)*0.1;
  
  p.z += 1 + sin(time*0.1)*0.4;
  
  return p.xy/p.z;
}

bool isrev(vec3 p) {
  
  float l = length(p.xy);
  p.xy *= rot(time*0.8);
  if(l<0.33) p.xy *= rot(time);
  if(l<0.13) p.xy *= rot(-time*2.6);
  
  return texture(texRevisionBW, clamp(p.xy+0.5,0,1)).x>0.5;
}

void circ(vec3 p, float r, vec3 c){
  vec2 pp=proj(p);
  float s=r*6.2831*2;
  for(float i=0; i<s; ++i) {
    float a=i/2;
    add(pp + vec2(cos(a), sin(a))*r/res.y, c);
  }
  
}

void line(vec3 p1, vec3 p2, vec3 c) {
  vec2 pp1=proj(p1);
  vec2 pp2=proj(p2);
  
  vec2 diff=abs(pp1-pp2)*res.y;
  float s=min(max(diff.x, diff.y),2000);
  for(int i=0; i<s; ++i) {
    add(mix(pp1,pp2,i/s), c);    
  }
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col=vec3(0);
  
  time = texture(texFFTIntegrated, 0.01).x*0.2;
  time += rnd(vec3(floor(fGlobalTime/4))).x*300;
  
  //col += texture(texFFTSmoothed, abs(uv.x)*0.1).x*10;
  
  vec2 fuv=gl_FragCoord.xy;
  if(fuv.y<6) {
    vec3 p=(rnd(vec3(uv, 0.1))-0.5) * vec3(1,1,0);
    vec3 bp=p;
    if(isrev(p)) {
      //add(proj(p), vec3(1,0.2,0.5));
      circ(p, 10, vec3(1,0.2,0.5));
    }
  }
  
  if(fuv.y<10) {
    vec3 p=(rnd(vec3(uv, 0.1))-0.5) * vec3(8,8,0);
    vec3 bp=p;
    float d=3;
    d += texture(texNoise, p.xy).x*8;
    d += texture(texNoise, p.yx).x*16;
    circ(p, d*10, vec3(1,0.2,1.5)*0.3);
  }
  
  if(fuv.y<10) {
    
    vec3 p=(rnd(vec3(uv, 0.1))-0.5) * vec3(1,1,0);
    for(int i=0; i<15; ++i) {
      vec3 r=(rnd(vec3(uv, 0.2+i))-0.5) * vec3(1,1,0) * 0.2;
      vec3 bp=p;
      p+=r;
      if(!isrev(p)) {
        break;
      }
      if(i>0)line(p, bp, abs(sin(vec3(0.3,0.9,0.7)+i))*1.5);
    }
  }
  
  col += read(fuv);
  
  add(uv, col*0.5);
  
  col *= 0.1;
  
  col.yz *= rot(abs(uv.x)*0.6);
  col.xz *= rot(uv.y*0.6);
  
  col*=1.2-length(uv);
  
  col=smoothstep(0,1,col);
  col=pow(col, vec3(0.4545));
  
	out_color = vec4(col, 1);
}