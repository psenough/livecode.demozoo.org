#version 410 core

#define repeat(i,n) for(int i=0;i<(n);i++)
#define saturate(x) clamp(x,0.,1.)
#define linearstep(a,b,t) saturate( ( (t)-(a) ) / ( (b)-(a) ) )

const float PI=acos(-1.0);
const float TAU=PI*2.;

float time;

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

vec3 hash3f(vec3 f){
  return vec3(hash3u(floatBitsToUint(f)))/float(-1u);
}

uvec3 seed;
vec3 random3(){
  seed=hash3u(seed);
  return vec3(seed)/float(-1u);
}

vec3 calcgrad(float t){
  return 3.*(.5-.5*cos(TAU*saturate(1.5*t-vec3(0,.25,.5))));
}

mat2 r2d(float t){
  float c=cos(t);
  float s=sin(t);
  return mat2(c,s,-s,c);
}

float ease(float t,float k){
  float k1=k+1.;
  t=1.-t;
  float v=k1*pow(t,k)-k*pow(t,k1);
  return 1.-v;
}

mat3 orthbas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)<.99?vec3(0,1,0):vec3(0,0,1);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

vec3 cyclic(vec3 p,vec3 warpoff,float pers){
  mat3 b=orthbas(vec3(-3,2,-1));
  vec4 sum=vec4(0);
  repeat(i,5){
    p*=b;
    p+=sin(p.yzx+warpoff);
    sum+=vec4(
      cross(sin(p.zxy),cos(p)),
      1
    );
    sum/=pers;
    p*=2.;
  }
  return sum.xyz/sum.w;
}

float calcdens(vec3 p,float t){
  float tt=t;
  tt=mix(
    tt,
    ease(fract(t),4.)+floor(t),
    .8
  );
  
  vec3 p1=p;
  p1.y-=20.;
  p1.yz*=r2d(-.5*tt);
  p1.yz*=r2d(log(length(p1.yz)));
  
  vec3 p2=p;
  p2.y+=15.;
  p2.z+=5.;
  p2.xy*=r2d(0.6);
  p2.yz*=r2d(-.7*tt);
  p2.yz*=r2d(2.*log(length(p2.yz)));
  
  p=mix(p1,p2,step(4.,mod(time,8.)));
  
  vec3 warpoff=vec3(2);
  warpoff.xy*=r2d(.4*tt);
  warpoff.yz*=r2d(.5*tt);
  
  float d=cyclic(p,warpoff,.5).x;
  d=mix(d,sin(20.*d),.1);
  d=pow(saturate(.5+.5*d),6.);
  return .5*d;
}

float sdtorus(vec3 p,float R,float r){
  vec2 pt=vec2(length(p.xy)-R,p.z);
  return length(pt)-r;
}

float map(vec3 p){
  float d=1E9;
  vec3 pt=p;
  
  p=mix(p,p.yzx,step(4.,mod(time,8.)));
  
  pt=p;
  pt.y-=2.;
  pt.yz*=r2d(-.6+.1*cos(time));
  pt.zx*=r2d(-.6+.1*sin(time)-1.9);
  d=min(d,sdtorus(pt,1.6,.1));
  
  pt=p;
  pt-=vec3(-.1,.2,0);
  pt.yz*=r2d(-.6+.1*cos(time));
  pt.zx*=r2d(-.6+.1*sin(time));
  d=min(d,sdtorus(pt,1.6,.1));
  
  pt=p;
  pt.y+=2.;
  pt.yz*=r2d(-.6+.1*cos(time));
  pt.zx*=r2d(-.6+.1*sin(time)+1.5);
  d=min(d,sdtorus(pt,1.6,.1));
  
  return d;
}

vec3 nmap(vec3 p){
  vec2 d=vec2(0,1E-4);
  return normalize(vec3(
    map(p+d.yxx)-map(p-d.yxx),
    map(p+d.xyx)-map(p-d.xyx),
    map(p+d.xxy)-map(p-d.xxy)
  ));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  float deltap=2./v2Resolution.y;
  
  time=fGlobalTime;
  seed=floatBitsToUint(vec3(p,time));
  p+=deltap*(random3().xy-.5);

  vec2 p0=p;
  float glt=mod(time,4.);
  float glf=1.;
  repeat(i,6){
    float fi=float(i);
    vec2 cell=floor(p/vec2(.8,.2)*glf/1.);
    vec3 xi=hash3f(vec3(cell,fi+floor(7.*fi+time*30.)));
    vec2 off=.5*(xi.xy-.5)/glf;
    off*=step(glt,.5*pow(xi.z,10.));
    p+=off;
    glf*=1.4;
  }
  
  vec3 col=vec3(0);
  vec3 colrem=vec3(1);
  
  float side=1.;
  vec3 ro=vec3(0,0,5);
  vec3 rd=normalize(vec3(p,-3));
  float rl=0.;
  vec3 rp=ro+rd*rl;
  
  repeat(i,100){
    float fi=float(i);
    vec3 xi=random3();
    float delay=xi.y;
    
    float tt=time-.3*delay;
    
    float dist=.1*exp2(xi.x);
    dist=min(dist,side*map(rp));
    rl+=dist;
    rp=ro+rd*rl;
    
    float dens=calcdens(rp,tt);
    col+=colrem*calcgrad(delay)*dist*dens;
    
    if(dist<.001){
      vec3 n=side*nmap(rp);
      
      ro=rp;
      
      vec3 rdt=refract(rd,n,exp2(-side*log2(1.5)));
      if(rdt==vec3(0)){
        rdt=reflect(rd,n);
      }else{
        side=-side;
      }
      rd=rdt;
      
      rl=.002/abs(dot(rd,n));
      rp=ro+rd*rl;
      
      colrem*=mix(
        vec3(1),
        .5+.5*cos(3.*abs(dot(rd,n))+vec3(0,2,4)),
        .2
      );
    }
  }
  
  col=pow(col,vec3(.4545));
  
  vec2 pt=p;
  pt.x-=sign(pt.x)*min(abs(pt.x),.4);
  float d=length(pt)-.2;
  col*=mix(1.,.5,linearstep(deltap,-deltap,d));
  pt.y+=.03;
  d=length(pt)-.2;
  col*=mix(1.,.5,smoothstep(.05,-.05,d));
  
  repeat(i,100){
    float fi=float(i);
    vec3 xi=random3();
    float delay=(fi+xi.x)/100.;
    float tt=time-.3*delay-.1;
    
    float r=.16;
    float d=1E9;
    float ani=ease(fract(tt),5.);
    vec2 ani2=vec2(r*ani,0);
    d=min(d, abs(length(p)-r) );
    d=min(d, abs(length(p-.5*ani2)-r) );
    d=min(d, abs(length(p+.5*ani2)-r) );
    d=min(d, abs(length(p-ani2)-r) );
    d=min(d, abs(length(p+ani2)-r) );
    d=min(d, abs(length(p-2.*ani2)-r) );
    d=min(d, abs(length(p+2.*ani2)-r) );
    
    d=min(d, abs(length(p-r*vec2(2.9,0.9))-.02*r) );
    d=min(d, abs(length(p+r*vec2(2.9,0.9))-.02*r) );
    
    vec2 cell=vec2(0);
    cell.x=clamp(round(p.x/.04)*.04,-.12,.12);
    d=min(d, length(abs(p-cell)-r*vec2(0,1.5))-.02*r );
    
    vec2 pt=abs(p);
    pt-=r*vec2(3.,1.5);
    cell=clamp(round(pt/.02)*.02,.0,.06);
    pt-=cell;
    float show=step(.5,hash3f(vec3(cell,floor((ani+floor(tt))*10.))).x);
    d=min(d, length(pt)-.02*r+1.*show );

    d-=.001;

    col+=calcgrad(delay)*linearstep(deltap,-deltap,d)/100.;
  }
  
  col=mix(
    col,
    abs(sin(5.*col)),
    saturate(length(p-p0)/.1)
  );

  col*=1.-.3*length(p);
  col=smoothstep(
    vec3(0,-.1,-.2),
    vec3(1,1.1,1.2),
    col
  );
  
  out_color=vec4(col,1);
}