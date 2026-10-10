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
vec2 z,v,e=vec2(-.00035,.00035);float t,tt,b,bb,g,gg,r,a;vec3 op,pp,po,no,al,ld;
vec4 kp,c=vec4(0,5,20,.1);
float smin(float a,float b,float k){float h=max(0.,k-abs(a-b));return min(a,b)-h*h*.25/k;}
float smax(float a,float b,float k){float h=max(0.,k-abs(-a-b));return max(-a,b)+h*h*.25/k;}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec2 mp( vec3 p)
{
  op=p;
  bb=1-(sin((p.z+tt*4.)*.064)*.5+.5);
  p.x=abs(p.x)-15*bb;
  p.xy*=r2(1.57*bb);
  p.z=mod(p.z+tt*4.,50)-25;
  pp=p;
  pp.xz=abs(pp.xz)-7.3;
  vec2 h,t=vec2(length(pp)-2.5,0);  
  t.x=smin(t.x,length(pp-1.6)-0.6,0.5);  
  t.x=smax(length(pp-1.7)-0.3,t.x,0.5);  
  h=vec2(length(pp-1.5)-0.5,2);
  t=t.x<h.x?t:h;
  kp=vec4(p-vec3(0,4.63,0),1);
  r=1.;
  for(int i=0;i<4;i++){
    kp.xz=abs(kp.xz)-.4;
    kp.xz*=r2(.785*mod(i,2));
    kp*=2.3;
    r=min(r,clamp(abs(cos(kp.y*.3)*abs(cos(kp.z*.3)*3.)-.5)-.5,-.25,.25)/kp.w);
  }  
  t.x=smin(t.x,p.y+1+sin(length(p.xz)-tt*2.)*.5,1.5);
  t.x=min(t.x,length(p.yz-vec2(8,0))-.1+r);
  
  a=max(length(p.xz)-8+r+p.y*.75,-(length(p.xz)-2+r));
  t.x=smin(t.x,a,1.5);
  t.x=max(t.x,-(abs(abs(p.y-4)-1.)-.2-r));
  a+=.2;
  h.x=min(h.x,a);
  pp+=cos(p.y*.5);
  
  h.x=min(h.x,length(pp.xy-vec2(0,9)));
  h.x=smin(h.x,
  max(
  length(abs(p.xz)-vec2(0,1))-.2+r,
  abs(p.y)-10+gg)
  
  ,1.5);
  g+=0.1/(0.1+h.x*h.x*(50-48*sin(op.z*.1+tt*2.+b)));  
  
  t=t.x<h.x?t:h;
  pp.xz=abs(pp.xz)-.3;
  h=vec2(length(pp.xz)-.1+r,1);
  pp.y=abs(pp.y-6.)-2.;
  h.x=smin(h.x,length(pp.xy-vec2(0,1))-.1+r,1.5);
  
  pp=p;pp.y=abs(abs(pp.y-5)-1.)-.5;
  h.x=smin(h.x,max(a-.5,pp.y),1.5);
  a=max(abs(length(p.xz)-16+r)-.6,abs(p.y+r)-1.5);
  h.x=smin(h.x,a,1.5);
  h.x=smin(h.x,length(p.xy)-1+r,1.5);
  
  t=t.x<h.x?t:h;
  t.x*=0.6;
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
#define a(d) clamp(mp(po+no*d).x/d,.0,1.)
#define s(d) smoothstep(.0,1.,mp(po+ld*d).x/d)
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  tt=mod(fGlobalTime,70);

	b = texture( texFFTSmoothed,  0.05).r * 50;
  gg = texture( texFFTSmoothed,  0.2).r * 50;
  
  vec3 ro=vec3(cos(tt*0.1)*13,13-sin(tt*0.4)*8,-10),
  cw=normalize(vec3(0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo;
  co=fo=vec3(.14,.13,.12)-length(uv)*.15-rd.y*.1;
  z=tr(ro,rd);t=z.x;
	if(z.y>-1){
    po=ro+rd*t;
    ld=normalize(ro-po);
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);
    al=mix(vec3(.3,.4,.7)-r*15,vec3(.1)-r*15,z.y*1.3);
    if(z.y>1) al=vec3(1);
    float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),40);
    co=mix(sp+al*(a(.1)*a(.5)+.2)*(dif+s(2)),fo,min(fr,.5));
    co=mix(fo,co,exp(-.00005*t*t*t));
    
  }
  co+=g*.2*vec3(.9,.5,.1);
  co=mix(co,co.xzy,length(uv)*.5);
	out_color = vec4(pow(co,vec3(.45)),1);
}