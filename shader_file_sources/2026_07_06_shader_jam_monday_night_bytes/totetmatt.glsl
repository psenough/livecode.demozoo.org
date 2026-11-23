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
vec3 hash3d(vec3 p){
    uvec3 q= floatBitsToUint(p);
    q=((q>>16u)^q.yzx)*1111111111u;
    q=((q>>15u)^q.zxy)*1111111111u;
    q=((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 stepNoise(float t,float n){return mix(hash3d(vec3(floor(t),-1u,124455680)),hash3d(vec3(floor(t+1),-1u,124455680)),smoothstep(.5-n,.5+n,fract(t)));}
float diam2(vec2 p,float s){p=abs(p);return (p.x+p.y-s)*inversesqrt(3.);}
float bpm = fGlobalTime*175/60;
vec3 hp;
vec2 sdf(vec3 p){
  //  p.y += bpm*.5;
     hp=p;
    vec2 h;
  vec3 rnd = hash3d(floor(hp*16));
  h.x =1e30;

  hp= erot(hp,normalize(stepNoise(bpm*.125,.1)-.5),bpm*.125/2);
   vec3 tp=hp;
  float lol = +sqrt(texture(texFFTSmoothed,mix(.1,.2,fract(rnd.y))).r*.1);
  float sc= 1.;
  for(float i=0,im=16;i<im;i++){
    hp =erot(hp,normalize(vec3(0,1,0)),.785*.5);
    hp = mix(12.,9.,stepNoise(-bpm*.125,.1).r)-abs(hp);
     hp.xz = hp.x <hp.z ? hp.zx:hp.xz;
   
     h.x =min(h.x, min(min(diam2(hp.xz,.1),diam2(hp.yz,.25)),diam2(hp.xy,.1)));
  }
  h.x /=sc;
  h.x = max(-diam2(p.xz,2.),h.x);
  h.y = 1.;
  
 
  tp+=cross(sin(tp*7-texture(texFFTIntegrated,.1).r*16),cos(tp*5+bpm+texture(texFFTIntegrated,.5).r*16))/7;
  vec2 t;
  t.x = length(tp)-1.-(texture(texFFTSmoothed,length(tp.xy/tp.z)/6.28+bpm*.125).r)*5;;
  t.y= 3;
  h= t.x <h.x ? t:h;
  return h;
}


#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
vec3 pal(float t){return .5+.5*cos(6.28*(1*t+vec3(.0,.3,.6)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3 cc= stepNoise(bpm*.0125,.4);
	vec3 col = vec3(0);
  float fft = sqrt(texture(texFFTSmoothed,mix(.01,.4,gl_FragCoord.x / v2Resolution.x)).r);
 
  
  vec3 ro=vec3(uv,-2)*6.,rd=vec3(0,0,1);
  
  vec3 rp=ro;
  vec3 light = (stepNoise(bpm*.25,.3)-.5)*5;
  vec2 d;
  float rl=0.;
  vec3 acc=vec3(0);
  for(float i=0;i++<128;){
     rp = erot(rp,vec3(1,0,0),.5);
     rp = erot(rp,vec3(0,-1,0),.785);
     d =sdf(rp);
    if(d.y ==3 ||.7<exp(-3*fract(bpm*.5+hash3d(floor(rp*5))*.1+length(rp)*.1).x)){
        acc+=pal(bpm*.125+rp.z*.1)*exp(-50*abs(d.x))/5;
        d.x=max(.001,abs(d.x));
      }
    if(d.x<.001)break;
    rl+=d.x;
    rp=ro+rl*rd;
   }
   if(d.x<.001){
     
      vec3 n= norm(rp,.001);
      vec3 ld = normalize(light-rp);
      
      float dif = pow((1+dot(ld,n))/2,2);
     float spc = pow(max(0,dot(reflect(ld,normalize(n+(hash3d(floor(hp*70))-.5))),rd)),32);
     float fre = pow(1+dot(rd,n),4);
       col = vec3(.1)*dif+mix(vec3(0),vec3(.95,.4,.2),spc*spc*spc)*7;     
     }
       col+=acc;
     col = sqrt(col);
     col+=cross(sin(col),cos(col.brg*5))*.5;
  
     
 
     vec3 pcol = texelFetch(texPreviousFrame,ivec2(gl_FragCoord.xy),0).rgb;
      col = mix(col,pcol,.5);
	out_color = vec4(col,1.);
}