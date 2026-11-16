#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything



float t=fGlobalTime,pulse=sin(t*4)/2;

vec3 dmin(vec3 d,float x,float y,float z) {return x<d.x ? vec3(x,y,z) : d; }

mat2 R(float a) {return mat2(-cos(a),sin(a),sin(a),cos(a));}


float apo(vec3 p)

{
  float k=.5,s=1;
  for (int i=0;i<4;i++) {
      p=mod(k*p-.8,2)-1.25;
      k=1.5/dot(p,p);
      s*=k;
  }
  return dot(p,sign(p))/s-.01;
    
}

float sea(vec3 p)
{
  float d=1,s=1;
  for (int i=0;i<4;i++) {
      d+=texture(texNoise,(p.xz+t)/2).x*s;
      p.xz*=mat2(.8,.7,-.8,.5);
  }
  s/=2;  
 // }
  return d;
}

float sq(vec3 p)

{
 
  p.xz*=(sin(p.y*8+t*4)*.1+1);
  float d=0;
  for (int i =0;i<4;i++) {
      d+=max(0,length(p.xz));
      p.y+=length(p)/2;
//      p=.2-(abs(p*3)).2;
    
  }
  return d;
}


vec3 S(vec3 p)

{
  vec3 d=vec3(1,1,-.8);
  p.xz*=R(t/5);
  p.z=mod(p.z+t*12,32)-16;
  d=dmin(d,apo(p/4-1),.3,1);
  d=dmin(d,-p.y+2+texture(texNoise,(p.xz+t)/2).x*.5,1,-.5);
  p.y-=t*4;
  vec3 psub=vec3(mod(p.x*3+t,16)-8,p.yz-1.5);
  d=dmin(d,length(p)-1,0,0);
  p=mod(p,8)-2;
  d=dmin(d,sq(p*2),1,.5);
   d=dmin(d,length(p)-1,1,1);
  
  
  return d;
  
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 p=vec3(-1,-1,0),r=normalize(vec3(uv,1));
  vec3 d,n,ll=vec3(0);
  r.xy*=R(sin(t/4)*.2);
  float z=0,vig=1.0-length(uv)/2;
  float la=1;
  for (int i=0;i<99;i++) {
       d=S(p);
      r.x+=texture(texNoise,p.xy*r.z).x*z/299;
      r.y+=texture(texNoise,r.yz*r.z).x*z/299;
      if (d.x<.01) {
          
       // break;
      }
      ll+=vec3(d.z+1,.8,1-d.z)*d.y*la;
      p+=r*d.x/4;
      z+=d.x/3;
      
    }
   
 ll*=vec3(.2/z);
	out_color = vec4(ll*vig,1);
}