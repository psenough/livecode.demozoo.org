#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texLcdz;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float rand(vec2 p){ return fract(535.69*sin(dot(p,vec2(252.3,658.6))));}
float sdOrientedBox( in vec2 p, in vec2 a, in vec2 b, float th )
{
    float l = length(b-a);
    vec2  d = (b-a)/l;
    vec2  q = (p-(a+b)*0.5);
          q = mat2(d.x,-d.y,d.y,d.x)*q;
          q = abs(q)-vec2(l,th)*0.5;
    return length(max(q,0.0)) + min(max(q.x,q.y),0.0);    
}
vec3 erot(vec3 p,vec3 ax,float t){
   return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);
  }
float box(vec3 p,vec3 b){
   p=abs(p)-b;
    return length(max(p,vec3(0)))+min(0.,max(p.x,max(p.y,p.z)));
  }
float jp_se(vec3 p){
    p.x+=.5;
    float h=sdOrientedBox(p.xy,vec2(-0,1.5),vec2(0.,-1.5),.5);
    h=min(h,sdOrientedBox(p.xy,vec2(0,-1.5),vec2(1.75,-1.5),.5));
    h=min(h,sdOrientedBox(p.xy,vec2(-.5,0.5),vec2(1.75,.75),.5));
    h=min(h,sdOrientedBox(p.xy,vec2(1.0,0.0),vec2(1.75,.75),.5));
    return max(abs(p.z)-.1,h);
}
float jp_s(vec3 p){
   
   float h=sdOrientedBox(p.xy,vec2(-.5,-1.0),vec2(.5,.0),.25);
       h=min(h,sdOrientedBox(p.xy,vec2(-.5,-0.2),vec2(-.90,.15),.25));
      h=min(h,sdOrientedBox(p.xy,vec2(-.25,-0.0),vec2(-.60,.35),.25));
    return max(abs(p.z)-.1,h);
  }
  float jp_si(vec3 p){
   
   float h=sdOrientedBox(p.xy,vec2(-1.0,-1.0),vec2(1.0,.0),.5);
       h=min(h,sdOrientedBox(p.xy,vec2(-.5,-0.2),vec2(-1.40,.15),.5));
      h=min(h,sdOrientedBox(p.xy,vec2(.25,0.2),vec2(-0.50,.55),.5));
    return max(abs(p.z)-.1,h);
  }
  float jp_o(vec3 p){
   p.x -=.5;
   float h=sdOrientedBox(p.xy,vec2(-0.0,-1.0),vec2(0.0,1.0),.5);
     h=min(h,sdOrientedBox(p.xy,vec2(-1.5,1.0),vec2(0.25,1.0),.5));
    h=min(h,sdOrientedBox(p.xy,vec2(-1.5,0.0),vec2(0.25,0.0),.5));
    h=min(h,sdOrientedBox(p.xy,vec2(-1.5,-1.0),vec2(0.25,-1.0),.5));
    return max(abs(p.z)-.1,h);
  }
    float jp_n(vec3 p){

   float h=sdOrientedBox(p.xy,vec2(-1.0,-1.0),vec2(1.0,.25),.5);
      h=min(h,sdOrientedBox(p.xy,vec2(.2,0.5),vec2(-1.00,.95),.5));
    return max(abs(p.z)-.1,h);
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
      float zz = (1.+sin(floor(texture(texFFTIntegrated,.13).r*10))*texture(texFFTSmoothed,.3).r*50);
    float bpm = texture(texFFTIntegrated,.13).r;
  bpm =floor(bpm) + pow(fract(bpm),.7);
   if(abs(uv.y)>.3+.05*dot(sin(uv*05+bpm),cos(70*uv.yx))){
          uv*=2.;
   }
 

  vec3 col = vec3(0.);
  vec3 p,d=normalize(vec3(uv,1.-(.8-zz+rand(uv)*.1)*sqrt(length(uv))));
  for(float i=0.,e=0.,g=0.;i++<99.;){
    
    
       p=d*g;
      
       
       float bar = mod(fGlobalTime*2,6.);
       p.z-=5.;
       
     p= erot(p,normalize(vec3(.1,1.,-.2)),bpm*5);
       vec3 op=p;
      
       vec2 h;
       vec3 hp=p;
      float rr= +rand(uv)*.1;
    float gy = abs(dot(sin(p*5),cos(p*7))*.1);
      float fade = tanh(pow(fract(bar)+gy,20.2))+rr;
    
     hp.x +=bpm*5;
      float idd=floor(hp.x);
     hp.x = fract(hp.x)-.5;
       bar+=mod(idd,6);
       hp.xy*=2.;
       if(bar<=1.){
        h.x =  mix(jp_se(hp),jp_s(hp),fade); 
       } else if(bar<=2.){
         h.x =mix(jp_s(hp),jp_si(hp),fade); 
         
         }else if(bar<=3.){
         h.x =  mix(jp_si(hp),jp_o(hp),fade); 
         
         }else if(bar<=4.){
         h.x =  mix(jp_o(hp),jp_n(hp),fade); 
         
         }else if(bar<=5.){
         h.x =   jp_n(hp);
         
         } else {
           h.x = 100.;
           }
       h.x = h.x;
       h.y = 1.;
       p.z+=bpm;
       vec2 t;
       vec3 tp=p;
       tp.y =-(abs(tp.y)-2.+.5*dot(asin(sin(tp)),asin(cos(tp.zxy*5+bpm)))+texture(texRevisionBW,clamp(op.xz*.125+.5,0,1)).r);
       t.x = dot(tp,vec3(0.,1.,0.))+1+texture(texRevisionBW,clamp(op.xz*.125+.5,0,1)).r;
       t.y = 2.; 
       h=t.x < h.x ? t:h;
           
           tp=p;
           tp=mod(tp,4.)-2.;
           t.x = min(length(tp.zx)+.05,min(length(tp.xy),length(tp.zy)))-.1-texture(texFFTSmoothed,tp.z).r;
           t.y=2.;
              h=t.x < h.x ? t:h;      
          g+=e=max(.001,h.x);
          vec2 tt= vec2(log(length(tp.xz)),atan(tp.x,tp.z));
          col += erot(vec3(.5+tan(bpm),.5+.5*cos(bpm),.5),normalize(vec3(.5,.7,2)),bpm+rand(tp.xy))*(h.y==1. ? vec3(.9,.9,.9)*(1.75+sin(bpm+hp.y*20)):vec3(.5))*.055/exp((.76+.25*sin(op.z*.5+bpm*5))*i*i*e);
        
    }
   if(fract(bpm*5)>.9){
       col = 1-col;
     }
  out_color = vec4(sqrt(col),1.);;
}