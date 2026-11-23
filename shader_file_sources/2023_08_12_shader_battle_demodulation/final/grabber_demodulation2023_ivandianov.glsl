#version 410 core

uniform float fGlobalTime; // in seconds
#define time fGlobalTime
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texLogo;
uniform sampler2D texLogoBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

#define F float
#define V vec2
#define W vec3
#define N normalize
#define L length
#define S(x) sin(x+2*sin(x+4*sin(x)))
#define sabs(x) sqrt((x)*(x)+.1)
#define smax(a,b) ((a+b+sabs(a-(b)))*.5)
#define Z(p,s) (asin(sin(p*T/s)*.9)/T*s)
#define T 6.283
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))

layout(location = 0) out vec4 o; // out_color must be written in order to see anything

F gl=0;

F sdf(W p){
  W pI=p;
  
 
  p.x+=S(p.z*.1+time)*p.z*.05;
  p.y+=S(p.z*.161+time)*p.z*.05;
  p.xy=V(atan(p.y,p.x)/T*8+S(pI.z*.162+time*.2),-L(p.xy)+1.5+.6*S(pI.z*.2+time*.2));
 
  p.z+=time*4;
  
  p.y+=.5;
  F pl=p.y;
  
  p.xz=Z(p.xz,2);
  
  p.y+=.5*sin(pI.z+time+atan(p.y,p.x));
  F sp=L(p)-.3;
  F l=L(p)-.02+.02*sin(pI.z+S(time));
  l*=.5;
  
  pl=smax(pl,-sp) + .01*sin(atan(pl,sp)*40);
  
  pl=min(pl,l);
  gl+=.01/l*pl;
  if(l<.002)gl++;
  
  return pl*.5;
}

W norm(W p){
  F d=sdf(p);V e=V(0,.001);
  return N(W(d-sdf(p-e.yxx),d-sdf(p-e.xyx),d-sdf(p-e.xxy)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  o*=0;

  F i=0,d=0,e=1;
  W p,rd=N(W(uv,1));
  rd.xz*=rot(.2*S(time*.1+uv.y*.2));
  rd.yz*=rot(.1*S(time*.161+uv.x*.23));
  for(;i++<99&&e>.001;){
    p=rd*d+.00001;
    d+=e=sdf(p);
  }
  W l=W(0,1,0);
  l.xy*=rot(p.z*.4+time*4);
  W n=norm(p);
  o.r+=dot(n,l)*.5+.5;
  o.g+=dot(n,l.zxy)*.5+.5;
  o.b+=dot(n,l.yzx)*.5+.5;
  o*=(1-i/99)*.8+.2;
  //o=pow(max(o,0),vec4(.5));
  o+=gl;
  o*=smoothstep(50,0,d);
}






