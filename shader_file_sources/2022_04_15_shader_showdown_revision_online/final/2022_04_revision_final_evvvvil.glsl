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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec2 z,v,e=vec2(-.00035,.00035);float t,tt,b,bb,g,gg,a,s;vec3 pp,op,tp,po,no,al,ld;
vec4 c=vec4(0,25,10,.1);
float smin(float a,float b,float k){float h=max(0,k-abs(a-b));return min(a,b)-h*h*.25/k;}
float smax(float a,float b,float k){float h=max(0,k-abs(-a-b));return max(-a,b)+h*h*.25/k;}
vec2 smin(vec2 a,vec2 b,float k){float h=clamp(.5+.5*(b.x-a.x)/k,0.,1.);return mix(b,a,h)-k*h*(1.-h);}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
float cy(vec3 p,vec3 r){return max(abs(length(p.xz)-r.x)-r.y,abs(p.y)-r.z);}
vec2 fb( vec3 p)
{
  b=sin(p.y*15)*.03;  
  vec2 h,d,t=vec2(length(p)-5,0);
  t.x=smax(length(p.xz)-3,t.x,0.5);
  pp=p;pp.xz*=r2(sin(p.y*.4-tt)*.4);
  pp.xz=abs(pp.xz)-3;
  h=vec2(cy(pp,vec3(.5,.2,7.)),1);
  h.x=smin(h.x,cy(abs(pp)-.75,vec3(.2-b,.05,6.)),0.5);
  
  tp=pp;
  tp.xz*=r2(.785);
  tp=abs(tp);
  tp.xz*=r2(.785);
  tp.y=mod(tp.y,2)-1.;
  d=vec2(cy(tp.yxz,vec3(.1,.01,2.5)),0);
  tp.xz*=r2(.785);
  tp=abs(tp)-1.8;
  d.x=smin(d.x,cy(tp,vec3(.1-b*.5,.05,3.)),.3);
  d.x=max(d.x,abs(p.y)-6);
  
  pp.y=mod(pp.y-tt*2.,3)-1.5;
  pp.xz*=r2(-tt);
  pp.xz=abs(pp.xz)-max(0,abs(p.y*.15)-1.5);
  s=length(pp);
  g+=0.5/(0.1+s*s*20);
  h.x=smin(h.x,s,1.);
  h.x=smin(h.x,length(pp.xz)-.02,.2);
  h.x=smin(h.x,max(length(pp.xz)-20,2.5),p.y*.5-5);
 
  
  t=smin(t,h,1.5);
  t=smin(t,d,.5);
  tp.y=mod(p.y-tt*4.,4)-2;
  h=vec2(length(tp),1);
  gg+=0.2/(0.1+h.x*h.x*100);
  t=smin(t,h,.5+p.y*0.05);
  t.x*=0.6;
	return t;
}
vec2 mp( vec3 p)
{
  
  vec2 h,t=fb(p);
  h=fb(p*.3);
  h.x/=.3;
  t=smin(t,h,1.5);
  
	return t;
}
vec2 tr( vec3 ro,vec3 rd )
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<128;i++){
    h=mp(ro+rd*t.x);
    if(h.x<.0001||t.x>60) break;
    t.x+=h.x;t.y=h.y;
  }
  if(t.x>60) t.y=-1;
	return t;
}
#define a(d) clamp(mp(po+no*d).x/d,0.,1.)
#define s(d) smoothstep(0.,1.,mp(po+ld*d).x/d)
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
tt=mod(fGlobalTime,62.83)*.5;
	//float f = texture( texFFT, d ).r * 100;
  b=ceil(cos(tt*.4));
  vec3 ro=mix(
  vec3(1,10+sin(tt*.4)*11,cos(tt*.4)*2),
  vec3(cos(tt*.4)*8,10+sin(tt*.4)*12,sin(tt*.4)*8),
  
  b),
  cw=normalize(vec3(0,12+6*b,0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo;
  co=fo=vec3(.17,.13,.12)-length(uv)*.2-rd.y*.1;
  
  z=tr(ro,rd);t=z.x;
  if(z.y>-1){
    po=ro+rd*t;
    ld=normalize(ro-po);
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);
    al=mix(vec3(.4,.6,.7),vec3(.7,.5,.3),z.y);  
    float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),40);
    
    co=mix(sp+al*(a(.1)*a(.5)+.2)*(dif+s(2)),fo,min(fr,.5));
    co=mix(fo,co,exp(-.00002*t*t*t));
  }
  co+=g*.2*vec3(.1,.2,.5)+gg*.2*vec3(.9,.5,.3);
  
  //IM DONE THANKX FOR WATCHING
  //MUCH LOVE GOES TO JETLAG: PROVOD, KEEN, DREW
  //I HOPE YOU GUYS ARE SAFE
  //FUCK THE WAR!!!
	
  
	out_color = vec4(pow(co,vec3(.45)),1);
}