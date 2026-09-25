#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT;
uniform sampler1D texFFTSmoothed;
uniform sampler1D texFFTIntegrated;
uniform sampler2D texPreviousFrame;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color;

#define pi acos(-1)
#define pi2 (acos(-1)*2)
#define R v2Resolution

float T = fGlobalTime/60 * 120;
#define FT(i) (texelFetch(texFFTIntegrated,i,0).x*0.1)

#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))  
#define saturate(x) clamp(x,0.0,1.0)
float mx(vec3 p){return max(p.x,max(p.y,p.z));}

vec3 uv2sp(vec2 uv){return vec3(2.0*uv.x,2.0*uv.y,uv.x*uv.x+uv.y*uv.y-1.0)/(uv.x*uv.x+uv.y*uv.y+1.0);}

vec2 sp2uv(vec3 p){return p.xy/(1.0-p.z);}
vec4 rndz(ivec3 p, int s) {
    p-=ivec3(p.x<=0,p.y<=0,p.z<=0);
    // p-=ivec3(p<=0);
    ivec4 c = ivec4(p.xyz, s);
    int r = (int(0x3504f333*c.x*c.x+c.y)*int(0xf1bbcdcb*c.y*c.y+c.x)*int(0xbf5c3da7*c.z*c.z+c.y)*int(0x2eb164b3*c.w*c.w+c.z));
    ivec4 r4 = ivec4(0xbf5c3da7,0xa4f8e125,0x9284afeb,0xe4f5ae21)*r;
    return (vec4(r4)*(2.0/8589934592.0)+0.5)*0.99999;
}



vec4 ff(vec3 p){
float d=99999;
  d=min(d,length(p)+0.5);
  //d=min(d,length(p-sign(p.y)*vec3(0,1,0))-0.25);
  float sd=d;
  float ed=d;
  p.xz=abs(p.xz)-.2;
  for(int i=0;i<8;i++){
    vec4 rnd1=rndz(ivec3(1,2,3),1+i);
    vec4 rnd2=rndz(ivec3(2,2,3),1+i);
    float lt=T*.013+float(i)*.25+FT(5+i*2)*.73;
    //lt+=sin(lt);
    //lt+=sin(lt);
    lt=mix(lt,floor(lt)+smoothstep(0.9,1.0,fract(lt)),.9);
    //lt*=pi*.5;
  vec3 v=sin((lt*.401+FT(3+i)*0)*(1+rnd1.xyz)*.4073);
    v*=2;
    v.y+=(fract(T*.4+float(i)/7)*2-1)*4;
    vec3 sz=exp(-1+1.5*sin((lt*1.401+FT(13+i)*0)*.6013*(1+rnd2.xyz)));
    vec3 lp=p-v;
    lp.xz*=rot(lt*2.);
    float nd=mx(abs(lp)-sz)-1.4205;
    //if(i%2==0)nd=length(lp)-1.4;
    ed=min(ed,max(abs(sd),abs(nd-.05)-.2)-0.01-.025*rnd2.w);
    nd+=.22;
    sd=min(nd,max(sd,.12-nd));
    //sd=min(sd,nd);
    
    }
    d=min(d,ed);
  d=min(d,sd+.7212);
  return vec4(d,sd,0,0);
}
float f(vec3 p){
  return ff(p).x;
}
vec3 trace(vec3 ro,vec3 rd){
  vec3 p=ro+rd*0;
  
  for(int i=0;i<30;i++){
    float d=f(p);
    float z=length(p-ro);
  if(abs(d)<.003||z>250)break;
    p+=rd*d;
    
    }
    p+=rd*f(p);
  return p;
}
vec3 nor(vec3 p,float eps){
vec2 e=vec2(eps,0);
vec3 n=-vec3(
  f(p-e.xyy)-f(p+e.xyy),
  f(p-e.yxy)-f(p+e.yxy),
  f(p-e.yyx)-f(p+e.yyx));
n=length(n)>0.0?normalize(n):vec3(1,0,0);
  return n;
  
}
vec3 envi(vec3 rd){
  vec3 p=normalize(rd);
  //p.xy*=rot(13*sin(T*.003));
float el=asin(p.y)/acos(-1);
  float d=length(sp2uv(p.zxy));
  el=exp(-d*1.1);
  float xf=abs(el);
  xf=pow(xf,.5);
  float fx=exp2((xf-1)*10);
  vec3 c=pow(textureLod(texFFTSmoothed,fx,0).xxx*8*pow(fx*20,.36),exp2(.5*vec3(2,2,2)))*2.3;  
  c+=.31/(1-p.y);
  return c;
  }
vec3 ftex(vec3 p){
vec3 c=vec3(0);
  vec3 dir=normalize(vec3(0,2,0));
  float tx=dot(p,dir)*.5;
  float xf=abs(fract(tx)*2-1);
  vec4 ftx=ff(p);
  
  xf=fract(tx*0+p.y*.0+ftx.y*5+.15+T*.01);
  xf=pow(xf,1);
  float fx=exp2((xf-1)*9);
  c=pow(textureLod(texFFTSmoothed,fx,0).xxx*8*pow(fx*20,.36),exp2(.5*vec3(2,2,2)))*2.3;
  
  return c;
  }
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvp=(uv-0.5)*R/R.y;  
  ivec2 ip = ivec2(gl_FragCoord.xy);

  vec3 c=vec3(uv.xy,0);
  float fx=exp2((uv.y-1)*10);
  c=pow(texture(texFFTSmoothed,fx).xxx*8*pow(fx*20,.6),exp2(.5*vec3(2,1,0)))*2.3;
  c=c*1.05/(1+c);
  
  vec3 ro=vec3(0,0,-7);
  vec3 rd=normalize(vec3(uvp,.36));
  //vec2 uvs=sp2uv(uv2sp(uvp)*.1)*3.016;
  //rd=normalize(vec3(uvs,.14));
  
      float lt=T*.22+FT(7)*.3;
    //lt+=sin(lt);
    //lt+=sin(lt);
    lt=mix(lt,floor(lt)+smoothstep(0.9,1.0,fract(lt)),.9);
  lt*=9;
  
   float az=1.6413*sin(lt*0.001*pi2)+fract(T*.2)*pi*2;
  float el=.0+0.963126*cos(lt*0.025*pi2);
  ro.yz*=rot(el);
  rd.yz*=rot(el);
  
  ro.xz*=rot(az);
  rd.xz*=rot(az);
  
  rd.yz*=rot(.142*sin(lt*.071));
  rd.xz*=rot(.242*sin(lt*.131));

  //c.rgb+=fract(rd*8)*0.2;
  vec3 p=trace(ro,rd);
  bool bghit=length(p-ro)>200;
  if(abs(f(p).x)>.01)bghit=true;
  if(bghit)p=rd*8;
  //c.rgb+=fract(p*8)*0.2;
  vec3 n=nor(p,.05);
  vec3 ref=reflect(rd,n);
  c=ftex(p);
  c+=envi(ref)*.1;
  
  if(bghit)c=envi(rd)*.14;
  
  vec2 clp=(1-uv)*R/64-0.5;
  if(length(clp)<.5)c=vec3(1)*float((atan(clp.x,clp.y)/pi2+.5<fract(T/2))^^(int(floor(T/2))%2==0));
  vec4 cprev=texture(texPreviousFrame,uv);
  out_color = vec4(cprev.wxy*.175+c.x*.5,c.x);
}

