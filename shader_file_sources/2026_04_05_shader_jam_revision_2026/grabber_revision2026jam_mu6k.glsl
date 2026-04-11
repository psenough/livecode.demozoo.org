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

#define IFFT(A) texture(texFFTIntegrated,A).x
#define T fGlobalTime*30.0/60.0
#define CT (T*3.14159*2.0)

mat2 rot(float a){ float c=cos(a),s=sin(a); return mat2(c,s,-s,c); }
mat2 R,R2;

float dfb(vec3 p){
  vec3 ab=abs(p);
  return max(max(ab.x, ab.y),ab.z);
}

#define REP(A,B) ((fract(A/B)-.5)*B)

float df(vec3 p) 
{ 
  vec3 p2=p;
  float s=9.5;
  for (int i=0; i<4; i+=1)
  {    
    p.xz*=R;
    p.yz*=R2;
    p=abs(p)-s-sin(CT/2);
    s*=0.4;
  }
  float d= dfb(p)-.5 + sin(T/2+IFFT(0)/4)*.125;
  d=min(d,length(p.xz)-0.1);
  d=min(d,length(p.yz)-0.1);
  d=min(d,length(p.xy)-0.1);
  p2.xz*=R;
  p2.z+=T*(.0+IFFT(0))*.15;
  d=min(d,length(REP(p2,4))-.5);
  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  R=rot(CT/14+IFFT(0));
  R2=rot(CT/8+IFFT(0.05));
  
  vec2 auv = gl_FragCoord.xy - 0.5*v2Resolution.xy;
  auv /= min(v2Resolution.x, v2Resolution.y);
  auv.xy*=1.0+pow(length(auv),4.0);
  auv.xy+=vec2(cos(CT/4),sin(CT/4))*.1;
  vec3 p = vec3(0,0, -4);
  vec3 d = normalize(vec3(auv,+1)),p2;
  float dt, t;
  vec3 c=vec3(0);
  int it, maxit;
  for (it=0,maxit=45,t=0; it<maxit; it+=1)
  {
    p2=p+d*t;
    dt=df(p2);
    t+=dt*.5+.1;
    c += sin(p2.yzx*.5+CT/8+dt)/(.1+pow(dt+.5,2.0))*.01;
  }
  c*=sin(auv.y*1000.0+T*8+IFFT(0.1)/2)*.5+1.0;
  c*=sin(auv.y*4000.0+T*8+IFFT(0.1)/2)*.5+1.0;
  c.x*=c.y;
  c=mix(c,vec3(length(c)),0.5);
  vec3 cprev = texture(texPreviousFrame,uv).xyz;
  c*=2.0-length(auv);
  vec3 crgb = vec3(
  texture(texPreviousFrame,((uv-.5)*.97)+.5).x,
  texture(texPreviousFrame,((uv-.5)*.99)+.5).y,
  texture(texPreviousFrame,((uv-.5)*1.01)+.5).z
  );
  vec2 uv2=-uv;
  vec3 crgb2 = vec3(
  texture(texPreviousFrame,((uv2-.5)*.97)+.5).x,
  texture(texPreviousFrame,((uv2-.5)*.99)+.5).y,
  texture(texPreviousFrame,((uv2-.5)*1.01)+.5).z
  );
  c=mix(c,crgb,0.7);
  c=mix(c,crgb2,0.1);
	out_color = vec4(tanh(c),0);
}