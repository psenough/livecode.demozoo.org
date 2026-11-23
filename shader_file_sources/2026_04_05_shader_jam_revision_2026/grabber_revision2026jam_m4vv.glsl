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
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T fGlobalTime
#define sm smoothstep

vec4 plas( vec2 v, float time )
{
	float c = 0.2 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .2) * .25, 1.0 );
}

mat2 rotator(float a) {
    float c=cos(a), s=sin(a);
    return mat2(c,s,-s,c);
}

float df(vec3 p)
{
  float an=sm(-1.,1.,sin(T))*0.56;
  float a2=sm(-1.,1.,sin(T*0.8))*4.9+sin(floor(T*0.7))*0.5+1.3;
  float s=1;
  vec3 p2=p;
  p2.xy*=rotator(T);
  p2.xz*=rotator(T/2);
  p2.yz*=rotator(T/4);
  mat2 r=rotator(0.01+T/(1+15*sin(floor(T*0.9))));
  for (int i=0;i<2;i+=1){
    p2.xy*=r;
    p2.xz*=r;
    p2.yz*=r;
    p2=abs(p2)-a2*s;
    s*=0.5;
  }
  float d=length(p2)-0.02;
  return d;
}


void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.09;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  int ix=int(gl_FragCoord.x);
  int iy=int(gl_FragCoord.y);
  vec2 cuv=(gl_FragCoord.xy - v2Resolution.xy*0.5)/v2Resolution.yy;
  
  vec3 pos=vec3(0,0,-4);
  vec3 dir=normalize(vec3(cuv,1));
  pos+=dir*float(((ix/1)^(iy/4)+int(T*88))&255)/400;
  float t=0;
  
  int it=0,maxit=80;
  
  for(;it<maxit;it+=1){
    float d=df(pos+t*dir);
    if (d<1e-3||d>1e+6) break;
    
    t+=d;
    
  }
  vec3 pos2=pos+t*dir;
  
  float fr=float(it)/float(maxit);
  vec3 col = fr*vec3(1);
  float ph=fr*4+floor(T+(uv*rotator(T)).x*7000);
  col=sm(-1,1,sin(vec3(ph,ph+6,ph+1)))*fr*fr;
  col*=4.0;
  col=1.*col/(1.+col);
  
  
  
  
	out_color = vec4(col, 1);
}