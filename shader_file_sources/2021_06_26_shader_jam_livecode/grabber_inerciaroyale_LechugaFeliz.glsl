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
uniform sampler2D texTexBee;
uniform sampler2D texTexOni;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))
float t=mod(fGlobalTime, 100.)*.15;
float st(vec3 p, vec2 s){
  return length(vec2(length(p.xy)-s.x,p.z))-s.y;
}
float cp(vec3 p, float s){
  vec3 ab=p-vec3(1.,2.,3.);
  vec3 bp=p+vec3(1.,2.,3.);
  //float t=clamp(,0.,1.);
  //return length()
  return 0.;
}
float smin(float a, float b, float k){
  float h=max(k-abs(a-b),0.);
  return min(a,b)-h*h*.25/k;
}
float sb(vec3 p, vec3 s){
  p=abs(p)-s;
  return max(max(p.x,p.y),p.z);
}
const float pi = acos(-1.);
float h(float p){return fract(sin(p*233.)*566.);}
vec2 h(vec2 p){return fract(sin(p*233.+p.yx*454.34)*vec2(566.));}
float c(float t){return mix(h(floor(t)), h(floor(t+1)), pow(smoothstep(fract(t), 0., 1.),20.));}
float g0,g1,g2,g3,g4,g5;
const float cut=100.;
float m1(vec3 p){
  
  vec2 id=h(floor(p.xz/cut-.5));
  
  p.y+=sin(t+id.y*2.)*10.+10.; //movement
  //p.x=abs(p.x)-20.;
  
  
  p.xz=(fract(p.xz/cut-.5)-.5)*cut;
  p.yz*=rot(id.y*.25*pi/2.);
  const float dd2=2.1;
  float d=st(p,vec2(1.,.023));
  
  float cc1=length(p)-.25;
  
  g1+=.1/(.1+cc1);
  float cc2=length(p-vec3(0., 0., dd2))-2.;
  
  g2+=.1/(.1+cc2*cc2);
  vec3 p1=p;
  p1.x+=sin(p1.y*.11+t*.56);
  p1.z+=sin(p1.y*.46+t*.23);
  float cc3=length(p1.xz-vec2(0., dd2))-.25;
  cc3+=h(cc3);
  cc3=max(cc3,p1.y+1.2);
  
  g3+=.1/(.1+cc3);
  vec3 p2=p;
  p2.yz*=rot(1.09);
  float cc4=length(p2.xy)-sin(sin(t*50.)*.95+.25+t*50.*id.x*2.)*.5+.5;
  cc4+=h(cc4);
  cc4=max(cc4,p.z);
  g4+=.1/(.1+cc4*cc4*cc4);
  cc4*=.6;
  cc4=max(cc4,p.z);
  d=smin(d,cc1,1.);
  d=smin(d,cc2,1.);
  d=smin(d,cc3,1.);
  //g0=d;
  d=smin(d,cc4,1.);
  
  return d;
}
float m(vec3 p){
  
  float d=m1(p);
  p.xz=(fract(p.xz/5.-.5)-.5)*5.;
  float cc1=sb(p-vec3(0., 5., 0.),vec3(1.,.25,1.));
  g5+=1./(1.+cc1*cc1);
  d=min(d,cc1);
  return d;
}
void cam(inout vec3 p){
  p.z+=t*250.;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  vec3 s=vec3(0.01, 0.01, -16.);
  cam(s);
  //s.xz*=rot(t*.221);
  //s.x+=sin(t)*20.;
  
  vec3 p=s;
  vec3 pp=vec3(0.01);
  cam(pp);
  pp.x+=sin(t*2.)*200.;
  vec3 cz=normalize(pp-s);
  vec3 cx=normalize(cross(cz,vec3(0.,-1., 0.)));
  vec3 cy=normalize(cross(cz,cx));
  vec3 r=mat3(cx,cy,cz)*normalize(vec3(-uv, 1.-fract(length(uv)*1.5+t)));
  const vec2 e=vec2(0.01, 0.);
  vec3 co,fo,al,ld,n;
  float d;
  ld=normalize(vec3(-1.,-1.,-1.));
  al=vec3(0.57);
  co=fo=vec3(0.)-length(uv)*.006;
  for(float i=0.; i < 100.; i++) if(d=m(p),p+=d*r,abs(d)-.15 < .0001){
    //if(d > 1.) break;
    n=normalize(
      e.xyy *(m(p+e.xyy)) +
      e.yyx *(m(p+e.yyx)) +
      e.yxy *(m(p+e.yxy)) +
      e.xxx *(m(p+e.xxx))
    );
    if(g0<.5) r=reflect(r,n),p+=1.25;
    float dif=max(dot(ld,n),0.);
    float fr=pow(1.+dif,3.);
    float sp=pow(dot(reflect(-ld, n),-r),40.);
    co=mix(dif*sp*al,fo,min(fr,.44));
  }
  
  co+=g1*vec3(0.25)*.96;
  co+=g2*vec3(0.001,0.,0.006)*.85;
  co+=g3*vec3(0.01, 0.1, 0.25)*.2;
  co+=g4*vec3(1., 0., 0.)*.15;
  co+=g5*vec3(0.13)*.065;
  //co=smoothstep(0., 1., co);
  //co=pow(co, vec3(.4545));
  co=max(co, 0.);
  
	out_color = sqrt(vec4(co, 1.));
}