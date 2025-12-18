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
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color;

float fm = clamp(texture( texFFTSmoothed , .3 ).x * 32. + 0.1,0,1);
float t=fGlobalTime,tf=t+fm,fpulse=.5;//sin(t*4);
float lpulse=smoothstep(.0,.4,mod(t,4.0));
float rand(float n) {return fract(sin(n)*45678.89);}
float rand3(vec3 p) {return fract(sin(p.x)*p.y*45678.89+p.z);}
vec3 dmin(vec3 d,float x,float y,float z) {return x<d.x ? vec3(x,y,z) : d;}
mat2 R(float a) {return mat2(-cos(a),sin(a),sin(a),cos(a));}

//t=t*fm;

float a(vec3 p)
{
  float k=1,s=1;
  for (int i=0;i<3;i++) {
      p=mod(k*p-.95,2)-1;
      k=1.5/dot(p,p);
      s=s*k;
  }
  return dot(p,sign(p))/s-.02;
}

float f(vec3 p) {
 for (int i=0;i<3;i++) p=reflect(abs(p)-fpulse/8, vec3(.75,.5,.1));
 return (dot(p,sign(p))-.1);     
}  

vec3 S(vec3 p)

{
  vec3 d=vec3(4,.5,-1);

  
  vec3 psh=vec3(p.x,p.y,mod(p.z,8)-4);

  psh.x=abs(psh.x);
  psh.xy*=R(tf);
  d=dmin(d,f(psh),.7,sin(psh.y*24-tf));

  p.z+=t*2.+tf*8.;  
  float od=a((p/4)+1);
  d=dmin(d,od,.2,-.5);

  p=mod(p,4)-2;
  d=dmin(d,length(abs(p.xy)+vec2(sin(p.z*2+t)/2,sin(p.z*3.-t)/4))-.01,1.,.25);
    
  
  return d;
  
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvOriginal = vec2(uv.x,1-uv.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float vig=rand3(vec3(uv*1337.,t))/2+2.-length(uv)/4;
  
  vec3 ro=vec3(0,0,-1),rd=normalize(vec3(uv,vig));

  rd.xz*=R(t/4);
  rd.xy*=R(sin(t/6)/2);
  float td=0.,ref=1.;
  vec3 p=ro,d,n;
  vec3 cc=vec3(0.);  
  for (int i=0;i<199;i++) {
      d=S(p);
      if (d.x<.001) {
         n=normalize(vec3(d.x-S(vec3(p.x-.01,p.yz)).x, d.x-S(vec3(p.x,p.y-.01,p.z)).x, d.x-S(vec3(p.xy,p.z-.01)).x));
          rd=reflect(rd,normalize(n+rand3(p)/64));
          p-=n/2;
        
         cc+=vec3(2.+d.z,1.,2.-d.z)*ref*d.y/4;
         ref*=.9;
      }
      p+=rd*d.x/4;
      td+=d.x/8;
  }  
//  vec4 cc=vec4(vec3(n/td),1);
  vec4 cLogo=texture(texInercia2025,uvOriginal);
  vig*=sin(uv.x*32)*.5+1.;
	out_color = vec4(cc+cLogo.xyz*.8,1);
}