#version 410 core

#define saturate(x) ( clamp(x,0.,1.) )
#define linearstep(a,b,t) ( saturate( ( (t)-(a) ) / ( (b)-(a) ) ) )
#define lofi(x,d) ( floor( (x)/(d) ) * (d) )

const float PI=3.14159265;
const float foldcos=cos(PI/5.);
const float foldrem=sqrt(.75-foldcos*foldcos);
const vec3 foldvec=vec3(-.5,-foldcos,foldrem);
const vec3 foldface=normalize(vec3(0,foldrem,foldcos));

float time;
float seed;
vec3 glow;

float fractSin(float s){
  return fract(sin(s*114.514)*1919.810);
}

float random(){
  seed=fractSin(seed);
  return seed;
}

vec3 randomSphere(){
  float a=random()*2.*PI;
  float b=acos(random()*2.-1.);
  return vec3(cos(a)*sin(b),cos(b),sin(a)*sin(b));
}

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

vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 r2d(float t){
  return mat2(cos(t),sin(t),-sin(t),cos(t));
}

float smin(float a,float b,float k){
  float h=linearstep(k,0.,abs(a-b));
  return min(a,b)-h*h*h*k/6.;
}

vec3 fold(vec3 p){
  for(int i=0;i<5;i++){
    p.xy=abs(p.xy);
    p-=2.*min(0.,dot(foldvec,p))*foldvec;
  }
  return p;
}

vec3 catColor(float t){
  return .5+.5*cos(vec3(0.,2.,4.)-t);
}

vec4 mapSpike(vec3 p){
  vec3 pt=p;
  
  float fart=sin(PI*exp(-5.0*mod(time,2.4)));
  
  pt.yz=r2d(.7*time)*pt.yz;
  pt.zx=r2d(time+pt.y*sin(time))*pt.zx;
  pt.xy=r2d(.2*pt.z*cos(time))*pt.xy;
  pt=fold(pt);
  float dotFace=dot(foldface,pt);
  float l=length(dotFace*foldface-pt);
  float r=.4-.2*sqrt(dotFace);
  float d=l-r;
  d=smin(d,length(pt)-1.-.7*fart,1.);
  d=max(d,length(pt)-4.);

  glow+=.5*catColor(4.+exp(-10.0*d))*d*exp(-10.0*d);

  return vec4(d,0,0,0);
}

vec4 mapPhantom(vec3 p){
  vec3 pt=p;
  
  float fart=sin(PI*exp(-5.0*mod(time-length(pt)*.1,2.4)));
  pt-=normalize(pt)*fart;
  
  pt.zx=r2d(4.+time+.6*pt.y*sin(time))*pt.zx;
  pt.xy=r2d(2.+.6*pt.z*cos(time))*pt.xy;
  pt.yz=r2d(3.+.7*time)*pt.yz;
  pt=fold(pt);
  float dotFace=dot(foldface,pt);
  float l=length(dotFace*foldface-pt);
  float r=.2*sqrt(dotFace);
  float d=l-r;
  d=smin(d,length(pt)-1.,1.);
  d=max(abs(d),.2);

  glow+=(.01+.2*fart)*catColor(3.+exp(-10.0*d)+8.0*exp(-length(pt)))*d*exp(-3.0*d);

  return vec4(d,0,0,0);
}

vec4 mapCrystal(vec3 p){
  vec3 pt=p;

  pt.zx=r2d(.2*time)*pt.zx;
  float a=atan(pt.x,pt.z);
  pt.zx=r2d(-lofi(a+PI/6.,PI/3.))*pt.zx;
  pt.z-=5.;
  pt.zx=r2d(-time)*pt.zx;

  pt.y*=.5;
  pt.y+=.1*texture(texNoise,pt.zx).x;
  pt.y-=sign(pt.y)*min(abs(pt.y),1.);
  
  pt=fold(pt);
  float dotFace=dot(foldface,pt);
  float d=dotFace-.6;

  glow+=.2*catColor(3.5+exp(-10.0*d))*d*exp(-5.0*d);

  return vec4(d,1,0,0);
}

vec4 map(vec3 p){
  vec4 i=vec4(1E9);
  vec4 i2;
  
  i2=mapSpike(p);
  i=i2.x<i.x?i2:i;
  i2=mapPhantom(p);
  i=i2.x<i.x?i2:i;
  i2=mapCrystal(p);
  i=i2.x<i.x?i2:i;
  
  return i;
}

vec3 nSpike(vec3 p,vec2 d){
  return normalize(vec3(
    mapSpike(p+d.yxx).x-mapSpike(p-d.yxx).x,
    mapSpike(p+d.xyx).x-mapSpike(p-d.xyx).x,
    mapSpike(p+d.xxy).x-mapSpike(p-d.xxy).x
  ));
}

vec3 nCrystal(vec3 p,vec2 d){
  return normalize(vec3(
    mapCrystal(p+d.yxx).x-mapCrystal(p-d.yxx).x,
    mapCrystal(p+d.xyx).x-mapCrystal(p-d.xyx).x,
    mapCrystal(p+d.xxy).x-mapCrystal(p-d.xxy).x
  ));
}

float dRadial(vec2 p,float offr,float repr,float exr,float offx,float exx,float r){
  p=r2d(offr)*p;
  float a=atan(p.y,p.x);
  p=r2d(-lofi(a+repr/2.,repr))*p;
  a=atan(p.y,p.x);
  p=r2d(-sign(a)*min(abs(a),exr))*p;
  p.x-=offx;
  p.x-=sign(p.x)*min(abs(p.x),exx);
  float d=length(p)-r;
  return d;
}

float sdbox(vec2 p,vec2 d){
  vec2 pt=abs(p)-d;
  return max(min(pt.x,pt.y),0.)+length(max(pt,0.));
}

float dCirc(vec2 p){
  return max(length(p)-0.02,0.018-length(p));
}

float dOverlay(vec2 p){
  float d=1E9;
  float t=fGlobalTime;
  d=min(d,sdbox(p,vec2(0.12,0.002)));
  {
    vec2 pt=abs(p);
    d=min(d,dCirc(pt-vec2(.0,.05)));
    d=min(d,dCirc(pt-vec2(.07,.05)));
    d=min(d,dCirc(pt-vec2(.035,.05+.035*sqrt(3))));
  }
  {
    vec2 pt=p;
    pt=pt.y<.0?-pt:pt;
    pt-=vec2(.0,.2);
    float d2=1E9;
    d2=min(d2,sdbox(pt,vec2(0.15,0.02)));
    pt=r2d(PI/4.)*pt;
    pt.y-=.1*t;
    pt-=lofi(pt.y+0.02,0.04);
    d2=max(d2,sdbox(pt,vec2(1E9,0.01)));
    d=min(d2,d);
  }
  {
    float d2=1E9;
    d2=smin(d2,dRadial(p,.1*t,PI/2.,PI/8.,.7,0.0,.02),.05);
    d2=smin(d2,dRadial(p,.1*t+PI/4.,PI/2.,PI/8.,.72,0.0,.02),.05);
    d=min(d2,d);
  }
  d=min(d,dRadial(p,.1*t,PI/8.,PI/19.,.76,0.002,.0));
  d=min(d,dRadial(p,-.1*t,PI/8.,PI/9.,.78,0.01,.0));
  d=min(d,dRadial(p,.04*t,PI/48.,0.002,.815,0.008,.0));
  d=min(d,dRadial(p,.04*t,PI/192.,0.002,.815,0.002,.0));
  {
    float d2=1E9;
    d2=smin(d2,dRadial(p,.1*t,PI/1.5,PI/8.,.86,0.0,.02),.05);
    d2=smin(d2,dRadial(p,.1*t+PI/4.,PI/1.5,PI,.88,0.0,.02),.05);
    d=min(d2,d);
  }
  d=min(d,dRadial(p,.2*t,PI/2.,PI/4.2,.915,0.002,.0));
  d=min(d,dRadial(p,-.1*t,PI/4.,PI/8.5,.94,0.01,.0));
  d=min(d,dRadial(p,.04*t,PI/96.,0.002,.99,0.03,.0));
  return d;
}

void main(void)
{
  vec2 p = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y)*2.-1.;
  p /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time=fGlobalTime;
  seed=texture(texNoise,p).x;
  time+=.02*random();
  
  bool mode=mod(fGlobalTime,6.)>4.;
  float modetime=mod(mod(fGlobalTime,6.),4.);
  float modetime2=mod(mod(time,6.),4.);
  
  vec3 col=vec3(0);
  
  vec3 cp=vec3(1,.3,2.5);
  cp.zx=r2d(-2.0*exp(-2.0*modetime2))*cp.zx;
  if(mode){
    cp*=2.6;
  }
  vec3 ct=vec3(1,.3,0);
  vec3 cd=normalize(ct-cp);
  vec3 cx=normalize(cross(cd,vec3(0,1,0)));
  vec3 cy=cross(cx,cd);
  
  vec2 camp=p;
  float mos=0.1*exp(-5.0*modetime);
  camp=lofi(camp+mos*.5,mos);
  camp=r2d(.4)*camp;
  
  vec3 ro=cp;
  vec3 rd=normalize(cx*camp.x+cy*camp.y+cd);
  vec3 fp=ro+rd*length(cp-ct)*.8;
  ro+=.02*randomSphere();
  rd=normalize(fp-ro);
  
  float rl=.1;
  vec3 rp=ro+rd*rl;
  vec4 isect;
  
  for(int i=0;i<128;i++){
    glow*=0.;
    isect=map(rp);
    col+=exp(-.1*rl)*glow;
    rl+=.3*isect.x;
    rp=ro+rd*rl;
  }
  
  if(isect.x<1E-2){
    if(isect.y==0.){

      vec3 n=nSpike(rp,vec2(0,2E-1));
      float f=1.-abs(dot(rd,n));
      f=f*f;
      col=vec3(f)*catColor(4.+3.*f);
      
    }else if(isect.y==1.){
      
      vec3 n=nCrystal(rp,vec2(0,1E-2));
      float f=1.-abs(dot(rd,n));
      f=f*f;
      col=7.0*vec3(f)*catColor(4.-2.*f);
      
    }
  }
  
  float overlay;
  {
    float d=dOverlay(p*.7);
    float pix=1.0/v2Resolution.y;
    overlay=pow(linearstep(pix,-pix,d),2.2);
    col+=.4*vec3(.02,.02,1.)*exp(-(0.1+.05*sin(40.0*time))/pix*max(0.,d));
  }
  col=mix(col,1.-2.*col.yzx,overlay);
  
  if(mode){
    col=.5-1.*col.yzx;
  }
  
  float flicker=step(fract(fGlobalTime*20.),.5);
  col=pow(col,vec3(.4545));
  col*=1.+.05*length(p)*flicker;
  col*=1.+.5*flicker*smoothstep(.2,.7,texture(texNoise,p*vec2(.5,.01)+time*vec2(.1,2.)).x);
  col=vec3(
    smoothstep(.1,.9,col.x),
    smoothstep(.1,.8,col.y),
    smoothstep(-.1,1.1,col.z)
  );
  
  out_color = vec4(col,1);
}