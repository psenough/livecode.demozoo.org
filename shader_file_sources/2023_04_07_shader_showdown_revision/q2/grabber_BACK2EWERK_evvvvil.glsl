#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec2 z,e=vec2(.00035,-.00035);float tt,b,c,r,s,ss,g,glo,di;vec3 pp;vec4 np,d;
float smin(float a,float b,float k){float h=max(0.,k-abs(a-b));return min(a,b)-h*h*.25/k;}
float box(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
float cy(vec3 p,vec3 r){return max(abs(length(p.xz-r.z)-r.x)-r.y,abs(p.y)-5);}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec2 fb( vec3 p,int i,float s )
{
  p.y-=5;
  r=1;
  np=vec4(p,1);
  for(int i=0;i<4;i++){
    np.xz=abs(np.xz)-20;
    np*=1.566;
    r=min(r,clamp(sin(np.x+np.y),-.2,.2)/np.w*s);
  }
  di=cos(p.y*.5)*.5;
  vec2 h,t=vec2(cy(p,vec3(1.5+di,.4,r)),i); 
  t.x=max(t.x,-.7*box(abs(p+p.y+r)-2.5,vec3(2,5,2)));
  p.xz*=r2(.785);
  if(i<3) t.x=min(t.x,cy(p,vec3(.4+di+r,.1,0)));
  glo=mix(length(abs(p)-vec3(0,5,0))-1,length(p.xz)-.5+p.y*.03,b);
  p.xz=abs(p.xz)-1-di;
  glo=min(glo,cy(p,vec3(0,.01,0)));
  if(i<2) glo=min(glo,(length(np.xyz)+.1-b)/np.w);
  t.x=smin(t.x,glo,.5);
  g+=0.1/(0.1+glo*glo*40);
  d[i]=-r;
	return t;
}
vec2 mp( vec3 p )
{
  pp=p;
  pp.yz*=r2(mix(-.6+s*.4,1.4,b));
  pp.xy*=r2(mix(.9,.3,b));
  vec2 h,t=fb(pp,0,1);
  pp.y-=10;
  pp.xy*=r2(mix(-1.6+ss*.4,-.7,b));
  h=fb(pp,1,1);
  t=t.x<h.x?t:h;
  pp.y-=10;
  pp*=2;
  pp.xz*=r2(s*6.28);
  pp.xz=abs(pp.xz)-.5;
  pp.yz*=r2(.3);
  pp.xy*=r2(-.3);
  h=fb(pp,2,1);
  h.x/=2;
  t=t.x<h.x?t:h;
  pp=p+vec3(0,52,0);
  pp.xz*=r2(.785);
  h=fb(pp*.1,3,.7);  
  h.x/=.1;
  h.x=smin(h.x,p.y+1+d[3]*5+max(0.,b-.5)*sin(-c*25+length(p-vec3(0,0,20))),5.);
  t=t.x<h.x?t:h;
 t.x*=0.8;
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
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	//float f = texture( texFFT, d ).r * 100;
  
  tt=mod(fGlobalTime,62.82);
  s=sin(tt);ss=sin(tt-2);
  b=smoothstep(0.,1.,(clamp(s,.8,.9)-.8)*10);
  c=smoothstep(0.,1.,(clamp(fract((tt-1.1)/6.28),.0,.1))*10);
  vec3 ro=mix(vec3(cos(tt*.4)*10,6-sin(tt*.4)*6,10+b*15),
  vec3(sin(tt*.4)*10,8+cos(tt*.4)*6,25+b*5),
  ceil(sin(tt*.4+1)));
  ro.xy+=sin(c*3.14*5);
  vec3 cw=normalize(vec3(0,5,0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo,po,no,al,ld,re;
  co=fo=clamp(vec3(.17,.12,.14)-length(uv)*.15-rd.y*.2-b*.2,0.,1.);
  z=tr(ro,rd);
  if(z.y>-1){
    po=ro+rd*z.x;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);
    al=clamp(mix(vec3(0),vec3(.5,-.2,-.5),sin(d[int(z.y)]*90)*.5+.5),0.,1.);
    if(z.y==2) al=vec3(0);
    ld=normalize(vec3(-.1,.2,.3));
    re=reflect(no,rd);
    float dif=max(0,dot(no,ld)),
    sp=length(sin(re*4)*.5+.5)/sqrt(3),
    fr=1-pow(dot(no,rd),2),
    ao=clamp(mp(po+no*.1).x/.1,0.,1.);
    ss=smoothstep(0.,1.,mp(po+ld*.4).x/.4);
    
    co=pow(sp,10)*fr+al*(ao+.2)*(dif+ss*.5);
    co=mix(fo,co,exp(-.00001*z.x*z.x*z.x));
  }
	co+=g*.3*mix(vec3(0,.1,.7),vec3(.7,.1,.0),b);
	out_color = vec4(pow(co,vec3(.45)),1);
}