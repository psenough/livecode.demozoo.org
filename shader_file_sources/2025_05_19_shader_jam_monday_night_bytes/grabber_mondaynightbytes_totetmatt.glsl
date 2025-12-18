#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fBeat;
uniform float rColor;
uniform float gColor;
uniform float bColor;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float bpm = 125*fGlobalTime/60;

vec3 ro,rt,rd,rp,rs,x,y,z;
mat3 o;
float speed = bpm;
vec3 hp;
vec3 hash3d(vec3 p){
     uvec3 q = floatBitsToUint(p);
     
     q = ((q>>16u)^q.yzx)*1111111111u;
     q = ((q>>16u)^q.yzx)*1111111111u;
  q = ((q>>16u)^q.yzx)*1111111111u;
    return vec3(q)/float(-1U);
  }
struct GS {vec3 hash,cell,size;};
struct Grid{GS sub;float d;};
Grid grid;
#define gsub grid.sub
void dosub(vec3 p){
     gsub.size =vec3(.5);
     for(int i=0;i<5;i++){
        gsub.cell = (floor(p/gsub.size)+.5)*gsub.size;
        gsub.cell.y =0;
        gsub.hash = hash3d(gsub.cell);
        if(i==4||gsub.hash.x < .5) break;
        gsub.size *=.5;
     }
  }
void dogrid(vec3 ro,vec3 rd){
     dosub(ro+rd*.001);
     vec3 src= -(ro-gsub.cell)/rd;
     src+= abs(.5*gsub.size/rd);
     grid.d = min(src.x,min(src.z,src.z));
  }
  
vec3 stepNoise(float x,float n){
    float u = smoothstep(.5-n,.5+n,fract(x));
    return mix(hash3d(vec3(floor(x),-1U,11111)),hash3d(vec3(floor(x+1),-1U,11111)),u);
}
vec3 path(vec3 p){
  
    vec3 o=vec3(0.);
    o.x += sin(p.z*.1);
      o.y += cos(p.z*.1)*2;
    o.y += sin(p.z*.5)*.2;
  o.x += cos(p.z*.2)*.5;
  o.xy  += (stepNoise(p.z*.15,.3).xy-.5);
  o += cross(sin(p*.3),cos(p*.4))*.1;
   return o;
  }
float sdChamferBox(vec2 p, vec2 b, float chamfer)
{
    p = abs(p) - b;

    p = (p.y>p.x) ? p.yx : p.xy;
    p.y += chamfer;
    
    const float k = 1.0-sqrt(2.0);
    if( p.y<0.0 && p.y+p.x*k<0.0 )
        return p.x;
    
    if( p.x<p.y )
        return (p.x+p.y)*sqrt(0.5);    
    
    return length(p);
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0),p))+min(0.,max(p.x,max(p.y,p.z)));}
vec2 sdf(vec3 p){
    vec2 h;
    hp=p;
    vec3 off = path(p);
    hp+=off;
    float track;
    h.x = track=sdChamferBox(hp.xy,vec2(1.,.5),.3);
    h.x = max(hp.y,abs(h.x)-.1);
    h.y = 1.;
  
   vec3 tp=p;
   vec2 t;
  t.x = dot(tp,vec3(0,1,0))-texture(texNoise,p.xz*.01).x*5;
  t.x = max(-(abs(p.x)-2.1),t.x);
  t.y =0;
   h=t.x <h.x ? t:h;
  
  tp=p;
  tp+=off;
  tp.y+=.1;
  tp.z -=speed;
  tp = erot(tp,normalize(vec3(0,.0,1)),sin(off.x));
  tp.x = abs(tp.x)-.125;
  tp = erot(tp,normalize(vec3(0,.1,1)),.785);
   t.x = box(tp,vec3(.25,.015,.65));
   
   
   
  t.y=-0;
   h=t.x <h.x ? t:h;
  
  
  //tp=p+off;
tp+= (cross(sin(hp*7),cos(hp.yzx*5))*mix(.01,.1,tp.z/2));


   t.x =max(tp.z,length(tp.xy)-.02+mix(.01,.03,tp.z/2));
   
   
   
  t.y=10;
   h=t.x <h.x ? t:h;
  tp=p-gsub.cell;
   t.x = box(tp,vec3(.49,100.49*gsub.hash.y*sqrt(texture(texFFTSmoothed,gsub.hash.x).r),.49)*gsub.size);
    t.x = max(-(abs(p.x)-2.1),t.x);
  t.y=-1;
   h=t.x <h.x ? t:h;
  
  return h;
}

#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3 col = vec3(0.);

vec3 rnd = hash3d(vec3(gl_FragCoord.xy,bpm));
    vec3 trnd  = stepNoise(bpm*.125,.1+(rnd.x-.5)*.1);
  speed*=2.;
  ro=vec3(0.,0.1,-.5-trnd.x),rt=vec3(0);
  ro.z += speed;
  ro-=path(ro);
  rt.z += speed;
    rt-=path(rt);
  z=normalize(rt-ro),x=vec3(z.z,0.,-z.x);
  rd = (o=mat3(x,cross(z,x),z))*normalize(rs=vec3(uv,.5-mix(.4,.1,trnd.x+rnd.y*.03)));
  rp=ro;
  vec3 light = vec3(1.,2.,-3.)+ro;
  vec3 acc=vec3(0.);
  vec2 d;
  float rl=0.,i=0., glen = 0.;
  for(float i=0.;i++<200.;){
        if(glen<=rl){
          dogrid(rp,rd);
          glen+=grid.d;
          }
        d =sdf(rp);
          if(d.y ==10){
            
             acc+=vec3(.1,.2,.3)*exp(-abs(d.x))/(10-9*exp(-3*fract(rp.z*.1)));
             d.x = max(.001,abs(d.x));
            }
        if(d.x<.001) break;
        rl=min(rl+d.x,glen);
        rp=ro+rd*rl;
  }
  if(d.x<.001) {
    
      vec3 n= norm(rp,.001);
      vec3 ld = normalize(light-rp);
      float dif = max(0.,dot(ld,n));
      float spc = pow(max(0,dot(reflect(ld,n),rd)),32);
      float fre = pow(1+dot(rd,n),4);
       if(d.y ==1){
         col = mix(vec3(.5+.25*mod(floor(hp.x*5)+floor(hp.z*5),2))*dif+spc,col,fre);
          if(mod(floor(hp.z /4),8)==0){
            col = .1/col;
           }
       } else if(d.y==0){
         
          col = mix(vec3(.1)*dif+spc,col,fre);
        
         } else {
           
             col = mix(vec3(exp(-5*fract(gsub.hash.z+bpm)))*dif+spc,col,fre);
           }
       
    }
    col = mix(col,vec3(.01),1-exp(-.001*rl*rl*rl));
    col = sqrt(col+acc);
    col = mix(col,fwidth(sqrt(col)*10)*vec3(.9,.3,.1),trnd.z+uv.y);
    //col = mix(col,cross(col,fract(rp.yzx)),exp(-6*fract(bpm+rp.y*.01)));
	out_color = vec4(col,1.);
}