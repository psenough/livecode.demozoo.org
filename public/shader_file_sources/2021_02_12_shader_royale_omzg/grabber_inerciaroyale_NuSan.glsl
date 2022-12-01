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

float time=mod(fGlobalTime*.3, 300.0);

mat2 rot(float a) {
  
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

vec3 rnd(vec3 p) {
  return fract(sin(p*524.574+p.yzx*874.512)*352.341);
}

float rnd(float t) {
  return fract(sin(t*472.547)*537.884);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)), 10));
}

vec3 curve(vec3 t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)), vec3(10)));
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

vec3 repeat(vec3 p, vec3 s) {
  return (fract(p/s+.5)-.5)*s;  
}

vec3 atm=vec3(0);
vec3 id=vec3(0);
float map(vec3 p) {
  
  p.y += curve(time*5-length(p.xz), 1.3)*.6;
  p.xz *= rot(time*.4-length(p.xz)*.3);
    
  vec3 p2=p+sin(time*vec3(1,1.2,.8)*.2)*.03;
  float mm=10000;
  id=vec3(0);
  for(int i=1; i<4; ++i) {
    float t=time*0.1+curve(time+i*.2, 1.3)*4;
    p2.xz *= rot(t);
    t+=sign(p2.x);
    p2.yx *= rot(t*.7);
    
    id += sign(p2)*i*i;
    p2=abs(p2);
    mm=min(mm, min(p2.x,min(p2.y,p2.z)));
    
    p2-=0.2+sin(time*.3)*.3;
  }
  
  p += (curve(rnd(id)+time*.3,.7)-.5)*.8;
  
  float d2=min(mm,1.5-length(p));
  
  float d=abs(length(p)-1-mm*1.4)-.1;
  
  vec3 r2=rnd(id+.1);
  if(r2.x<.3) {
    d=min(d, max(box(repeat(p2, vec3(.25)), vec3(.1)), d-.1)); 
  } else if(r2.x<.7) {
    d=min(d, max(length(repeat(p2, vec3(.15)).xy-.05), d-.2)); 
  }
  
  d=max(d,0.06-mm);
  
  
  atm += vec3(1,0.5,0.3)*r2*0.0013/(0.01+abs(d2))*max(0,curve(time+r2.y, .3)-.4);
  d2=max(d2,0.2);
  
  d=min(d,d2);
  
  float d3 = p.y+2;
  
  vec3 p3 = repeat(p,vec3(10,10,10));
  d3 = min(d3, length(p3.xz)-0.7);
  //d=min(d, max(d3, 0.5-abs(p3.y)));
  
  d=min(d, max(d3, .2-mm));
  
  return d;
}

void cam(inout vec3 p) {
  
  float t=time*.2;//+curve(time, 1.3)*7;
  p.yz *= rot(sin(t*1.3)*.5-.7);
  p.xz *= rot(t);
}

float gao(vec3 p, vec3 r, float d) {
  return clamp(map(p+r*d)/d,0,1)*.5+.5;  
}

float rnd(vec2 uv) {
  return fract(dot(sin(uv*521.744+uv.yx*352.512),vec2(471.52)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  //uv *= 1+curve(time*3-length(uv),.7)*.2; 

  vec3 s=vec3(curve(time, .7)-.5,curve(time+7.2, .8)-.5,-8);
  vec3 r=normalize(vec3(uv, .8 + curve(time, 1.7)*1.4));
  
  cam(s);
  cam(r);
  
  bool hit=false;
  
  vec3 p=s;
  for(int i=0; i<100; ++i) {
    
    float d=map(p);
    if(d<0.001) {
      hit=true;
      break;
    }
    if(d>100.0) break;
    
    p+=r*d*.8;
    
  }
  
  vec3 col=vec3(0);
  if(hit) {
    vec3 id2=id;
    vec2 off=vec2(0.01,0);
    vec3 n=normalize(map(p)-vec3(map(p+off.xyy), map(p+off.yxy), map(p+off.yyx)));
    vec3 l=normalize(vec3(1,-3,2));
    if(dot(l,n)<0) l=-l;
    vec3 h=normalize(l+r);
    float spec=max(0,dot(n,h));
    
    float fog=1-clamp(length(p-s),0,1);
        
    float ao=gao(p,n,.1)*gao(p,n,.2)*gao(p,n,.4)*gao(p,n,.8);
    col += max(0,dot(n,l)) * (0.3 + pow(spec,10) + pow(spec,50)) * ao * 3;
    
    for(int i=1; i<15; ++i) {
      float dist=i*.07;
      col += max(0,map(p+r*dist)) * vec3(.5+dist,0.5,0.5) * .8 * ao;
    }
    
    off.x=0.04;
    vec3 n2=normalize(map(p)-vec3(map(p+off.xyy), map(p+off.yxy), map(p+off.yyx)));
    col += vec3(id2.x,id2.y*.5+.4,.7)*pow(curve(time-id2.z, .7),4)*.1*length(n-n2);
    
    //col+=map(p-r*.2)*4;
  }
  
  col += pow(atm*3.,vec3(2.));
  
  col += max(col.yzx-1,0);
  col += max(col.zxy-1,0);
  
  col *= 1.2-length(uv);
  
  float t4 = time*.3+uv.y*.6+floor(abs(uv.x+col.x*.1)*3)*17;
  col.xz*=rot(t4);
  col.yz*=rot(t4*1.3);
  col=abs(col);
  
  col=smoothstep(0.0,1.,col);
  col=pow(col, vec3(.4545));
  
  vec2 uv2=gl_FragCoord.xy / v2Resolution.xy;
  uv2-=.5;
  uv2*=.92+rnd(uv2)*.03;
  uv2+=.5;
  vec3 c2=texture(texPreviousFrame, uv2).xyz;
  float t3=0.0;
  c2.xz *= rot(.05+t3);
  c2.xy *= rot(.02+t3);
  c2=abs(c2);
  float fac=clamp(1.5-length(uv)*1.3,0,1);
  fac=min(fac, pow(fract(time*.5),2.));
  col *= 0.3+fac*.7;
  col += c2*.9*(1-fac);
  
	out_color = vec4(col, 1);
}