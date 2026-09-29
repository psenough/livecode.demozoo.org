#version 420 core

#define repeat(i,n) for(int i=0;i<n;i++)

const float FAR=100.;
const float PI=acos(-1.);
const float TAU=PI*2.;

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
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

uvec3 hash3u(uvec3 s){
  s=s*1145141919u+1919810u;
  s.x+=s.y*s.z;
  s.y+=s.z*s.x;
  s.z+=s.x*s.y;
  s=s^s>>16u;
  s.x+=s.y*s.z;
  s.y+=s.z*s.x;
  s.z+=s.x*s.y;
  return s;
}

vec3 hash3(vec3 s){
  uvec3 r=floatBitsToUint(s);
  return vec3(hash3u(r))/float(-1u);
}

uvec3 seed;

uvec3 random3u(){
  seed=hash3u(seed);
  return seed;
}

vec3 random3(){
  return vec3(random3u())/float(-1u);
}

vec2 cis(float t){
  return vec2(cos(t),sin(t));
}

vec4 isectplane(vec3 ro,vec3 rd,vec3 n){
  float t=-dot(ro,n)/dot(rd,n);
  return vec4(n,t>0.?t:FAR);
}

mat3 orthbas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)>.99?vec3(0,0,1):vec3(0,1,0);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

vec3 cyclic(vec3 p,float pump){
  mat3 m=orthbas(vec3(-5,2,-1));
  vec4 sum=vec4(0);
  repeat(i,5){
    p*=m;
    p+=sin(p.yzx);
    sum+=vec4(cross(cos(p),sin(p.zxy)),1);
    p*=2.;
    sum*=pump;
  }
  return sum.xyz/sum.w;
}

vec3 samplelambert(vec3 n){
  vec3 xi=random3();
  float p=TAU*xi.x;
  float ct=sqrt(xi.y);
  float st=sqrt(1.-ct*ct);
  return orthbas(n)*vec3(cis(p)*st,ct);
}

const int SAMPLES=32;

void main(void)
{
  seed=uvec3(gl_FragCoord.xy,60.0*fGlobalTime);

	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;

  vec3 sum=vec3(0);
  
  repeat(iS,SAMPLES){
    vec2 pt=p;
    pt+=2.*(random3().xy-.5)/v2Resolution.y;
    vec3 ro=vec3(0,0,5);
    vec3 rd=normalize(vec3(pt,-2));
    
    vec3 col=vec3(0);
    vec3 colr=vec3(1);
    
    repeat(iP,5){
      vec3 bc=vec3(0);
      vec3 em=vec3(0);
      
      vec4 isect=vec4(FAR);
      vec4 isect2;

      repeat(iL,10){
        float prog=float(iL)/9.;
        float z=mix(-1.,0.,prog);
        isect2=isectplane(ro-vec3(0,0,z),rd,vec3(0,0,1));
        vec3 rp=ro+rd*isect2.w;
        vec2 co=rp.xy;
        co+=mix(.0,1.,prog)*cyclic(.04*(rp+vec3(10,10,fGlobalTime)),1.).xy;
        float d=length(co)-mix(1.,2.,prog);
        if(isect2.w<isect.w&&d>0.){
          isect=isect2;
          bc=mix(
            pow(.5+.5*sin(1.+2.*prog+vec3(0,2,4)),vec3(2.)),
            vec3(.02),
            prog
          );
          em=vec3(0);
        }
      }
    
      isect2=isectplane(ro-vec3(0,0,50),rd,normalize(vec3(0,-1,-1)));
      if(isect2.w<isect.w){
        isect=isect2;
        vec3 rp=ro+rd*isect2.w;
        bc=vec3(0);
        em=vec3(2);
      }
      
      if(isect.w>=FAR){
        //col+=.1*colr;
        break;
      }
      
      col+=colr*em;
      ro=ro+rd*isect.w;
      ro+=0.01*isect.w;
      rd=samplelambert(isect.xyz);//reflect(rd,isect.xyz);
      colr*=bc;
      
      if(dot(colr,vec3(1.))<.01){
        break;
      }
    }
    
    sum+=col;
  }
  
  vec3 col=sum/float(SAMPLES);
  col=pow(col,vec3(.4545));
  col*=1.-.5*length(p);
  col=smoothstep(vec3(0,-.04,-.08),vec3(1,1.01,1.04),col);
  
  out_color=vec4(col,1);
}