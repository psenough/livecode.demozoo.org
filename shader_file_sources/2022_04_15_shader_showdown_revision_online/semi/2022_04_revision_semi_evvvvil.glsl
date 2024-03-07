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
vec2 z,v,e=vec2(-.00035,.00035);float t,tt,b,bb,g,gg,r,a,s,tnoi;vec3 pp,rp,op,po,no,al,ld;
vec4 c=vec4(0,-5,12,0);
float smin(float a,float b,float k){float h=max(0.,k-abs(a-b));return min(a,b)-h*h*.25/k;}
float smax(float a,float b,float k){float h=max(0.,k-abs(-a-b));return max(-a,b)+h*h*.25/k;}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
float cy(vec3 p,float r){
  vec3 pp=abs(p)-vec3(.1,10.,.1);
  
  return mix(
  length(p.xz)-r,max(max(pp.x,pp.y),pp.z),bb);
  }
const float PI=acos(-1);
vec2 mp( vec3 p)
{
  op=p;
  bb=clamp(sin(op.y*.1-tt*.75),-.25,.25)*2.+.5;
  p.xz*=r2(sin(op.y*.1+bb*2.)+tt*.1);
  pp=p+sin(op.y*.5)-cos(op.y*.2+tt)+sin(op.z*op.y*0.01);
  rp=vec3(atan(pp.x,pp.z)*10/PI,pp.y,length(pp.xz)-2.5);
  rp.x=mod(rp.x,4)-2;
  rp.y=mod(rp.y,8)-4;
  
  v=vec2(atan(pp.z,pp.x)/(2*PI),pp.y*.1);
  tnoi=texture(texNoise,v).r;
  vec2 h,t=vec2(cy(pp,3-tnoi),0);  
  t.x=smin(t.x,cy(rp,.5+cos(rp.y*15)*.03),.5);  
  float bu=cos(p.y*.15)*3.,
  ta=abs(p.y)*.05,
  ex=max(0,abs(p.y)-5),
  wav=sin(p.y*2.+tt*5.)*ex*.075;
  
  t.x=smin(t.x,cy(abs(pp)-4+bu,1-ta),1.);  
  t.x=smin(t.x,cy(abs(abs(pp)-3.8+bu)-.4-ta-wav-ex*.1,0.5-ta),.5);  
  t.x=smax(length(rp)-1+tnoi,t.x,1.4);  
  rp.y+=sin(rp.z*.5+tt*2.)*min(rp.z-.2,1.)*.5;
  t.x=smin(t.x,cy(rp.xzy,.17-rp.z*.02),0.5);  
  pp=rp;
  pp.z=abs(pp.z)-8;
  t.x=smin(t.x,max(length(pp)-.1,-(length(pp)-.8)),1.0);  
  
  h=vec2(length(rp)-1.1+tnoi,1);
  h.x=smax(length(rp.xy)-0.6+tnoi,h.x,0.5);
  h.x=min(length(abs(rp.xy)-.2-rp.z*.1)-0.05,h.x);
  h.x=max(h.x,abs(rp.z)-8);
  pp.xy=abs(pp.xy)-.2-rp.z*.1;
  bu=length(pp)-.02;
  g+=0.1/(0.1*bu*bu*50);
  h.x=min(h.x,bu);
  t=t.x<h.x?t:h;
  t.x*=0.6;
	return t;
}
vec2 tr( vec3 ro, vec3 rd)
{
  vec2 h,t=vec2(1.);
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
tt=mod(fGlobalTime,83.7);
	//float f = texture( texFFT, d ).r * 100;
  
  vec3 ro=vec3(cos(tt*c.w)*c.z,cos(tt*.2)*11,sin(tt*c.w)*c.z),
  cw=normalize(vec3(0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo;
  co=fo=vec3(.1,.2,.3)-length(uv)*.2-sin(uv.x*40)*rd.y*.01;
  ld=normalize(vec3(.2,-.2,.3));
  z=tr(ro,rd);t=z.x;
  if(z.y>-1){
    po=ro+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x); 
    al=mix(vec3(1,.3,.2),vec3(.1,.1,1.),sin(tnoi*5-1.5)*.5+.5);
    al=mix(al,vec3(1,.3-sin(op.y)*.2,.2),bb);
    if(z.y>0) al=vec3(0);
float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),40);
co=mix(sp+al*(a(.05)*a(.15)+.2)*(dif+s(2)),fo,min(fr,.5));
    co=mix(fo,co,exp(-.00002*t*t*t));
    co=mix(co,fo,abs(uv.y*1.7));
    }
	
	out_color = vec4(pow(co+g*.2*vec3(1,.5,.2),vec3(.45)),1);
}