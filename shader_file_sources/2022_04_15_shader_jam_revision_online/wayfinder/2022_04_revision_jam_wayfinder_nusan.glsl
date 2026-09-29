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

float time = mod(fGlobalTime, 300)*.3;


mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

float rep(float t, float s) {
  return (fract(t/s+0.5)-0.5)*s;
}
vec2 rep(vec2 t, vec2 s) {
  return (fract(t/s+0.5)-0.5)*s;
}
vec3 rep(vec3 t, vec3 s) {
  return (fract(t/s+0.5)-0.5)*s;
}

float rnd(float t) {
  return fract(sin(t*457.884)*271.533);
}

float rnd(vec2 t) {
  return fract(dot(sin(t*457.884),vec2(271.533)));
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1,fract(t)), 10));
}

float fft(float t) {
  return texture(texFFTSmoothed, t).x;
}

vec3 pop=vec3(0);
float map(vec3 p) {
  
  vec3 bp=p;
  
  p.xz -= normalize(p.xz) * (80*curve(time, 0.1)/(0.01+length(p)));
  
  p.y += time*5 + curve(time, 7)*19;
  
  p.y = rep(p.y, 20);
  
  float oo=5;
  p.x-=oo;
  p.xz *= rot(bp.y*0.1);
  p.x+=oo;
  
  float d3=1000;
  float t=time*.3+curve(time, 0.5);
  float s=1.9 + curve(time+bp.y*0.01, 0.3)*6;
  for(int i=0; i<5; ++i) {
    p.xz *= rot(0.7+i*.7+t);
    p.yz *= rot(0.3+i+curve(time, 0.5)*7);
    p.xz = abs(p.xz)-s;
    s*=0.9;
    
    d3 = min(d3, length(p.xy)-.3);
  }
  
  float ss=smoothstep(50,3,length(bp));
  float d = box(p, vec3(.2+ss*.8));
  float d2 = d;
  pop+=vec3(0.5,0.7,1)*0.3/(1.5+abs(d3));
  //d=min(d, d3);
  vec3 p2=bp;
  p2.xz *= rot(sin(time*3 - length(p2.xz)*0.01)*3);
  p2.xy *= rot(sin(time*0.5 - length(p2.xz)*0.01)*3);
  d = min(d, abs(box(p2, vec3(10))));
  p2 += sin(d2*0.5);
  d = min(d, length(p2.xy)-1);
  d = min(d, length(p2.zy)-1);
  
  return d;
}

void cam(inout vec3 p) {
  p.yz *= rot(sin(time*0.2)*0.6);
  p.xz *= rot(time*0.1);
}

vec3 norm(vec3 p, float s) {
  vec2 off=vec2(s, 0);
  return normalize(vec3(map(p+off.xyy), map(p+off.yxy), map(p+off.yyx))-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv.y -= curve(time, 0.2)*0.1;
  
  
  vec2 uv2 = uv;
  for(int i=0; i<3; ++i) {
    uv2 *= rot(time*.3+i);
    uv2.x=abs(uv2.x);
  }
  float gr=25+50 * curve(time+.7,.4);
  //uv += (fract(uv2*gr)-.5)*.03*curve(time, 0.3);
  
  //uv=floor(uv*gr)/gr;
  
  //uv *= 1 - 0.3 * curve(time+.1, 0.2);
  
  float dither=mix(0.9,1.,rnd(uv));
  
  vec3 s=vec3(0,0,-50);
  vec3 r=normalize(vec3(uv, 1));
  
  cam(s);
  cam(r);
  
  vec3 col=vec3(0);
  
  vec3 p=s;
  float dd=0;
  vec3 diff=vec3(.3,0.7,1);
  float t2 = time - floor(abs(uv.x)*30);
  diff.xz *= rot(0.7+t2*.3);
  diff.xy *= rot(0.3+t2*.1);
  for(int i=0; i<90; ++i) {
    
    float d=abs(map(p));
    if(d<0.001) {
      vec3 n=norm(p, 0.01);
      //r=reflect(r,n);
      diff.xz *= rot(0.7+time*.3);
      diff.xy *= rot(0.3+time*.1);
      diff=abs(diff);
      if(length(p.xz)<5) {
        
        break;
      }
      d=0.1;
    }
    if(d>100.0) break;
    
    p+=r*d*dither;
    dd+=d*dither;
    col += diff*0.001/(0.1+abs(d));
    
  }
  
  float fog=1-clamp(dd/100.0,0,1);
  col += diff * 3 * length(norm(p, 0.05)-norm(p, 1.1)) * fog;
  col += pop * 0.09 * curve(time, .05);
  col=smoothstep(0,1,col);
  col = pow(col, vec3(0.4545));
	
  out_color = vec4(col, 1);
}