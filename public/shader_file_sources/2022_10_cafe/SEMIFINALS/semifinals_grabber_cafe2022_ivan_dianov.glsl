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

#define B texture(texFFTIntegrated,.1).r
#define F float
#define V vec2
#define W vec3
#define N normalize
#define L length
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))
#define S(x) sin((x)+2*sin((x)+4*sin(x)))

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  F i=0,e=1,d=0;
  W p,P,rd=N(W(uv,1+.5*S(time+L(uv))));
  rd.xz *= rot(.5*S(time*.3));
  rd.xy *= rot(.5*S(time*.7)+B*.1);
  for(;i++<99&&e>.001;){
    P=p=rd*d+.001;
    
    p.z+=time*2;
    
    p.z+=atan(p.y,p.x)/3.1415;
    F ss=4,s;
    p.xy+=1;
    p.x+=S(time*99)*.01;
    for(F j=0;j++<12;){
      p=mod(p+1,2)-1;
      ss*=s=(1.6+.2*S(time+P.z))/dot(p,p);
      p*=s;
      p.z+=.3*S(P.z+time);
    }
    d+=e=(length(p.xz)-.5)/ss;
  }
	out_color += 1-i/99;
}