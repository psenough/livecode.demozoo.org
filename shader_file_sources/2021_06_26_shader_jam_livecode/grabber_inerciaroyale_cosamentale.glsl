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
float time = fGlobalTime;
float hs(vec3 p){return fract(sin(dot(p,vec3(45.,95.,123.)))*7845.236);}
mat2 rot(float t){ float c = cos(t); float s = sin(t); return mat2(c,-s,s,c);}
float box(vec3 p, vec3 b){vec3 q = abs(p)-b;
  return length(max(q,vec3(0.)))+min(0.,max(q.x,max(q.y,q.z)));}
  float smin(float a, float b, float t){ float h = clamp(0.5+0.5*(b-a)/t,0.,1.);
    return mix(b,a,h)-t*h*(1.-h);}
    float li(vec3 p , vec3 a ,  vec3 b){vec3 pa = p-a; vec3 ba  = b-a; float h = clamp(dot(pa,ba)/dot(ba,ba),0.,1.);
      return length(pa-ba*h);}
    float l1 ;float zl ;
float map(vec3 p){vec3 pc = p; vec3 pl = p;vec3 pb = p;
  float tn1 = 0.02;float tn2 = 0.4;
  float nn = ((texture(texNoise,p.xy*tn1+23.).x+texture(texNoise,p.zy*tn1+435.).x+texture(texNoise,p.xz*tn1+512.).x)-0.7)*2.;
  nn +=  ((texture(texNoise,p.xy*tn2+296.).x+texture(texNoise,p.zy*tn2).x+texture(texNoise,p.xz*tn2+125.).x)-1.)*0.2;
  float v1 = pow(texture(texNoise,vec2(0.5,time)).x,1.5)*10.;
  float d1 = length (p*vec3(1.,0.8,1.))-2.-nn;
  pc.xy *= rot(0.8);
  pc.xz *= rot(0.8);
  float d2 = box(pc,vec3(1.6))-nn;
  float d3 = smin(d1,d2,0.2);
  float tj = step(0.4,fract(time*0.3));
  float tm4 = time*2.;
  float d4 = length(p+vec3(cos(tm4),sin(time*2.),sin(tm4))*2.7);
  float ta  = 6.28/3.;
  float a = atan(pl.x,pl.z);
  float at = mod(a+0.5*ta,ta)-0.5*ta;
  pl.xz = vec2(cos(at),sin(at))*length(pl.xz);
  pl.y = distance(fract(pl.y),0.5);
  float d6 = max(li(pl,vec3(3.,0.,-100.),vec3(3.,0.,100.)),(length(p.y+0.5)-v1));
  l1 = mix(d4,d6*2.,tj);
  float fzl = 0.003;
  zl += fzl/(fzl+mix(d4,d6,tj));
  pb.xz *= rot(time);
  float d7 = mix((distance(0.5,fract(pb.y))*2.)-0.5,1000.,step(0.3,fract(time)));
  float d5 = min(max(max(d3,-(d3+0.1)),-d7),mix(d4-0.3,d6-0.03,tj));
  return d5;}
 float ev(vec3 r){ float v1 = smoothstep(0.,1.,texture(texNoise,vec2(0.2,time)).x);
   return pow(smoothstep(0.15,0.95,texture(texNoise,r.xz*0.02).x),v1)*smoothstep(1.4,0.,length(r.y));}
 
 vec3 nor (vec3 p){ vec2 e  = vec2(0.01,0.); return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
void main(void)
{
  float v1 = texture(texNoise,vec2(0.51,time*0.4)).x;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;
  uv *=2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 p = vec3(0.,0.,-4.-v1*3.);
  vec3 r = normalize(vec3(uv,1.));
 float tt = time;float tt2 = time*0.5;
  p.xz *= rot(tt);
  r.xz *=rot(tt);
  p.xy *= rot(tt2);
  r.xy *=rot(tt2);
  float dd = 0.;float dm = 10.;
  for(int  i = 0 ; i < 64 ; i++){
    float d = map(p);
    if(dd>dm){dd= dm;break;}
    if(d<0.001){break;}
    p += r*d;
    dd += d;
  }
  float ti1 = step(0.5,fract(time*5.));
  float ti2 = step(0.1,fract(time));
  float s = smoothstep(dm,5.,dd);
  vec3 n = nor(p);
  float dao = 1.;
  float ao = clamp(map(p+n*dao)/dao,0.,1.);
 
  float ld = clamp(dot(n,-r),0.,1.);
  float br = hs(p*0.1);
  float sp = pow(ld,5.+br*5.)*0.5+pow(ld,30.+br*30.)*0.2*br;
  float fr = pow(1.-ld,0.4+br*0.4)*0.2+pow(1.-ld,1.+br)*0.2*br;
  float r0 = pow(ev(reflect(n,r)),1.+br*0.7);
  r0 += sp*0.2;
  r0 += fr*0.2;
  r0 *= ao;
  float li = smoothstep(5.,0.,l1);
   float dss = 2.5;
  float ss = clamp(map(p+r*dss)/dss,0.,1.);
  float li2 = pow(li,mix(1.5,0.5,ss));
  //li2 *= s;
  li2 *= ti1;
   
  float r1 = pow(clamp(mix(ev(r),r0,s),0.,1.),1.+ti2*5.);
  r1 += li2*s*(ti2);
  r1 += zl;float c = 0.;
  for( int i = -1 ; i <= 1 ; i ++)
  for( int j = -1 ; j <= 1 ; j ++){
    c += texture(texPreviousFrame, uc +vec2 (i,j)/v2Resolution).a;
  }
  c/= 9.;
   r1 = mix(r1,c,0.5);
  vec3 rc = mix(vec3(1.),3.*abs(1.-2.*fract(time*40.+vec3(0.,-1./3.,1./3.)))-1.,0.3)*r1*1.5;
	out_color =vec4(vec3(rc),r1);
}