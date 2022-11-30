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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

/**

HELLO FIELDFX, HAPPY NEW YEAR !!!!



Thanks a lot, love to everybody !!!
*/

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
float hex(vec2 p,float s){
    p = abs(p);
    return max(p.x*.866026+p.y*.5,p.y)-s;
}
float tunnel(vec3 p){
    p.z +=fGlobalTime;
    p.xy*=rot(asin(sin(p.z))*.1+p.z*.1);
    return -hex(p.xy,3);
}
// From art of code, bT_Td 
float hexdist(vec2 uv){
  uv = abs(uv);
  float c = dot(uv,normalize(vec2(1,1.73)));
  c = max(c,uv.x);
  return c;
}
vec4 hexcoords(vec2 uv){
    vec2 r = vec2(1,1.73);
    vec2 h = r*.5;
    vec2 a = mod(uv,r)-h;
   vec2 b = mod(uv-h,r)-h;
   vec2 gv = dot(a,a) < dot(b,b) ? a:b;
   float x = atan(gv.x,gv.y);
  float y=  .5*hexdist(gv);
   vec2 id = uv-gv;
   return vec4(x,y,id.x,id.y);
}
float grid(vec3 p){
   vec4 hexgrid = hexcoords((p.xy*rot(p.z*.1))*.5);
    hexgrid.xy/=.5;
    float tt = texture(texFFTIntegrated,.3).r;
     return max(abs(asin(sin(p.z+tt*5)))-.1,-(hexgrid.y-.23/.5));
 }
 
 /*
 It's a jam so I prepared this, sorry not sorry :D 
 
 
 */
 float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}
float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
 float lm_eye(vec2 uv){
uv.y +=.06;
  uv.x =abs(uv.x)-.4;
  float d = length(uv)-.2;
  float e = length(uv+vec2(.0,.1))-.19;
  return max(d,-e);
}

float lm(vec2 uv){
   float a= length(uv)-1.;
   float b= length(uv)-.9;

   float e = sdRoundedBox(uv,vec2(1.5,.2),vec4(.05));
 
   float eye = lm_eye(uv);
   float cap = sdRoundedBox(uv-vec2(1.1,0),vec2(.5,.25),vec4(.2));
   float ccap= sdRoundedBox(uv-vec2(1.1,0),vec2(.4,.15),vec4(.2));
   float hat = sdBox(uv-vec2(0.,1.),vec2(.1,.05));
   cap = max(-uv.x+.87,max(cap,-ccap));
   float bb =  sdBox(uv-vec2(.0,.2),vec2(.975,.05));
   uv +=vec2(0.,.2);
   float m = max(uv.y,length(uv)-.5+texture(texFFT,.33).r*2);
    uv +=vec2(0.,.05);
   float mm = max(uv.y,length(uv)-.4);
    m = abs(m)-.03;
   return min(bb,min(hat,min(cap,min(m,min(eye,max(-e,max(a,-b)))))));
}

float laughingman(vec3 p){
  
    return max(abs(p.z)-.2,lm(p.xy));
 }
vec2 sdf(vec3 p){
    vec2 h;
    h.x = tunnel(p);
    h.y = 1.;
  
   vec2 t ;
  t.x  = max(-h.x,grid(p));
  t.y = 2;;
  h = t.x < h.x  ?t:h;
    
  t.x = laughingman(p);
  t.y =3.;
    h = t.x < h.x  ?t:h;
  
  t.x = max(abs(p.z)-.1,length(p.xy)-1.7);
   t.x = max(t.x,-max(abs(p.z)-.5,length(p.xy)-1));
  t.y =4.;
    h = t.x < h.x  ?t:h;
    return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.2,.4,.6)));}
float txt(vec2 uv){
   
    float tt = texture(texFFTIntegrated,.5).r;
   uv *=rot(floor(tt*10)*.1);
    ivec2 uuv = ivec2(abs(uv)*128);
    float q = uuv.x | uuv.y;
    float t = uuv.x ^ uuv.y;
    float r = texture(texFFT,q/128+texture(texFFTIntegrated,t/128).r*.1).r;
    return r;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float ttt1= texture(texFFTIntegrated,.3).r*2.;
   float ttt2= texture(texFFTIntegrated,.7).r*2.;
 vec3 col = sqrt(pal(fract(fGlobalTime)+txt(uv))*txt(uv));
  vec3 ro = vec3(0.,.5,-5.)+1e-5;
  ro.xy +=vec2(sin(ttt1),cos(ttt2))*.5;
  vec3 rt = vec3(0.)+1e-5;
   rt.yx +=vec2(sin(ttt1*.3),cos(ttt2*.6));
  vec3 z = normalize(rt-ro);
   vec3 x = normalize(cross(z,vec3(0.,-1.,0.)));
  vec3 y = normalize(cross(z,x));
  // Yes I followed Seminar from 0b5vr
  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.-asin(sin(-fGlobalTime))*length(uv)));
  
  vec3 rp = ro;
  vec3 light = vec3(1.,2.,-3.);
  float dd = 0;
  float s  = 1.;
  vec3 acc = vec3(0.);
  for(float i=0;i<=128.;i++){
      vec2 d = sdf(rp); 
      d.x *=s;
      dd +=d.x;
     if(d.y==4.){
             
              acc +=vec3(.1)*exp(-abs(d.x))/(60*sin(10*fGlobalTime+atan(rp.x,rp.y)*5.1)+65.);
              d.x = max(.001,abs(d.x));
             }
      if(dd>50) break;
      rp +=rd*d.x;
      if(d.x <.0001){
          vec3 n = norm(rp,.001);
          float dif = max(0.,dot(normalize(light-rp),n));
          float fr = pow(max(0.,1-dot(-rd,n)),4.);
          // ONE day 'ill learn it by heart float spc = pow(max(0.,dot(normalize(rp),reflect(normalize(light),n))),32);
        vec3 nn = norm(rp,.01);  
        if(d.y ==1.){
          col = (1.-dot(n,nn))*pal(rp.z)+vec3(.01)*dif+fr*vec3(.01,.02,.03);
          } else if(d.y==2.) {
            
            float h = step(.01,length(nn-n));
             if(h==0){
                 
                 if(s==1) rd = refract(rd,n,2.5);
               s*=-1.;
                   
               rp+=rd*.01;
                 continue;
               }
             col =min(1.,002*exp(5*-rp.z))*h*sqrt(pal(rp.z*.02+fract(fGlobalTime)+txt(uv))*txt(uv));
             col = sqrt(col);
             break;
          } else if(d.y==3){
            
              acc+= vec3(.1,.3,.5)*dif; 
               rd = reflect(rd,n);
               rp+=rd*.01;
               continue;
          } 
           break;
        
      }
  }
  col +=acc;
	out_color = vec4(sqrt(col),1.);
}