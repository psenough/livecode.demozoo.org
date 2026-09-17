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
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
// THIS IS TOTETMATT, IM NOT A BOT
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
  float bpm = texture(texFFTIntegrated,.13).r*2+fGlobalTime;
  vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float txt(vec2 p,float t){
     ivec2 i = ivec2(abs(p)*128.);
      return dot(sin(i),cos(i.yx*t))+(i.x&i.y)/128.;;
  }
  float rand(vec2 p){
       return fract(535.55*sin(dot(p,vec2(85.5,479.5))));
    }
  vec3 path(vec3 p){
    
     vec3 o = vec3(0.);
       o.x +=sin(p.z*.1)*2.;
       o.x +=sin(p.z*.55)*.44;
       o.y +=sin(p.z*.33)*.44;
       o.y +=cos(p.z*.24)*.5;
      return o;
    }
    float terr(vec3 p){
        float d=0.;
         for(float i=.5;i<5;i+=i){
           
              d+= dot(asin(sin(erot(p*i,vec3(0.,1.,0),i))),vec3(.5))/i/4.;
           }
           
           return d;
      
      }
vec2 sdf(vec3 p){
     vec2 h;
     vec3 hp=p;
  
     vec3 ph= path(hp);
  
     float ff = 1-tanh(abs(hp.x-ph.x)-1.);
     h.x  = dot(hp,vec3(0.,1.,0.))+1.+ff+terr(hp)+texture(texFFTSmoothed,.3+ff*.01).r*50;;
     h.y= 1.;
  
     vec2 t;
     vec3 tp=p;
     
      tp-=ph;  
      tp.y +=1.;
   float gy = dot(sin(tp*1.5),cos(tp.zxy));
    tp+=gy*.1;
     tp= erot(tp,vec3(0,0,1),tp.z);
  tp.xy= abs(tp.xy)-.2;tp.xy=abs(tp.xy)-.1;
     t.x =  max(abs(tp.z-bpm)-5,length(tp.xy)-.02);
     t.y = 2.;
     h=t.x < h.x ? t:h;
     return h;
  
  }
  #define q(s) s*sdf(p+s).x
  
  vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
   bpm+=+rand(uv)*.1;
  bpm = floor(bpm) + pow(fract(bpm),2.1);
vec3 col = vec3(0.);
    col.r= texture(texRevisionBW,clamp(uv+.5+texture(texFFTSmoothed,floor(bpm)*.1+txt(uv,1.)).r,0.,1.)).r;
     col.gb= texture(texRevisionBW,clamp(uv+.5+texture(texFFTSmoothed,floor(bpm)*.1+txt(uv,2.)).r,0.,1.)).gb;
   
  vec3 ro=vec3(1.,1.,bpm+cos(bpm)),rt=vec3(0.,0.,bpm+tanh(sin(bpm*.25))*15);
  ro+=path(ro);
  rt+=path(rt);
  vec3 z=normalize(rt-ro),x=normalize(cross(z,vec3(0.,-1.,0))),y=cross(z,x);  
  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.+sin(bpm)*.1));
  
  vec3 rp= ro;
   vec3 acc= vec3(0.);
  // AZERTY FOR THE WIN
   float dd =0.;
  vec3 light = normalize(vec3(1.,2.,-3.));
  for(float i=0.;i++<128. && dd < 50.;){
    
      vec2 d = sdf(rp);
    
       if(d.y ==2.){
          acc+=vec3(.0,.3,.7)*exp(-abs(d.x))/(50-min(45,texture(texFFTSmoothed,.3+bpm+rp.z*.01).r*5000));
          d.x = max(.001,abs(d.x));
         }
      rp+=rd*d.x;
      dd+=d.x;
       if(d.x < .001){
          vec3 n = norm(rp,.005);
         vec3 n2 = norm(rp,.007);
           float dif = max(0.,dot(light,n));
            float fr= pow(1+dot(rd,n),4);
             col = +dif * vec3(.1);
             if(d.y==1.){
                  col  += smoothstep(.001,.1,length(n-n2))+fr*vec3(1.,.7,.3)*max(0,1-abs(rp.z-bpm-5)*.2);
                  rd= reflect(rd,n);
                  rp+=rd*.1;
                  continue;
               
               }
             break;
         
         }
    }
    col = mix(col,vec3(.1),(.5)-exp(-dd));
  
	out_color = vec4(sqrt(col+acc),1.)
  ;
}