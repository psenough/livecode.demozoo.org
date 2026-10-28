#version 410 core

#define fs(i) (fract(sin((i)*114.514)*1919.810))
#define lofi(i,j) (floor((i)/(j))*(j))

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame;
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI=acos(-1);
const float TAU=PI*2.;

float time;
float seed;

float random(){
  seed=fs(seed);
  return seed;
}

mat3 orthBas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)>.99?vec3(0,0,1):vec3(0,1,0);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

mat2 r2d(float t){
  return mat2(cos(t),sin(t),-sin(t),cos(t));
}

vec3 sampleLambert(vec3 n){
  float phi16=TAU*random();
  float ct=sqrt(random());
  float st=sqrt(1.0-ct*ct);
  return orthBas(n)*vec3(
    cos(phi16)*st,
    sin(phi16)*st,
    ct
  );
}

vec4 ibox(vec3 ro,vec3 rd,vec3 s){
  vec3 src=ro/rd;
  vec3 dst=abs(s/rd);
  vec3 fv=-src-dst;
  vec3 bv=-src+dst;
  float f=max(max(fv.x,fv.y),fv.z);
  float b=min(min(bv.x,bv.y),bv.z);
  if(f<0.||b<f){return vec4(1E2);}
  vec3 n=-sign(rd)*step(fv.zxy,fv)*step(fv.yzx,fv);
  return vec4(n,f);
}

struct QTR{
  vec3 cell;
  vec3 size;
  float len;
  bool hole;
};

QTR qt(vec3 ro,vec3 rd){
  QTR r;
  r.size=vec3(1,1E3,1);
  for(int i=0;i<4;i++){
    r.size/=2.;
    r.cell=lofi(ro+rd*1E-2*r.size,r.size)+r.size/2.;
    float d1=fs(dot(vec3(.2,1.4,-2.),r.cell));
    r.hole=(
      r.cell.y>0.
      || d1>.8
    );
    if(r.hole){break;}
    float d2=fs(dot(vec3(4,5,6),r.cell));
    if(d2>.5){break;}
  }
  
  
  vec3 src=(ro-r.cell)/rd;
  vec3 dst=abs(r.size/2./rd);
  vec3 bv=-src+dst;
  float b=min(min(bv.x,bv.y),bv.z);
  r.len=b;
  
  return r;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  
  time=fGlobalTime;
  seed=texture(texNoise,uv*8.).x;
  seed+=fract(time);
  
  vec3 col=vec3(0);
  vec3 colRem=vec3(1);
  
  p.xy*=r2d(.4);
  
  vec3 co=vec3(0,1,2);
  co.zx*=r2d(.2*time);
  vec3 ct=vec3(.2,-1,0);
  vec3 cz=normalize(co-ct);
  
  vec3 ro=co;
  vec3 ro0=ro;
  vec3 rd=orthBas(cz)*normalize(vec3(p,-2));
  vec3 rd0=rd;
  
  bool shouldInit=true;
  float samples=0.;
  
  for(int i=0;i<99;i++){
    if(shouldInit){
      shouldInit=false;
      ro=ro0;
      rd=rd0;
      colRem=vec3(1);
      samples++;
    }
    
    QTR qtr=qt(ro,rd);
    
    vec4 isect=vec4(1E2);
    vec3 off=vec3(0);
    if(!qtr.hole){
      off.y-=1.;
      float d1=fs(dot(qtr.cell,vec3(.2,.8,.6)));
      off.y-=sin(d1*6.+time);
      vec3 size=vec3(qtr.size/2.-.02);
      isect=ibox(ro-qtr.cell-off,rd,size);
    }
    
    if(isect.w<1E2){
      ro+=rd*qtr.len;

      if((ro-off).y>-1.*qtr.size.x){
        col+=colRem*5.;
        colRem*=0.;
      }

      vec3 N=isect.xyz;
      colRem*=.3;
     
      rd=mix(
        sampleLambert(N),
        reflect(rd,N),
        .5
      );
    }else{
      ro+=rd*qtr.len;
    }
    
    if(colRem.x<.01){
      shouldInit=true;
    }
  }
  
  col/=samples;
  col*=1.0-length(p)*.3;
  col=vec3(
    smoothstep(.1,.9,col.x),
    smoothstep(.0,1.,col.y),
    smoothstep(-.1,1.1,col.z)
  );

  out_color = vec4(col,1);
}
