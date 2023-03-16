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
vec2 z,v,e=vec2(.00035,-.00035);float t,tt,b,bb,g,gg,a,la,wa,tn;vec3 np,cp,pp,po,no,al,ld;
float bo(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
float ex(vec3 p,float s,float h){vec2 w=vec2(s,abs(p.y)-h);return min(max(w.x,w.y),0.)+length(max(w,0.));}
float oc(vec3 p,float r){p=abs(p);return (p.x+p.y+p.z-r)*.57735;}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec4 c=vec4(0,10,7,.1);
vec2 mp( vec3 p)
{
  vec2 h=vec2(1000,3),t=vec2(1000,5);  
  np=vec3(p.xz*.3,.5);
  wa=(1-b)*sin(3*length(p.xz*.1)-5*tt);
  for(int i=0;i<4;i++){
   np.xy=abs(np.xy)-2.4;
    np.xy*=r2(.785*(i+1));
    np*=1.6;
    np.y=abs(np.y)-1.;
    bb=i==3?9.:6.;
    a=ex(p,bo(np.xyx,vec3(6.5,(.14-clamp(sin(np.x*2.),-.2,.2)*.2)*(i+1),6.5))/np.z,bb-i*.5);    
    a=max(abs(a)-.05,abs(p.y)-(bb-.5)+i*.5);
    a=max(a,-(length(p.xy-vec2(0,10))-4));
    t.x=min(t.x,a);
    
    a=ex(p,bo(np.xyx,vec3(6.5,0,6.5))/np.z,bb-i*.5);    
    a=max(a,abs(p.y)-(bb-.5)+i*.5+.5-wa);
    a=max(a,-(length(p.xy-vec2(0,10+wa))-4));
    g+=0.2/(0.1+a*a*(600-590*wa));
    t.x=min(t.x,a);
    
    a=ex(p,bo(np.xyx,vec3(6.5,.15*(i+1),6.5))/np.z,bb-i*.5);    
    a=max(abs(a)-.1,abs(p.y)-(bb-1.)+i*.5);
    a=max(a,-(length(p.xy-vec2(0,10))-4));
    h.x=min(h.x,a);
    
    
  }
  bb=sin(p.y-3*b)*b;
  h.x=min(h.x,.7*bo(p,vec3(1-bb,6+5*b,1-bb)));
  t=t.x<h.x?t:h;
  tn=texture(texNoise,p.xz*.1).r*1.2;
  h=vec2(p.y-5+cos(p.x*.2)*5+cos(p.z*.5)-tn,7);
  pp=p;
  pp.y=mod(pp.y,2)-1;
  //h.x=max(h.x,-(abs(pp.y)-.1-tn*.2));
  la=p.y-4.8+cos(p.x*.2)*5+cos(p.z*.5);
  gg+=0.1/(0.1*la*la*40);
  h.x*=0.6;
  t=t.x<h.x?t:h;
  
  h=vec2(max(oc(p,10.4),-6+p.y),6);
  pp=p;
  pp.xz*=r2(-b*3.14);
  pp.y-=5*b;
  h.x=min(max(oc(pp,10.4),6.1-pp.y),h.x);
  
  t=t.x<h.x?t:h;
  cp=vec3(np.xy,p.y*2);
	return t;
}
vec2 tr( vec3 ro,vec3 rd,int it)
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<it;i++){
    h=mp(ro+rd*t.x);
    if(h.x<.0001||t.x>40) break;
    t.x+=h.x;t.y=h.y;
  }
  if(t.x>40) t.y=0;
	return t;
}
#define a(d) clamp(mp(po+no*d).x/d,0.,1.)
#define s(d) smoothstep(0.,1.,mp(po+ld*d).x/d)
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	//	float f = texture( texFFT, d ).r * 100;
  tt=mod(fGlobalTime,62.82);
  b=smoothstep(0.,1.,clamp(sin(tt),-.2,.2)*2.5+.5);
  vec3 ro=mix(
  vec3(sin(tt*.5),11-cos(tt)*5,cos(tt*.5)*20),
  vec3(cos(tt*c.w+c.x)*c.z,c.y,sin(tt*c.w+c.x)*c.z),
  ceil(sin(tt*.5)));
  ro.xy-=sin(smoothstep(0.,1.,clamp(cos(tt*.5-.25),-.2,.2)*2.5+.5)*16.)*.4;
  vec3 cw=normalize(vec3(0,5,0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo,rco;
  co=fo=vec3(.18,.16,.2)-length(uv)*.25;
  ld=normalize(vec3(.1,.3,-.3));
  z=tr(ro,rd,128);t=z.x;
  if(z.y>0){
    v=cp.xz*.075;
    float d=1;
    for(int i=0;i<4;i++){
   v.xy=abs(v.xy)-1;
    v.xy*=r2(.785);
    v*=1.5;
      d=min(d,ceil(abs(sin(v.x))-.05-clamp(sin(v.y*2),-.1,.1)*.4));
    }
    po=ro+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);al=mix(vec3(.3,.16,.3),vec3(.5),cp.y);
    if(z.y<5)al=vec3(0.);
    if(z.y>5)al=vec3(.5);
    if(z.y>6)al=mix(vec3(.5,.4,.3),vec3(.2),3-tn*5);
    float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),40);
    co=mix(sp+al*(a(.1)+.2)*(dif+s(4)),fo,min(fr,.5));
    co=mix(fo,co,exp(-.0002*t*t*t));
    
    if(z.y==3||z.y==6){
      rd=reflect(rd,no);
      z=tr(po+rd*.01,rd,60);t=z.x;
      po=po+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);al=mix(vec3(.3,.16,.3),vec3(.5),cp.y);
    if(z.y<5)al=vec3(0.);
    if(z.y>5)al=vec3(.5);
    if(z.y>6)al=mix(vec3(.5,.4,.3),vec3(.2),3-tn*5);
    float dif=max(0,dot(no,ld)),    
    sp=pow(max(dot(reflect(-ld,no),-rd),0),40);
    rco=sp+al*(a(.1)+.2)*(dif+s(4));
    rco=mix(fo,rco,exp(-.0002*t*t*t));
      co+=rco*(.5+fr)*d;
    }
  }
uv/=(1-b)*fract(tt/(acos(-1)*2));
  uv*=r2(-tt);
  co*=min(1,ceil(abs(bo(uv.xyx,vec3(.5)))-.1));
  
	out_color = vec4(pow(co+g*.2*vec3(.1,.2,.7),vec3(.45)),1);
}