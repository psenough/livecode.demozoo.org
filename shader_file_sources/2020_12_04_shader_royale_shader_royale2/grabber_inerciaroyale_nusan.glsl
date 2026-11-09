#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = mod(fGlobalTime*.6, 300);

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
  return fract(sin(t*425.551)*974.512);  
}

float rnd(vec2 uv) {
  return fract(dot(sin(uv*352.742+uv.yx*254.741),vec2(642.541)));
  
}


float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)), 10));
  
}

vec3 fractal(vec3 p, float t) {
  
  float s=2 + (curve(time, .3)-0.5)*.1;
  for(int i=0; i<3; ++i) {
    p.xz *= rot(t);
    p.yz *= rot(t*1.3);
    p.xz=abs(p.xz)-s*(1+vec2(rnd(i),rnd(i+.1)));
    s*=0.7;
  }
  
  return p;
}

float tick(float t) {
  float g=fract(t);
  g=smoothstep(0,1,g);
  g=pow(g,10);
  return floor(t)+g;
}



float smin(float a, float b, float h) {
  float k=clamp((a-b)/h*0.5+0.5,0,1);
  return mix(a,b,k) - k*(1-k)*h;
}

vec3 repeat(vec3 p, vec3 s) {
  return (fract(p/s+0.5)-0.5)*s;
}

float center = 10000;
float map(vec3 p) {
  
  
  p.y += curve(time*3 - length(p.xz)*0.02, 1)*8;
  
  float t=tick(time)*2;
  
  float d=box(fractal(p, t*.3), vec3(0.3,1.3,0.4));
  float d2=box(fractal(p+vec3(1), t*.4), vec3(0.3,1.3,0.4)*2);
  
  d = abs(max(d,d2))-0.2;
  
  float d5 = box(fractal(p-vec3(0,10,0), t*.1), vec3(5,5,1000.0));  
  d = min(d, d5);
  center = d;
  
  
  d = smin(d, -p.y+5, 1 + curve(time, 0.3)*15);
  
  vec3 p2=p;
  
  p2.xz = abs(p2.xz)-40;
  p2.xz = abs(p2.xz)-20;
  p2.xz = abs(p2.xz)-10*curve(time, .3);
  
  p2.xz *= rot(p2.y*curve(time, 0.4)*0.5-time);
  
  float sd = -abs(p.y)*0.3+3;
  d = min(d, box(p2, vec3(sd,10,sd)));
  
  
  vec3 p3=p;
  p3=repeat(p3, vec3(13));
  float d3 = length(p3)-.1-sin(p.x*.3)*.3-sin(p.y*.2)*.3-sin(p.z*.1)*.3 - sin(length(p)*0.03-time)*.1;
  d3 = max(d3, p.y);
  d = min(d, d3);
    
  d=abs(d)-0.1;
  return d;
}

void cam(inout vec3 p) {
  
  float t=time*0.3;
  p.yz *= rot(.4 + sin(t*.2)*.4);
  p.xz *= rot(t);
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv *= 1+max(0,curve(time - length(uv),.2)-.7)*.6;
  uv.y -= curve(time, .2)*.1;
    
  float di2 = pow(curve(time, .8),4)*3-length(uv)-.1;
  bool circ = di2<0;
  bool truc = curve(time, 6)<.7;
  vec2 nu = vec2(0);
  vec2 nuv = uv;
  if(!truc) nuv.x = abs(nuv.x)*fract(time);
  
  float di = 1000;
  for(int i=0; i<4; ++i) {
    nuv *= rot(curve(time+i*0.32,1.2)*2);
    nuv.y += curve(time+.7+i*.1,.5)-.5;
    nu += sign(nuv)*(1+i*0.2);
    nuv=abs(nuv);
    di = min(di, min(nuv.x,nuv.y));
    nuv-=0.4*rnd(nu);
  }
  
  float pulse = floor(time*0.7);
  
  if(circ && truc) uv += nu*(0.03+0.03*curve(time+.7,.3))*.5;
  
  vec3 s=vec3((curve(time+2.3,.8)-.5)*20 ,-10,-30 - curve(time, 1.3)*40);
  vec3 r=normalize(vec3(-uv, .5 + curve(pulse, .7)*2));
  
  cam(s);
  cam(r);
  
  vec3 p=s;
  vec3 col = vec3(0);
  float mu=mix(0.9,1.0,rnd(uv));
  
  bool band = rnd(nu)>0.7 && circ;
  if(rnd(pulse+.7)<.4) band=true;
  
  vec3 diff=vec3(1,0.4,0.5);
  float t2 = tick(time*.5)*.7;
  diff.xz *= rot(t2);
  diff.yz *= rot(t2*.7);
  diff=abs(diff);
    
  float de = 0.01*(1+sin(abs(uv.x*3)-time*4)*0.8);
  
  vec3 diff2 = vec3(1);
  bool maa=false;
  for(int i=0; i<100; ++i) {
    float d=map(p);
    if(d<0.001) {
      if(band) {
        d=0.1;
        if(center<10) {
          diff.xz *= rot(.1);
          diff=abs(diff);
          maa=abs(center-10)<1;
        }
      } else {
        vec2 off=vec2(0.01,0);
        if(center<10) {
          diff2 = vec3(.3,8,10)*curve(time, .75);
          maa=abs(center-10)<1;
        }
        vec3 n=normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
        r=reflect(r,n);        
      }
      d=0.1;
      //break;
    }
    if(d>100.0) break;
    p+=r*d*mu;    
    if(band) {
      col += diff*0.3*de/(de+.1+abs(d));
    } else {
      col += diff2*vec3(0.7,0.7,0.7)*0.1*de/(de+abs(d));
    }
  }
  
  if(circ) col *= smoothstep(0.0,0.01,di);
  if(circ) col *= smoothstep(0.0,0.02,abs(di2));
  if(maa) {
    col *= .2;
  }
  
  if(rnd(pulse)<1.3 && abs(uv.y)<.1) {
    float t4 = time + uv.x;
    col.yz *= rot(t4);
    col.xz *= rot(t4*1.3);
    col=abs(col);
  }
  
  col *= 1.2-length(uv);
  
  col=smoothstep(0,1,col);
  col=pow(col, vec3(0.4545));
  
  //col += map(p-r);
  
  out_color = vec4(col, 1);
}