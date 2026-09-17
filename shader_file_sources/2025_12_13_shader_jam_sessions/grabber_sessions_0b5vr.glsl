#version 420 core

const float BPM=148.;
const float FAR=30.;
const int SAMPLES=16;

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time;
float beat;
uvec3 hash3u(uvec3 s){
  s=s*1145141919u+1919810u;
  s.x+=s.y*s.z;
  s.y+=s.z*s.x;
  s.z+=s.x*s.y;
  s^=s>>16;
  s.x+=s.y*s.z;
  s.y+=s.z*s.x;
  s.z+=s.x*s.y;
  return s;
}

vec3 hash3f(vec3 r){
  uvec3 s=floatBitsToUint(r);
  return vec3(hash3u(s))/float(-1u);
}

uvec3 seed;
vec3 random3(){
  seed=hash3u(seed);
  return vec3(seed)/float(-1u);
}

vec2 cis(float t){
  return vec2(cos(t),sin(t));
}

mat2 r2d(float t){
  float c=cos(t);
  float s=sin(t);
  return mat2(c,s,-s,c);
}

float easein(float x,float k){
  float y=fract(x);
  y=(k+1.)*pow(y,k)-k*pow(y,k+1.);
  return y+floor(x);
}

float easeout(float x,float k){
  return 1.-easein(1.-x,k);
}

vec3 easerand(float x,float k){
  float y=floor(x);
  return mix(
    hash3f(vec3(y-1.)),
    hash3f(vec3(y)),
    easeout(fract(x),k)
  );
}

vec4 isectplane(vec3 ro,vec3 rd,vec3 n){
  n=dot(rd,n)<.0?n:-n;
  float t=-dot(ro,n)/dot(rd,n);
  if(t<0.){return vec4(FAR);}
  return vec4(n,t);
}

mat3 orthbas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)>.99?vec3(0,0,1):vec3(0,1,0);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

vec3 sampleggx(vec3 n,float a){
  vec3 xi=random3();
  float phi16=16.*TAU*xi.x;
  float cost=sqrt( (1.-xi.y) / (1.-xi.y*(1.-a*a)) );
  float sint=sqrt(1.-cost*cost);
  
  return orthbas(n)*vec3(
    sint*cis(phi16),
    cost
  );
}

float pattern(vec2 p,float t){
  for(int i=0;i<5;i++){
    p=abs(p);
    p=p.x<p.y?p.xy:p.yx;
    if(p.y<.5){p*=r2d(PI/4.);}
    // .5*easeout(beat/2.,5.)
    p-=.5+.5*easerand(t*BPM/60.,5.).xy;
  }
  
  float r=2.*p.x-fract(.4*t);
  return abs(2.*fract(r)-1.);
}

void main(void)
{
  seed=floatBitsToUint(vec3(gl_FragCoord.xy,fGlobalTime));
  time=fGlobalTime+.0*random3().x;
  beat=time*BPM/60.;
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  
  float v=pattern(p,.5*easeout(beat/2.,5.));
  vec3 col=vec3(0);
  
  for(int i=0;i<SAMPLES;i++){
    vec3 ro=vec3(0,0,4);
    ro.x+=.1*sin(time);
    ro.y+=.1*sin(.8*time);
    vec3 rd=normalize(vec3(p*r2d(.01*sin(.4*time)),-2.));
    rd.yz*=r2d(.03*sin(.7*time));
    rd.zx*=r2d(.3*sin(.5*time));
    
    vec3 colrem=vec3(1);
    
    for(int i=0;i<4;i++){
      vec4 isect=vec4(FAR);
      vec4 isect2;
      vec3 bcol;
      vec3 ecol;
      
      isect2=isectplane(ro-vec3(0,0,-1.),rd,vec3(0,0,1));
      if(isect2.w<isect.w){
        isect=isect2;
        vec3 rp=ro+rd*isect.w;
        bcol=vec3(.8);
        ecol=vec3(0);
      }
      
      for(int i=0;i<5;i++){
        float prog=float(i)/4.;
        isect2=isectplane(ro-vec3(0,0,-.4*prog),rd,vec3(0,0,1));
        if(isect2.w<isect.w){
          vec3 rp=ro+rd*isect2.w;
          float v=pattern(.3*rp.xy,time);
          if(v<mix(.1,.8,prog)){
            isect=isect2;
            ecol=exp2(mix(.5,-1.,prog))*(.5+.5*cos(vec3(0,1,2)+5.-.8*prog));
            bcol=vec3(0);
          }
        }
      }
      
      isect2=isectplane(ro-vec3(0,-1,0),rd,vec3(0,1,0));
      if(isect2.w<isect.w){
        isect=isect2;
        bcol=vec3(1);
        ecol=vec3(0);
      }
      
      // miss?
      if(isect.w>=FAR){
        col+=.0*colrem;
        break;
      }
      
      col+=colrem*ecol;
      
      vec3 n=isect.xyz;
      ro+=rd*isect.w;
      ro+=n*.001;
      
      float dotvn=max(0.,dot(-rd,n));
      float fn=mix(.2,1.,pow(1.-dotvn,5.));
      
      if(fn>random3().x){
        vec3 h=sampleggx(n,.02);
        float dotvh=max(0.,dot(-rd,h));
        float fh=mix(.2,1.,pow(1.-dotvh,5.));
        colrem*=fh/fn*dotvh*bcol;
        rd=reflect(rd,h);
      }else{
        colrem*=bcol;
        rd=sampleggx(n,1.);
      }
    }
  }
  
  col/=float(SAMPLES);
  col=pow(col,vec3(.4545));
  col=smoothstep(vec3(0,-.1,-.2),vec3(1,1.1,1.2),col);
  if(uv.y<.01){
    col+=.5*easerand(time,5.);
  }
  
	out_color = mix(
    texture(texPreviousFrame,uv),
    vec4(col,1),
    .5
  );
}