#version 410 core

#define lofi(i,j) (floor((i)/(j))*(j))
#define fs(i) (fract(sin((i)*114.514)*1919.810))

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

float time;
float seed;

const float FAR=20.;
const float PI=acos(-1.);
const float TAU=PI*2.;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float random(){
  seed++;
  return fs(seed);
}

mat2 r2d(float t){
  float c=cos(t);
  float s=sin(t);
  return mat2(c,-s,s,c);
}

mat3 orthBas(vec3 z){
  z=normalize(z);
  vec3 up=abs(z.y)>.999?vec3(0,0,1):vec3(0,1,0);
  vec3 x=normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

vec3 sampleLambert(vec3 N){
  float p=TAU*random();
  float ct=sqrt(random());
  float st=sqrt(1.0-ct*ct);
  return orthBas(N)*vec3(cos(p)*st,sin(p)*st,ct);
}

vec4 ibox(vec3 ro,vec3 rd,vec3 s){
  vec3 o=ro/rd;
  vec3 t=abs(s/rd);
  vec3 fv=-o-t;
  vec3 bv=-o+t;
  float f=max(fv.x,max(fv.y,fv.z));
  float b=min(bv.x,min(bv.y,bv.z));
  if(f<.0||b<f){return vec4(FAR);}
  vec3 N=-sign(rd)*step(fv.zxy,fv)*step(fv.yzx,fv);
  return vec4(N,f);
}

float heck(vec3 p){
  float dice=fs(dot(p,vec3(7,1,-3)));
  return .5*time+.1*dot(p,vec3(1,-1,1))+.1*dice;
}

bool isHole(vec3 p){
  if(dot(p,vec3(1))>1.){return true;}
  
  float h=heck(p);
  float s=floor(h);
  float dens=mix(.4,.8,step(1.,mod(h,2.)));

  float dice=fs(s+dot(p,vec3(5,8,1)));
  return dice>dens;
}

struct QTR {
  vec3 cell;
  vec3 pos;
  float len;
  float size;
  bool hole;
};

QTR qt(vec3 ro,vec3 rd){
  QTR r;
  r.size=1.;
  vec3 dicecell=lofi(ro+rd*1E-2*0.5,0.5)+0.5/2.;
  float dice=dot(dicecell,vec3(1,-3,0));
  float piston=smoothstep(-.5,.5,sin(dice+time));
  vec3 off=vec3(0,0,piston);
  ro+=off;
  
  for(int i=0;i<4;i++){
    r.size/=2.;
    r.cell=lofi(ro+rd*1E-2*r.size,r.size)+r.size/2.;
    
    if(isHole(r.cell)){break;}
    
    float dice=fs(dot(r.cell,vec3(3,4,5)));
    if(dice>r.size+.2){break;}
  }
  vec3 o=(ro-r.cell)/rd;
  vec3 t=abs(r.size/2./rd);
  vec3 bv=-o+t;
  float b=min(bv.x,min(bv.y,bv.z));
  r.len=b;
  
  r.pos=r.cell-off;
  r.hole=isHole(r.cell);
  
  return r;
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  
  time=fGlobalTime;
  seed=texture(texNoise,uv*8.).x*8.;
  seed+=fract(time);

  vec3 col=vec3(0);
  vec3 colRem=vec3(1);
  
  vec3 co=vec3(3,1,1.5);
  vec3 ct=vec3(0,0,0);
  mat3 basis=orthBas(co-ct);
  
  vec3 ro0=co+(basis*vec3(2.*p,0));
  ro0+=orthBas(vec3(1))*vec3(0,-.4*time,0);
  vec3 ro=ro0+basis*vec3(random(),random(),0)/v2Resolution.y*2.;
  vec3 rd0=basis*normalize(vec3(p*.0,-1));
  vec3 rd=rd0;
  
  float samples=1.;
  bool shouldInit=false;
  bool isFirstRay=true;
  
  for(int i=0;i<200;i++){
    if(shouldInit){
      ro=ro0;
      rd=rd0+basis*vec3(random(),random(),0)/v2Resolution.y*2.;
      colRem=vec3(1);
      samples++;
      shouldInit=false;
    }
    
    QTR qtr=qt(ro,rd);
    
    if(!qtr.hole){
      float size=qtr.size/2.;
      size-=.01;
      size=max(0.,size);
      vec4 isect=ibox(ro-qtr.pos,rd,vec3(size));
      if(isect.w<FAR){
        ro+=rd*isect.w;

        vec3 N=isect.xyz;
        
        float h=heck(qtr.cell);
        float sw=step(1.,mod(h,2.));
        
        vec3 m=fs(floor(h)+cross(qtr.cell,vec3(6,8,1)));
        
        float rough=pow(random(),mix(2.,.5,sw)); // cringe
        
        const vec3 ikea0=vec3(.7,.6,.2);
        const vec3 ikea1=vec3(.1,.1,.7);
        
        float fresnel=1.0-abs(dot(rd,N));
        fresnel=pow(fresnel,5.);
        if(random()<fresnel){
          rough=.0;
        }else if(m.x<.2){
          colRem*=.1;
        }else if(m.x<.4){
          colRem*=.5+.5*sin(vec3(0,2,4)+1.*lofi(m.y,.25)+sw);
        }else if(m.x<.5){
          if(sw<.5){
            col+=colRem*2.;
          }else{
            colRem*=.8;
          }
          rough=.1;
        }else{
          colRem*=.8;
        }
        
        rd=mix(
          reflect(rd,N),
          sampleLambert(N),
          rough
        );
        isFirstRay=false;
        
        if(length(colRem)<.1){
          shouldInit=true;
        }
      }
    }
    
    if(isFirstRay){
      ro0=ro;
    }
      
    ro+=rd*qtr.len;
    
    if(length(ro-ro0)>FAR||(dot(ro,vec3(1))>2.&&dot(rd,vec3(1))>0.)){
      float h=heck(ro);
      float sw=step(1.,mod(h,2.));
      col+=colRem*mix(.1,2.,sw);
      float scan=step(.99,sin(.2*ro.y+4.0*time));
      col+=colRem*scan*vec3(10.,.1,.1);
      shouldInit=true;
    }
  }
  
  col=pow(col/samples,vec3(.4545));
  col*=1.0-.3*length(p);
  col=vec3(
    smoothstep(.1,.9,col.x),
    smoothstep(.0,1.0,col.y),
    smoothstep(-.1,1.1,col.z)
  );
  
  col=mix(texture(texPreviousFrame,uv).rgb,col,.5);

	out_color = vec4(col,1);
}