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
uniform sampler2D texRevision;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything



/*********






ON VIT DANS UNE SAUCISSE ?
ON VIT DANS UNE SAUCISSE ?
ON VIT DANS UNE SAUCISSE ?
ON VIT DANS UNE SAUCISSE ?








*******/
float bpm = fGlobalTime*125/60;
vec3 hash3d(vec3 p){
    uvec3 q= floatBitsToUint(p);
    q= ((q>>16u)^q.yzx)*1111111111u;
      q= ((q>>16u)^q.yzx)*1111111111u;
    q= ((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
}
vec3 stepNoise(float t,float n){
    float u = smoothstep(.5-n,.5+n,fract(t));
    return mix(hash3d(vec3(floor(t),-1U,1234657980)),hash3d(vec3(floor(t+1),-1U,1234657980)),u);
    
}
struct GS{vec3 hash,size,cell;};
struct Grid{GS sub;float d;};
Grid grid;
#define gsub grid.sub
float diam(vec3 p,float s){p=abs(p);return (p.x+p.y+p.z-s)*inversesqrt(3.);}

void doSub(vec3 p){
         gsub.size = vec3(.5);
         for(int i=0;i<5;i++){
                gsub.cell  = (floor(p/gsub.size)+.5)*gsub.size;
                gsub.hash = hash3d(gsub.cell);
                if(i==4|| gsub.hash.x <.5) break;
                gsub.size *=.5;
           
           }
   
  }
 vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0),p))+min(0.,max(p.x,max(p.y,p.z)));;}
float box2(vec2 p,vec2 b){p=abs(p)-b;return length(max(vec2(0),p))+min(0.,max(p.x,p.y));;}
void doGrid(vec3 ro,vec3 rd){
      doSub(ro+rd*1e-3);
      vec3 src= -(ro-gsub.cell)/rd;
      vec3 dst = abs(.5*gsub.size/rd);
      src += dst;
      grid.d = min(min(src.x,src.y),src.z);
}
vec2 sdf(vec3 p){
    vec3 hp=p-gsub.cell;
 
    vec2 h;
   // h.x = length(hp)-(.25-.1*exp(-3*fract(texture(texFFTIntegrated,.3+gsub.hash.x).r)))*gsub.size.x;
  h.x = box(hp,vec3(.25)*gsub.size.x);
    h.y= 1.;
  
  vec2 t;
  vec3 tp=p;
  
  p = erot(p,normalize(stepNoise(bpm+5,3.)-.5),bpm);
  float fr = mix(box(p,vec3(1.1)),box2(p.xz,vec2(.5,.5)),(.5*sin(bpm)+.5));
  h.x  = max(fr,h.x);
    return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3  col = vec3(0);
 // col += step(uv.y+.5,sqrt(texture(texFFTSmoothed,uv.x).x));
  
  vec3 rrot = stepNoise(bpm/2,.25-hash3d(vec3(bpm,uv)).x*.1);
  vec3 ro = vec3(.33,0.75,-2.),rt=vec3(0);
  ro.z = mix(-2,-4,rrot.z);
    ro.y = mix(-4,4,rrot.y);
  
  ro =erot(ro,vec3(0,1,0),rrot.x*6.28);
  vec3 z = normalize(rt-ro),x=vec3(z.z,0,-z.x);
  vec3 rd = mat3(x,cross(z,x),z)*normalize(vec3(uv,1.));
  
  vec3 light = vec3(1.,2.,-3.);
  vec3 rp=ro;
  vec2 d;
  float rl;
  float glen = 0.;
  vec3 acc=vec3(0);
  for(float i=0.;i++<99;){
       vec3 rnd = hash3d(vec3(uv,i+bpm));
       if(glen<=rl) {
           doGrid(rp,rd);
           glen += grid.d;
       }
       d = sdf(rp);
        if(gsub.hash.y <.5){
          float dd = d.x*(1-rnd.x*exp(-fract(bpm+gsub.hash.x)));
         acc += vec3(1.)*exp(-abs(dd))/(120-114*exp(-3*fract(rp.x+bpm+gsub.hash.z*5)));
           if(gsub.hash.z<.5){
               d.x= max(.001,abs(dd));
             }
        }
        //  d*=1-(rnd.x-.5)*2; //From Peregrine awesome presentation yesterday , whhheeeeee
       if(d.x<.001) break;
       rl=min(rl+d.x,glen);
       rp=ro+rd*rl;
    }
  if(d.x<.001){
       vec3 n = norm(rp,.001); 
       vec3 ld = normalize(light-rp);
        float dif = max(.05,dot(ld,n));
       float spc = pow(max(0,dot(reflect(ld,n),rd)),32.);
      float fre= pow(1+dot(rd,n),4);
       col = mix(vec3(.1)*dif + spc,col,fre);
    }
    //col = mix(col,vec3(1.),1-exp(-.1*rl*rl*rl));
  col = sqrt(col)+acc*vec3(.3,.9,.6);
    col = mix(col,.1/col,exp(-6*fract(bpm+gsub.hash.x*.0+length(rp)*.0)));
    
    ivec2 gl= ivec2(gl_FragCoord.xy);
    ivec2 off = ivec2( (hash3d(vec3(floor(uv*5),1654)).xy-.5)*10);
    vec3 pcol = vec3(
    texelFetch(texPreviousFrame,gl+off,0).r,
    texelFetch(texPreviousFrame,gl-off,0).g,
    
    texelFetch(texPreviousFrame,gl-off,0).b
    );
    
    col = mix(col,pcol,.1);
    
    vec3 win = stepNoise(bpm+242,.25);

     float dd = box2(uv+win.yz-.5,vec2(.1));
   dd= smoothstep(fwidth(dd),0.,dd);
    col = mix(col,fwidth(col),dd);   
	out_color = vec4(col,1.);
}