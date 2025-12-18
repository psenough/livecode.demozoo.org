#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
// I'm still NOt a bot 
// Party Party ! KORE DA !
layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float bpm = 174/60*fGlobalTime;
float frw = bpm *4.;

vec3 erot(vec3 p,vec3 ax,float t){
  return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);
  }
float txt(vec2 p){
  
  float t=  floor(bpm)+smoothstep(.1,.9,fract(bpm));
   p = erot(p.xyy,vec3(0.,0.,1),t*(step(.3,length(p))-.5)).xy;
  return texture(texRevisionBW,clamp(p*vec2(1.,-1.),-.5,.5)-.5).x;
  }
vec3 path(vec3 p){
  
   vec3 o = vec3(0.);
   o.x +=sin(p.z*.01)*30;
    o.x +=tanh(cos(p.z*.053)*4)*5;;
   o.y +=cos(p.z*.033)*20;;
    o.y +=tanh(sin(p.z*.043)*4)*5;;
   return o;
  }
mat3 orth(vec3 p){
   vec3 z = normalize(p),x=vec3(z.z,0.,-z.x);
   return mat3(x,cross(z,x),z);
  }
float box(vec2 p,vec2 b){p=abs(p)-b;return length(max(vec2(0.),p))+min(0.,max(p.x,p.y));}
vec3 cy(vec3 p,float pump){
  
    vec4 s = vec4(0.);
    mat3 o = orth(vec3(-1.,2.,-3.));
    for(float i=0;i++<5.;){
         p*=o;
         p+=sin(p.xyz);
         s+=vec4(cross(sin(p),cos(p.yzx)),1.);
         s*=pump;
         p*=2.;
      }
      return s.xyz/s.w;
  }
vec3 pcg3d(vec3 p){
  
   uvec3 q= floatBitsToUint(p)*123457u+1234567890u;
    q.x +=q.y*q.z;q.y +=q.x*q.z;q.z +=q.y*q.x;
  q^=q>>16u;
  q.x +=q.y*q.z;q.y +=q.x*q.z;q.z +=q.y*q.x;
  return vec3(q)/float(-1U);
  }
vec2 sdf(vec3 p){
  vec3 c = cy(p,2.);
    vec3 ph =path(p);
    vec3 hp=p-ph;
   vec2 h;
  h.x = box(hp.xy-c.yz*.4,vec2(1.,2.));
  h.y = 1.+step(.9,fract(p.y))+length(c);
  
  vec3 tp=p-c*.4;
  vec2 t;
  t.x = dot(vec3(0.,1,0),tp)-step(-10,-p.z)*100+dot(sin(tp*.45),cos(tp.yzx*.12))/.13;
  h.x = max(-h.x,t.x*.13);
  
  
  tp=p-ph;
  
  tp.z = mod(tp.z,10)-5.;
  tp=erot(tp,vec3(0.,1,0),bpm+floor(p.z/10));
  vec2 q =vec2((1-txt(tp.xy))*.1,abs(tp.z));
  t.x = max(length(tp.xy)-.5, length(max(vec2(0.),q))+min(0.,max(q.x,q.y)));
  
  h=t.x< h.x ? t:h;
  
  
    tp=p-ph;
 
 
  t.x = max(abs(tp.z-frw)-2., length(tp.xy)-abs(length(c)*.7));
  t.y = -1.;
  h=t.x< h.x ? t:h;
  return h;
  
  }
  
 #define q(s) s*sdf(p+s).x
  vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3 rnd= pcg3d(vec3(uv,bpm));
  float wheeeee = clamp(tanh(sin(bpm*.125+rnd.x*.1)*4),0.,1.);
	vec3 col = vec3(0);
  uv *= 1-.5*step(.4,abs(uv.y));
  
  uv = erot(uv.xyy,vec3(0.,0.,1),sin(bpm*0.125+cos(bpm*.5))).xy;
  vec3 ro= vec3(0.5,0.5,-5.+frw),rt=vec3(0.,0.,5.+frw);
  ro=erot(ro,vec3(0.,0.,1),bpm*.5);
  ro+=path(ro);
  rt+=path(rt);
  vec3 rd= orth(rt-ro)*normalize(vec3(uv,1.-.9*wheeeee));
  vec3 rp=ro;
  vec3 acc=vec3(0.);
  vec3 light =vec3(1.,2.,-3.+frw);
  light +=path(light);
  vec2 d;
  float rl=0.,i=0;;
  for(;i++<128;){
    
      d = sdf(rp);
      if(d.y <=0){
            vec3 cc= d.y ==-1. ? sin(vec3(.2,.5,.9)+rp.z)*.5 :vec3(.2,.5,.9);
           acc+=cc*exp(-abs(d.x))/10;
         
          d.x = max(.001,abs(d.x));
        }
      rl+=d.x;
      rp=ro+rd*rl;
     if(d.x< .001)break;
     }
     if(d.x< .001){
         vec3 n = norm(rp,.001); 
         vec3 ld = normalize(light-rp);
        float dif = max(0.,dot(ld,n));
        float spc = max(0.,pow(dot(reflect(ld,n),rd),32));
        float sss = clamp(sdf(rp+ld*.4).x/.4,0.,1.);
         float fre = pow(1+dot(rd,n),4);
         vec3 cc= d.y >1.9 ? vec3(.9,.5,.2)*sqrt(texture(texFFTSmoothed,fGlobalTime+rp.z+d.y).r)*10:vec3(.2);
         col = cc*(dif+sss*.5)+spc*vec3(.9,.5,.2);
         col = mix(vec3(.1),col,1-fre);
       }
       col = mix(col,mix(vec3(.2,.5,.9),vec3(.9,.5,.2),uv.y*2),1-exp(-.00004*rl*rl*rl));
    
	out_color = vec4(col+acc,1.);
}