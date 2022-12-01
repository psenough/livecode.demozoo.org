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

float time=mod(fGlobalTime, 300);

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);  
}

float ffti(float t) {
  return texture(texFFTIntegrated, t).x * .3;
}

float fft(float t) {
  return texture(texFFTSmoothed, t).x*.7;
}

vec3 repeat(vec3 p, float s) {
  return (fract(p/s+.5)-.5)*s;
}

float d2=10000;
bool isportal=false;
float map(vec3 p) {
  
  float push = 1 + fft(fract(length(p)*0.00-time*.2)*0.04)*3;  
  //float push = 1 + smoothstep(-1,1,sin(length(p)*0.02-time))*0.2;
  
  
  vec3 p2 = p;
  float t = ffti(0.005)*.3;
  p2.yx *= rot(t);
  p2.xz *= rot(t*1.3);
  p2.z -= 5;
  p2.xz *= rot(sin(time*.1)*.5);
  p2.yz *= rot(sin(time*0.05)*.5);
  
  
  float epa = pow(smoothstep(-1.,-.7,sin(time)),10);
  vec3 p4 = p2;
  float mm=1000;
  for(int i=0; i<3; ++i) {
    p4.xy *= rot(.7+i);
    p4.y-=sign(p4.x);
    p4.xy=abs(p4.xy);
    mm=min(mm, min(p4.x, p4.y));
    p4.xy-=0.9;
  }
  float cut=0.4-mm-epa*.8;
  
  float size=6-epa*3;
  d2 = box(p2, vec3(size,size,.2));  
  d2=max(d2, cut);
  
  float d3 = box(p2, vec3(size+.5,size+.5,.5));
  d3 = max(d3, -box(p2, vec3(size,size,.6)));
  d3=max(d3, cut);
  
  d3=min(d3, d2);
    
  
  p *= push;
  float d=box(repeat(p-10,20),vec3(1));
  for(int i=0; i<3; ++i) {
    
    vec3 p2=p-i*7;
    float t=time*.12 + i;
    p2.xz *= rot(t);
    p2.xy *= rot(t*1.3);
    p2=repeat(p2, 5+i*.7);
    
    d=max(abs(d), abs(box(p2, vec3(1,.2,.4)*4)))-0.8;
  }
  
  d=min(d/push, d3);
  
  return d*.8;
}

void cam(inout vec3 p) {
  
  float t=ffti(0.01) * .1;
  
  p.xz *= rot(t+ffti(0.03) * .1);
  p.xy *= rot(t*1.3);
    
}

vec3 norm(vec3 p, float s) {
  vec2 off=vec2(s,0);
  return normalize(vec3(map(p+off.xyy), map(p+off.yxy), map(p+off.yyx))-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
}

float gao(vec3 p, vec3 n, float d) {
  return smoothstep(0,1,map(p+n*d)/d);
}

float rnd(float a) {
  return fract(sin(a*352.346)*812.714);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv.y -= pow(fft(0.0)*10,4)*2;
  
  float prev = texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).w;
  //uv *= 1 + fft(fract(length(uv)-time*.5)*0.04) * (1-prev);
  
  vec3 s=vec3(0,0,-10);
  float fov = .7+fft(0.02)*10;
  vec3 r=normalize(vec3(uv, fov));
  
  cam(s);
  cam(r);
  
  vec3 col=vec3(0);
  
  vec3 l=normalize(vec3(1,3,2));
  
  vec3 diff=vec3(.4,0.5,1);
  float t2=(ffti(0.015)+time*.5)*.1 + uv.x*.3;
  t2 += 5*rnd(floor(max(abs(r.x),abs(r.y))*7-time*.5-ffti(0.01)*2 - prev*3));
  diff.xy *= rot(t2*.7);
  diff.xz *= rot(t2+uv.y*.5);
  diff=abs(diff);
  
  vec3 p=s;
  float dd=0;
  float fofo=0;
  float atm=0;
  for(int i=0; i<100; ++i) {
    float d=map(p);
    if(abs(d)<0.001) {
      float po=d2;
      vec3 n=norm(p, 0.02);
      float fog = 1-clamp(dd/100,0,1);
      if(abs(po)<0.002) {
        isportal=true;
      }
      if(isportal) {
        float edge = 0.004*dd;
        col += length(n-norm(p, edge)) * 2 * diff.yzx * vec3(2-fog,1,1) * fog;
        fofo=1;
        d=0.003;
      } else {
        vec3 h=normalize(l-r);
        float spec=max(0,dot(n,h));
        float ao=gao(p,n,0.2)*gao(p,n,1);
        float fre=pow(1-abs(dot(n,r)),3);
        col += max(0,dot(n,l)) * ao * fog * (0.5*diff + 3*diff*pow(spec, 10) + 3*pow(spec,50));
        col += (-dot(n,l)*.5+.5)*diff*.3 * fog * ao;
        col += fre*vec3(0.5,0.6,1)*fog*ao;
        fofo=fog;
        break;
      }
    }
    if(dd>100.0) break;
    p+=r*abs(d);
    dd+=abs(d);
    if(!isportal) {
      atm += 0.1/(15+abs(d));
    }
  }
  
  col += diff * (pow(1-fofo,2) * 0.7 + atm);
  
  //col += map(p-r) * fog;
  
  col=smoothstep(0,1,col);
  col=pow(col, vec3(0.4545));
  
  col = mix(col, texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).xyz, mix(0.2,0.9,smoothstep(0.5,0.8,length(uv))));
  
	out_color = vec4(col,fofo);
}