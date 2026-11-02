#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec2 z,v,e=vec2(.00035,-.00035); float t,tt,b,bb,g,gg;vec3 np,bp,op,pp,po,no,al,ld;
vec4 c=vec4(0,5,20,.2);
float bo(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec2 fb( vec3 p )
{
  vec2 h,t=vec2(bo(p,vec3(2,5,2)),5);
  t.x=min(t.x,length(p.xz)-.1);
  t.x=max(abs(t.x)-.5,abs(p.y)-.5);
  
  h=vec2(bo(p,vec3(2,5,2)),6);
  h.x=max(abs(h.x)-.3,abs(p.y)-.7);
  t=t.x<h.x?t:h;
  h=vec2(bo(p,vec3(2,5,2)),3);
  h.x=max(abs(h.x)-.1,abs(p.y)-1.);
  t=t.x<h.x?t:h;
  
  h=vec2(bo(p,vec3(3,5,3)),6);
  h.x=max(abs(h.x)-.1,abs(p.y)-.1);
  g+=0.1/(0.1+h.x*h.x*40);
  t=t.x<h.x?t:h;
  return t;
}
vec2 mp( vec3 p )
{
  op=p;
  
  np=p;
  bp=p;
//  np.xz*=r2(sin(p.y*.2+tt)*.2);
  pp=np;
   for(int i=0;i<4;i++){
     np=abs(np)-2.5;
     np.xz*=r2(.785);
     np.yz*=r2(-.785+sin(p.y*.2)*.2);
   }
   np.xz+=.5;
  vec2 h,t=fb(np);
   t.x*=0.7;
  h=vec2(length(p.xz)-2+sin(p.y*.5),6);
   //h.x=min(length(p.xz)-20,6);
 g+=0.1/(0.1+h.x*h.x*(10-sin(p.y*.2+tt*5.)*9.));
  t=t.x<h.x?t:h;  
   float tnoi=texture(texNoise,op.xz*0.05).r;
   h=vec2(pp.y+7+tnoi*5.,6);
   h.x*=0.6;
   
 //g+=0.1/(0.1+h.x*h.x*40);
  t=t.x<h.x?t:h;  
   
   
  return t;
}
vec2 tr( vec3 ro,vec3 rd )
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<128;i++){
    h=mp(ro+rd*t.x);
    if(h.x<.0001||t.x>120) break;
    t.x+=h.x;t.y=h.y;
  }
  if(t.x>120) t.y=0;
  return t;
}
#define a(d) clamp(mp(po+no*d).x/d,0.,1.)
#define s(d) smoothstep(0.,1.,mp(po+ld*d).x/d)
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
tt=mod(fGlobalTime,62.82);
  c.z*=mix(1.,-.17,ceil(sin(tt)));
  vec3 ro=vec3(cos(tt*c.w+c.x)*c.z,5.,sin(tt*c.w+c.x)*c.z),
  cw=normalize(vec3(0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo;
  co=fo=vec3(.15,.1,.13)-length(uv)*.1-rd.y*.1;
  ld=normalize(vec3(.2,.3,-.5));
  
  z=tr(ro,rd);t=z.x;
  if(z.y>0){
    po=ro+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);
    
    
    al=mix(vec3(.1,.2,.7),vec3(.1,.3,1.),sin(np.z)*.5+.5)+ceil(abs(sin(np.z*5))-.2)*.5;
    if(z.y<5)al=vec3(0);
    if(z.y>5)al=vec3(1);
    float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),40);
    co=mix(sp+al*(a(.05)*a(.1)+.2)*(dif+s(2)),fo,min(fr,.5));
    co=mix(fo,co,exp(-.0002*t*t*t));
  }

  out_color = vec4(pow(co+g*.2*vec3(.1,.2,.7),vec3(.45)),1);
}