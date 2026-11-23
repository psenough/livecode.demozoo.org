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
vec2 z,v,e=vec2(.0035,-.0035);float t,tt,b,bb,g,gg,ggg;vec3 np,bp,pp,op,po,no,al,ld;
float bo(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec4 c=vec4(0,12,15,.2);
vec2 fb( vec3 p)
{
  bp=p;
  bp.x=abs(bp.x)-2;
  bp.xz*=r2(.785);
  b=sin(op.z*.4+tt);
  vec2 h,t=vec2(bo(bp,vec3(2)),6);
  t.x=abs(abs(t.x)-.5)-.3;
  t.x=max(t.x,abs(p.y)-1);
  t.x=max(t.x,-(abs(p.x)-1));
  
  h=vec2(bo(bp,vec3(2,10,2)),5);
  h.x=abs(abs(h.x)-.5)-.15;
  h.x=max(h.x,abs(p.y)-2.-b);
  h.x=max(h.x,-(abs(p.x)-1));
  h.x*=0.7;
  t=t.x<h.x?t:h;
  
  h=vec2(bo(p,vec3(.7,10,3.5)),3);
  h.x=abs(h.x)-.3;
  h.x=max(h.x,abs(p.y)-1.4);
  h.x=min(h.x,.7*(length(bp)-.5));
    t=t.x<h.x?t:h;
  
  h=vec2(0.7*bo(p,vec3(.3,3+b*1.5,3)),6); 
  h.x=min(h.x,max(.6*(length(abs(p.xz)-2)-.1+p.y*.02),abs(p.y)-5));
  g+=0.1/(0.1+h.x*h.x*40);
  float laz=length(bp.xy)-.2;
  laz=min(laz,length(bp.yz)-.2);
  laz*=0.7;
  gg+=0.1/(0.1+laz*laz*4);
  h.x=min(h.x,laz);
  t=t.x<h.x?t:h;
  
  return t;
}

vec2 mp( vec3 p)
{
  np=op=p;
   for(int i=0;i<4;i++){
    np.xz=abs(np.xz)-vec2(7,3);
     np.xz*=r2(-.785);
  }
  vec2 h,t=fb(np);
  bb=sin(p.x*30)*.03;
  h=vec2(p.y+bb,7);
  t=t.x<h.x?t:h;
  pp=p-vec3(0,10+b*2.,0);
  pp.yz*=r2(.785*2);
   h=fb(pp);
  t=t.x<h.x?t:h;
  vec3 parP=p;
  parP.xz*=r2(sin(p.y*.2)*1.5+tt);
  parP+=vec3(0,tt,0);
  h=vec2(length(cos(parP*.75)),6);
  h.x=max(h.x,max(length(p.xz)-10,-(length(p.xz)-5)));
  ggg+=0.1/(0.1+h.x*h.x*(40-sin(p.y*.3-tt*5.)*39));
  t=t.x<h.x?t:h;
  
   pp=p-vec3(0,0,0); //BIGGEST FB
  //pp.xz*=r2(.785*2);
   h=fb(pp*.5);
  h.x/=.5;
  t=t.x<h.x?t:h;
  np.xz*=r2(.785*2);
  h=fb(np);
  t=t.x<h.x?t:h;
  return t;
}
vec2 tr( vec3 ro,vec3 rd )
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<128;i++){
    h=mp(ro+rd*t.x);
    if(h.x<.0001||t.x>100) break;
    t.x+=h.x;t.y=h.y;
  }
  if(t.x>100) t.y=0;
  return t;
}
#define a(d) clamp(mp(po+no*d).x/d,0.,1.)
#define s(d) smoothstep(0.,1.,mp(po+ld*d).x/d)
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
tt=mod(fGlobalTime,62.83);
  //float f = texture( texFFT, d ).r * 100;
 
vec3 ro=mix(vec3(cos(tt*c.w+c.x)*c.z,c.y,sin(tt*c.w+c.x)*c.z),
vec3(cos(tt*.3)*7,20,sin(tt*.5)*20),ceil(sin(tt*.5))),  
  cw=normalize(vec3(0,2,0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.6)),co,fo;
  co=fo=vec3(.1,.12,.15)-length(uv)*.1-rd.y*.2;
ld=normalize(vec3(.2,.5,-.3));
  z=tr(ro,rd);t=z.x;
  if(z.y>0){
    po=ro+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);al=vec3(1,.1,.2);
    if(z.y<5) al=vec3(0);
      if(z.y>5) al=vec3(1);
    if(z.y>6) al=vec3(.5);
    float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),40);
    co=mix(sp+al*(a(.05)*a(.1)+.2)*(dif+s(.4)*.2),fo,min(fr,.5));
    co=mix(fo,co,exp(-.00005*t*t*t));
  }
  out_color = vec4(pow(co+g*.2*vec3(.1,.2,.9)+gg*.1*vec3(.7,.3,.2)+ggg*.2,vec3(.55)),1);
}