#version 410 core

uniform float fGlobalTime;// in seconds
uniform vec2 v2Resolution;// viewport resolution (in pixels)
uniform float fFrameTime;// duration of the last frame, in seconds

uniform sampler1D texFFT;// towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed;// this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated;// this is continually increasing
uniform sampler2D texPreviousFrame;// screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location=0)out vec4 out_color;// out_color must be written in order to see anything
#define time fGlobalTime
#define dt fFrameTime
#define get_id(x,n)floor((x)*(n))
//#define lofi(x,n) get_id(x,n) / (n)
//#define saturate(x) clamp((x), 0,1)

//const float PI = acos(-1);
//const float TAU = 2 * PI;
const vec3 up=vec3(0,1,0);

mat3 ortho(vec3 z,vec3 up){
  vec3 cu=normalize(cross(z,up));
  vec3 cv=cross(cu,z);
  return mat3(cu,cv,z);
}

const int n_part=5;
vec3 psn[n_part],vel[n_part];
float rad[n_part]=float[](1,1.5,2,3,.5);

void chmin(inout vec4 a,vec4 b,float k){
  float h=max(0,k-abs(a.x-b.x))/k;
  float x=min(a.x,b.x)-h*h*h*k/6;
  vec3 aa=a.x<b.x?a.yzx:b.yzw;
  vec3 bb=a.x<b.x?b.yzx:a.yzw;
  
  a=vec4(x,mix(aa,bb,h*h*h*k/6));
}

float rnd(int n){
  n=(n<<13)^n;
  return 1.-((n*(n*n*12351+45803)+7082934)&0x7fffffff)/pow(2,30);
}

float box(vec3 p,vec3 b){
  p=abs(p)-b;
  return length(max(p,0))+min(0,max(p.x,max(p.y,p.z)));
}

vec4 map(vec3 q){
  vec4 d=vec4(1000,0,0,0);
  vec3 p=q;
  
  for(int i=0;i<n_part;i++){
    float sp=length(p-psn[i])-rad[i];
    chmin(d,vec4(sp,1,length(vel[i]),0),3);
  }
  
  float bx=box(p,vec3(12));
  bx=max(bx,-box(p-vec3(0,0,2),vec3(10))+.5);
  chmin(d,vec4(bx,0,0,0),.01);
  return d;
}

vec3 normal(vec3 p,vec2 e){
  return normalize(vec3(
      map(p+e.xyy).x-map(p-e.xyy).x,
      map(p+e.yxy).x-map(p-e.yxy).x,
      map(p+e.yyx).x-map(p-e.yyx).x
    ));
  }
  
  float pRange=20;
  float vRange=30;
  void calcVelo(){
    for(int i=0;i<n_part;i++)for(int j=0;j<n_part;j++){
      if(i==j){continue;}
      float m1=1.3333*rad[i]*rad[i]*rad[i];
      float m2=1.3333*rad[j]*rad[j]*rad[j];
      vec3 r=psn[j]-psn[i];
      vec3 rh=normalize(r);
      float rl=length(r);
      vel[i]+=.05*m2*rh/max(.005,pow(rl,2));
      
      vec3 b=abs(psn[i]);
      if(b.x>pRange/2-1){
        vel[i].x=.9*abs(vel[i].x)*-sign(psn[i].x);
      }
      
      if(b.y>pRange/2-1){
        vel[i].y=.9*abs(vel[i].y)*-sign(psn[i].y);
      }
      
      if(b.z>pRange/2-1){
        vel[i].z=.9*abs(vel[i].z)*-sign(psn[i].z);
      }
    }
  }
  
  float shad(vec3 ro,vec3 rd,vec3 sp,float r,float k,float maxt){
    vec3 oc=ro-sp;
    float b=dot(oc,rd);
    float c=dot(oc,oc)-r*r;
    float h=b*b-c;
    float d=-r+sqrt(max(0,r*r-h));
    float t=-b-sqrt(max(0,h));
    return(t<0||t>maxt)?1:smoothstep(0.,1.,k*d/t);
  }
  
  void main(void)
  {
    vec2 uv=vec2(gl_FragCoord.x/v2Resolution.x,gl_FragCoord.y/v2Resolution.y);
    vec2 pt=uv-.5;
    pt/=vec2(v2Resolution.y/v2Resolution.x,1);
    vec3 c=vec3(0);
    
    int seed=int(gl_FragCoord.x+8000)*int(gl_FragCoord.y+7777)+int(1000*time);
    
    for(int i=0;i<n_part;i++){
      float pu=(i*2+.5)/(2*n_part);
      float vu=(i*2+1.5)/(2*n_part);
      float px=texture(texPreviousFrame,vec2(pu,1./12.)).a
      +texture(texPreviousFrame,vec2(pu,3./12.)).a/255;
      float py=texture(texPreviousFrame,vec2(pu,5./12.)).a
      +texture(texPreviousFrame,vec2(pu,7./12.)).a/255;
      float pz=texture(texPreviousFrame,vec2(pu,9./12.)).a
      +texture(texPreviousFrame,vec2(pu,11./12.)).a/255;
      float vx=texture(texPreviousFrame,vec2(vu,1./12.)).a
      +texture(texPreviousFrame,vec2(vu,3./12.)).a/255;
      float vy=texture(texPreviousFrame,vec2(vu,5./12.)).a
      +texture(texPreviousFrame,vec2(vu,7./12.)).a/255;
      float vz=texture(texPreviousFrame,vec2(vu,9./12.)).a
      +texture(texPreviousFrame,vec2(vu,11./12.)).a/255;
      
      psn[i]=vec3(px,py,pz)*pRange-pRange/2;
      vel[i]=vec3(vx,vy,vz)*vRange-vRange/2;
    }
    calcVelo();
    
    vec3 ro=vec3(0,0,30);
    vec3 rd=normalize(vec3(pt,-1));
    
    vec3 p=ro;
    vec4 d;
    float t=0;
    for(int i=0;i<128;i++){
      p=ro+rd*t;
      d=map(p);
      t+=d.x;
      if(abs(d.x)<.001||t>60){
        break;
      }
    }
    
    if(abs(d.x)<.001){
      vec3 n=normal(p,vec2(.01,0));
      vec3 al=vec3(.5);
      vec3 lp=vec3(0,8,14);
      vec3 l=normalize(lp-p);
      float ld=length(lp-p);
      float li=30/pow(ld,2);
      
      c=li*al*max(dot(n,l),0);
      for(int i=0;i<n_part;i++){
        c*=shad(p,l,psn[i],rad[i],15,ld);
      }
      c+=vec3(.2,.8,.9)*pow(d.z/15,3);
    }
    
    vec2 parts=get_id(uv,vec2(n_part,3)*2);
    int id=int(parts.x/2);
    bool isP=mod(parts.x,2)==0;
    int xyz=int(parts.y/2);
    bool isU=mod(parts.y,2)==0;
    if(time==0){
      psn[id]=vec3(rnd(id+17),rnd(id),rnd(id+23))*pRange-pRange/2;
      vel[id]=vec3(0);
    }
    psn[id]+=dt*vel[id];
    vec3 val=isP?mod(psn[id]+pRange/2,pRange)/pRange:clamp(vel[id]+vRange/2,0,vRange)/vRange;
    val=isU?floor(val*255)/255:mod(val,1./255.)*255.;
    float a=val[xyz];
    
    c*=(.8+.4*rnd(seed));
    //c += .01 * vec3(a);
    
    c=pow(c,vec3(.4545));
    out_color=vec4(c,a);
  }
  