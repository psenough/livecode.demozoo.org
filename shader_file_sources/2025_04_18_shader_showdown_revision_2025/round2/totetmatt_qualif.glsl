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
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
// I'm still not a bot
// Party Party , Koreda!
// Greets to all livecoders

vec3 ro,rt,rp,rd,rs,x,z;
mat3 o;
float bpm = fGlobalTime*140/60;

vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 hash3d(vec3 p){
    uvec3 q = floatBitsToUint(p);
    q = ((q>>16u)^q.yzx)*1111111111u;
    q = ((q>>16u)^q.yzx)*1111111111u;
    q = ((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
  }
  vec3 stepNoise(float x,float n){
       float u = smoothstep(.5-n,.5+n,fract(x));
        return mix(hash3d(vec3(floor(x),-1U,1)),hash3d(vec3(floor(x+1),-1U,1)),u);
       
    }
    float txt(vec2 uv){uv=clamp(uv/14,-.5,.5)-.5;return texture(texRevisionBW,uv).r;}
 float box(vec3 p, vec3 b){p =abs(p)-b;return min(0,max(p.x,max(p.y,p.z)));}
  vec2 tr(vec3 p){
      p/=6.;
      p.y+=.3;
      vec2 h,t;h.x =100;
      for(float i=0.,sc=1.,s=1.;i++<10;){ // 10 = 1+9*float(fGlobalTime>20*60)
            sc/=s=dot(p,p);
            p/=s+.01;
             p.xz = abs(erot(p,vec3(0,1,0),i+.2*sin(bpm/2)).xz)-.57 + mix(-.03,.03,stepNoise(bpm+length(p),.3).x);
            p.y = 1.73 - p.y;
            t.y = i;
            t.x = max(length(p.xz)-.03/s,p.y)/sc;
           h= t.x <h.x ? t:h;
        }
        return h;
    
    }
    
  vec2 sdf(vec3 p){
    
     vec3 hp=p;
     hp.y-=8.;
      vec2 h;
h.y = 0.;
    float ttt = txt(hp.xz);
 h.x = abs(box(hp,vec3(10,10+ttt*.1*texture(texFFTSmoothed,.3).r,10)))-1.;

  vec2 t = tr(p);
   return t.x <h.x ? t:h;    
  }

  #define q(s) s*sdf(p+s).x
  vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
  
  void add(vec2 p,vec3 c){
       for(int i=0;i<3;i++){imageAtomicAdd(computeTex[i],ivec2(p),int(c[i]*1e6));}
    }
    
    vec3 get(vec2 p){
        vec3 o=vec3(0.);
        for(int i=0;i<3;i++){o[i]+=imageLoad(computeTexBack[i],ivec2(p)).x;}  
      return o/1e6;
      }
      
   vec2 toBuf(vec3 p){
        p= inverse(o)*p;
        float prj = rs.z /(length(ro)+p.z);
        p-=rt;
       return p.xy*prj*v2Resolution.y+.5*v2Resolution.xy;
     }
   void line(vec2 a,vec2 b,vec3 c){
       for(float i=0.;i++<100;){
               add(mix(a,b,i/100),c);
         }
     }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3 col = vec3(0);
   ivec2 k = ivec2(abs(uv*128));
   col += texture(texFFTSmoothed,(k.x|k.y)/128.).r;
  
    vec3 rnd = stepNoise(bpm/1,.3+hash3d(uv.xyy+bpm).x*.1);
   ro= vec3(0,mix(-1,5,rnd.y),mix(5,8,rnd.z)),rt=vec3(0.);
    ro = erot(ro,vec3(0,1,0),rnd.x*6.28); 
  z= normalize(rt-ro),x=vec3(z.z,0.,-z.x);
   rd = (o=mat3(x,cross(z,x),z))*normalize(rs=vec3(uv,.5));
   rp=ro;
   vec3 light = vec3(1.,2,-3.),acc=vec3(0.);
    float rl=0,i=0.;
  vec2 d;
  
    vec3 px = hash3d(vec3(gl_FragCoord.xy,bpm))-.5;
    float gs= 25,gr=10;
  
     px = (floor(px*gs)+.5)*gr/gs;
     
     if(tr(px).x<.05){
       
           vec3 nx = px+vec3(1,0,0);
       
           vec3 ny = px+vec3(0,1,0);
       
           vec3 nz = px+vec3(0,0,1);
       
       
           vec2 buf = toBuf(px);
         if(abs(tr(nx).x)<.05) line(buf,toBuf(nx),vec3(.9,.3,.1)*.05);;
                if(abs(tr(ny).x)<.05) line(buf,toBuf(ny),vec3(.9,.3,.1)*.05);;
                if(abs(tr(nz).x)<.05) line(buf,toBuf(nz),vec3(.9,.3,.1)*.05);;
       }
   for(float st=0.;st++<3.;){
     
        for(;i++<200;){
          
            d = sdf(rp);
            if(d.y > 5){
               acc+=vec3(1.,.1,.5)*exp(-abs(d.x)*30)/(150-149*exp(-fract(bpm+rl)));
               d.x = max(.001,abs(d.x));
              }
            if(d.x<.001) break;
           rl+=d.x;
     rp=ro+rd*rl;              
          }
          
                vec3 n= norm(rp,.001);
                vec3 ld = normalize(light-rp);
                float dif = max(.05,dot(ld,n));
           if(d.y ==0){
                rl=0.;
                rp=ro=rp+n*.01;
                col += vec3(.1,.2,.3);
                  float rev = txt(rp.xz);
              col+=rev;
                 col*=dif;
             rd=reflect(rd,normalize(n+mix(.01,.03,rev)*hash3d(rp+bpm).x)); 
                 
             continue;
             }
           if(d.x<.001){
             
                float spc = pow(max(0,dot(reflect(ld,n),rd)),32);
                 float fre = pow(1+dot(rd,n),4);
             
               col += mix(vec3(.3,.2,.1)*dif+spc,col,fre)/st;
             }
     }
     col = sqrt(col+acc);
    vec3 gg= get(gl_FragCoord.xy)*(2e5/(v2Resolution.y*v2Resolution.x));  
	
        col = mix(col-gg,dFdx(gg)*vec3(-1,1,1)+length(col)*.1+gg,step(.5,fract(uv.y*.1+bpm*.1+hash3d(uv.yyy).x*.1)));
      // WARNING FLASH
      col = mix(col,1-col,exp(-3*fract(bpm/2)));
     out_color = vec4(col,1);
}


// HOMMAGE TO BROSKIIIIIII
// HOMMAGE TO ALKAMA
// GREETS 0b5vr, Zozuar, Xor, Nusan, Flopine and all Shader coder around the world !!!!!!!