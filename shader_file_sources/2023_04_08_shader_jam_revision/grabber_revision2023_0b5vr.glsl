#version 410 core

#define loop(i,n) for(int i=0;i<n;i++)
#define lofi(i,j) (floor((i)/(j))*(j))
#define lofir(i,j) (floor((i)/(j)+.5)*(j))

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

uvec3 pcg3d(uvec3 s){
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

vec3 pcg3df(vec3 s){
  uvec3 r=pcg3d(floatBitsToUint(s));
  return vec3(r)/float(0xffffffffu);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec4 fuck(vec2 uv,float time){
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, time) / d;
	t = clamp( t, 0.0, 1.0 );
  return t;
}

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

float smin(float a,float b,float k){
  float h=max(k-abs(a-b),0.)/k;
  return min(a,b)-h*h*h*k/6.;
}

float smax(float a,float b,float k){
  return -smin(-a,-b,k);
}

float sdcapsule(vec3 p,vec3 tail){
  float h=clamp(dot(p,tail)/dot(tail,tail),0.,1.);
  return length(p-tail*h);
}

float sdbox(vec3 p,vec3 s){
  vec3 d=abs(p)-s;
  return min(max(max(d.x,d.y),d.z),0.)+length(max(d,0.));
}

// let's see how dojoe dance
float sdbend(vec3 p,float w,float b){
  float t=p.x/w;
  t*=t;
  p.y+=b*(1.-t);
  return sdcapsule(p+vec3(w,0,0),vec3(w*2.,0,0));
}

vec3 happybump(vec3 p,float phase){
  p.y-=.2*abs(sin(phase));
  p.xy*=r2d(.05*acos(cos(phase))-.05);
  return p;
}

vec4 map(vec3 p){
  vec3 pt=p;
  vec4 isect=vec4(1E9);
  float d=1E9;
  
  vec3 origin=vec3(0);
  origin.xz=lofir(p.xz,4.);
  p-=origin;
  
  vec3 dice=pcg3df(origin);
  p.zx*=r2d(dice.x-.5);
  
  float phase=PI*140./60.*fGlobalTime;
  phase+=PI*step(.5,dice.y)+dice.y;
  
  // mouth
  pt=p;
  pt=happybump(pt,phase);
  pt.y=-pt.y;
  pt.y-=.2;
  pt.z-=.1;
  d=sdbend(pt,.5,-.05)-.05;
  if(d<isect.x){
    isect=vec4(d,1,0,0);
  }
  
  // eyes
  pt=p;
  pt=happybump(pt,phase);
  pt.x=abs(pt.x);
  pt.x-=.4;
  pt.y-=.2;
  pt.z-=.1;
  d=length(pt)-.05;
  if(d<isect.x){
    isect=vec4(d,1,0,0);
  }
  
  // plane
  pt=p;
  pt=happybump(pt,phase);
  d=sdbox(pt,vec3(1,1,.1));
  if(d<isect.x){
    isect=vec4(d,2+dice.y,pt*.5);
  }
  
  // arm
  pt=p;
  pt=happybump(pt,phase);
  float armdir=sign(pt.x);
  pt.x=abs(pt.x);
  pt.x-=1.2;
  d=sdbend(pt,.25,.05*sin(phase+armdir))-.02;
  if(d<isect.x){
    isect=vec4(d,3,0,0);
  }
  
  // feet
  pt=p;
  pt=happybump(pt,phase);
  pt.x=abs(pt.x);
  pt.xy*=r2d(-1.2);
  pt.x-=1.2;
  d=sdbend(pt,.25,-.05)-.02;
  if(d<isect.x){
    isect=vec4(d,3,0,0);
  }
  
  // floor
  pt=p;
  pt.y+=1.5;
  d=sdbox(pt,vec3(100,.1,100));
  if(d<isect.x){
    isect=vec4(d,5,0,0);
  }
  
  // beer
  pt=p;
  pt=happybump(pt,phase);
  pt.x-=dice.z<.5?1.5:-1.5;
  pt.y+=.2;
  d=sdcapsule(pt,vec3(0,.3,0))-.1;
  d=smin(d,sdcapsule(pt,vec3(0,.6,0))-.05,.05);
  d=smax(d,-pt.y,.05);
  d=smax(d,pt.y-.6,.05);
  d*=.5;
  if(d<isect.x){
    isect=vec4(d,4,0,0);
  }
  
  return isect;
}

vec3 nmap(vec3 p){
  vec2 d=vec2(0,1E-4);
  return normalize(vec3(
    map(p+d.yxx).x-map(p-d.yxx).x,
    map(p+d.xyx).x-map(p-d.xyx).x,
    map(p+d.xxy).x-map(p-d.xxy).x
  ));
}

vec3 cyclic(vec3 p){
  mat3 b=orthbas(vec3(-1,5,2));
  vec4 sum=vec4(0);
  loop(i,6){
    p*=b;
    p+=sin(p.zxy);
    sum+=vec4(
      cross(cos(p),sin(p.yzx)),
      1
    );
    sum*=2.;
    p*=2.;
  }
  return sum.xyz/sum.w;
}

vec4 dobg(vec2 p){
  float plasma=cyclic(vec3(4.*p,fGlobalTime)).x;
  plasma+=2.*fGlobalTime;
  vec3 col=.5+.5*sin(-10.*plasma+vec3(0,1,2));
  return vec4(col,1);
}

vec3 dancefloor(vec2 p){
  vec2 cell=lofir(p,.5);
  vec2 pt=p;
  pt-=cell;
  float ph=max(abs(pt.x),abs(pt.y));
  float macroph=length(mod(cell,16.)-7.5);
  float heck=smoothstep(.9,.98,sin(-macroph-10.0*ph+10.0*fGlobalTime));
  return vec3(mix(vec3(1),vec3(1,.2,.01),heck));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  
  vec4 bg=dobg(p);
  
  vec3 co=vec3(0,2,5);
  co.xz+=fGlobalTime;
  vec3 ct=vec3(0,0,0);
  ct.xz+=fGlobalTime;
  mat3 cb=orthbas(co-ct);
  
  vec3 ro=co;
  ro.x+=fGlobalTime;
  vec3 rd=cb*normalize(vec3(p,-2));
  float rl=0.;
  vec3 rp=ro;
  vec4 isect;
  
  loop(i,100){
    isect=map(rp);
    rl+=.8*isect.x;
    rp=ro+rd*rl;
  }
  
  if(isect.x<.01){
    vec3 N=nmap(rp);
    vec3 L=normalize(vec3(1,1,2));
    float dotNL=max(dot(N,L),0.);
    float halflamb=.5+.5*dot(N,L);
    float irrad=halflamb;
    
    vec3 H=normalize(L-rd);
    float phong=pow(dot(N,H),100.);
    
    float rls=.01;
    vec3 rps=rp+L*rls;
    loop(i,50){
      rls+=.8*map(rps).x;
      rps=rp+rls*L;
    }
    irrad*=mix(.5,1.,smoothstep(5.,10.,rls));
    
    if(isect.y<2.){
      out_color=vec4(vec3(1.)*irrad,1);
    }else if(isect.y<3.){
      out_color=fuck(isect.zw*.5,fGlobalTime+5.*fract(isect.y))*vec4(vec3(irrad),1);
    }else if(isect.y<4.){
      out_color=vec4(vec3(.1)*irrad,1);
    }else if(isect.y<5.){
      out_color=vec4(vec3(.2,.3,.04)*irrad+phong,1);
    }else if(isect.y<6.){
      out_color=vec4(dancefloor(rp.xz)*irrad,1);
    }
    
    float fog=smoothstep(10.,20.,rl);
    out_color=mix(out_color,bg,fog);
  }else{
  	out_color = bg;
  }
}