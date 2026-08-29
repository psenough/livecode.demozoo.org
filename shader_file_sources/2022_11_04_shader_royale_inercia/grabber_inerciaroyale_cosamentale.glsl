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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2  rot(float t){ float c = cos(t); float s  = sin(t); return mat2(c,-s,s,c);}
float time = fGlobalTime* mix(1.,2.,step(0.5,fract(fGlobalTime*0.2)))*mix(1.,fract(fGlobalTime),step(0.9,fract(fGlobalTime*0.1)));
float zl;
float se;
float bl(vec2 p ,vec2 b){vec2 q = abs(p)-b;
  return length(max(q,vec2(0.)))+min(0.,max(q.x,q.y));}
float rd(){return fract(sin(se+=1.)*7845.236);}
vec3 vr(){ float z = (rd()-0.5)*2.;
  float s = rd()*6.28;
  float a = sqrt(1.-z*z);
  vec3 vn = vec3(a*cos(s),a*sin(s),z);
  vn *= sqrt(rd());return vn;}
  
float map(vec3 p){ 
  vec3 pr  = p ;

  pr = abs(pr);
  pr -= 30.;
  if(pr.x>pr.y){pr.xy=pr.yx;}
  pr.x-=2.;
  if(pr.x>pr.z){pr.xz=pr.zx;}
  if(pr.y>pr.z){pr.yz=pr.zy;}
  vec3 r = vec3(15.);
  pr = mod(pr,r)-0.5*r;
  float d4 = bl(pr.xy,vec2(2.));
  float d5 = max(length(pr.xz)-0.2,fract(p.y*0.1+time*2.)-0.5);
  float tdd = step(0.75,fract(time*0.25));
  vec3 pb = p;
  for(int  i = 0 ; i <4 ; i++){
    pb -= 0.5;
    pb.ry*= rot(time*1.2);
    pb.xz *= rot(time);
    pb = abs(pb);
  }
  float ta = step(0.5,fract(time*0.5));
  if(ta>0.5){
  float d1 = length(pb-vec3(0.,4.5,0.))-2.;
  float d2 = length(pb-0.1)-1.25+fract(time*3.)*0.5;
  float d3 = p.y+10.;
  zl = min(d5,d2);
  return min(min(d1,min(d2,mix(d4,d3,tdd))),d5);}
  else{
    float d1 = max(length(pb.yz)-0.7,length(p)-8.);
  float d2 = max(length(pb.xy-vec2(3.5,0.))-0.25+fract(time*3.)*0.05,length(p)-8.);
  float d3 = p.y+10.;
  zl = min(d5,d2);
  return min(min(d1,min(d2,mix(d4,d3,tdd))),d5);}
    }
  float rm(vec3 p, vec3 r){
    float dd = 0.;
    for(int  i = 0 ; i< 40 ; i++){
      float d = map(p);
      if(dd>64.){dd= 64.;break;}
      if(d<0.001){break;}
      p += r*d;
      dd +=d;
    }return dd;
    }
    vec3 nor (vec3 p){ vec2 e  = vec2(0.01,0.); return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;
  uv *= 2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  se = uv.x*v2Resolution.x+uv.y;
 // se += time;
  vec3 p = vec3(0.,0.,-16.);
  vec3 r  = normalize(vec3(uv,1.5));
  r.xz *= rot(time);
  p.xz *= rot(time);
  float r1 = 0.;
  for(int  i = 0 ; i< 3 ; i++){
  float d = rm(p,r);
   if(step(0.2,zl)>0.5){
    vec3 pp = p +r*d;
     vec3 n = nor(p);
     r = n+vr();
     p = pp+r*0.1;
   }    else{r1=1.;break;} 
  }
  float b  =sqrt(24.);
  float c = 0.;
  float d1 = 0.001;
  float d2 = 0.00066;
  float d3 = 0.00033;
  float vv = 1.8+pow(length(uv.y),2.)*8.;
  for(float i = -0.5*b ; i<0.5*b ; i+= 1.)
  for(float j = -0.5*b ; j<0.5*b ; j+= 1.){
    c += texture(texPreviousFrame,uc+vec2(i,j)*d1*vv).a;
    c += texture(texPreviousFrame,uc+vec2(i,j)*d2*vv).a;
    c += texture(texPreviousFrame,uc+vec2(i,j)*d3*vv).a;
  }
  c /= 24.;
  c = pow(c,0.8);
  float ta = step(0.5,fract(time*0.5));
  vec3 c2 = mix(vec3(1.),3.*abs(1.-2.*fract(c*0.3-mix(0.1,0.6,ta)+vec3(0.,-1./3.,1./3.)))-1.,mix(0.5,0.3,ta))*c;
	out_color = vec4(vec3(c2),r1);
}