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
float time= fGlobalTime;;
mat2 rot(float t){ float c = cos(t); float s = sin(t); return mat2(c,-s,s,c);}
float rd(float t){ return fract(sin(dot(floor(t),45.236))*7845.236);}
float no(float t){ return mix(rd(t), rd(t+1.),smoothstep(0.,1.,fract(t)));}
float cap(vec3 p, vec3 a, vec3 b){ vec3 pa  = p-a; vec3 ba = b-a;
  float h = clamp(dot(pa,ba)/dot(ba,ba),0.,1.);
  return length(pa-ba*h);}
  float smin(float a, float b){
    float h = clamp(0.5+0.5*(a-b)/0.5,0.,1.);
    return mix(a,b,h)-0.5*h*(1.-h);}
float map(vec3 p){
  vec3 r = vec3(12.,0.,12.);
  p = mix(p,mod(p+0.5*r,r)-0.5*r,step(0.5,no(texture(texFFTIntegrated,0.34).x*4.)));
  float t1 = no(texture(texFFTIntegrated,0.5).x*10.);
  p.xz += vec2(cos(p.y*0.5+t1),sin(p.y*0.5+t1));
  float f = 10.;
  vec2  b=  vec2(-2.,-3.);
  p.x = mix(p.x,-p.x,smoothstep(-1.,1.,p.x));
  float d1 = 100.;
  for( int  i = 0 ;i < 3 ; i++){
    b += 1.;
    float t1 = texture(texFFTIntegrated,i*0.1).x;
       float t2 = texture(texFFTIntegrated,i*0.1-0.1).x;
    vec2 v1 = (vec2(no(t1*f),no(t1*f+6.25))-0.5)*2.;
     vec2 v2 = (vec2(no(t2*f),no(t2*f+6.25))-0.5)*2.;
    d1 = smin(d1,cap(p+vec3(2.,0.,0.),vec3(v1.x,b.x,v1.y),vec3(v2.x,b.y,v2.y))-pow(length(p.y+3.),0.5)*0.8);
    d1 = smin(d1,cap(p+vec3(0.,-3.8,0.),vec3(v1.x*0.5,b.x*0.5,v1.y),vec3(v2.x*0.5,b.y*0.5,v2.y))-2.);
     d1 = smin(d1,cap(p+vec3(3.,-5.8,0.),vec3(b.x,v1.x,v1.y),vec3(b.y,v2.x,v2.y))-(1.-pow(length(p.x),2.)*0.05));
     d1 = smin(d1,cap(p+vec3(0.,-7.,0.),vec3(v1.x*0.1,b.x*0.25,v1.y),vec3(v2.x*0.1,b.y*0.25,v2.y))-0.3);
  }
  float d2 = p.y+3.+no(p.x*10.)*0.05;
  return min(d1,d2);}
  vec3 n(vec3 p){ vec2 e = vec2(0.01,0.); return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
  float ev(vec3 r){ r  = normalize(r*vec3(1.,3.,1.)); return no(r.x*3.);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;
  uv *=2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 p = vec3(0.,0.,-6.-no(texture(texFFTIntegrated,0.55).x*20.)*4.);
  vec3 r = normalize(vec3(uv+vec2(0., no(texture(texFFTIntegrated,0.45).x*4.)),1.));
  p.xz *= rot(time);
r.xz *=rot(time);
  float t1 = sin(time)*mix(0.,1., step(0.5,no(texture(texFFTIntegrated,0.23).x*4.)));;
   p.xy *= rot(t1);
r.xy *= rot(t1);
  float dd;
  for(int  i = 0 ; i < 64 ; i++){
    float d = map(p);
    if(d<0.01){break;}
    p +=r*d;
    dd +=d;
  }
  float d1 = smoothstep(20.,10.,dd);
  float d2 = mix(ev(r), clamp(ev(reflect(r,n(p))),0.,1.),d1);
  float b = sqrt(32.);
  float d = pow(length(uv.y),2.)*0.01+pow(no(texture(texFFTIntegrated,0.7).x*7.),20.)*0.05;
  float d3;
  for(float i = -0.5*b ; i<0.5*b; i+=1.)
    for(float j = -0.5*b ; j<0.5*b; j+=1.){
      d3 += texture(texPreviousFrame,uc+vec2(i,j)*d).a;
    }d3 /= 32.;
    vec3 d4 = mix(vec3(1.),3.*abs(1.-2.*fract(d3*0.8+0.4+vec3(0.,-1./3.,1./3.)))-1.,0.4)*d3*1.2;
    vec3 d5 = mix(vec3(2.,0.,0.),vec3(0.,0.,2.),d3)*d3*1.5;
    vec3 d6 = mix(d4,d5,step(0.5,no(texture(texFFTIntegrated,0.45).x*6.)));
	out_color = vec4(vec3 (d6),d2);
}