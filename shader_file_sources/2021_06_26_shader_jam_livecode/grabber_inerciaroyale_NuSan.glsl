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

#define time fGlobalTime

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);  
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

float caps(vec3 p, vec3 p1, vec3 p2, float s) {
  vec3 pa=p-p1;
  vec3 pb=p2-p1;
  float prog=dot(pa,pb)/dot(pb,pb);
  prog=clamp(prog, 0, 1);
  return length(p1+pb*prog-p)-s;
}

int scene = 0;

float map(vec3 p) {
  
  vec3 p2=p;
  float t=time*0.1;
  p2.yz *= rot(t);
  p2.yx *= rot(t*1.3);
  float d4 = max(box(p2, vec3(3)),1.2-length(p));
  
  vec3 pb = p;
  float d2=10000;
  for(int i=0; i<3; ++i) {
    float t=time*0.03 + i;
    p.yz *= rot(t+i);
    p.yx *= rot(t*1.3);
    d2 = min(d2, length(p) - 0.47);
    p=abs(p);
    p-=0.9;
  }
  
  
  float d = box(p, vec3(0.4,0.4,0.4));
  
  d=min(d,d2);
  //d=d2;
    
  if(scene==0) d=d4;
  //d=d4;
  
  return d;
}

#define pcount 10
vec3 points[pcount];
int pid=1;
vec3 didi=vec3(1);

vec3 atm=vec3(0);
float map2(vec3 p) {
  
  float d = map(p);
  
  float d2=10000;
  for(int i=0; i<pid-1; ++i) {
    float d3 = caps(p, points[i], points[i+1], 0.01);
    
    atm += (i>0?didi:vec3(.3))*0.013/(0.05+abs(d3)) * smoothstep(4.,0.3,d3);
    
    d2=min(d2,d3);
  }
  
  
  return min(abs(d),d2);
}

vec3 rnd3(vec2 uv) {
  return fract(sin(uv.xyy*452.714+uv.yxx*947.524+uv.yyx*124.271)*352.887);  
}

float rnd(vec2 uv) {
  return fract(dot(sin(uv*452.714+uv.yx*947.524),vec2(352.887)));  
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  scene = int(mod(floor(time/10),2));
  
  vec3 s2=vec3(10,0,0);
  vec3 r2=normalize(vec3(-1,sin(time)*0.1,0));
  
  float iot = (rnd(uv+fract(time*.1))-0.5);
  //iot = (fract(gl_FragCoord.y/3)-.5);
  float id=iot*2;
  vec3 diff=1.3-vec3(1+id,0.45+abs(id),1-id);
  didi = diff;
    
  vec3 p2=s2;
  points[0]=p2;
  pid=1;
  float side=1;
  for(int i=0; i<60; ++i) {
    float d=abs(map(p2));
    if(d<0.001) {
      points[pid] = p2;
      pid+=1;
      if(pid>=pcount-1) break;
      
      vec2 off=vec2(0.01,0);
      vec3 n2=side*normalize(d-vec3(map(p2-off.xyy), map(p2-off.yxy), map(p2-off.yyx)));
      //r2=reflect(r2,n2);
      vec3 r3=refract(r2,n2,1-side*(0.3 + 0.1*iot));
      if(dot(r3,r3)<0.5) r3=reflect(r2,n2);
      r2=r3;
      side=-side;
      d=0.1;
    }
    if(d>100.0) break;
    p2+=r2*d;
  }
  points[pid]=p2+r2*1000;
  ++pid;
  
  //points[pid]=p2;
  
  vec3 s=vec3(0,0,-10);
  vec3 r=normalize(vec3(uv, 1));
  
  float mumu = mix(rnd(-uv+fract(time*.1)),1.,0.9);
  vec3 p=s;
  float dd=0;
  float side2=1;
  for(int i=0; i<90; ++i) {
    float d=abs(map2(p));
    if(d<0.001) {
      
      vec2 off=vec2(0.01,0);
      vec3 n=side2*normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
      vec3 r3=refract(r,n,1-side2*(0.3 + 0.1*iot));
      if(dot(r3,r3)<0.5) r3=reflect(r,n);
      r=r3;
      
      side2=-side2;
      d=0.1;
      //break;
    }
    if(d>100.0) break;
    p+=r*d*mumu;
    dd+=d*mumu;
  }
    
  vec3 col=vec3(0);
  float fog = 1-clamp(dd/100.0,0,1);
  //col += map2(p-r) * fog;
  col += atm;
  
  col=smoothstep(0.01,0.9,col);
  col=pow(col, vec3(0.4545));
  
  vec3 prev=texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).xyz;
  col = mix(col, prev, 0.7);
  
	out_color = vec4(col, 1);
}