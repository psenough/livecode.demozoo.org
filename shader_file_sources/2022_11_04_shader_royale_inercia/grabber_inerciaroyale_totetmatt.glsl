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
// HELLO INERCIAAAAAAA
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float rnd = 0.;
float bpm = texture(texFFTIntegrated,.3).r;
float box3(vec3 p,vec3 b){
    p = abs(p)-b;
    return length(max(vec3(0.),p))+min(0.,max(p.x,max(p.y,p.z)));
}
float box2(vec2 p,vec2 b){
    p = abs(p)-b;
    return length(max(vec2(0.),p))+min(0.,max(p.x,p.y));
}
vec2 sdf(vec3 p){
  vec3 op = p;
  vec2 h;
   p.x +=fGlobalTime;
 
  vec3 hp = p;
  hp.y -=2.;
   float d = 0.;
  for(float i=0.2;i<25;hp=erot(hp,vec3(0.,1.,0.),i+=i)){
      
       d += abs(dot(asin(sin(hp*i)),vec3(.4)/i));
       hp=erot(hp,normalize(vec3(.1,.2,.3)),i);
  }    float txt = texture(texFFT,.05+floor(hp.x*10)/100).r;
     h.x = abs(p.y+2)-d*.3-txt;
   
     h.x = max(abs(p.z-7)-7.5,h.x);
     h.y = 1.;
  
     vec2 t;
    vec3 tp=p;
  
  tp.y +=1.+sin(p.z*.5+bpm+fGlobalTime)*.1;
   float q = sign(p.y);
   tp.xz = fract(tp.xz)-.5;
   tp =erot(tp,vec3(0.,1.,0.),sign(q)*.785);
   tp.y = abs(tp.y)-.05;
  t.x =max(abs(p.z)-5.5, min(length(tp.zy),length(tp.xy))-.01);
  t.y = 2.;
  h= t.x < h.x ? t:h;
  
    tp = p;
   
   tp.y = abs(tp.y)-1.75;
     tp = erot(tp,vec3(1.,0.,0.),bpm+p.x);
    tp = abs(tp)-.2;
 
     t.x = box2(tp.yz,vec2(.05));
     
     t.y = 3.;
  
    h= t.x < h.x ? t:h;
    
    
    
    tp = op;
    for(float j=0.;j<=8;j++){
      vec3 ttp= tp;
      ttp.y +=sin(fGlobalTime+j+rnd*.01);
    ttp.x += tan(bpm+fGlobalTime+j+rnd*.01);
    ttp=erot(ttp,normalize(vec3(.0,.1,.2)),bpm);
     t.x = box3(ttp,vec3(.2));
     t.y = 1+mod(j,3);;
    h= t.x < h.x ? t:h;
       }
    
       
       tp=p;
       tp.y +=1.5;
       t.x = abs(tp.y)-.1;
       t.y = 4;;
      
        h= t.x < h.x ? t:h;
    
  return h;
}

#define q(s) s*sdf(p+s).x

vec3 norm(vec3 p, float ee){vec2 e =vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
vec3 sun(vec2 p){
    float up = max(0.,p.y);
     float d = length(p)-.5;;
     float t = texture(texFFTSmoothed,abs(floor(p.x*100)/100)).r;
     float bar = abs(abs(p.y+cos(p.x*5+fGlobalTime)*.1)-.2-t)-.01;
     d = max(-bar,d);

     float glow = abs(.05/d);
     d = smoothstep(fwidth(d),0.,d);
     vec3 col = mix(vec3(.9,.9,.0),vec3(.9,.0,.9),sqrt(up));
    return col *d * up+glow*up*mix(col,1.-col,sin(atan(p.x,p.y)+fGlobalTime));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3 col = sun(uv);
  float beat = sqrt(texture(texFFT,.3).r);
     rnd = dot(sin(uv*700),cos(uv.yx*500))*.5;
bpm = floor(bpm)+pow(fract(bpm),2.);
   vec3 ro = vec3(0.2+sin(bpm),1.,-2.+sin(fGlobalTime)*2),rt = vec3(0,1.,0);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,vec3(0.,-1.,0.)));
  vec3 y = cross(z,x);
  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.-(.3+floor(sin(bpm+rnd*.05)*5)*.1)*sqrt(length(uv+rnd*.01))));
  vec3 rp = ro;
  vec3 light = vec3(1.,2.,9.);
  float dd =0.;
  vec3 acc = vec3(0.);
  bool ref= false;
  float dir = 1.;
  float IOR = 2.4;
  float i=0;
  for(i=0;i++<108. && dd < 50.;){
      vec2 d = sdf(rp);
    d.x  *=dir;
     if(d.y == 2.){
         
          acc += vec3(.9,.0,.9)*exp(-abs(d.x))/(60.-beat*100+rnd*5);
          d.x = max(.002,abs(d.x));       
      }
        
    dd+=d.x;
      rp+=rd*d.x;
    
      if(d.x < .001){
        
           
           vec3 n = norm(rp,.01);
         vec3 n2 = norm(rp,.03);
           float dif = max(0.,dot(normalize(light-rp),n));
           if(d.y == 3.){
              if(!ref){
                   rd = refract(rp,n,1./IOR);
                   rp+=-n+rd*.1;
                    acc+=dif*.1;
                ref = true;
                dir *=-1.;
              } else {
                
                vec3 _rd = refract(rp,n,IOR);
                if(dot(_rd,rd) ==0){
                   rd = reflect(rp,-n);   
                   rp+=rd*.1;
                } else {
                  rd=_rd;
                  rp+=n+rd*.1;
                   dir *=-1.;
                }
               }
              continue;
             
           } else if(d.y == 4){
             
             rd = reflect(rd,n+rnd*.01);
              rp+=rd*.1;
             col =vec3(.1,.0,.2);
               continue;
             }
           float spc = pow(max(0.,dot(rd,reflect(normalize(light-rp),n))),32.);
           col = dif * vec3(.5)+ mix(vec3(.1),vec3(.3,.0,.9),spc*5)*dif*step(.15,length(n-n2))*texture(texFFT,.3).r*100;
           break;
        }
  }
  if(ref && dd >=50){
    col = sun(rd.xy);
  } 
  col = mix(vec3(.01),col,1.-exp(-i*i));
	out_color = vec4(col+acc,1.);
}