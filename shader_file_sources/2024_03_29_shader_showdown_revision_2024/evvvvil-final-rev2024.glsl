#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float f,b,c,d,r,t,wa,af;vec2 U=gl_FragCoord.xy,R=v2Resolution.xy;
uint se=0;
uint hi(uint x){
  x^=x>>16;x*=0x1234567bU;x^=x>>15;x*=0x8468461dU;x^=x>>16;return x;  
}
float hash(){return float(se=hi(se))/float(0xffffffffU);}
vec2 hash2(){return vec2(hash(),hash());}
vec2 hash_d(){vec2 r=hash2();return vec2(cos(r.x*6.28),sin(r.x*6.28))*sqrt(r.y);}
mat2 r2(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}
vec3 hash3(){return vec3(hash(),hash(),hash());}
void ad(ivec2 u,vec3 c){
  ivec3 q=ivec3(c*1000);
  imageAtomicAdd(computeTex[0],u,q.x);
  imageAtomicAdd(computeTex[1],u,q.y);
  imageAtomicAdd(computeTex[2],u,q.z);
}
vec3 re(ivec2 u){
  return .001*vec3(
  imageLoad(computeTexBack[0],u).x,
  imageLoad(computeTexBack[1],u).x,
  imageLoad(computeTexBack[2],u).x);
}
  
ivec2 pr( vec3 p,vec3 ro,mat3 rd,float s)
{
	p-=ro;p*=rd;
  p.xy*=r2(sin(p.z*.2)*.5*s*(1-b));
  if(p.z<0) return ivec2(-10);
  p.xy/=p.z*.5;
  p.xy+=hash_d()*abs(p.z-70)*.0001;
  ivec2 q=ivec2((p.xy+vec2(R.x/R.y,1)*.5)*vec2(R.y/R.x,1)*R);
	return q;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	//uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  //f= texture( texFFT, d ).r * 100;
  t=mod(fGlobalTime*.1,4.1);
  se+=hi(uint(U.x))+hi(uint(U.y)*125);
 b=smoothstep(0.,1.,clamp(cos(max(0.,t-.5)*3),-.5,.5)+.5);
  c=1-smoothstep(0.,1.,min(t*2.,1.))+clamp((t-3.55),0.,1.);
  d=1.-c;
  vec3 ro=mix(
  vec3(0,0,-90-70*cos(t*6)),
  vec3(-70+cos(t*12)*15,2,50-cos(t*12)*15),b),
  cw=normalize(vec3(0,0,-20+b*40)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw));
  wa=sin(uv.x*50+t*25)*.5+.5;
  mat3 rd=mat3(cu,cv,cw);
  if(U.x<400){
    vec3 p=hash3()*sin(uv.x*40*(1+b*3))*sin(uv.y*40);
    p.z+=U.x*.1;
    r=2.7+wa*b+p.y*.5;
    p.xy+=vec2(cos(uv.y*6.28)*r,sin(uv.y*6.28)*r);
    p.yz*=r2(p.z*.5*c);
    for(int i=0;i<4;i++){      
      p.xy*=mix(1.5,.6,b);
      if(i==1) p.xy+=vec2(cos(uv.y*6.28)*r,sin(uv.y*6.28)*r);
      vec3 ap=vec3(0,0,10)-p;
      af=length(ap)/(10+wa+cos(p.z+1)+100*c);
      af=pow(clamp(1-af,0.,1.),2.72);
      if(i>0)p-=af*ap*3;      
      ivec2 q=pr(p,ro,rd,1);
      if(q.x>0) ad(q,d*mix(vec3(.7,.2,.1),vec3(.2,.5,.7),cos(p.z*.2+1)*.5+.5));
    }
  }
  else if(U.x>400&&U.x<500){
    vec3 p=hash3()*0.2;
    p.z+=15+(U.x-400)*.3;
    r=0.5;
    p.xy+=vec2(cos(uv.y*6.28)*r,sin(uv.y*6.28)*r);
    p.yz*=r2(p.z*.5*c);
    p.x+=3+wa*(p.z-14)*.5+(p.z-14)*.5;
    for(int i=0;i<12;i++){      
      p.xy*=r2(.523);      
      ivec2 q=pr(p,ro,rd,1);
      if(q.x>0) ad(q,d*(sin(p.z*5)*.5+.5)*mix(vec3(.7,.2,.1),vec3(.2,.5,.7),cos(p.z*.2)*.5+.5));
    }
  }
  else if(U.x>500&&U.x<600){
    vec3 p=hash3()*0.2;
    p.y-=U.y*.01*(1-c*40)-7+b*20;
    p.xy-=1-b*20;
    p.z+=(U.x-500)*(.3+b)-sin(t*3-2)*b*40-b*40;
    p.xy*=r2(-.256+b*6.5);
    for(int i=0;i<5;i++){      
      p.xy*=r2(1.256);      
      ivec2 q=pr(p,ro,rd,0.2);
      if(q.x>0) ad(q,d*vec3(.1+b*.5));
    }
  }
  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1); 
  vec3 v=rd*normalize(vec3(uv,.5));
	vec3 co=vec3(.2,.35,.5)-length(uv)*.5+sin(v.z*20-t*60)*.05*d;
  co+=pow(re(ivec2(U))*.1,vec3(.45));
  co-=texture(texNoise,v.yz).r*.2;
	out_color = vec4(co,1);
}