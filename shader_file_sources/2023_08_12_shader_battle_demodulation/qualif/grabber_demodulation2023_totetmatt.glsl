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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 pal(float t){return .5+.5*cos(6.28*(t+vec3(0,.3,.7)));}
float diam2(vec2 p,float s){p=abs(p);return (p.x+p.y-s)*inversesqrt(3.);}
float timer ;
float bpm = texture(texFFTIntegrated,.3).r*3;
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float tru(vec3 p){
  
     vec3 id = floor(p)+.5;
     vec3 gv = p-id;
      gv.x  *= fract(452.6*sin(dot(id,vec3(452.5,985.5,487.56)))) > .5 ? -1:1 ;
    gv.xz-=.5 * (gv.x >-gv.z ? 1:-1);
      return max(abs(gv.y)-.05,abs(diam2(gv.xz,.5)*4)-.05);
  }
 vec3 path(float t){
   
     vec3 o=vec3(0);
     o.x+=asin(sin(t*.45))*.5;
    o.x+=asin(cos(t*.75))*.45;
    o.y+=asin(cos(t*.95))*.33;
    o.y+=asin(sin(t*.35))*.44;
   return o;
   }
vec2 sdf(vec3 p){
   vec2 h;
   vec3 hp=p;
  hp.z -=timer;
   hp+=path(floor((hp.z*.025+.5))+timer);
   h.x = length(hp)-1.-.2*mix(0,dot(sin(hp+fGlobalTime),cos(hp.zxy*5)),tanh(sin(bpm+fGlobalTime)*10)*.5+.5);;
  h.y =1.;
  
    vec2 t;
    vec3 tp=p;
    tp+=path(tp.z);
     tp/=4.;
    t.x = min(tru(tp.zxy),min(tru(tp),tru(tp.yzx)));
    t.y= 2.;
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
  float rnd = ((floatBitsToInt(uv.x)*floatBitsToInt(gl_FragCoord.y)) ^ (floatBitsToInt(uv.y)*floatBitsToInt(gl_FragCoord.x)))/2.19e9;
  bpm+=+rnd*.1;
  bpm = floor(bpm)+smoothstep(.0,1.,pow(fract(bpm),.4));  timer +=fGlobalTime+bpm;
vec3 col = vec3(0.);
   vec2 puv = uv* gl_FragCoord.x / v2Resolution.x;
    puv +=.5;
    float q = texelFetch(texFFTSmoothed,int(puv.x*50),0).r;
  float st ;
  col+=sqrt((st=step(-(abs(uv.y)-.5),sqrt(q)))*sqrt(q));
    if(st>.00) uv*=(1+sqrt(q)*5);
    vec3 ro=vec3(0,0,-5),rt=vec3(0);
  ro = erot(ro,vec3(0.,1.,0),bpm*.1);
  ro.z +=timer-tanh(cos(bpm)*5);
   
  ro+=path(ro.z)*2;
  rt.z+=timer;
   rt+=path(ro.z);
    vec3 z=normalize(rt-ro),x=normalize(cross(z,vec3(0.,-1.,0))),y=cross(z,x);
    vec3 rd=mat3(x,y,z)*normalize(vec3(uv,1.+.5*tanh(sin(bpm)*5)));
    vec3 rp=ro;
    vec3 light = vec3(1.,2,-3+timer);
  vec3 acc=vec3(0.);
    for(float i=0;i++<128;){
      
         vec2 d = sdf(rp);
         if(d.y==2.){
              acc+=vec3(.03,.04,.05)*exp(10*-abs(d.x))/(20-19*exp(-3*fract(fGlobalTime+rp.z)));
              d.x = max(.001,abs(d.x));
              
           }
         rp+=rd*d.x;
         if(d.x <  .001){
           
             vec3 n = norm(rp,.001);
             vec3 nl=  normalize(light-rp);
              float dif = max(0.,dot(nl,n));
              float spc = pow(max(0,dot(rd,reflect(nl,n))),16); 
             col = vec3(.75)*dif + spc;
           
           if(d.y==1){
               col=col*(col);
               rd= reflect(rd,n);
               rp+=rd*.1;
              continue;
             }
             break;
           }
      }
  
  
	out_color = vec4(sqrt(col+acc),1.);
}