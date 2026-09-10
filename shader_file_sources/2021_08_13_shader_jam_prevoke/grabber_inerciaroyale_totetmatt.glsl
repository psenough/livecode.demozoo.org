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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texTex5;
/*


-- HELLO --



*/
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
vec3 op ;

float baseTT(float t){
    return clamp(abs(sin(t))-.5,0.,.35)*2.;
}
float TT(vec2 t){
     float q = .90;
  for(float i=1.;i<=8.;i++){
       
       q =q + sign(mod(i,1.)-.5)* baseTT(t.y+t.x*i*3.1415+i*2.)/(i*4.);
       t*=rot(-.785);
    }
    return pow(q,2.5);
}
float diam(vec3 p,float s){
    p = abs(p);
   return (p.x+p.y+p.z-s)*inversesqrt(3.);
}
float ring(vec3 p,float size,float lol){
  
    float h = abs(length(p.xy)-(size+lol*.2))-.1;
     return max(abs(p.z)-.1-lol*1.,h);
}
float box(vec3 p,vec3 b){
    vec3 q = abs(p)-b;
    return length(max(vec3(0.),q))+min(0.,max(q.x,max(q.y,q.z)));
}
vec2 sdf(vec3 p){
  
  if(mod(fGlobalTime,20)<=10){
p.z +=fGlobalTime*20;
 p.xz /=7.;
  p.xz = asin(sin(p.xz)*.9);
   p.xz *=7.;
  }
  vec3 wtP=p;
  vec3 ringP = p;
    vec2 h;
  p.xy*=rot(texture(texFFTIntegrated,.6).r);
  p.xz *=rot(texture(texFFTIntegrated,.3).r);
  float lol = TT(+texture(texFFT,abs(p.x*.01)).r*.1+TT(p.zx*.8)/8.+vec2(sin(atan(p.x,p.z)*4.)/4.,p.y))*.5;
  h.x= mix(diam(p,1.+lol), length(p)-(1.+lol),sin(p.y*2.+fGlobalTime*10)*.5+.5);
  h.y = 1.-lol;
  op = p;
  
  
  
  // HELLO FOLKS ::
  // LEARN UTC TIME AT SCHOOL ! IT MIGHT SERVE TO ORGANISE SHADER JAM :D :D :D  
  
  
  
  
  float lim = 7.;
  for(float i=0;i<=lim;i++){
      vec2 t;
    vec3 localRingP = ringP;
    float lolelol = 0.;
      if(i==5.) lolelol = lol;
      localRingP.xz *=rot(texture(texFFTIntegrated,clamp(i/(lim+.1),.0,1.)).r);
      localRingP.yz *=rot(texture(texFFTIntegrated,clamp(i/(lim+.1),.0,1.)).r);
      t.x = ring(localRingP,1.5+i*.3+2.*texture(texFFTSmoothed,.33).r*100,lolelol);
        t.y = 2.+i;
      h = t.x < h.x ? t:h;
     if(h.x ==t.x) op =localRingP;
    }
vec2 t;
    wtP.xz*=rot(fGlobalTime*5.);
    
    wtP.yz*=rot(fGlobalTime*5.);
    t.x =  mix(box(wtP,vec3(20.)),diam(wtP,20.),sin(floor(texture(texFFTIntegrated,.3).r*20))*.75+.5);
    t.x =  box(abs(wtP)-3.5,vec3(.25+lol*2.,.25+lol*3.,.25+lol*2.));
    t.y= 1.;
    
    
    h = t.x < h.x ?t:h;
  return h;
}

#define q(s) s*sdf(p+s).x
vec2 e=vec2(-.003,.003);
vec3 norm(vec3 p){return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.0,.2,.3)));}
vec3 txt(vec2 uv){
    
    int x = int(abs(uv.x)*50.);
    int y = int(abs(uv.y)*50.);
    float z = mix((x^y)/100.,(x|y)/100.,sin(length(uv)+texture(texFFTIntegrated,.3).r)*.5+.5);
    z = sqrt(texture(texFFT,z).r)*5.;
    return pal(z);
}
#define ao(rp,n,k) (sdf(rp+n*k).x/k)
#define AO(rp,n) (ao(rp,n,.1)+ao(rp,n,5.1)+ao(rp,n,10.1))
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

   
  vec3 col =  vec3(.02);
  vec3 ro= vec3(sin(fGlobalTime)*5.,15.,-7.);
  vec3 rt =  mod(fGlobalTime,20)<=10 ? vec3(0.,10.5,0.):vec3(0.,1.5,0.) ;
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,vec3(0.,-1.,0.)));
  vec3 y = normalize(cross(z,x));
  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.));
  vec3 light = vec3(1.,2.,-3.);
  vec3 rp = ro;
  vec3 acc = vec3(0.);
  /*
  
  LETS TRY REFRACTION
  
  */
  float IOR = 1.02;
  bool inside=false;
  for(float i=0;i<=128;i++){
    
      vec2 d = sdf(rp);
      if(inside) d.x = abs(d.x);
      if(mod(d.y,3.) == 0.){
        vec2 tuv= op.xy; // not the TÜV
           tuv *=rot(texture(texFFTIntegrated,.5).r*10);
         acc +=pal(d.y*.1)*exp(4.*-abs(d.x))/(39.+sin(atan(tuv.x,tuv.y)*100)*30.);
        d.x = max(.01,abs(d.x));
      }
       if(d.y <.8 && d.x <.1){
        vec2 tuv= op.xy; // not the TÜV
           tuv *=rot(texture(texFFTIntegrated,.5).r*10);
         acc +=vec3(.5,2.,1.)*exp(-abs(d.x))/(49.+sin(atan(tuv.x,tuv.y)*10)*30.);
        d.x = max(.01,abs(d.x));
      }
    if(length(rp)>100) break;
       if(d.x <=.001){
            vec3 n = norm(rp);
         if(d.y== 7. || d.y == 4.){
           
             n += (fract(TT(op.xz)+TT(op.xy)+TT(op.zy))-.5)*.1 ;
             if(!inside){
               
                rd = refract(rd,n,1./IOR);
                rp -=n*.005;
                inside = true;
              } else {
                  n = -n;
                  vec3 _rd = refract(rd,n,IOR);
                  if(dot(_rd,_rd)==0.){
                    
                      rd = reflect(rd,n);
                      rp +=n*.005;
                   } else{
                       rd =_rd;
                      rp -=n*.005;
                      inside = false;
                   }
              }
             col += sqrt(pal(d.y*.1+.5))*.2;
           } else {
        
         float diff = max(0.,dot(normalize(light-rp),n));
          float sp = max(0.,dot(normalize(ro-rp),reflect(-normalize(light),n)));
         sp = pow(sp,32.);
          float fr = pow(1.+dot(n,rd),8.);
          col =  txt(vec2(atan(op.x,op.z),op.y)*.2)*diff+vec3(1.,.7,.5)*sp;
         col = mix(vec3(.1),col,fr+AO(rp,n)/3.);
         break;
         }
       }
       rp+=rd*d.x;
  }
  col +=acc;
	out_color = vec4(col,1.);
}