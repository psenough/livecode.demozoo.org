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
vec2 z,e=vec2(.00035,-.00035);float tt,b=1,tn,g,bal,di,tu,pa,f;vec3 op,pp,np;
float smin(float a,float b,float k){float h=max(0.,k-abs(a-b));return min(a,b)-h*h*.25/k;}
float smax(float a,float b,float k){float h=max(0.,k-abs(-a-b));return max(-a,b)+h*h*.25/k;}
vec2 smin2(vec2 a,vec2 b,float k){float h=clamp((a.x-b.x)/k*.5+.5,0.,1.);return mix(a,b,h)-h*(1-h)*k;}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec2 mp( vec3 p )
{
  op=p;
  di=cos(p.y*.4);
  p.xz=abs(p.xz)-6-2*di;
  pp=p;
  pp.xz*=r2(sin(p.y*.5+tt));
  np=vec3(atan(pp.x,pp.z)*1.5,pp.y*max(0.1,b),length(pp.xz)-2.5+abs(p.y)*.1);  
  np.xy=abs(abs(abs(np.xy)-11)-6)-3;
  tn=texture(texNoise,np.xy*.1).r;
  np+=tn*.9;
  
  vec2 h,t=vec2(length(np)-1.4,1);  
  t.x=smax(length(np-vec3(0,0,1))-1.3,t.x,.3);  
  bal=length(np)-.9;
  bal=smin(bal,length(np.xz-vec2(0,.5)),.3);
  bal=smin(bal,length(np.xz-vec2(0,1.5)),1.);
  g+=0.1/(0.1+bal*bal*(40-39*sin(pp.y+tt*2.)));
  t.x=min(t.x,bal);
  np.xy=abs(np.xy)-1.6;  
  h=vec2(length(np.xz)-.5-sin(np.y*30)*.02,0);
  
  tu=max(length(np.xy)-.2,abs(np.z)-2-di);
  t.x=smin(t.x,tu,.5);
  op.xz*=r2(-.785);
  op.xz=abs(op.xz);
  op.xz*=r2(-.785);
  t.x=smin(t.x,length(op.xy)-.3-sin(op.z*15)*.02,3.);
  h.x=smin(h.x,.8*(length(np.yz-vec2(0,2.5+di))-.3),.5);
  h.x=smin(h.x,p.y+tn-sin(length(p.xz)-tt*5-f)*.5,.5);
  t=smin2(t,h,.75);
  
  np.z-=3*di;
  np=abs(np)-di;
  pa=length(np);
  
  vec3 rp=op;
  rp.z=mod(rp.z,2)-1;
  pa=min(pa,max(length(rp.xz),abs(op.y)-2));
  t.x=smin(t.x,pa,.5);
   g+=0.1/(0.1+pa*pa*40);
  t.x*=0.7;
	return t;
}
vec2 tr( vec3 ro,vec3 rd )
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<128;i++){
    h=mp(ro+rd*t.x);
    if(h.x<.0001||t.x>80) break;
    t.x+=h.x;t.y=h.y;
  }
  if(t.x>80) t.y=-1;
	return t;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	f = texture( texFFT, 0.1 ).r * 30;
  tt=mod(fGlobalTime,62.82);
  float bro=ceil(cos(tt*.2));
  b=sin(tt*.5)*.5+.5;
  vec3 ro=mix(vec3(sin(tt*.2)*12.,5.,cos(tt*.2)*22.),
  vec3(cos(tt*.2)*2.,cos(tt*.2)*5.+20,sin(tt*.2)*25.),
  bro),
  cw=normalize(vec3(0.,10-bro*10,0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo,po,no,al,ld,re;
  co=fo=clamp((vec3(.14,.1,.12)-length(uv)*.1)*(1-texture(texNoise,rd.xy*.5).r*2.5),0.,1.);
  z=tr(ro,rd);
  if(z.y>-1){
    po=ro+rd*z.x;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);
    al=clamp(mix(vec3(.1,.2,.8)-tn*.5,vec3(1),z.y),0.,1.);
    ld=normalize(vec3(.1,.2,.1));
    re=reflect(rd,no);
    float dif=max(0.,dot(no,ld)),
    sp=length(sin(re*4)*.5+.5)/sqrt(3),
    fr=1-pow(dot(rd,no),2),
    ao=clamp(mp(po+no*.1).x/.1,0.,1.),
    ss=smoothstep(0.,1.,mp(po+ld*.4).x/.4);
    co=pow(sp,10)*fr+al*(ao+.2)*(dif+ss*.5);
    co=mix(fo,co,exp(-.00001*z.x*z.x*z.x));
  }
  co+=g*.3*mix(vec3(.7,.2,1.),vec3(.1,.2,.7),b);
	out_color = mix(vec4(pow(co,vec3(.45)),1),texture(texPreviousFrame,gl_FragCoord.xy / v2Resolution),0.5 );
}