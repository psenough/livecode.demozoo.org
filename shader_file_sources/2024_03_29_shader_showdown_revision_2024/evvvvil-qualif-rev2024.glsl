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
float f,t,r,s;vec2 U=gl_FragCoord.xy,R=v2Resolution.xy;
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
ivec2 pr( vec3 p,vec3 ro,mat3 rd)
{
	p-=ro;p*=rd;
  if(p.z<0) return ivec2(-1);
  p.xy/=p.z*.65;
  p.xy+=hash_d()*abs(p.z-5)*.003;
  ivec2 q=ivec2((p.xy+vec2(R.x/R.y,1)*.5)*vec2(R.y/R.x,1)*R);
	return q;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	//uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  f= texture( texFFTSmoothed, 0.29 ).r * 50;
  t=fGlobalTime*.1;
  se+=hi(uint(U.x))+hi(uint(U.y)*125);
  vec3 ro=mix(
  mix(vec3(5+cos(t*8-1)*3,sin(t*8-1)*5,0),vec3(.5,cos(t*8)*.5,sin(t*8)*.5+2),ceil(sin(t*2-.1))),
  vec3(4,cos(t*8)*2,sin(t*8)*2),
  ceil(sin(t*4+sin(uv.x)*.5+f*.3))),
  cw=normalize(vec3(0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw));
  mat3 rd=mat3(cu,cv,cw);
  if(U.x<100){
    vec3 p=vec3(0);//hash3();
    p.z+=U.x*.2;
    p.z+=.5;
    r=max(0.,.4-length(p)*.15)+f*.1;
    s=sin(U.x*.1+f-t*5);
    p.xy+=vec2(sin(uv.y*6.28*s)*r,cos(uv.y*6.28*s)*r);
    for(int i=0;i<8;i++){      
      ivec2 q=pr(p,ro,rd);
      if(q.x>0) ad(q,vec3(.1,.4,1));
      p.yz*=r2(.785);
    }
  }
  else if(U.x>100&&U.x<200){
    vec3 p=hash3()*.01;
    p.z+=(U.x-100)*.2;
    p.z+=.5;
    r=max(0.,.4-length(p)*.15)+texture(texFFTSmoothed,p.z+.05).r*5;
    s=sin((U.x-100)*.1+f-t*5);
    p.xy+=vec2(sin(uv.y*6.28*s)*r,cos(uv.y*6.28*s)*r);
    for(int i=0;i<8;i++){      
      ivec2 q=pr(p,ro,rd);
      if(q.x>0) ad(q,mix(vec3(1,.4,.2),vec3(.1,.4,1),cos(p.x*10)*.5+.5));
      p.yz*=r2(.785);
    }
  }
  else if(U.x>200&&U.x<300){
    vec3 p=hash3()*.005;
    p.z+=(U.x-200)*.2;
    p.z+=.5;
    p.x=max(0.,uv.y*.4-length(p)*.15)+texture(texFFTSmoothed,p.z+.05).r*5;
    s=sin((U.x-200)*.1+f-t*5);
    p.xy*=r2(1.57-s*6.28);
    for(int i=0;i<8;i++){      
      ivec2 q=pr(p,ro,rd);
      if(q.x>0) ad(q,mix(vec3(1),vec3(.1,.4,1),uv.y));
      p.yz*=r2(.785);
    }
  }
  else if(U.x>300&&U.x<400){
    vec3 p=hash3()*.01;
    p.z+=(U.x-300)*.2;
    p.z+=.5;
    p.y=max(0.,U.y*.00034-length(p)*.15);
    p.xy*=r2(p.y*100+f*2-t*10);
    for(int i=0;i<8;i++){      
      ivec2 q=pr(p,ro,rd);
      if(q.x>0) ad(q,mix(vec3(1,.4,.2),vec3(.1,.4,1),cos(uv.y*50)*.5+.5));
      p.yz*=r2(.785);
    }
  }
  else if(U.x>400&&U.x<500){
    vec3 p=hash3()*vec3(0,.9,1);
    p-=vec3(0,.5,.5);
    for(int i=0;i<3;i++){      
      p.x-=.1-f*.1;
      p/=dot(p*.5,p*7);
      p.yz*=r2(sin(p.z*5)*1.4);
      ivec2 q=pr(p*(.7+f*.5),ro,rd);
      if(q.x>0) ad(q,mix(vec3(1,.4,.2),vec3(.1,.4,1),sin(p.x*20)*.5+.5)-U.x*.0005);      
    }
  }
  else if(U.x>500&&U.x<504){
    vec3 p=hash3()*vec3(max(0.,-.5+f*5),.02,.02);
    p-=vec3(0,.01,.01);
    p.x-=.1-f*.1;
    p.z+=.15+f*.05;
    p.y+=.015-f*.06;
    for(int i=0;i<2;i++){      
      ivec2 q=pr(p*(.7+f*.25),ro,rd);
      if(q.x>0) ad(q,vec3(1,.2,.1));      
      p.z-=.3+f*.1;
    }
  }
 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 v=rd*normalize(vec3(uv,.5));
	vec3 c=vec3(.2+f*.2,.25,.5)-length(sin(abs(v.z)-f*.5))*.4;
  c+=pow(re(ivec2(U))*.4,vec3(.45));
  c-=0.4*texture(texNoise,v.yz).r;
  c-=0.1*texture(texTex1,v.yz*2).r;
  c+=0.1*texture(texFFTSmoothed,abs(v.z*.1)-.05).r;
	out_color = vec4(c,1);
}