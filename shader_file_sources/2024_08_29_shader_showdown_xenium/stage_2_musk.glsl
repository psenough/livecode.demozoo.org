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

#define T (fGlobalTime*.5)
#define ss smoothstep

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(float a){ 
  float c=cos(a),s=sin(a);
  return mat2(c,s,-s,c);
}

float box(vec3 p) {
  vec3 ap=abs(p);
  return max(p.x,max(p.y, p.z));
}

float df2(vec3 p)
{
  float an=ss(-1.,1.,sin(T))*0.1;
  float a2=ss(-1.,1.,sin(T*0.4))*0.2+sin(floor(T*0.7))*0.1+0.2;
  float s=2;
  vec3 p2=p;
  p2=abs(p2)-2.0;
  p2.xy*=rot(T);
  p2.xz*=rot(T/2);
  p2.yz*=rot(T/4);
  mat2 r=rot(0.01+T/(2+15*sin(floor(T*0.3))));
  for (int i=0;i<4+sin(T)*4;i+=1){
    p2.xy*=r;
    p2.xz*=r;
    p2.yz*=r;
    p2=abs(p2)-a2*s;
    s*=0.5;
  }
  float d=box(p2)-0.05;
  float r2=0.01;
  d=min(d,length(p2.xy)-r2);
  d=min(d,length(p2.yz)-r2);
  d=min(d,length(p2.xz)-r2);
  d=max(d,length(p2)-9);
  return d;
}

float df3(vec3 p){
  float d=sin(T)+2.-abs(p.y);
  float s=1.;
  vec3 p2=p;
  mat2 r=rot(0.1);
  p2.z+=T*sin(floor(T))*10;
  for (int i=0;i<12;i+=1){
    p2.xz*=r;
    p2.xy*=r;
    vec3 p3=mod(p2,s+s)-s;
    d=min(d, max(d-0.2*s,box(p3)-s*0.4));
    s*=0.6;
  }
  return d;
}

float df(vec3 p) {
  float d=1e3;
  d=min(d,df2(p));
  d=min(d,df3(p));
  return d;
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  int ix=int(gl_FragCoord.x);
  int iy=int(gl_FragCoord.y);
  vec2 cuv=(gl_FragCoord.xy - v2Resolution.xy*0.5)/v2Resolution.yy;
  
  vec3 pos=vec3(0,0,-8);
  vec3 dir=normalize(vec3(cuv,1));
  float rs=sin(floor(T));
  dir.xz*=rot(T*rs);
  pos.xz*=rot(T*rs);
  pos+=dir*float(((ix/132)^2345^(iy/4+int(T))^342+int(T*55))&255)/40;
  float t=0;
  
  int it=0,maxit=40+int(cos(floor(T))*30);
  
  for(;it<maxit;it+=1){
    float d=df(pos+t*dir);
    if (d<1e-3||d>1e+3) break;
    
    t+=d;
    
  }
  vec3 pos2=pos+t*dir;
  
  float fr=float(it)/float(maxit);
  vec3 col = fr*vec3(1);
  float ph=fr*4+floor(T+(uv*rot(T)).x*0.1)-length(cuv);
  col=ss(-1.,1.,sin(vec3(ph-4,ph+3,ph+6)))*fr*fr*fr*fr;
  col*=1.-length(cuv);
  col+=col.yzx*0.3;
  col*=32.0;
  col+=max(vec3(0),sin(cuv.xyx*5123+dir+pos2*4354.543)*0.1);
  col=1.*col/(1.+col);
  
	out_color = vec4(col, 1);
  
}