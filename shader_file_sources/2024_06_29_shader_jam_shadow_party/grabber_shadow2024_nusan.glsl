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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = mod(fGlobalTime, 300.0);

float fft(float t) {
  return texture(texFFTSmoothed, fract(t)*0.1+0.01).x;
}

float ffti(float t) {
  return texture(texFFTIntegrated, fract(t)*0.1+0.01).x*0.02;
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

float rnd(float d) {
  return fract(sin(d*342.034)*435.923);
}
vec3 rnd(vec3 d) {
  return fract(sin(d*342.034+d.yzx*463.553+d.zxy*843.854)*435.923);
}
vec2 rnd(vec2 d) {
  return fract(sin(d*342.034+d.yx*463.553)*435.923);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1.0), pow(smoothstep(0,1,fract(t)),10.0));
}

float curvei(float t, float d) {
  t/=d;
  return mix(rnd(floor(t))+floor(t), rnd(floor(t)+1.0)+floor(t)+1.0, pow(smoothstep(0,1,fract(t)),10.0));
}

vec3 amb=vec3(0);
float map(vec3 p) {
  
  vec3 bp=p;
  float ex=fft(0);
  for(int i=0; i<3; ++i) {
    p.xy *= rot(ffti(0.02+0.01*i)+time*0.1);
    p.xz *= rot(ffti(0.032+0.01*i)+time*0.06);
    p=abs(p)-0.3-pow(ex,0.2)*1.0;
  }
  
  float d2=abs(length(p.xz)-0.01);
  d2=max(d2,abs(p.y)-curve(time-p.x*20,0.2)*20.0);
  float d=d2;
  amb += vec3(1,0.3,0.5) * 0.0003/(0.01+d2);
  
  p=abs(p)-0.1;
  p=abs(p)-0.05;
  
  p=abs(p-2.0)-2.0;
  
  p=abs(p-5.0)-5.0;
  
  float ll=max(1,length(bp)*0.3);
  d=min(d, box(p, vec3(curve(time,0.5)*1.5,0.025,0.025)*ll));

  d=min(d, length(bp)-3.0);
  
  return d;
}

vec3 getnorm(float d, vec3 p) {
  vec2 off=vec2(d,0.0);
  return normalize(map(p)-vec3(map(p-off.xyy),map(p-off.yxy),map(p-off.yyx)));
}

void cam(inout vec3 p) {
  
    p.xz *= rot(time*0.1);
    p.yz *= rot(time*0.06);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  time = mod(fGlobalTime, 300.0);
  time*=0.3;
  time += rnd(floor(fGlobalTime/2.0-length(uv)*0.2))*300.0;
  time += rnd(floor(fGlobalTime/2.0+0.5-abs(uv.x)*0.2))*300.0;
  time += rnd(floor(uv*20+time)).x*(0.0+2.0*max(0,length(uv)*curve(time, 0.3)-0.3));
  time*=0.1+max(0,curve(floor(time), 3)-0.2);
  
  if(rnd(floor(time)+0.1)<0.3) uv.x=abs(uv.x);
  if(rnd(floor(time)+0.2)<0.3) uv.y=abs(uv.y);
  
  vec3 col=vec3(0);
  
  vec3 p=vec3(0,0,-10-curve(time, 7.2)*10);
  p.x+=(curve(time, 1.2)-0.5)*8.0;
  p.y+=(curve(time, 1.4)-0.5)*3.0;
  vec3 r=normalize(vec3(uv, 1*curve(time, 4.7)*1.6+0.2));
  
  cam(r);
  cam(p);
  
  float ligh=clamp(sin(fGlobalTime/10)*1.5+0.5,0,1);
  
  vec3 s=p;
  vec3 alpha=vec3(1.0);
  float first=-1;
  for(int i=0; i<100; ++i) {
    float d=map(p); 
    col += amb*alpha*(1-ligh);
    if(abs(d)<0.001) {
      vec3 n=getnorm(0.01,p);
      //col += dot(n,vec3(0,1,0));
      float rough=rnd(floor(p*7.0)).y*0.3;
      n=normalize(n+rough*rnd(vec3(uv,i)));
      r=reflect(r,n);
      if(first<0) first=length(p-s);
      d=0.1;
      alpha*=0.7;
      //break;
    }
    if(d>100.0) break;
    p+=r*d;
  }
  float dep=map(p);
  if(dep>100.0) {
    col += alpha * vec3(0.6,0.6,1.0)*1.0*(r.y*0.5+0.5) * ligh;
    col += alpha * vec3(1.6,0.8,0.4)*4.6*pow(max(0,r.x),10.0);
  
    col *=0.8;
    
    col *= 1.2-length(uv);
    
    col = pow(col, vec3(0.4545));
    col = smoothstep(0,1,col);
    
  }
  
  if(first<curve(time, 2.9)*.0) {
    vec3 prev=vec3(0.);
    vec2 off=uv*0.01*(0.04+30.7*fft(0.03));
    vec2 buv=gl_FragCoord.xy / v2Resolution.xy;
    prev.x += texture(texPreviousFrame, buv-off).x;
    prev.y += texture(texPreviousFrame, buv+off*0.1).y;
    prev.z += texture(texPreviousFrame, buv+off).z;
    
    col = mix(col, prev, 0.9+0.4*max(0,curve(time+rnd(floor(buv.y*(10+100*curve(time,0.1))))*100.0,6)-0.3));
  }
  
  
	out_color = vec4(col, 1);
}