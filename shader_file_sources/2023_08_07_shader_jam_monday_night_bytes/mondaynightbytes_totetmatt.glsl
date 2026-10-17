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
// HELLO !
//  ###########################################################
//  >> ASK  FOR MORE SHADER SHOWDOWN TO YOUR LOCAL DEMOPARTY <<
// //  #######################################################
float bpm = texelFetch(texFFTIntegrated,30,0).r*.5;
float rnd;
vec3 edges(vec3 p){
      vec3 ap=abs(p);
      if(ap.x>ap.z) return vec3(ap.x/p.x,0,0);
     return vec3(0,0,ap.z/p.z);
  }
float mandel(vec2 uv){
     vec2 c = uv;
     vec2 z = uv;
     float i=0.,im=200.;
     for(;i<im;i++){
          z = vec2(z.x*z.x-z.y*z.y,2.*z.x*z.y)+c;
         if(dot(z,z)>4.) break;
         
       
      }
       return i/im;
  }
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box(vec3 p,vec3 b){p=abs(p)-b; return length(max(vec3(0.),p))+min(0.,max(p.x,max(p.y,p.z)));}
vec2 sdf(vec3 p){
      vec2 h;
      vec3 hp=p;
       hp.z -=bpm;
      float jump = -bpm;
      hp.y -=sqrt(2)*abs(sin(bpm*3.14));
      hp = erot(hp,vec3(1,0,0),jump*3.14);
      h.x = box(hp,vec3(1.));
      h.y = 1.;
  
    vec2 t;
    vec3 tp=p;
    
    tp.y+=1.5;
    vec3 id = floor(tp)+.5;
    id.y=0.;
  
    vec3 nid  = id + edges(hp-id);
    nid .y= 0.;
     float diff = sin(texture(texFFTIntegrated,dot(cos(id*.4),sin(id.zyx*.3))).r)/2;
  diff= dot(cos(id*.4),sin(id.zyx*.3));
     tp.y-=diff/2.;
    t.x = box(tp-id,vec3(.49,diff/2.,.49));
    t.x = min(t.x,box(tp-nid,vec3(.493,1.,.493)));
    
    // t.x = max(abs(tp.x)-5.,t.x);
    t.y=3+dot(sin(id*.4),cos(id.yzx*.23));
  h= t.x < h.x ? t:h;
      return h;
}
#define q(s) s*sdf(p+s).x
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(0,.1,.2)));}
vec3 norm(vec3 p,float ee){vec2 e= vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

#define FBI(x,y) (floatBitsToInt(x)^floatBitsToInt(y))
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv*=1.+abs(tanh(sin(-fGlobalTime+length(uv))*10));
    rnd = tanh((FBI(uv.x,gl_FragCoord.y)*FBI(uv.y,gl_FragCoord.x))/2.19e9);
  bpm+=rnd*.05*length(uv);
  bpm = floor(bpm) + smoothstep(0.,1.,pow(fract(bpm),.75));
 vec3 col =vec3(0.);
  float zoomzoomzeum=sin(fGlobalTime);
  vec3 ro=vec3(5.,2.,-5.),rt=vec3(0.);
  ro = erot(ro,vec3(0.,1.,0),bpm);
  ro.x +=zoomzoomzeum;
  ro.z +=bpm;
  rt.z +=bpm;
  vec3 z= normalize(rt-ro),x=normalize(cross(z,vec3(0.,-1.,0.))),y=cross(z,x);
  vec3 rd=mat3(x,y,z)*normalize(vec3(uv,(1.-zoomzoomzeum*.5+.5)));
  vec3 rp=ro;
  vec3 light = vec3(1.,2.,-3.);
  vec3 acc = vec3(0.);
  for(float i=0.;i++<128;){
    
       vec2 d =sdf(rp);
       float effectSwitch = mod(fGlobalTime,10)<5. ? d.y:0;
       float wave= exp(-7.*fract(effectSwitch+bpm*.5+rp.y*.1-.01*length(rp.xz-vec2(0,bpm))));
       if(d.x<.1 && d.y==1.)acc +=mix(vec3(.1),pal(d.y),tanh(wave))*exp(-abs(d.x))/(60.-wave*50);
       if(d.y==1.)d.x = max(.001,abs(d.x));
       rp+=rd*d.x;
       if(d.x<.001){
            vec3 n = norm(rp,.001);
           float dif = max(0.,dot(normalize(light),n));
         
           col =mix(vec3(.01),pal(d.y),tanh(wave))*dif;
           
           break;
       }
    }
    ivec2 gl = ivec2(gl_FragCoord.xy);
    ivec2 off= ivec2(5.);
    float vr = texelFetch(texPreviousFrame,gl+off,0).a;
    float vg = texelFetch(texPreviousFrame,gl-off,0).a;
    float vb = texelFetch(texPreviousFrame,gl-off,0).a;
	out_color = vec4(mix(vec3(vr,vg,vb),sqrt(col+acc),sin(bpm)+1.5+texture(texFFT,uv.y+fGlobalTime).r*5),length(col+acc));
}