#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D black_cat;
uniform sampler2D cream_cat;
uniform sampler2D grey_cat;
uniform sampler2D grey_white_cat;
uniform sampler2D orange_cat;
uniform sampler2D texChecker;
uniform sampler2D texHttf;
uniform sampler2D texLogo;
uniform sampler2D texMsdf;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D white_cat;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float bpm = fGlobalTime*120/60;
float box(vec2 p,vec2 b){p=abs(p)-b;return length(max(vec2(0),p))+min(0,max(p.x,p.y));}
vec3 pal(float t){return .5+.5*cos(6.28*(1*t+vec3(.0,.3,.6)));}
vec3 hash3d(vec3 p){
    uvec3 q= floatBitsToUint(p);
   q+=((q>>16U)^q.yzx)*1111111111u;
   q+=((q>>15U)^q.zxy)*1111111111u;
   q+=((q>>16U)^q.yzx)*1111111111u;return vec3(q)/float(-1U);
 }
vec3 intro(vec2 uv){
  
     float u = atan(uv.x,uv.y)/6.28+.5;
     float t = texture(texFFTSmoothed,mix(.1,.4,u)).r;
     
     return step(length(uv)-.2,t)*sqrt(pal(u))*5*sqrt(t);
  }
vec3 hp;
vec2 sdf(vec3 p){
     hp=p;
    vec2 h;
  float d =0.;
  vec3 hhp=hp;
  float sc= 1.;
  for(float i=0;i++<4;){
      d += clamp((sin(hhp.z*2)+cos(hhp.y*4))/d,-.5,.5);
      d += dot(asin(sin(hhp)),asin(cos(hhp.yzx*2)));
      hhp*=1.2;;
      hhp= erot(hhp,normalize(vec3(.1,.5,-.75)),.785);
      sc*=1.2;
    }
    d/=sc*2;
    d*=.2;
    vec2 q = vec2(length(hp.xz)-5.,hp.y);
    h.x = -(length(q)-1.+d)*.8;
    h.y =1.;
    
    vec3 tp=p;
    tp=erot(tp,normalize(vec3(1)),.785);
    vec2 t;
    tp=(fract(tp*2)-.5)/2;

    t.x = min(length(tp.yz),min(length(tp.xy),length(tp.xz)));
    t.y =2.;
    h=t.x<h.x ? t:h;
    return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0);

  
  vec3 ro=erot(vec3(0,0,-5.5),vec3(0,1,0),-bpm*.125);;vec3 rt=erot(ro,vec3(0,1,0),-.5);;
   
  vec3 z= normalize(rt-ro),x=vec3(z.z,0.,-z.x);
  vec3 rd=mat3(x,cross(z,x),z)*erot(normalize(vec3(uv,1.)),vec3(0,0,1),6.28*floor(bpm*.25)/4+exp(-7*fract(bpm/4+hash3d(uv.xyy+bpm).x*.1)));;
  vec3 rp=ro;
  vec3 light = erot(ro,vec3(0,1,0),-.5);
   vec2 d;
  float rl=0;;
  vec3 acc=vec3(0);
  for(float i=0;i++<128.;){
      d= sdf(rp);
      if(d.y==2){
          acc+=(texture(texFFTSmoothed,dot(sin(hp),cos(hp.yzx))*.1+bpm*.125).r)*50*pal(atan(hp.x,hp.z))*exp(-30*abs(d.x))/60;
          d.x = max(.001,abs(d.x));
        }
      if(d.x<.001)break;
      rl+=d.x;
      rp=ro+rd*rl;
  }
  if(d.x<.001){
      vec3 n= norm(rp,.001);
      vec3 ld = normalize(light-rp);
      float dif = pow((1+dot(ld,n))/2,2);
      float spc=  pow(max(0,dot(reflect(ld,n),rd)),32);
    float spc2=  pow(max(0,dot(reflect(ld,normalize(n+hash3d(floor(hp*10))*2-1)),rd)),32);
      col = .02*mod(floor(atan(hp.x,hp.z)*6.28*2)+floor(hp.y*6.28),2)*vec3(1.)*dif
      +spc2*pal(atan(hp.x,hp.z))*2
      +spc*pal(atan(hp.x,hp.z));
  }

  col = mix(col,vec3(.01),1-exp(-(.01+hash3d(floor(rp*50)).x*.1)*rl*rl*rl));
    col+=acc;col =sqrt(col);

  ivec2 gl= ivec2(gl_FragCoord.xy);ivec2 off=ivec2(10,0);
  for(float j=0;j++<8;){
      vec2 uuv=uv;
 vec3 qq= hash3d(vec3(floor(bpm*(4+j/8)+j*654),-1u,123456798));
    uuv+=(qq.yz*2-1);
   float qqq = box(uuv,.1+.25*vec2(qq.x,qq.x*v2Resolution.y/v2Resolution.x));
   qqq= step(fwidth(qqq),mod(j,2)<1 ? qqq:abs(qqq)-.01);
    
    vec3 pcol=vec3(texelFetch(texPreviousFrame,gl-off,0).r,
    texelFetch(texPreviousFrame,gl+off,0).g,
    texelFetch(texPreviousFrame,gl+off,0).b
    );
  col += mix(15*((dFdy(col)+dFdx(col))*pal(j/8)),vec3(0),qqq);
    col = mix(col,pcol,.9*step(0,-qqq));
  }
  col =mix(col,col+cross(sin(col),cos(col.yzx*5.))*.4,2*exp(-5*fract(bpm)));
  col =mix(col,col+cross(sin(col),cos(col.yzx*5.))*.4,2*exp(-5*fract(bpm)));
  out_color = vec4(col,1.);
}