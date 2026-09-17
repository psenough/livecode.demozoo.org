#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float ti = fGlobalTime,n1,n2,f,PI = 3.141592;

float mc(float z,float m1,float m2,float time){return clamp(cos(z*m1+ti*time)*m2,-.25,.25)*2.+.5;}

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

float sdf(vec3 p,float sm)
{
  vec3 p2 = p;
  float bz = mc(p.y,.4,.5,2.);
  
  for(float i = 0;i++<5.;)
  {
    p = abs(p);
    float tii = mix(floor(ti/i*5.),ti/i,mc(p.y,.4,1000.,.5));
    p.xz *= R2D(tii);
    p.xy *= R2D(tii);
    p.yz *= R2D(tii);
    p = abs(p);
    
    float sp = mix(length(max(abs(p)-2.,0.)),length(p+4.)-10.,bz);
    f= sp;
  }
  p = p2;
  
  p.xz = abs(p.xz)-4.;
  p.xy *= R2D(-.25);
  p.zy *= R2D(-.25);
  
  float co = dot(p,vec3(0.,1.,0.))+8.;
  
  p = p2;
  
  p.xy *= R2D(sin(ti)*.15);
  p.xy *= R2D(sin(ti)*.15);
  p.xz = abs(p.xz)-9.;
  
  p.xz *= R2D(ti);
  p.xy *= R2D(ti);
  p.yz *= R2D(ti);
  p= abs(p)-2.;
  
  float cu = mix(length(max(p,0.)),length(p)-1.,bz);
  
  p = p2;
  
  float fo = PI*2.5;
  
  p.y = mod(p.y+ti*5.+PI*.75,fo)-fo/2.;
  
  float cy = dot(p,vec3(0.,1.,0.))-2.;
  
  f= min(min(f,cu),co);
  
  
  #define nn(s) .1/(s*s*40.+.1)
  n1 += nn(f);
  n2 += nn(cy);
  
  return f*sm;
  
}

vec3 h3(vec3 p)
{
  uvec3 q = floatBitsToUint(p);
  q=((q>>16u)^q.yzx)*111111111u,  q=((q>>16u)^q.yzx)*111111111u,  q=((q>>16u)^q.yzx)*111111111u;
  return vec3(q)/float(-1U);
}

vec3 sn(float x,float n)
{
  float u = smoothstep(.5-n,.5+n,fract(x));
  
  return mix(h3(vec3(floor(x),-1U,1)),h3(vec3(floor(x+1.),-1U,1)),u);
}

void main(void)
{
  vec2 uv = (gl_FragCoord.xy/v2Resolution.xy-.5)/vec2(v2Resolution.y/v2Resolution.x,1.),uv2=uv;
  vec2 e = vec2(.01,-.01);
  
  float bpm = ti*130./60.;
  
  vec3 rn = sn(bpm,.3+h3(uv.xyy+bpm).x*.05);
  
  float by = mc(ti,.4,.5,.125);
  
  float o = mix(20.,0.,by);
  float sm = mix(1.,.6,by);
  float md = mix(500,70,by);
  
  uv = mix(uv,mix(uv*R2D(.5),uv*R2D(-.3),clamp(rn.x,0.,1.)),by);
  
  vec3 col;
  vec3 ro = mix(vec3(0.,10.,20.)*o,vec3(mix(-5.,5.,rn.x),mix(1.,10.,rn.x),mix(2.,7.,rn.z))+vec3(0.,0.,25),by);
  ro.xz *= R2D(ti/2.);
  vec3 fr = normalize(vec3(0.)-ro);
  vec3 ri = normalize(cross(fr,vec3(0.,1.,0.)));
  vec3 up = normalize(cross(ri,fr));
  
  vec3 rd = normalize(ri*uv.x+up*uv.y+mix(fr*o,fr*clamp(rn.x,.75,3.),by));
  
  for(float i = 0.;i++<3.;)
  {
  float t = 0.;
  
    for(float i = 0.;i++<64.;)
    {
      float d = sdf(ro+rd*t,sm);
      if(d<.001||t>md)break;
      t+=d;
      
    }
    if(t<md)
    {
      vec3 p = ro+rd*t;
      #define q(s) s*sdf(p+s,md)
      vec3 n = normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));
      
      vec3 lp,pl = p;
      pl.xz = abs(pl.xz)-4.;
      pl.xz *= R2D(.785);
      vec3 lv = pl-lp;
      float li = (pow(.1,2.)/pow(length(lv),2.))*10e3;
      
      col = vec3(li);
      
      rd = reflect(rd,n);
      ro = p+n*.1;
      
    }
    
  }
  
  float fog = length(uv2);
  
  float pat = ceil(-sin(uv2.y*mix(4.5,1.,by)-PI/2.));
  
	out_color =vec4(n2*.03+n1*.02*col*fog,0.)/pat;
}