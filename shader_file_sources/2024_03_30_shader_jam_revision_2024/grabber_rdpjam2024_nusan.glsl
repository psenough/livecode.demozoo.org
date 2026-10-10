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

float time = mod(fGlobalTime, 300);

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);  
}

float fft(float t) {
  return texture(texFFTSmoothed, 0.01+fract(t)*0.1).x;
}

float rnd(float t) {
  return fract(sin(t*234.854)*543.945);
}
vec3 rnd(vec3 t) {
  return fract(sin(t*234.854+t.yzx*453.864+t.zxy*564.954)*543.945);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)),10));
}

float sec;

vec3 atm=vec3(0);
float map(vec3 p) {
  vec3 bp=p;
  for(int i=0; i<3; ++i ){
    p.yz *= rot(time*0.3 + i +fft(0.02+i*0.02)*2);
    p.xz *= rot(time*0.2 + i*0.3 + fft(0.03+i*0.1)*2);
    p=abs(p)-1-min(fft(0.02),0.1)*10-3;
  }
  
  vec3 p2=p;
  
  float d=box(p,vec3(1));
  
  p=abs(p)-3;
  p=abs(p)-1;
  d=min(d, box(p,vec3(0.2,0.2,30)));
  
  p2=abs(p2)-7;
  
  //d=min(d, box(p2,vec3(30,0.2,0.2)));
  
  
  d = max(d, 20-length(bp));
  
  d = min(d, length(bp)-10);
  
  float d2 = length(p.xz)-0.1;
  d=min(d,max(d2,0.1));
  //if(rnd(sec+0.1)<0.5) atm-= vec3(1,0.4,0.8) * 0.004/(0.01+abs(d2));
  
  return d;
}

void cam(inout vec3 p) {
  p.xz *= rot(time*0.12);
  p.xy*=rot(time*0.1);
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time=mod(fGlobalTime, 300);
  sec=floor(time-length(uv)/3);
  
  
  time *= 0.3;
  
  //time *= 0.4+sin(time)*0.02;
  time += rnd(sec)*400;
  time += rnd(floor(abs(uv.x)*5-time*10)*0.3+0.1)*0.9;
  
  uv.y -= fft(0)-0.05;

  if(rnd(sec*0.3)<0.3) uv.x=abs(uv.x);
  if(rnd(sec*0.4)<0.3) uv.y=abs(uv.y);
  
  vec3 s=vec3(0,0,-80);
  s.x += sin(time/30)*10;
  vec3 r=normalize(vec3(uv,0.3+4*rnd(sec+0.2)));
  cam(s);
  cam(r);
  
  vec3 col=vec3(0);
  
  vec3 p=s;
  float alpha=1;
  float fd=10000;
  bool first=true;
  for(int i=0; i<100; ++i) {
    float d=abs(map(p));
    if(d<0.001) {
      //col += map(p-r);
      vec2 off=vec2(0.01,0);
      vec3 n=normalize(map(p)-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx))); 
      float rough=0.3;
      n=normalize(n+(rnd(vec3(uv,0.4))-0.5)*rough);
      r=reflect(r,n);
      d=0.1;
      if(first) {fd=d; first=false;}
      //
      //atm *= 0;
      alpha*=0.7;
      //break;
    }
    if(d>100) break;
    p+=r*d;
  }
  
  col += alpha*pow(abs(dot(r,vec3(0.7))),2) * 2*vec3(1,0.6,0.3);
  col += alpha*vec3(0.4,0.5,1)*0.7;
  col += atm*alpha;
  
  col *= 1.3-length(uv);
  
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
  //col = smoothstep(vec3(0.09),vec3(1.2),col);
  
  if(abs(uv.y+0.05)<0.1+curve(time,0.3)*0.5-fft(0.01)-fd) {
    col.xz *= rot(time*0.6+uv.x);
    col -=0.3;
    col=abs(col);
  }
  
  if(texture(texRevisionBW,clamp(uv*(1.2-9*fft(0))*rot(time*sign(length(uv)-0.5)+curve(time,0.7)*5)+0.5,0,1)).x>0.1) {
    col=col*.4;
  }
  
  vec3 prev=vec3(0);
  vec2 off=uv/60;
  prev.x+=texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy + off).x;
  prev.y+=texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy + off*0.2).y;
  prev.z+=texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy - off).z;
  
  float mi = clamp(0.1 + fd/20,0,1);
  col = mix(col, prev, mi);
    
	out_color = vec4(col, 1);
}