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
vec2 z,v,e=vec2(.0035,-.0035); float t,tt,b,bb,g,cr,gg,ggg,f,fb,fm,ft; vec3 ro,np,rp,bp,cp,pp,op,sp,po,no,al,lp,ld,cop;vec4 su=vec4(0);
float noi(vec3 p){
  vec3 f=floor(p),s=vec3(7,157,113);  p-=f;vec4 h=vec4(0,s.yz,s.y+s.z)+dot(f,s);  p=p*p*(3.-2.*p);
  h=mix(fract(sin(h)*43758.5),fract(sin(h+s.x)*43758.5),p.x);  h.xy=mix(h.xz,h.yw,p.y);
  return mix(h.x,h.y,p.z);}
float cno(vec3 p,float k){  float f=0.; p.z+=tt*k;f+=0.5*noi(p);p=2.1*p;f+=0.25*noi(p+1.);p=2.2*p;
  f+=0.125*noi(p+2.);p=2.3*p;  return f;}
float bo(vec3 p,vec3 r){p=abs(p)-r; return max(max(p.x,p.y),p.z);}
float b2d(vec2 p,vec2 r){  p=abs(p)-r;return length(max(p,0))+min(max(p.x,p.y),0);}
float cy(vec3 p,vec3 r){return max(abs(length(p.xz)-r.x)-r.y,abs(p.y)-r.z/2.);}
float cx(vec3 p,vec3 r){return max(abs(length(p.yz)-r.x)-r.y,abs(p.x)-r.z/2.);}
float cz(vec3 p,vec3 r){return max(abs(length(p.xy)-r.x)-r.y,abs(p.z)-r.z/2.);}
float cap(vec3 p, float h, float r ){ p.y -= clamp( p.y, 0.0, h );return length( p ) - r;}
float ext(vec3 p,float sdf,float h){ vec2 w=vec2(sdf,abs(p.y)-h); return min(max(w.x,w.y),0.)+length(max(w,0));}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
float smin( float d1, float d2, float k ){float h=max(k-abs(d1-d2),0.0);return min(d1, d2) - h*h*0.25/k;}
float smax( float d1, float d2, float k ){float h=max(k-abs(-d1-d2),0.0);return max(-d1,d2)+h*h*0.25/k;}
vec2 smin(vec2 a,vec2 b,float k){float h=clamp(.5+.5*(b.x-a.x)/k,0.,1.);return mix(b,a,h)-k*h*(1.-h);}
vec3 proj(vec3 p){
  p=vec3(atan(p.x,p.z)*8.,abs(abs(p.y)-25.)-7.,length(p.xz)-5.-bb);
  //p=vec3(abs(atan(p.z,p.x))*10.-5., (10.-length(p)), abs(atan(length(p.xz),p.y))*10.);
  //p.yz-=.5*exp(p.y*.1);
  //p.yz*=r2(.3*exp(p.y*.1));
  p.xy=mod(p.xy+vec2(0,tt*2.),2.)-1.;
  return p;
}
/* VOLUMETRIC CLOUDS */
float cmp( vec3 p){
  float t=length(p)-2;
  return t;
}
/* ORBITTTTTTTTT */
vec4 c=vec4(4.57,2,10,0.1);

/* MMMAAAAPPPPPPPPPPPPPPPPPPPP*/
vec2 mp( vec3 p, float ga ){
  op=p;
  
 float tn=texture(texNoise,p.xy).r; 
  //f = texture( texFFTSmoothed, abs(op.z*.01) ).r *500;
  //float ta=smoothstep(0.,1.,(clamp(sin(p.y*.01+tt*.5),-.25,.25)*2.+.5));
  //p=mix(p,p.xzy,ta);
  //float mxr=clamp(sin(tt*.65+p.z*.1),-.5,.5)+.5;
vec3 ccp=p;ccp.y=abs(ccp.y)-5;
  vec2 h,t=vec2(length(p+tn*.2)-4,0);
  vec3 vp=p;
  vp.xy*=r2(.785+tt*.5+fm*.1);
  t.x=smax(abs(abs(vp.y)-.2-fb*.1)-.5,t.x,.5);
  float disp=sin(p.y*.5+tt*2.+fb)*.2;
  pp=p-disp; //tubes  
  pp.xz=abs(pp.xz)-2;
  t.x=smin(t.x,length(pp.xz)-.2,1.);
  vec3 sp=pp;
  sp.xz*=r2(sin(p.y*.4+tt+fm*.5));
  t.x=smin(t.x,length(abs(sp.xz)-.5-abs(p.y)*.1)-.05,0.7);
  float inside=length(p)-3;
  h=vec2(inside,2);
  inside=min(inside,cy(ccp,vec3(7.5,.01,.2)));
  t=t.x<h.x?t:h;
  g+=0.5/(0.1+inside*inside*(20-19*sin(p.y+tt+fm)));
  h=vec2(length(p.xz)-1.,1);
  vec3 cp=p;
  cp.y=abs(cp.y)-1.5-fb;
  h.x=min(h.x,cy(cp,vec3(5,.3,.1)));
  
  h.x=min(h.x,cy(ccp,vec3(7.5,.5,.2)));
  pp=p;
  pp.y=abs(pp.y)-1.5;
  pp.xz=abs(abs(pp.xz)-2.4)-1.2-sin(p.x+tt+fm)*.5;
  pp.xy*=r2(sin(p.x*.5)*.2);
  h.x=smin(h.x,0.8*(length(pp.yz)-.1),0.5);
  t.x=smin(t.x,length(abs(p.xz-tn*.1)-5.75-sin(p.y*.3)*.3-disp)-.5-disp,1.5);
  
t=smin(t,h,1.5);

  //h=vec2(ext(p,b2d(p.xz,vec2(1,2)),2),6);
  pp=p;
  //pp.xz=abs(pp.xz)-1.;
  pp.y=abs(pp.y)-4;
  h=vec2(cy(pp,vec3(12+sin(fm)*3.,.1,.1)),5);
  gg+=0.5/(0.1+h.x*h.x*(20-19*sin(p.y+tt+fm)));
  t=t.x<h.x?t:h;
  t.x*=0.8;
  //t.x=max(t.x,-(length(p-ro)-3));//sphere cut
  return t;
}

vec2 tr( vec3 ro, vec3 rd )
{
  vec2 h,t=vec2(.1);
  for(int i=0;i<128;i++){
    h=mp(ro+rd*t.x,1); if(h.x<.0001||t.x>120) break;
    t.x+=h.x;t.y=h.y;
  } if(t.x>120) t.y=-1;
  return t;
}
#define a(d) clamp(mp(po+no*d,0).x/d,0.,1.)
#define s(d) smoothstep(0.,1.,mp(po+ld*d,0).x/d)
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uuv=uv;
  uv -= 0.5;  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  tt=mod(fGlobalTime,62.82);
  fb = texture( texFFTSmoothed, 0.02 ).r *250;
  fm = texture( texFFTSmoothed, 0.15 ).r *600;
  
  //bb=max(0.,-3.+floor(tt*.25)+smoothstep(0.,1.,min(fract(tt*.25),.25)*4.));
  //b=smoothstep(0.,1.,clamp(sin(tt*.5),-.25,.25)*2.+.5);

  ///////////////////////// CCCCCCAAAAAAAAAAAAAMMMMMMMM
  ro=vec3(cos(tt*c.w+c.x)*c.z,sin(tt*.4)*2.,sin(tt*c.w+c.x)*c.z*1.5);
  vec3 cw=normalize(vec3(0)-ro),
  cu=normalize(cross(cw,vec3(0,1,0))),
  cv=normalize(cross(cu,cw)),
  rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo;
  float ft = texture( texFFTSmoothed, abs(rd.x)*.05 ).r *200;
  co=fo=vec3(.1,.2,.4)-length(uv)*.1-rd.y*.1+ft*.005;

  lp=ro+vec3(0,2,0);
  z=tr(ro,rd);t=z.x;
  if(z.y>-1){
    po=ro+rd*t;
    no=normalize(e.xyy*mp(po+e.xyy,0).x+
    e.yyx*mp(po+e.yyx,0).x+
    e.yxy*mp(po+e.yxy,0).x+
    e.xxx*mp(po+e.xxx,0).x);//al=mix(vec3(.0,0.20,.7),vec3(.1,0.40,.5),sin(cop*2.5)*.5+.5);
    al=mix(vec3(.4,.3-sin(op.y-.5)*.1,.7),vec3(0),z.y*1.3);
    //if(z.y<5)al=vec3(0);
    if(z.y>1)al=vec3(1);
    ld=normalize(lp-po);
    float attn=1.0-pow(min(1.0,length(lp-po)/20.),4.0),
    dif=max(0,dot(no,ld)),
    fr=pow(1+dot(no,rd),4),
    sp=pow(max(dot(reflect(-ld,no),-rd),0),30);
    co=mix((sp+al*(a(.1)*a(.3)+.2)*(dif+s(1)*.3))*attn,fo,min(fr,.5));
    co=mix(fo,co,exp(-.00005*t*t*t));
  }
  //cr=cmp(ro-1.)
  /*cr=0+fract(dot(sin(uv*476.567+uv.yx*785.951+tt),vec2(984.156)));
    for(int i=0;i<120;i++){
        cp=ro+rd*(cr+=1./3.);//(cr+=60./150.);
        if(su.a>.99||cr>t) break;
        float de=clamp(-cmp(cp)+2.*cno(cp,10.),0.,1.); //-0.2-mp(cp).x+0.5*cno(cp*0.5,1.)
        su+=vec4(vec3(mix(1.,0.,de)*de),de)*(1.-su.a);
  }*/
  co=mix(co,su.xyz,su.a*0.8); //mix(su.xyz,fo,1.-exp(-.000005*cr*cr*cr)),su.a*.9)
  //float light=clamp(-0.5-mp(cp-ld*.5).x+2.5*cno(cp*5,5),0.,1.);//cloud lighting
  //su+=vec4(vec3(mix(de*de,light,de)),de)*(1-su.a); //co=su.xyz;
  co=co+g*.2*vec3(.0,.1,.7)+gg*.2*vec3(.7,.1,.1)+ggg*.2;
  //if(length(lp-ro)<t||t==0.) co+=1.6*pow(max(dot(normalize(lp-ro),rd),0.),150.);
  //out_color = texture(texFFTSmoothed,uuv.x*.1);
  out_color = vec4(pow(co,vec3(.55)),1);
}
