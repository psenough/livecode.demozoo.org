#version 410 core

/****
Radio bonzo

Credit: 
 grabber_inerciaroyale_0b5vr.glsl 
****/

#define lofi(i,j) (floor((i)/(j))*(j))
#define lofir(i,j) (round((i)/(j))*(j))

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 r2d(float t){
  float c=cos(t),s=sin(t);
  return mat2(c,s,-s,c);
}

mat3 orthbas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)>.999?vec3(0,0,1):vec3(0,1,0);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

uvec3 pcg3d(uvec3 s){
  s=s*1145141919u+1919810u;
  s+=s.yzx*s.zxy;
  s^=s>>16;
  s+=s.yzx*s.zxy;
  return s;
}

vec3 pcg3df(vec3 s){
  uvec3 r=pcg3d(floatBitsToUint(s));
  return vec3(r)/float(0xffffffffu);
}

float sdbox(vec3 p,vec3 s){
  vec3 d=abs(p)-s;
  return length(max(d,0.))+min(0.,max(max(d.x,d.y),d.z));
}

float sdbox(vec2 p,vec2 s){
  vec2 d=abs(p)-s;
  return length(max(d,0.))+min(0.,(max(d.x,d.y)));
}

struct Grid{
  vec3 c;
  vec3 h;
  vec3 s;
  int i;
  float d;
};

Grid dogrid(vec3 ro,vec3 rd){
  Grid r;
  r.s=vec3(2,2,100);

  for(int i=0;i<3;i++){
    r.c=(floor(ro/r.s)+.5)*r.s;
    r.h=pcg3df(r.c);
    r.i=i;
    
    if(r.h.x<.4){
      break;
    }else if(i==0){
      r.s=vec3(2,1,100);
    }else if(i==1){
      r.s=vec3(1,1,100);
    }
  }
  
  vec3 src=-(ro-r.c)/rd;
  vec3 dst=abs(.501*r.s/rd);
  vec3 bv=src+dst;
  float b=min(min(bv.x,bv.y),bv.z);
  r.d=b;
  
  return r;
}

vec4 map(vec3 p,Grid grid){
  p-=grid.c;
  
  vec3 pt=p;
  float rot=floor(fGlobalTime);
  rot-=exp(-5.0*fract(fGlobalTime));
  float pcol=1.;
  //pt.yz*=r2d(3.*rot);
  
  vec3 psize=grid.s/2.;
  psize.z=1.;
  psize-=.02;
  float d=sdbox(pt+vec3(0,0,1),psize);
  
  if(grid.i==0){
    if(false){
    }else if(grid.h.y<1.){//speaker
      vec2 c=vec2(0);
      pt.xy*=r2d(PI/4.);
      c.xy=lofir(pt.xy,.1);
      pt.xy-=c.xy;
      float r=.02*smoothstep(.9,.7,abs(p.x))*smoothstep(.9,.7,abs(p.y));
      float hole=length(pt.xy)-r;
      d=max(d,-hole);
    }
  }else if(grid.i==1){
    if(false){
    }else if(grid.h.y<1.){//fader
      float hole=sdbox(p.xy,vec2(.9,.05));
      d=max(d,-hole);

      float ani=smoothstep(-.2,.2,sin(fGlobalTime+grid.h.z*100.));
      pt.x+=mix(-.8,.8,ani);
      
      float d2=sdbox(pt,vec3(.07,.25,.4))+pt.z*.05;
      
      if(d2<d){
        float l=smoothstep(.01,.0,abs(pt.y)-.02);
        return vec4(d2,0,l,0);
      }
    }
  }else{
    if(false){
    }else if(grid.h.y<1.){//knob
      float hole=length(p.xy)-.25;
      d=max(d,-hole);
      
      float ani=smoothstep(-.2,.2,sin(fGlobalTime+grid.h.z*100.));
      pt.xy*=r2d(PI/6.*5.*mix(-1.,1.,ani));

      float d2=length(pt.xy)-.23+.05*pt.z;
      d2=max(d2,abs(pt.z)-.4);
      
      if(d2<d){
        float l=smoothstep(.01,.0,abs(pt.x)-.015);
        l*=smoothstep(.0,.01,pt.y-.02);
        return vec4(d2,0,l,0);
      }
      
      pt=p;
      float a=clamp(lofir(atan(-pt.x,pt.y),PI/6.),-PI/6.*5.,PI/6.*5.);
      pt.xy*=r2d(a);
      pcol*=smoothstep(.0,.01,sdbox(pt.xy-vec2(0,.34),vec2(.0,.02))-.005);

      pt=p;
      a=clamp(lofir(atan(-pt.x,pt.y),PI/6.*5.),-PI/6.*5.,PI/6.*5.);
      pt.xy*=r2d(a);
      pcol*=smoothstep(.0,.01,sdbox(pt.xy-vec2(0,.34),vec2(.01,.03))-.005);
    }
  }
  
  return vec4(d,0,pcol,0);
}

vec3 nmap(vec3 p,Grid grid,float dd){
  vec2 d=vec2(0,dd);
  return normalize(vec3(
    map(p+d.yxx,grid).x-map(p-d.yxx,grid).x,
    map(p+d.xyx,grid).x-map(p-d.xyx,grid).x,
    map(p+d.xxy,grid).x-map(p-d.xxy,grid).x
  ));
}

struct March{
  vec4 isect;
  vec3 rp;
  float rl;
  Grid grid;
};

March domarch(vec3 ro,vec3 rd,int iter){
  float rl=1E-2;
  vec3 rp=ro+rd*rl;
  vec4 isect;
  Grid grid;
  float gridlen=rl;
  
  for(int i=0;i<iter;i++){
    if(gridlen<=rl){
      grid=dogrid(rp,rd);
      gridlen+=grid.d;
    }
    
    isect=map(rp,grid);
    rl=min(rl+.8*isect.x,gridlen);
    rp=ro+rd*rl;
    
    if(isect.x<1E-4){break;}
    if(rl>50.){break;}
  }

  March r;
  
  r.isect=isect;
  r.rp=rp;
  r.rl=rl;
  r.grid=grid;
  
  return r;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;

  vec3 col=vec3(0);
  
  float canim=smoothstep(-.2,.2,sin(fGlobalTime));
  float cr=mix(.33,0.,canim);
  vec3 co=mix(vec3(-6,-8,-40),vec3(0,0,-40),canim);
  co.xy+=fGlobalTime;
  vec3 ct=vec3(0,0,-50);
  ct.xy+=fGlobalTime;
  mat3 cb=orthbas(co-ct);
  vec3 ro=co+cb*vec3(4.*p*r2d(cr),0);
  vec3 rd=cb*normalize(vec3(0,0,-2.));
  
  March march=domarch(ro,rd,200);
  
  if(march.isect.x<1E-2){
    vec3 basecol=vec3(.5);
    vec3 speccol=vec3(.5);
    float specpow=30.;
    
    float mtl=march.isect.y;
    float mtlp=march.isect.z;
    if(mtl==0.){
      basecol=mix(vec3(.04),vec3(.9),mtlp);
    }
    
    float ndelta=1E-3;
    vec3 n=nmap(march.rp,march.grid,ndelta);
    vec3 v=-rd;
    
    {
      vec3 l=normalize(vec3(1,2,5));
      vec3 h=normalize(l+v);
      float dotnl=max(0.,dot(l,n));
      float dotnh=max(0.,dot(n,h));
      vec3 diff=basecol/PI;
      vec3 spec=speccol*pow(dotnh,specpow);
      col+=vec3(.5,.6,.7)*dotnl*(diff+spec);
      //col=vec3(.5+.5*n);
    }
    
    {
      vec3 l=normalize(vec3(-1,-2,5));
      vec3 h=normalize(l+v);
      float dotnl=max(0.,dot(l,n));
      float dotnh=max(0.,dot(n,h));
      vec3 diff=basecol/PI;
      vec3 spec=speccol*pow(dotnh,specpow);
      col+=dotnl*(diff+spec);
      //col=vec3(.5+.5*n);
    }
  }
  
  col=pow(col,vec3(.4545));
  col=smoothstep(vec3(.0,-.1,-.2),vec3(1.,1.1,1.2),col);
  
	out_color = vec4(col,1);
}