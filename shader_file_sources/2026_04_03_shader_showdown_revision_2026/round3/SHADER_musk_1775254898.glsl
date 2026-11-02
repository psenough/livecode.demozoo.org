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

#define T fGlobalTime
#define FFT(A) (texture(texFFTIntegrated,A)).x

mat2 rot(float a){ float c=cos(a),s=sin(a); return mat2(c,s,-s,c);}
mat2 R;
#define REP(A,B) (fract(A/B)-0.5)*B
#define RIP(A,B) ((A-fract(A/B))-0.5)*B

float df(vec3 p) {
  float s=2.5;
  vec3 p2=p;
  p2.z+=T*4.0+FFT(0.5);
  p2.xy*=rot(p.z/14);
  vec3 id=RIP(p2,2.0);
  
  for (int i=0;i<5; i+=1) {
    p.yz*=R;
    p.xz*=R;
    p.xy*=R;
    
    p=abs(p)-s+sin(FFT(0.02))*.01;
    s*=0.4;
  }
  float d= length(p)-.2+sin(T/4)*.01+sin(FFT(.0)*4.0)*.05;
  d=min(d,length(p.xy)-.2);
  d=min(d,length(REP(p2,4.0))-.0+.4*sin(dot(id,vec3(12,3,4)*.01)));
  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 auv = gl_FragCoord.xy -0.5*v2Resolution.xy;
  auv/=min(v2Resolution.x, v2Resolution.y);
  
  R=rot(T/9+FFT(0)*.2);

  vec3 d=normalize(vec3(auv, +1));
  vec3 p=vec3(0,0,-4);
  float t=0,dt;
  int it,maxit;
  vec3 p2;
  vec3 c=vec3(0);
  
  for (it=0,maxit=80,t=0;it<maxit;it+=1)
  {
    p2=p+d*t;
    dt=df(p2);
    t+=dt*.5+.1;
    c+=(sin(p2.yzx*.5+T)*.4+0.25)/(0.01+pow(dt-0.2,2.0)*33.0)*.01;
  }
  c.x+=c.y;
  c*=(1.0-length(auv));
  c=mix(c,vec3(length(c)),sin(T+FFT(0.4))*.2+.5);
  out_color = vec4(tanh(c),1);
}