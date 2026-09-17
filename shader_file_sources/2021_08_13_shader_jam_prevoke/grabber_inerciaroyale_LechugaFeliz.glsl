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


float t=mod(fGlobalTime, 36.)*.00025;
#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))
float rn(float p){
  return fract(sin(p*345.56)*455.);
  }
float c(float t){
  t*=.41;
  return mix(floor(rn(t)), floor(rn(t+1)), pow(smoothstep(0., 1., fract(t)), 20.));
}
float sb(vec3 p, vec3 s){
  p=abs(p)-s;
  return max(max(p.x,p.y), p.z);
}
void fr(inout vec3 p){
  for(float i = 0.; i < 3.;i++){
    //p.xz *= ro);
    //p.xz*=rot(t*.1);
    //p.xy*=rot(t*.1);
    
    p.xz*=rot(t*.954);
    p.yz*=rot(t*.641);
    p.yx*=rot(t*.64);
    p=abs(p)-25.;
  }
}
float smin(float a, float b, float k){
  float h=max(k-abs(a-b),0.);
  return min(a,b)-h*h-k*(1.0/6.0);
}
float g1,g2,g3;
float m(vec3 p){
  //p.y += sin(t)*.5+.5;
  
  vec3 p1=p;
  //return
  fr(p);
  //p=(fract(p/20.-.5)-.5)*20.;
  
  float d = mix(length(p)-25., sb(p, vec3(10.)),.5+sin(t)*.5-.5);
  float dd=sb(p1, vec3(35.));
  float ddd=length(p1)-fract(sin(t*20.+p.y*.01));
  
  d=smin(d, dd, 1.);
  g3+=.55/(1.+ddd*ddd);
  g2+=.15/(.1+dd*dd);
  g1+=.15/(.1+d*d);
  return d;
}
vec3 nm(vec3 p){
  vec2 e= vec2(0.031, 0.);
  e=abs(e)+.25;
  e*=rot(t*1.95);
  return normalize(vec3(
    e.xyy * (m(p-e.xyy)) +
    e.yyx * (m(p-e.yyx)) +
    e.yxy * (m(p-e.yxy)) +
    e.xxx * (m(p-e.xxx))
  ));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  //t-=c(t*2.45)*15.;
  t=sin(t*.251)*50.;
  t+=c(t*.35)*200.;
  vec3 col=vec3(0.);
  float d;
  vec3 s=vec3(0.01, 0.01, -4.);
  s.x+=sin(t*100.);
  s.z+=sin(t*50.)*20.;
  const float tg=50.;
  s.xz*=rot(t*tg);
  s.yz*=rot(t*tg);
  s.xy*=rot(t*tg);
  //uv.x+=sin(t*.2436)*1.;
  
  //if(mod(t,2.) >= 2.){
    for(float i = 0.; i < sin(t)*4.; i++){
      uv=abs(uv)-.6275;
      uv*=rot(t*20.);
    //}
  }
  
  //uv+=floor(rn(t*.05));
  //uv*=rot(smoothstep(0., 1., rn(t)*2.+uv.x*.001));
  
  vec3 p=s;
  vec3 cz=normalize(p-vec3(0.));
  vec3 cx=normalize(cross(cz,vec3(0., -1., 0.)));
  vec3 cy=normalize(cross(cz,cx));
  
  uv*=rot(t*5.3);
  uv*=10.;
  vec3 r=mat3(cx,cy,cz)*normalize(vec3(sign(uv)*smoothstep(-13.,15., pow(fract(uv+t*.14), vec2(5.)))*
  dot(uv, vec2(-1.5))+sin(t*uv)*.15+4.5, 1.-length(uv)*.25+.25));
  vec3 n,ld=normalize(vec3(-2., -1., -1.));
  float i;
  for(i= 0.; i < 128.; i++) if(d=m(p),p+=d*r,abs(d) < 0.0001 || d > 100.){
    n=nm(p);
    //if(g1< .001){
      r=reflect(r,n);p+=45.;
    //}
    col = vec3(max(dot(ld,n), 0.));
    col +=g1*.0031;
    col=smoothstep(0., 1., col);
    //col=sign(col) < vec3(.0) ? col:-col;
    //break;
  }
  col *= i/(250.+sin(t*2000.)*20.+20.)*abs(nm(p).x*.555)-.15;
  vec3 COL_BAS=vec3(.23, .25, 1.)*.25;
  //COL_BAS.xz*=rot(c(t*.25));
  col+=g3*vec3(.34, .46, .1)*.5;
  col+=g2*vec3(.42, 0.1, 0.)*.5;
  col+=g1*COL_BAS*.005*normalize(texture(texFFTSmoothed,0.01).x*100.)*1.955+.15;
  //col-=length(p.xz)*.000000000000000001;
  //col=1.-pow(col, vec3(3.535));
  //col*=2.675-length(col)*.2395;
  col=pow(col, vec3(2.));
	out_color = vec4(col, 1.);
}