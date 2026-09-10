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
vec2 z,v,e=vec2(.00035,-.00035);float t,tt,b,bb,g,gg,tnoi;vec3 np,op,bp,pp,po,no,al,ld;
float smin(float a,float b,float k){
  float h=max(k-abs(a-b),0.);
  return min(a,b)-h*h*.25/k;}
float smax(float b,float a,float k){
  float h=max(k-abs(-a-b),0.);
  return min(-a,b)+h*h*.25/k;}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec4 c=vec4(0,5,10,.1);
vec2 mp( vec3 p,float ga )
{
  op=p;
  float spe=0.5;
  
  tnoi=texture(texNoise,op.xz*.1+vec2(0,tt*spe)).r;
  vec2 h,t=vec2(p.y+5+tnoi*3.+cos(op.x*.1)*5.+cos(op.z*.1),6);
  bp=p+vec3(0,2+sin(op.z*.1),0);
  bp.x=abs(bp.x)-15;
  t.x=smin(t.x,length(bp.xy)-4+tnoi+sin(op.z*.1+spe)+sin(op.z+tt*spe)*.1,4.);
  bp.z=mod(bp.z+tt*5,5)-2.5;
  //t.x=smax(length(bp.xz)-.1,t.x,.5);
  t.x=smin(t.x,length(bp.xz)-1+bp.y*.1+tnoi+sin(op.y*15)*0.005,.5);
  float blo=length(bp-vec3(0,5+sin(op.z*.1+spe),0))-.3;
g+=0.1/(0.1+blo*blo*40)*ga;
  t.x=min(t.x,blo);
  //t.x=smax(length(bp.xz)-.5,t.x,1.5);
  t.x*=0.5;
  pp=p;
  pp.xy*=r2(sin(op.z*.1));
  pp.xz*=r2(sin(op.z*.1)*.2);
  pp=vec3(atan(pp.x,pp.y)*4,pp.z,length(pp.xy)-7);
  pp.xy=mod(pp.xy+vec2(0,tt*spe*10.),2)-1;
  h=vec2(length(pp)-0.5,5);
  
  h.x*=0.7;
  t=t.x<h.x?t:h;
  
  h=vec2(length(pp.xz)-0.2,3);  
  h.x*=0.7;
  t=t.x<h.x?t:h;
  
  h=vec2(length(pp.yz)-0.3,6);  
  h.x=max(h.x,abs(pp.z)-.2);
  h.x=max(h.x,abs(abs(pp.y)-.2)-.1);
  float glo=length(pp.yz)-0.1;
  g+=0.1/(0.1+glo*glo*(40-sin(p.z*.1+tt*2.)*39.9))*ga;
  h.x=min(h.x,glo);
  
  
  float part=length(pp-vec3(0,0,5));
  g+=0.1/(0.1+part*part*40)*ga;
  h.x=min(h.x,part);
  h.x*=0.7;
  t=t.x<h.x?t:h;
  
  
  
  return t;
}
vec2 tr( vec3 ro,vec3 rd )
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<128;i++){
    h=mp(ro+rd*t.x,1);
    if(h.x<.0001||t.x>120) break;
    t.x+=h.x;t.y=h.y;
  }
  if(t.x>120) t.y=0;
  return t;
}
#define a(d) clamp(mp(po+no*d,0).x/d,0.,1.)
#define s(d) smoothstep(0.,1.,mp(po+ld*d,0).x/d)
//const vec3[5] cam=vec3[](vec3(),vec3(),vec3());
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
tt=mod(fGlobalTime,62.83);
 //  float f = texture( texFFT, d ).r * 100;
  
//  vec3 ro=vec3(cos(tt*c.w+c.x)*c.z,c.y,sin(tt*c.w+c.x)*c.z),
  vec3 ro=mix(
  vec3(cos(tt*.5)*2,0,-10),
  vec3(cos(tt*.5)*2-15,10,-10),ceil(sin(tt*.5))
  ),
  
  cw=normalize(vec3(0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo;
  co=fo=vec3(.1,.15,.1)-length(uv)*.1;
  ld=normalize(vec3(.2,.5,-.3));
  z=tr(ro,rd);
  t=z.x;
  if(z.y>0){
   po=ro+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy,0).x+
    e.yyx*mp(po+e.yyx,0).x+
    e.yxy*mp(po+e.yxy,0).x+
    e.xxx*mp(po+e.xxx,0).x);al=mix(vec3(.7,.4,.0),vec3(.1,.1,.9),ceil(sin(tt*.5))); 
    if(z.y<5)al=vec3(0);
    if(z.y>5)al=vec3(1)-tnoi*3.;
    float dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),30);
    co=mix(sp+al*(a(.15)*a(.05)+.2)*(dif+s(2)),fo,min(fr,.5));
    co=mix(fo,co,exp(-.00001*t*t*t));
  }
  co=mix(co,co.xzy,length(uv*2.));
  out_color = vec4(pow(co+g*.2*vec3(.1,.2,.7),vec3(.45)),1);
}