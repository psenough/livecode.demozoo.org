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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time=0;
float pul=0;
float pul2=0;
float sec=0;
float pi2 = acos(-1)*2.;

vec3 read(ivec2 iuv) {
  return vec3(imageLoad(computeTexBack[0], iuv).x
              ,imageLoad(computeTexBack[1], iuv).x
              ,imageLoad(computeTexBack[2], iuv).x) * 0.001;
}

void add(vec2 uv, vec3 col) {
  ivec2 iuv=ivec2(uv*v2Resolution.y+v2Resolution.xy*0.5);
  ivec3 qcol=ivec3(col*1000);
  imageAtomicAdd(computeTex[0], iuv, qcol.x);
  imageAtomicAdd(computeTex[1], iuv, qcol.y);
  imageAtomicAdd(computeTex[2], iuv, qcol.z);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}


float rnd(float t) {
  return fract(sin(t*542.412)*935.624);
}

vec2 rnd(vec2 t) {
  return fract(sin(t*542.412+t.yx*437.544)*935.624);
}

vec3 rnd(vec3 t) {
  return fract(sin(t*542.412+t.yzx*437.544+t.zxy*274.814)*935.624);
}


void proj(vec3 p, vec3 col, float blur) {
    
  float gr=1+3*rnd(floor(time*5.));
  p.xy=floor(p.xy*gr)/gr;
    
  float t=time*0.1 + pul;
  p += sin(t*vec3(0.3,0.27,0.36));
  
  p.yz *= rot(sin(t*0.2)*0.3);
  p.xz *= rot(t*(rnd(sec)-.5)*0.7);
  
  
  float dof = smoothstep(0,1,abs(p.z)/10);
  
  p.z += 10.0;
  if(p.z<=0.0) return;
  p.z *= 0.3+1.5*rnd(floor(time)+.3);
  p.xy /= p.z;
    
  vec2 rn=rnd(p.xy);
  rn.x*=pi2;
  rn.y=pow(rn.y,0.4)*0.25;
  
  vec2 dec=vec2(cos(rn.x), sin(rn.x))*rn.y;
  p.xy+=dec * dof * blur;
  
  col.xz+=dec*0.3;
  
  add(p.xy, col);
  
  
}

float map(vec3 p) {
  float d=length(p)-1;
  for(int i=0; i<3; ++i) {
    float t=time*0.02+pul2*0.4+i;
    p.xz *= rot(t*.7 + sin(p.y*.1+time*.3)*.2);
    p.yz *= rot(t+i + sin(p.x*.13-time*.2)*.2);
    p=abs(p)-0.7-0.4*sin(time*vec3(.3,0.4,0.5)-1.8*max(0,sin(time*0.2)));
  }
  vec3 p2 = p;
  p2=abs(p2)-1.3;
  p2=abs(p2)-0.3;
  d=min(d,length(p2.xz)-.05);
  d=min(d,length(p2.yz)-.05);
  d=min(d,length(p2.yx)-.05);

  d=min(d, box(p, vec3(0.4+0.3*sin(time*vec3(0.7,0.4,0.6)*0.4))));
  return d;
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  time=mod(fGlobalTime*.6, 300);
  sec = rnd(floor(time)+.1) * 200 + rnd(floor(time/2)+.2)*200;
  pul = texture(texFFTIntegrated, 0.01).x * 0.4 + sec;
  pul2 = texture(texFFTIntegrated, 0.02).x * 0.5 + sec*2;
  
  
  vec3 s=vec3(0,0,-10);
  float fov = 0.7 + rnd(sec+.1)*.5;
  vec3 r=normalize(vec3(uv, fov));
  vec3 p=s;
  float dd=0;
  for(int i=0; i<100; ++i) {
    float d=abs(map(p));
    if(d<0.001) {
      d=0.1;
      proj(p, vec3(abs(uv)*3.0, 1), 1.);
      //break;
    }
    if(dd>20.0) break;
    p+=r*d;
    dd+=d;
  }
  
  vec3 p2=mix(s,p,rnd(uv).x);
  proj(p, vec3(abs(uv.yx)*1.0, 1), 0.3);
  
  vec3 col=vec3(0);
    
  col += read(ivec2(gl_FragCoord.xy));
  col *= 0.13 * (1.2-length(uv));
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
	out_color = vec4(col, 1);
}