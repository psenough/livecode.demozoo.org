#version 410 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define hash(x) fract(sin(x)*1532.2672)
#define saturate(x) clamp(x,0,1)
#define ease(x,s) smoothstep(.5-s,.5+s,fract(x))
const float pi2=acos(-1)*2;
const float cs=.25;

vec2 hash22(vec2 p){
  vec2 v=vec2(dot(p,vec2(1.5263,1.1632)),dot(p,vec2(1.8273,1.3162)));
  //return hash(v)*2-1;
  float t=time*cs;
  return sin(hash(v)*pi2+(floor(t)+ease(t,.1))*5);
}

float p2d(vec2 p){
  vec2 i=floor(p);
  vec2 f=fract(p);
  vec2 b=vec2(1,0);
  vec2 u=f*f*(3-2*f);
  return mix(mix(dot(f-b.yy,hash22(i+b.yy)),dot(f-b.xy,hash22(i+b.xy)),u.x),
             mix(dot(f-b.yx,hash22(i+b.yx)),dot(f-b.xx,hash22(i+b.xx)),u.x),
             u.y);
}

float fbm(vec2 p){
  float ac=0,a=1;
  for(int i=0;i<5;i++){
    ac+=p2d(p*a)/a;
    a*=2;
  }
  return saturate(ac);
}

vec3 hsv(float h,float s,float v){
  vec3 res=fract(h+vec3(0,2,1)/3)*6-3;
  res=saturate(abs(res)-1);
  res=(res-1)*s+1;
  res*=v;
  return res;
}

mat2 rot(float a){
  float s=sin(a),c=cos(a);
  return mat2(c,s,-s,c);
}

#define odd(x) step(1,mod(x,2))
float sqWave(float x){
  float i=floor(x);
  return mix(odd(i),odd(i+1),ease(x,.05));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1)*.5;
  vec3 col=vec3(0);
  
  uv*=.3+sqWave(time*.2)*.7;
  uv-=sin(vec2(.5,.7)*time*.5)*.5;
  uv*=rot(time*.2);
  
  float cp=time;
  for(int i=0;i<20;i++){
    float L=1-fract(cp)+i;
    float id=floor(cp)+i;
    vec2 p=uv/atan(.001,L)*.001;
    float c1=saturate(sin(fbm(p*.5+hash(id)*500)*20));
    c1+=pow(sin((time*cs-.25)*pi2)*.5+.5,30)*.4;
    float a=hash(id*1.1)*pi2;
    vec2 v=vec2(cos(a),sin(a))*.5;
    float c2=saturate(sin(fbm(p*.25+hash(id*1.2)*500+time*v)*20));
    float c=c1+pow(c1*c2,5)*8;
    float L2=dot(p,p)*10+L*L;
    col+=hsv(hash(id*1.3),.8,c)*exp(-L2*.01);
  }
  
  float l=2;
  col=col/(1+col)*(1+col/l/l);
  //col=hsv(uv.y,.5,.5);
	out_color = vec4(col,1);
}