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


float t=fGlobalTime;
float ts=texture(texFFTSmoothed,.1).x;
float ti=texture(texFFTIntegrated,.1).x;
float s=clamp(sin(t/8)/2+.5,0,1);
float tm=mod(t/8,2);
float hop=smoothstep(0.8,1.0,tm) * smoothstep(2.0,1.8,tm) * 22;

vec3 dmin(vec3 d,float x,float y,float z) {return x<d.x ? vec3(x,y,z) : d;}
mat2 R(float a) {return mat2(-cos(a),sin(a),sin(a),cos(a));}

float apo(vec3 p) {
  
  float k=.5,s=1;
  for (int i=0;i<4;i++) {
    p=mod(k*p-.9,2)-1.2;
    k=1.25/dot(p,p);
    s=s*k;
  }
  return dot(p,sign(p))/s-.1;
    
  
}

float sw(vec3 p) 
{
  p.x+=sin(p.z+t*2);
  p.y+=cos(p.z*1.3+t*2);
  float a=mod(atan(p.x,p.y),6.28/5);
  float l=length(p.xy)*4;
  return length(vec2(sin(a)*l,cos(a)*l-ts*64))-.25;
}


vec3 S(vec3 p)

{
  vec3 d=vec3(2,1,-.5);
 
  p.xz*=R(t/5);
  
  p.z=mod(p.z+t*24+ti,64)-32;
  d=dmin(d,apo(p/4-1),0,0);
  d=dmin(d,4+p.y+d.x,.5,.1);
  d=dmin(d,length((mod(p.xz,16)-8)*d.x/2)-.5, .3, .1);
  d=dmin(d,sw(p+1)+s*sin(p.x*16)/4,1,s*2-1);
  d.x+=max(0,(p.y-8)/4);

  d=dmin(d,length(p-vec3(8,24,0))-2,2,1+s*2);
  
  return d;
}
  
// 

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

 vec3 p=vec3(0,sin(t/4)-1+hop,-1),r=normalize(vec3(uv,.7));
  vec3 d,n,ll=vec3(0),tc=ll;
  float z=0;
  float vig=1-length(uv)/2;
  r.xy*=R(sin(t/6+ti/4)*.2);
  for (int i=0;i<64;i++) {
       d=S(p);
       if (abs(d.x)<.001) {
         vec3 n=normalize(vec3(d.x-S(vec3(p.x-.01,p.yz)).x , d.x-S(vec3(p.x,p.y-.01,p.z)).x , d.x-S(vec3(p.xy,p.z=.01)).x)); 
         tc=texture(texAcorn1,n.xy/2.2-1).xyz;
         }
       ll+=vec3(1+d.z,1,1-d.z)*d.y;
       p+=r*d.x/3;
       z+=d.x/3;
       
     }
      
  ll=mix(vec3(ll*.5/z), tc.xyz*4, .9);
  ll.x+=s*-uv.y;
  ll*=(texture(texNoise,r.xy-t/4).x+1);
  
	out_color = vec4(ll*vig,1);
}