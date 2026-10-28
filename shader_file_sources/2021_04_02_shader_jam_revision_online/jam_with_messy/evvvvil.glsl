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
vec2 z,v,e=vec2(.00035,-.00035);float t,tt,b,bb,g,gg,de,cr,n,a,la;vec3 wp,bp,cp,pp,np,po,no,al,ld,ro;
vec4 c=vec4(0,7,25,.05),s=vec4(0);
float bo(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
const mat2 r2fucked=mat2(cos(.023),sin(.023),-cos(.023),sin(.023));
float smin(float a,float b,float k){float h=max(k-abs(a-b),0);return min(a,b)-h*h*.25/k;}
float smax(float a,float b,float k){float h=max(k-abs(-a-b),0);return max(-a,b)+h*h*.25/k;}
float noi(vec3 p){ 
  vec3 f=floor(p),s=vec3(7,157,113);
  p-=f;vec4 h=vec4(0,s.yz,s.y+s.z)+dot(f,s);
  p=p*p*(3-2*p); //here i had this: p*p*(3-.2*p); and could see dot ;)   
  h=mix(fract(sin(h)*48735.5),fract(sin(h+s.x)*48735.5),p.x);
  h.xy=mix(h.xz,h.yw,p.y);
  return mix(h.x,h.y,p.z);
}
const float sp=3;
float fer(vec3 p){ 
  float f=0;
 p.xz*=r2(-p.y*.2);//this is just to make it move 
  p.y-=tt*sp;
  //check out this size pocket perlin that fiits in da loop
  for(int i=0;i<3;i++) f+=0.5/(i+1)*noi(p+i),p*=2.1;
  //done!
  return f;
}
float cmp( vec3 p )
{  
  np=pp=p;pp.xz=abs(pp.xz)-10*cos(p.y*.12);
  bb=cos(p.y-tt*sp);  
  p.xz-=bb;
  pp.xz-=bb*.3;
  np.y-=10;
  np.xz=abs(np.xz)-4;
  float t=length(p.xz)-3-max(0,p.y*.5+1);;
  t=smax(length(np)-4.,t,2.);
  float glo=length(pp.xz)-1.5-sin(p.y*.3+b*6.28-2.5)*.5;
  t=smin(t,glo,2);
  g+=0.1/(0.1+glo*glo*4+2*abs(cos(p.y*.2+b*3.14)));
  float par=max(length(p.xz)-5.2-p.y*.5,length(cos(pp-vec3(0,-tt*4,0)))-.01);
  gg+=0.1/(0.1+par*par*40);
  t=max(t,-(length(p-ro)-3));
	return t;
}

vec2 mp( vec3 p )
{
  
  wp=p;n=0;a=3;
  for(int i=0;i<7;i++){
    wp.xz*=r2(((length(p.xz)*.05)-tt*.2/(i+1))*.3);
    n+=abs(sin(noi((wp+vec3(0,0,tt*3.))*.15)-.5)*3.14)*(a*=.51);    
    wp.xy*=r2fucked;
    wp*=1.75;
  }
  vec2 h,t=vec2(p.y+n*.5,5);
  t.x=smax(cmp(p)+.5,t.x,5);
	return t;
}
vec2 tr( vec3 ro,vec3 rd )
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<128;i++){
    h=mp(ro+rd*t.x);    
    if(h.x<.0001||t.x>43) break;
    t.x+=h.x;t.y=h.y;    
  }
  if(t.x>43) t.y=0;
    
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
//	float f = texture( texFFT, d ).r * 100;
  ro=mix(
  vec3(cos(tt*.4)*5.,10.5,sin(tt*.4)*30),
  vec3(cos(tt*c.w+c.x)*c.z,c.y,sin(tt*c.w+c.x)*c.z),
  ceil(sin(tt*.4)));
  vec3 cw=normalize(vec3(0,10,0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo;
  tt=mod(fGlobalTime,62.82);
  b=fract(tt);
  co=fo=vec3(.1)-length(uv)*.1;
  ld=normalize(vec3(0.,.1,-.3));
  z=tr(ro,rd);t=z.x;  
  if(z.y>0){
    po=ro+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy).x+
    e.yyx*mp(po+e.yyx).x+
    e.yxy*mp(po+e.yxy).x+
    e.xxx*mp(po+e.xxx).x);
    float tn=texture(texNoise,wp.xz*.005).r;
    al=vec3(.1,.2,.9)*tn/n*3.;
    
    float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4);
    
    co=mix(al*(a(.1)+.2)*(dif+s(1)*4),fo,min(fr,.5));
    co=mix(fo,co,exp(-.00005*t*t*t));
  }	
  cr=cmp(ro)-4+.3*fract(dot(sin(uv*465.789+uv.yx*768.654),vec2(987.156)));
  for(int i=0;i<120;i++){
    cp=ro+rd*(cr+=0.2);
    if(s.a>.99||cr>t) break;    
    de=clamp(1.-(cmp(cp)+fer(cp)*2.),0.,1.);
    s+=vec4(vec3(de*de),de)*(1-s.a);
  }
  s.xyz*=1-de*smoothstep(0.,1.6,.01-cmp(cp+ld*1.5)-fer(cp+ld*1.5)*2.0);
  co=mix(co,s.xyz,s.a);
	out_color = vec4(pow(co+g*.2*vec3(.7,.2,.1)+gg*1.5*vec3(.1,.2,.7),vec3(.55)),1);
}