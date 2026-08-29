#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
/*

*/
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 erot(vec3 p,vec3 ax,float t){
    return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);
}
     
float box2(vec2 p, vec2 b){
    vec2 q = abs(p)-b;
    return length(max(vec2(0.),q))+min(0.,max(q.x,q.y));  
}

float box3(vec3 p,vec3 b){
    vec3 q = abs(p)-b;
    return length(max(vec3(0.),q))+min(0.,max(q.x,max(q.y,q.z)));
}
float sdOrientedBox( in vec2 p, in vec2 a, in vec2 b, float th )
{
    float l = length(b-a);
    vec2  d = (b-a)/l;
    vec2  q = (p-(a+b)*0.5);
          q = mat2(d.x,-d.y,d.y,d.x)*q;
          q = abs(q)-vec2(l,th)*0.5;
    return length(max(q,0.0)) + min(max(q.x,q.y),0.0);    
}
float diam(vec3 p,float s){
    p = abs(p);
    return (p.x+p.y+p.z-s)*inversesqrt(3.);
}
float si(vec3 p){
    float h = abs(box2(p.xy,vec2(1.)))-.1;
    h = min(
     min(sdOrientedBox(p.xy,vec2(0.2,0.),vec2(1.,0),.2),
         sdOrientedBox(p.xy,vec2(0.2,0.),vec2(0.2,1),.2))
  ,h);
  h = min(
     
         sdOrientedBox(p.xy,vec2(-0.2,1.),vec2(-0.2+min(p.y,0),-.4),.2)
  ,h);
    h= max(abs(p.z)-.1,h);
    return h;
}
float liu(vec3 p){
     float h = sdOrientedBox(p.xy,vec2(-1.,0.),vec2(1.,0),.2);
     h= min( sdOrientedBox(p.xy,vec2(-0.2,0.5),vec2(.1,.3),.2),h);
     h= min( sdOrientedBox(p.xy,vec2(-0.8,-1.0),vec2(-.2,-.2),.2),h);
     h= min( sdOrientedBox(p.xy,vec2(0.8,-1.0),vec2(.2,-.2),.2),h);
    h= max(abs(p.z)-.1,h);
  return h;
}
vec2 sdf(vec3 p){  
 
    vec3 tp=p,hp=p;
    hp.y -=abs(asin(sin(fGlobalTime)));  
  float gy = dot(sin(p),cos(p.zxy*7));  
    
hp = erot(hp,normalize(vec3(1.,2.,3)),fGlobalTime);
    vec2 h;
    h.x = length(hp)-1.;
    h.x = .7*mix(diam(hp,1.),box3(hp,vec3(1.)),sin(fGlobalTime+gy*.2)*.5-0.2)*.9;
   
     
    
  
    h.y = 1.;
  
    vec2 t;
     tp.y +=1.;
      tp.x +=fGlobalTime;
     tp.xz = asin(sin(tp.xz));
  
   float sc=1.;
    for(float i=0;i<4.;i++){
          tp.x = .5-abs(tp.x);
         tp*=2.5;
         sc*=2.5;
          
      tp = erot(tp,vec3(0,1,0),.785);
      }
     float dd,c=10/3.141592;
     
     tp.xz = vec2(log(dd=length(tp.xz)),atan(tp.x,tp.z))*c;
     tp.y /=dd/=c;
    
    tp.x +=fGlobalTime;
    tp.xz = asin(sin(tp.xz));
  
    tp.y = abs(tp.y)-0.5-abs(gy)*.1;
 
    gy = dot(sin(tp),cos(tp.zxy*7)); 
    t.x=  dd*.8*min(box2(tp.yz,vec2(.01)), box2(tp.xy,vec2(.01)))/sc;
    t.y = 2.;
    h = t.x < h.x ? t:h;
      
      
      
    return h;
}
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.0,.3,.7)));}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 col = vec3(.1,.2,.7)*max(0,1.+uv.y*7.);
	vec3 ro = vec3(0.,1.+sin(fGlobalTime),-5.);
   
  if(mod(fGlobalTime,20) > 10 ) ro = erot(ro,normalize(vec3(0.,1.,0.)),fGlobalTime*.5);
 
  vec3 rt = vec3(0.);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,vec3(0.,-1.,0.)));
  vec3 y = normalize(cross(z,x));
  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.-sin(floor(fGlobalTime*.5)*55)*.8*sqrt(length(uv))));
  vec3 rp = ro;
  vec3 light = vec3(1.,2.,-3);
  float dd = 0.;
  vec3 acc = vec3(0.);
  

  for(float i=0.;i<128.;i++){
      vec2 d = sdf(rp);
      if(d.y == 2.){
        acc += vec3(1.,1.,0.)*.25*exp(i*-abs(d.x))/(60+sin(fGlobalTime*10+rp.y*10)*50);
        d.x = max(.001,abs(d.x));
      }
      rp+=rd*d.x;
      
      dd+=d.x;
      if(dd>50) break;
      if(d.x < .0001){
          vec3 n = norm(rp,.001);
         vec3 n2 = norm(rp,.02+cos(rp.z*10)*.01);
          float dif = max(0.5,dot(normalize(light-rp),n));
          float spc = pow(max(0.,dot(rd,reflect(normalize(light),n))),32.);
          float fres = pow(1. - dot(-rd, n), 5.);
         float ol = step(.1,.3*length(n-n2));
         if(ol ==0){
             rd = reflect(rd,n);
             rp+=rd*.1;
           continue;
           }
          col = pal(fres*2-fGlobalTime*.5+dif)*ol+spc+fres;
          break;
      }

  }  
  
  out_color = vec4(col+acc,1.);
}