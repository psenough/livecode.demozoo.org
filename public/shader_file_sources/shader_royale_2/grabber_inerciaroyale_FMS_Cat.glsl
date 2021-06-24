#version 410 core

#define PI 3.14159265
#define saturate(x) clamp(x,0.,1.)
#define linearstep(a,b,t) ( saturate( ( (t)-(a) ) / ( (b)-(a) ) ) )
#define lofi(i,j) ( floor( (i) / (j) ) * (j) )

float time;
float seed;

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float fractSin(float t){
  return fract(sin(t*114.514)*1919.810);
}

float random(){
  seed=fractSin(seed);
  return seed;
}

vec3 randomSphere(){
  float a=2.*PI*random();
  float b=acos(random()*2.-1.);
  return vec3(cos(a)*sin(b),cos(b),sin(a)*sin(b));
}

vec3 randomHemisphere(vec3 n){
  vec3 r=randomSphere();
  return dot(r,n)<.0?-r:r;
}

mat2 r2d(float t){
  return mat2(cos(t),sin(t),-sin(t),cos(t));
}

struct Heck{
  vec2 coord;
  vec2 cell;
  float len;
};

vec2 uv2heck(vec2 v){
  v.y*=2./sqrt(3.);
  v.x+=v.y*.5;
  return v;
}

vec2 heck2uv(vec2 v){
  v.y/=2./sqrt(3.);
  v.x-=v.y*.5;
  return v;
}

Heck doHeck(vec2 v,float scale){
  Heck heck;
  
  v=uv2heck(v)*scale;
  
  heck.cell.x=lofi(v.x,1.);
  heck.cell.y=lofi(v.y+heck.cell.x+2.0,3.)-heck.cell.x-2.0;
  heck.coord=v-heck.cell-vec2(0,1);
  
  bool a=heck.coord.x<heck.coord.y;
  heck.cell+=a?vec2(0,2):vec2(1,1);
  heck.coord+=a?vec2(0,-1):vec2(-1,0);
  
  heck.cell=heck2uv(heck.cell/scale);
  
  heck.len=max(abs(heck.coord.x),abs(heck.coord.y));
  heck.len=max(heck.len,abs(heck.coord.y-heck.coord.x));
  
  return heck;
}

const float foldcos=cos(PI/5.0);
const float foldrem=sqrt(0.75-foldcos*foldcos);
const vec3 foldvec=vec3(-.5,-foldcos,foldrem);
const vec3 foldsurf=normalize(vec3(0,foldrem,foldcos));
const vec3 foldu=vec3(1,0,0);
const vec3 foldv=normalize(cross(foldu,foldsurf));

vec3 fold(vec3 p){
  for(int i=0;i<5;i++){
    p.xy=abs(p.xy);
    p-=2.*min(0.,dot(p,foldvec))*foldvec;
  }
  return p;
}

vec4 mapPlane(vec3 p){
  float d=5.0-abs(p.y);
  return vec4(d,1,0,0);
}

vec4 mapIcosa2(vec3 p){
  float t=sin(time)+time;
  p.zx=r2d(.1*t)*p.zx;
  p=fold(p);
  p-=foldsurf;
  p.yz=r2d(2.+.17*t)*p.yz;
  p=fold(p);
  p-=0.41*foldsurf;
  p.xy=r2d(5.+.07*t)*p.xy;
  p=fold(p);
  p-=0.26*foldsurf;
  p.xy=r2d(3.+.12*t)*p.xy;
  p=fold(p);
  p-=0.07*foldsurf;
  float d=dot(foldsurf,p)-.2;
  return vec4(d,2,0,0);
}

vec4 mapIcosa(vec3 p){
  p.zx=r2d(.1*time)*p.zx;
  p=fold(p);
  
  vec3 isect=p/dot(foldsurf,p);
  vec2 uv=vec2(dot(isect,foldu),dot(isect,foldv));
  
  float phase=time;
  phase=floor(phase)+(.5+.5*cos(PI*exp(-5.0*fract(phase))));
  float scale=5.0+4.0*sin(1.8*phase);
  Heck heck=doHeck(uv,scale);
  vec3 point=normalize(foldsurf+heck.cell.x*foldu+heck.cell.y*foldv);

  phase+=4.7*length(heck.cell);
  float height=2.0+.3*sin(4.9*phase);
  
  float dotPointP=dot(point,p);
  float d=max(dotPointP-height,(heck.len-0.6/dotPointP)/scale*dotPointP*dotPointP);
  vec4 ia=vec4(d,2,0,0);
  
  float width=0.6+0.3*sin(7.6*phase);
  float haha=abs(dotPointP-height)-.1;
  float haha2=(heck.len-width)/scale*dotPointP;
  d=max(haha,haha2);
  vec4 ib=vec4(d,3,step(-0.03,heck.len-width)*step(-haha,0.03),0);
  
  ia=ib.x<ia.x?ib:ia;
  
  return ia;
}

vec4 mapRings(vec3 p){
  vec3 pInit=p;

  p.zx=r2d(time)*p.zx;
  p.xy=r2d(1.78*time)*p.xy;
  p.zx=r2d(-lofi(atan(p.x,p.z)+PI/64.0,PI/32.0))*p.zx;
  p.y=abs(p.y);
  p.y=max(0.0,p.y-0.2);
  float d=length(p-vec3(0,0,2.4))-.01;

  p=pInit;
  p.zx=r2d(-time)*p.zx;
  p.yz=r2d(1.57*time)*p.yz;
  p.zx=r2d(-lofi(atan(p.x,p.z)+PI/64.0,PI/32.0))*p.zx;
  p.y=abs(p.y);
  p.y=max(0.0,p.y-0.2);
  d=min(d,length(p-vec3(0,0,2.6))-.01);
  
  return vec4(d,4,0,0);
}
vec4 mapHelp(vec3 p){
  p.z+=20.0*mod(time+.8*sin(time),100.0); // forgive me

  Heck heck=doHeck(p.zx,1.0/2.0);
  
  p.zx-=heck.cell;
  p.y+=8.0*(fractSin(heck.cell.x)-.5);
  p.y+=8.0*(fractSin(1.78*heck.cell.y)-.5);

  p.z=abs(p.z);
  p.z=max(0.0,p.z-(1.0*(1.0+1.0*cos(time))));
  
  float d=length(p)-0.01;
  
  return vec4(d,4,0,0);
}

vec4 map(vec3 p){
  vec4 ia=vec4(9E9);
  vec4 ib=mapIcosa(p);
  ia=ib.x<ia.x?ib:ia;
  ib=mapPlane(p);
  ia=ib.x<ia.x?ib:ia;
  ib=mapRings(p);
  ia=ib.x<ia.x?ib:ia;
  ib=mapHelp(p);
  ia=ib.x<ia.x?ib:ia;
  return ia;
}

vec3 normalIcosa(vec3 p,vec2 d){
  return normalize(vec3(
    mapIcosa(p+d.yxx).x-mapIcosa(p-d.yxx).x,
    mapIcosa(p+d.xyx).x-mapIcosa(p-d.xyx).x,
    mapIcosa(p+d.xxy).x-mapIcosa(p-d.xxy).x
  ));
}

float aoFunc(vec3 p,vec3 n){
  float accum=0.0;
  for(int i=0;i<32;i++){
    vec3 r=0.04*(1.+float(i))*randomHemisphere(n);
    float d=map(p+r).x;
    accum+=linearstep(0.04,0.0,d)/64.0;
  }
  return saturate(1.0-sqrt(accum*6.));
}

void main(void)
{
  vec2 p = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y)*2.-1.;
  p /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time=fGlobalTime;
  seed=texture(texNoise,97.27*p).x+time;
  time+=0.01*random();
  
  vec3 cp=mix(vec3(-.5,.7,3),vec3(0,0,7),.5+.5*sin(time));
  cp.zx=r2d(.2*time)*cp.zx;
  vec3 ct=vec3(0,1,-.8);
  vec3 cd=normalize(ct-cp);
  vec3 cx=normalize(cross(cd,vec3(0,1,0)));
  vec3 cy=cross(cx,cd);
  
  vec3 ro=cp;
  vec3 rd=normalize(cd*(1.-.4*length(p))+cx*p.x+cy*p.y);
  float fl=mix(2., 6.,.5+.5*sin(time));
  vec3 fp=ro+fl*rd;
  ro+=.02*randomSphere();
  rd=normalize(fp-ro);
  
  vec3 col=vec3(0.);
  vec3 colRem=vec3(1);
  
  for(int is=0;is<2;is++){
    float rl=0.04;
    vec3 rp=ro+rd*rl;
    vec4 isect;
    
    for(int i=0;i<69;i++){ // nice
      isect=map(rp);
      rl+=.5*isect.x;
      rp=ro+rd*rl;
    }
    
    if(.01<isect.x){
      rl*=(sign(rd.y)*5.-ro.y)/(rp-ro).y;
      rp=ro+rd*rl;
      isect=vec4(0,1,0,0);
    }
    
    float fog=exp(-0.01*rl);
    colRem*=fog;
  
    if(isect.x<.01){
      if(isect.y==1.){
        vec3 n=vec3(0,-sign(rp.y),0);
        Heck heck=doHeck(rp.xz+vec2(0,20.0*(time+.8*sin(time))),2.0);
        float phase=time;
        phase+=0.2*heck.cell.y;
        phase+=4.0*texture(texNoise,0.03*heck.cell).x;
        phase+=1.0*fractSin(texture(texNoise,30.03*heck.cell).x);
        phase=mod(phase,5.0);
        float width=0.9*(1.0-exp(-5.0*phase));
        float shape=step(heck.len,width);
        float shapewaku=step(heck.len,.9);
        float dec=exp(-phase);
        col+=colRem*dec*shape*vec3(0.9,0.02+0.002*rl,0.1);
        colRem*=.6*shapewaku;
        rd=normalize(reflect(rd,n)+.01*randomHemisphere(n));
        ro=rp;
      }else if(isect.y==2.){
        vec3 n=normalIcosa(rp,vec2(0,1E-4));
        vec3 n2=normalIcosa(rp,vec2(0,1E-2));
        float edge=linearstep(.1,.2,length(n-n2));
        float ao=aoFunc(rp,n);
        float fresnel=1.0-abs(dot(rd,n));
        fresnel=pow(fresnel,2.0);
        col+=(1.0-edge)*colRem*vec3(0.9,0.02+0.002*rl,0.1)*ao;
        colRem*=.2+.6*fresnel;
        rd=reflect(rd,n);
        ro=rp;
      }else if(isect.y==3.){
        vec3 n=normalIcosa(rp,vec2(0,1E-4));
        float ao=aoFunc(rp,n);
        float fresnel=1.0-abs(dot(rd,n));
        fresnel=pow(fresnel,2.0);
        col+=colRem*vec3(0.02)*ao;
        col+=colRem*vec3(0.9,0.02+0.002*rl,0.1)*isect.z;
        colRem*=.2+.6*fresnel;
        rd=reflect(rd,n);
        ro=rp;
      }else if(isect.y==4.){
        col+=colRem*2.0*vec3(0.9,0.02+0.002*rl,0.1);
        colRem*=.0;
      }
    }
  }
  
  col=pow(col,vec3(.4545));
  col*=1.0-.2*length(p);
  col*=1.+.2*sin(vec3(0,2,4)+2.*gl_FragCoord.y);
  col=vec3(
    smoothstep(0.1,0.9,col.x),
    smoothstep(-0.2,1.1,col.y),
    smoothstep(-0.3,1.2,col.z)
  );
  
  out_color = vec4(col,1);
}