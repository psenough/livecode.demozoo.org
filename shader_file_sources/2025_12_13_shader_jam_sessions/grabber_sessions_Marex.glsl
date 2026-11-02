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

float t = fGlobalTime,n1,n2,n3,f,PI = 3.14159265,tex = min(texture(texFFTSmoothed,1.).x*50.,40.);

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

float mc(float z, float m1, float m2, float time){return clamp(cos(z*m1+t*time)*m2,-.25,.25)*2.+.5;}

float sdf(vec3 p){
  
  float bz = mc(p.z,.005,1.,.4);
  
  vec3 p3 = p;
  
  p.xz*= R2D(mix(t/64,t/4.,mc(p.z,.005,10.,.4)));
  p.xz = R2D(PI/4.*round(atan(p.z,p.x)/(PI/4.)))*p.xz-30.-tex*2.;
  p.xz = abs(p.xz)-30.-tex*2.;
  p.yx *= R2D(-.456);
  
  vec3 p2=p;
  p.xz *= R2D(t/4.);
  for(float i = 0.;i++<5.;){  
    p.xz = (abs(p.xz-1.)-2.1+sin(p.y*.5-t)*.5)*R2D(-.765);
    p.xy *= R2D(sin(.2-t+p.y*.1)*.05+.2);
    p2.xz = (abs(p2.xz)-.5);
    p2.xy += sin(p2.xy*.1);
    p.xz *= mix(.95,1.,bz);
    float co = max(dot(vec2(1.,.08),vec2(length(p.xz),p.y-40)),-p.y);
    float cy = max(length(p2.xz)-5*sin(-t+p.y*.1)/2.-3,p.y);
    float pl = dot(p3,vec3(0.,1.,0.))-6.*tex;
    #define nn(s) .1/(s*s*40.+.1)
    n1 += nn(co);
    n2 += nn(cy);
    n3 += nn(pl);
    
    f=min(co,cy)*.7;
  }
  return f;
}

void main(void)
{
  vec2 uv = (gl_FragCoord.xy/v2Resolution.xy-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  vec2 R2D2 = uv*R2D(-t/32.);
  
  float tex = texture(texFFTSmoothed,1.).x;
  
  float mcc = mc(t,.005,1.,.4);
  
  vec3 col = vec3(0.);
  vec3 ro = mix(vec3(0,200.,-300.),vec3(0.,400.,.001),mcc);
  vec3 fr = normalize(vec3(0.)-ro);
  vec3 ri = normalize(cross(fr,vec3(0.,1.,0.)));
  vec3 up = normalize(cross(ri,fr));
  vec3 rd = normalize(ri*R2D2.x+up*R2D2.y+fr*2.);
  
  float d = 0.;
  
  for(float i = 0.;i++<128.;){
    
    float h = sdf(ro+rd*d);
    if(h<.001||d>10000.)break;
    d+=h;
    
  }
  
  vec3 p = ro+rd*d;
  float cmc = mc(p.z,.005,1000.,.4);
  
	out_color = vec4(mix(n1*vec3(20.,.02,.01),n1*vec3(.01,.1,20.0),cmc)+mix(n2*vec3(0.,20.,.05),n2*vec3(20.,0.1,.2),cmc)+mix(n3*.2*vec3(1.,.5,0.),n3*.2*vec3(3.,2.,0.),cmc),0.);
}