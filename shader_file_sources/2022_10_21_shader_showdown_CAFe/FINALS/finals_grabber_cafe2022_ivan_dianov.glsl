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
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))
#define S(x) sin((x)+2*sin((x)+4*sin(x)))
#define SS(X) S(L(P.xy)-P.z*1.4+time*.3+99*X)
//#define 

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void main(void)
{
  out_color-=out_color;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  F i=0,d=0,e=1;
  W p,P,rd=N(W(uv,1));
  rd.y*=4.;
  rd.xz*=rot(-2*uv.x+time*.1);
  for(;i++<99&&e>.0001;){
    p=P=rd*d+.001;
    p.z-=5-time*.5;
    
    p.z+=atan(p.y,p.x)/3.1415;
    p.z=mod(p.z,.5)-.25;
    
    F ss=3,s;
    for(F j=0;j++<3;){
    p.xy=mod(p.xy,1)-.5;
      ss*=s=2;p*=s;
      p.xy = V(L(p.xy)-.7+SS(3)*.1,atan(p.y,p.x)/3.1415*2);
      ss*=s=2;p*=s;
      //cyl
      p.xz=V(atan(p.z,p.x)/3.1415*1,L(p.xz)-.5+.2*SS(0));
      p.x+=time*.1;
      out_color.r+=.004/exp(300*e)*(S(L(-P.z+P.x))*.5+.5);
      out_color.b+=.004/exp(300*e)*(S(L(P.z+P.y))*.5+.5);
    }
    p.xy=mod(p.xy,1)-.5;
    d+=e=(L(V(L(p.xy)-.5+.3*SS(2),p.z))-.3+.2*SS(1))/ss;
  }

	out_color += 1-i/99;
}