#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCatJam;
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float PI = 3.14159265,n1,n2,n3,f,t=fGlobalTime,tex = min(texture(texFFTSmoothed,1.).x*1000.,20.);

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

float chs(vec3 p, float r, float h){
  
  float w = sqrt(r*r-h*h);
  vec2 q = vec2(length(p.xz),p.y);
  
  return ((h*q.x<w*q.y)?length(q-vec2(w,h)):abs(length(q)-r))-2.;
}

float mc(float z, float m1, float m2, float time){return clamp(cos(z*m1+t*time)*m2,-.25,.25)*2.+.5;}

float sdf(vec3 p){
  float bz = mc(p.z,.005,1.,.4);
  float by = mc(p.y, .1,1.,1.);
  vec3 p3 = p*by;
  p.xz *= R2D(mix(t/4.,t/64.,mc(p.z,.005,1000.,.4)));
  p.xz = R2D(PI/4.*round(atan(p.z,p.x)/(PI/4.)))*p.xz-40.+mix(vec2(-t*10.,0.),vec2(t*10.-abs(sin(t)),0.),mc(p.z,.005,1000.,.4));
  p.xz = mod(p.xz,80.)-40.;
  p.yx = mix(p.yx*R2D(.765),+p.yx*R2D(-.765),bz);
  p.xz *= R2D(sin(t/2.)*p.y*.1);
  vec3 p2=p;
  for(float i = 0.;i++<2.;){  
    p.xz = (abs(p.xz)-(2.1-sin(t-p.y*.2))-sin(p.y*.5-t)*.5)*R2D(.765);
    p *= mix(1.,.85,bz);
    float co = max(dot(vec2(1.,.08),vec2(length(p.xz),p.y-35)),-p.y);
    float ch = chs(p2, 14-sin(t+p.y/4.),5-sin(-t));
    float cy = dot(p3,vec3(0.,1.,0.))-6./tex;
    float cy2 = dot(p3,vec3(1.,-1.,0.))-5./tex;
    float cy3 = dot(p3,vec3(-1.,0.,1.))-10./tex;
    f = min(co,ch)*.5;
    #define nn(s) .1/(s*s*40.+.1)
    n1 += nn(co);
    n2 += nn(ch);
    n3 += nn(cy);
  }
  return f;
}

void main(void)
{
  
  vec2 uv = (gl_FragCoord.xy/v2Resolution-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  
  float ex = exp(mod(t*6.,60.))*10.;
  uv = floor(uv*ex)/ex;
  
  vec2 R2D2 = uv*R2D(t/32.);
  vec3 col = vec3(0.);
  vec2 e = vec2(.001,-.001);
  
  float mcc = mc(t,.005,1.,.4);
  
  vec3 ro = mix(vec3(200.,200.,0.),vec3(0.,400.,.001),mcc);
  vec3 fr = normalize(vec3(0.)-ro);
  vec3 ri = normalize(cross(fr,vec3(0,1,0)));
  vec3 up = normalize(cross(ri,fr));
  vec3 rd = normalize(ri*R2D2.x+up*R2D2.y+fr*mix(2.,2.5,mcc));
  
  float d = 0.;
  
  for(float i = 0.;i++<128.;){
    
    float h = sdf(ro+rd*d);
    if(h<.001||d>500.)break;
    
    d+=h;
  }
  
  vec3 p = ro+rd*d;
  float cmc = mc(p.z,.005,1000.,.4);
  
	out_color =vec4((mix(n1*.5*vec3(20.,.5,0.),n1*vec3(.09,20.,0.09),cmc)+mix(n2*vec3(0.,.05,20.),n2*vec3(20.,.04,.07),cmc)+mix(n3*vec3(0.,1.,1.),n3*vec3(0.,1.,0.),cmc))*.4545,0.);
}