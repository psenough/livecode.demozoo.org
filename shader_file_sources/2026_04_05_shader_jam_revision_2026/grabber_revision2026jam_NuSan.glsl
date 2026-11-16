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


float time=mod(fGlobalTime, 300);
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
  return fract(sin(p*723.239+p.yzx*634.799+p.zxy*684.612)*316.823);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

vec2 proj(vec3 p) {
  
  float t=time*0.2;
  
  p.xy *= rot(sin(t*0.4)*sin(t*0.3)*sin(t*0.5)*20);
  p.xz *= rot(t);
  
  p.z += 1.5;
  
  return p.xy/p.z;
}


void circ(vec3 p, float r, vec3 c) {
  vec2 pp=proj(p);
  r=min(r, 500);
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
  float s=min(max(diff.x,diff.y),2000);
  for(int i=0; i<s; ++i) {
    add(mix(pp1, pp2, i/s), c);
  }
}

float get(vec3 p) {
  
  float d=1;
  d += texture(texNoise, p.xy+time).x*50;
  d += texture(texNoise, p.yx-time*0.3).x*100;
  return d;
}


vec4 mytex(vec3 p) {
  
  float id=mod(floor(time),7);
  
  float l=length(p.xy);
  vec2 uv=clamp(p.xy+0.5,0,1);
  vec4 t=texture(texAmiga, uv);
  if(id==1) t=texture(texAtari, uv);
  if(id==2) t=texture(texC64, uv);
  if(id==3) t=texture(texEvilbotTunnel, clamp((p.xy*0.5-vec2(0.0,1.6))*0.2+0.5, 0, 1));
  if(id==4) t=texture(texEwerk, uv);
  if(id==5) t=texture(texRevisionBW, uv);
  if(id==6) t=texture(texST, uv);
  
  return t;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	
  vec3 col=vec3(0);
  
  vec2 fuv=gl_FragCoord.xy;
  if(fuv.y<1) {
    vec3 p=(rnd(vec3(uv, 0.1))-0.5) * vec3(1,1,0);
    p.z += texture(texFFTSmoothed, 0.01).x*5.0;
    vec4 d = mytex(p);
    if(d.w>0) {
      //add(proj(p), vec3(1,0.2,0.5));
      circ(p, 2 + d.x*10, d.xyz);
      line(p, vec3(0,0,-15), d.xyz * 0.2);
    }
  }
  
   if(fuv.y<2) {
     
     vec3 p=(rnd(vec3(uv, 0.1))-0.5) * vec3(10,10,0);
     circ(p + dot(sin(p.xy+time),vec2(0.5,0.6))*vec3(0,0,1), get(p), vec3(0.3,1,0.5)*0.5);
     
   }
   
  
  col += read(fuv);
  
  add(uv, col*0.8);
  
  col *= 0.3;
   
  float t=time*0.1;
  col.xz *= rot(t+abs(uv.x));
  col.yz *= rot(t*0.7 + uv.y);
  col=abs(col);
   
  col=smoothstep(0,1, col);
  col=pow(col, vec3(0.4545));
   
  
	out_color = vec4(col, 1);
}