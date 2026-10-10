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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time=mod(fGlobalTime, 300);

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float musi(float t) {
  return texture(texFFTIntegrated, fract(t)*0.1+0.01).x;
}

float mus(float t) {
  return texture(texFFTSmoothed, fract(t)*0.1+0.01).x;
}

float rnd(float t) {
  return fract(sin(t*374.452)*895.342);
}

vec3 rnd3(vec3 t) {
  return fract(sin(t*545.349+t.yzx*434.234+t.zxy*954.234)*543.252);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

float sec;

float map(vec3 p) {
  
  float d=length(p)-1;
  d=min(d, abs(box(p, vec3(5+mus(0.01)*50))));
  p.xz = abs(p.xz)-sin(time*vec2(0.2,0.3))*4-2;
  d=min(d, length(p.xz)-0.1);
  
  d=abs(d)-1;
  
  return d;
}

void cam(inout vec3 p) {
  float t=time*0.1+musi(0.01)*0.2;
  p.xz *= rot(t);
  p.xy *= rot(t*0.7);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col=vec3(0);
  
  sec=floor(fGlobalTime*0.5-length(uv)*0.2);
  sec+=5*floor(fGlobalTime*0.3-abs(uv.x)*0.2);
  time = mod(fGlobalTime, 300) + rnd(sec)*300;
  
  
  if(rnd(sec+0.4)<0.3) uv.x=abs(uv.x);
  if(rnd(sec+0.5)<0.3) uv.y=abs(uv.y);
    
  float count=10;
  for(int j=0; j<count; ++j) {
    vec3 rn=(rnd3(vec3(uv, fract(time)+j))-0.5)*0.5;
    vec3 s=vec3(0,0,-10);
    s.x += (rnd(sec+0.05)-0.5)*6;
    s.y += (rnd(sec+0.1)-0.5)*4;
    s+=rn;
    vec3 r=normalize(vec3(uv, rnd(sec+0.2)+0.5));
    r-=rn*0.1+0.08*sin(time*0.3);
    
    cam(s);
    cam(r);
    
    const int plan = 30;
    float dd=10000.0;
    vec3 cur=vec3(0);
    for(int i=0; i<plan; ++i) {
      vec3 n=vec3(0,0,1);
      float t=musi(0.05*i+0.01)*0.2+i+time*0.02;
      n.yz *= rot(t);
      n.xz *= rot(t*1.3+i);
      vec3 ps=vec3(sin(time*0.12)*2,sin(time*0.2)*2, sin(time*0.26)*2);
      float d=dot(ps-s,n)/dot(n,r);
      if(d>0 && d<dd) {
        vec3 p=s+d*r;
        float ds=map(p);
        float du=abs(ds-(i-plan*0.5)*0.2);
        if(du<0.1) {
          dd=d;
          cur = abs(sin(time*0.01+i*sin(time*0.023)*0.3+vec3(0.25,0.5,0.75+abs(uv.x)*rnd(sec+0.6)*3) + rn*2))*1.3*pow(smoothstep(1,0,abs(du)/0.1),0.2);
        }
      }
    }
    
    if(dd>=9000) {
      cur = abs(sin(time*0.3+vec3(0.25,0.5,0.75)))*min(0.6,0.5/(0.1+length(uv)));
    }
    col += cur;
  }
  col /= count;
  
  
  col *= 0.7;
  col *= 1.2-length(uv);
  
  col = smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
  
	out_color = vec4(col, 1);

}