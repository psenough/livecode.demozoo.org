#version 410 core

#define fs(i) (fract(sin((i)*114.514)*1919.810))
#define lofi(i,j) (floor((i)/(j))*(j))
#define saturate(i) (clamp(i,0.,1.))
#define linearstep(a,b,t) (saturate(((t)-(a))/((b)-(a))))

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

float time=fGlobalTime;
float integ;
float seed;

mat2 r2d(float t){
  float s=sin(t);
  float c=cos(t);
  return mat2(c,-s,s,c);
}

mat3 orthBas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)>.999?vec3(0,0,1):vec3(0,1,0);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

vec3 cyclic(vec3 p,float pump){
  float warp=1.;
  mat3 b=orthBas(vec3(1,-3,-2));
  vec4 accum=vec4(0);
  for(int i=0;i<4;i++){
    p*=b;
    p*=2.;
    p+=warp*sin(p.yzx);
    accum+=vec4(
      cross(sin(p.zxy),cos(p)),
      1
    );
    warp*=1.3;
    accum*=pump;
  }
  return accum.xyz/accum.w;
}

float random(){
  seed++;
  return fs(seed);
}

float sdbox(vec3 p,vec3 s){
  vec3 d=abs(p)-s;
  return min(0.,max(max(d.x,d.y),d.z))+length(max(d,0.));
}

vec3 sampleLambert(vec3 N){
  float p=TAU*random();
  float ct=sqrt(random());
  float st=sqrt(1.0-ct*ct);
  return orthBas(N)*vec3(cos(p)*st,sin(p)*st,ct);
}

float smin(float a,float b,float k){
  float h=linearstep(k,0.,abs(a-b));
  return min(a,b)-h*h*h*k/6.;
}

vec4 mapMin(vec4 a,vec4 b){
  return a.x<b.x?a:b;
}

vec4 mapTake(vec3 p,float l){
  float mtl=smoothstep(.1,.11,length(p.xz));
  float d=abs(length(p.xz)-.1)-.01;
  d-=mtl*.003*smoothstep(.97,1.,sin(20.*(3.2+p.y-l)));
  d=max(d,-p.y);
  d=max(d,dot(p-vec3(0,l,0),normalize(vec3(0,1,2))));
  return vec4(d,1,mtl,0);
}

vec4 mapTakes(vec3 p){
  p+=.004*cyclic(p*vec3(8,.3,8),2.0);
  vec4 i=vec4(1E9);
  vec3 pt;
  pt=p-vec3(-.13,.0,.1);
  float l=1.+texture(texFFT,2000./24000.).x;
  i=mapMin(i,mapTake(pt,l));
  pt=p-vec3(.13,.0,.1);
  l=1.1+texture(texFFT,400./24000.).x;
  i=mapMin(i,mapTake(pt,l));
  pt=p-vec3(0,.0,-.1);
  l=1.5+texture(texFFT,50./24000.).x;
  i=mapMin(i,mapTake(pt,l));
  return i;
}

vec4 mapMushiro(vec3 p){
  p+=.005*cyclic(p*vec3(8,2,8),2.0);
  float t=lofi(atan(p.z,p.x)+PI/128.,PI/64.);
  p.xz*=r2d(-t);
  p.x-=.28;
  p.xy*=r2d(.1);
  float d=length(p.zx)-.01;
  d=max(d,-p.y);
  d=max(d,p.y-.5);
  return vec4(d,2,0,0);
}

vec4 mapMatsu(vec3 p){
  float ff=texture(texFFT,50./24000.).x;
  p+=.05*cyclic(p+ff,2.0);
  p.y-=.52;
  float dd=1E9;
  for(int i=0;i<3;i++){
    p.xz*=r2d(.23*integ);
    float t=lofi(atan(p.z,p.x)+PI/8.,PI/4.);
    p.xz*=r2d(-t);
    p.xy*=r2d(.5*exp(-.4*float(i)));
    if(i==0){
      p.x-=.2;
    }
    float d=length(p.zx)-.01+.015*p.y;
    d=max(d,-p.y);
    d=max(d,p.y-.5);
    dd=min(dd,d);
  }
  return vec4(dd*.8,3,0,0);
}

vec4 mapUme(vec3 p){
  p.y-=.7;
  p+=.005*cyclic(p*vec3(8,2,8),2.0);
  float t=lofi(atan(p.z,p.x)+PI/32.,PI/16.);
  p.y+=.04*sin(t*1.+integ*.31);
  p.y+=.04*sin(t*2.+integ*.21);
  p.y+=.04*sin(t*3.+integ*.11);
  p.xz*=r2d(-t);
  p.x-=.4;
  p.xy*=r2d(.1);
  float d=length(p)-.01;
  return vec4(d,4,0,0);
}


vec4 mapTora(vec3 p){
  p.y-=1.;
  float d=1E9;
  float size=.3+.5*texture(texFFTSmoothed,50./24000.).x;
  vec3 pt=p+.5*sin(integ*vec3(.12,.07,.23)+vec3(4,7,22));
  d=smin(d,length(pt)-size,.2);
  pt=p+.5*sin(integ*vec3(.08,.18,.13)+vec3(44,52,32));
  d=smin(d,length(pt)-size,.2);
  pt=p+.5*sin(integ*vec3(.21,.27,.09)+vec3(8,1,2));
  d=smin(d,length(pt)-size,.2);
  return vec4(d,5,0,0);
}

vec4 mapSense(vec3 p){
  p-=vec3(0,.4,.4);
  p.yz*=r2d(.2);
  p.xy*=r2d(-PI/2.);
  p+=.005*cyclic(p*vec3(8,2,8),2.0);
  float t=clamp(lofi(atan(p.y,p.x)+PI/32.,PI/16.),-PI/4.,PI/4.);
  p.xy*=r2d(-t);
  p.x-=.28;
  p.yz*=r2d(.2);
  float d=sdbox(p,vec3(.2,.08,.01));
  return vec4(d,6,0,0);
}

vec4 map(vec3 p){
  vec4 i=vec4(1E9);
  i=mapMin(i,mapTora(p));
  p.x=abs(p.x);
  p.x-=1.5;
  i=mapMin(i,mapTakes(p));
  i=mapMin(i,mapMushiro(p));
  i=mapMin(i,mapMatsu(p));
  i=mapMin(i,mapUme(p));
  i=mapMin(i,mapSense(p));
  return i;
}

vec3 nMap(vec3 p){
  vec2 d=vec2(0.,1E-3);
  return normalize(vec3(
    map(p+d.yxx).x-map(p-d.yxx).x,
    map(p+d.xyx).x-map(p-d.xyx).x,
    map(p+d.xxy).x-map(p-d.xxy).x
  ));
}

float aoMap(vec3 p,vec3 N){
  float accum=0.;
  for(int i=0;i<20;i++){
    vec3 pt=p+sampleLambert(N)*mix(.02,.5,random());
    float d=map(pt).x;
    accum+=linearstep(.02,.0,d)/20.;
  }
  return saturate(1.0-sqrt(accum*2.));
}

// hello silvester demoparty

// I'm pretty sure I'm eating a lot of GPU loads LMAO
// kill me

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  
  seed=texture(texNoise,p*9.).x*9.;
  seed+=fract(time);
  
  integ=texture(texFFTIntegrated,100./24000.).x;

  p.xy*=r2d(.4*sin(.07*integ));
  
  vec3 co=vec3(0,1,2.5);
  co.zx*=r2d(.1*integ);
  vec3 ct=vec3(0,1,0);
  vec3 cz=normalize(co-ct);
  mat3 cb=orthBas(cz);
  
  vec3 ro=co;
  vec3 rd=cb*normalize(vec3(p,-1));

  vec3 bgnoise=cyclic(rd*vec3(1,1,8)+.04*integ,2.0);
  vec3 col=saturate(vec3(bgnoise*.2+vec3(.9,.3,.1)));
  
  float rl=0.;
  vec3 rp=ro;
  vec4 isect;
  
  for(int i=0;i<64;i++){
    isect=map(rp);
    rl+=isect.x;
    rp=ro+rd*rl;
  }
  
  if(abs(isect.x)<1E-2){
    vec3 N=nMap(rp);
    vec3 V=-rd;
    vec3 L=normalize(vec3(1,3,2));
    vec3 H=normalize(L+V);
    float dotNL=max(1E-3,dot(N,L));
    float dotNH=max(1E-3,dot(N,H));
    float dotNV=max(1E-3,dot(N,V));
    float F=1.0-dotNV;
    F*=F;
    F*=F;
    float ao=aoMap(rp,N);
    
    vec3 albedo=vec3(1);
    
    if(isect.y==1){
      albedo=mix(
        vec3(.8,.6,.3),
        vec3(.2,.6,.1),
        isect.z
      );
    }else if(isect.y==2){
      albedo=vec3(.8,.5,.3);
    }else if(isect.y==3){
      albedo=vec3(.04,.3,.02);
    }else if(isect.y==4){
      albedo=vec3(.7,.02,.02);
    }else if(isect.y==5){
      float n=cyclic(rp*vec3(1,4,4)+.2*integ,2.).x;
      n=smoothstep(-.1,.1,sin(4.*n));
      albedo=mix(
        vec3(.02),
        vec3(.8,.6,.1),
        n
      );
    }else if(isect.y==6){
      albedo=vec3(.8,.4,.01);
    }
    
    float phong=pow(dotNH,20.);
    float s=mix(.04,1.,mix(phong,1.,F*.3));
    col=(dotNL+ao)*mix(albedo,vec3(1),s);
  }
  
  col=pow(col,vec3(.4545));
  col*=1.0-.3*length(p);
  col=smoothstep(vec3(.1,.0,-.1),vec3(.9,1.,1.1),col);
  
	out_color = vec4(col,1);
}
