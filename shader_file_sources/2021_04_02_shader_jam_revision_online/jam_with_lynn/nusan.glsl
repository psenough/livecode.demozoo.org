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

float time=fGlobalTime*.6;

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));  
}

float rnd(float t) {
  return fract(sin(t*452.331)*877.574);
}

vec3 rnd(vec3 t) {
  return fract(sin(t*452.331+t.yzx*324.512+t.zxy*741.544)*877.574);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)),10));
}

vec3 add=vec3(0);
float map(vec3 p) {
  
  p.y += (curve(time-length(p.xz)*.01,.2)-.5)*10.;
  
  vec3 bp=p;
  vec3 off=vec3(3,curve(time, .7)*5,0);
  p+=off;
  float t=time*.3;
  p.xy *= rot(t+sin(p.z*.3+time)*.2);
  p.zy *= rot(t*.7+sin(p.x*.3+time*.7)*.2);
  p-=off;
  
  float push=sin(time*0.7)*2+1.5;
  
  float d3=10000;
  float mm=10000;
  for(int i=0; i<4; ++i) {
    float t=curve(time+i, 0.9)*3+time*.4+i;
    p.xz *= rot(t);
    p.xy *= rot(t*.7);
    p=abs(p);
    if(i<3) d3=min(d3, length(p.xz-.7)-.01);
    mm=min(mm, min(p.x, min(p.y,p.z)));
    p-=push*.7;
  }
  
  float d=box(p, vec3(.4));
  add += vec3(1,.3,.7) * 0.0003/(0.01+abs(d));
  
  float d2 = max(abs(length(bp)-7*push)-.4,.7*push-mm);
  add += vec3(.5,.4,1) * 0.0007/(0.1+abs(d2));
  
  d=min(d,d2);
  
  add += vec3(.5,.4,.7) * 0.0007/(0.01+abs(d3));
  d=min(d, d3);
  
  float grid=1.7;
  vec3 pr=abs(fract(bp/grid+.5)-.5);
  vec3 pid=floor(bp/grid);
  if(dot(pr,vec3(1))<.75) pid=floor(bp/grid+.5);
  vec3 mo=rnd(pid);
  
  float mu = .6;//pow(curve(time, .1),2.)*.5+.5;
  
  add += vec3(.5,.6,1) * 0.007*pow(fract(mo.y-time*.7),10)/(0.04+abs(d));
  
  float re2=smoothstep(.7,.3,texture(texRevision, clamp(bp.xz*.01+.5,0,1)).x)*.5*curve(time, .1)+.1;
  float d4=abs(bp.y*.9+4 + re2*10);
  add += vec3(.5,1,.5) * 0.002*re2/(0.01+abs(d4));
  d=min(d,d4);
  
  d *= pow(mo.x,2)*mu+.03;
  
  return d;
}

void cam(inout vec3 p) {
  float t=time*.3;
  p.yz *= rot(sin(time)*.4-.6);
  p.xz *= rot(time);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv.y -= curve(time, .15)*.1;
  uv *= 1+curve(time-length(uv), .1)*.1;
  
  vec2 uv4=uv;
  if(curve(time+7.4, .7)>.5) uv.x=abs(uv.x);
  
  vec3 s=vec3((curve(time, .8)-.5)*15,(curve(time+7.3, .8)-.5)*15,-56);
  vec3 r=normalize(vec3(uv, 1));
  
  cam(s);
  cam(r);
    
  vec3 col=vec3(0);
  vec3 p=s;
  for(int i=0; i<100; ++i) {
    float d=abs(map(p));
    if(d<0.001) {
      d=0.1;
    }
    if(d>100.) break;
    p+=r*d;
    
  }
  col += add;
  
  
  for(int i=0; i<5; ++i) {
    
    vec2 uv3=uv;
    uv3*=rot(.7+sin(i)*.3);
    uv3.x=abs(uv3.x)-.8-rnd(i)*.1;
    uv3=uv3*4+.5;
    uv3.y=fract(uv3.y+time*10*(rnd(i+.7)-.5));
    float rev=smoothstep(.7,.3,texture(texRevision, clamp(uv3,0,1)).x);
    col += vec3(.3,.5,.7)*rev*.1;
  }
  
  float rev=smoothstep(.7,.3,texture(texRevision, clamp(uv4+.5,0,1)).x)*.3;
  col+= vec3(.5,.6,1)*rev*smoothstep(0.7,0.91,curve(time, .5));
  
  
  float t2=time*.2+uv.y + rnd(floor(abs(uv.x)*6-time))*.3;
  //col.xz *= rot(t2);
  col.xy *= rot(t2*1.3);
  col=abs(col);
  
  
  col=smoothstep(0,1,col);
  col=pow(col, vec3(0.4545));
  
	out_color = vec4(col, 1);
}