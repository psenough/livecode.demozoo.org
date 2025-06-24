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

float time = mod(fGlobalTime, 300);

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float rnd(float t) {
    return fract(sin(t*234.453)*654.302);
}

vec3 rnd(vec3 t) {
  return fract(sin(t*485.854 + t.yzx * 847.584 + t.zxy * 476.554) * 834.554);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1), pow(smoothstep(0,1, fract(t)), 10));
  
}

vec3 repeat(vec3 p, vec3 s) {
  return (fract(p/s+0.5)-0.5)*s;
  }
  
vec3 repeatid(vec3 p, vec3 s) {
  return floor(p/s+0.5);
  }

  vec3 am;
float map(vec3 p) {
  
  float t=time*0.1;
  for(int i=0; i<3; ++i) {
    p.xz *= rot(t + i + curve(t+i, 0.3)*4 + p.y * 0.03);
    p.yz *= rot(t*0.7 + i + curve(t+i, 0.13)*2 + p.x*0.01);
    p.xz = abs(p.xz) - 2 - sin(time) - curve(time+i, 0.4)*2;
  }
  
  float d=box(p, vec3(1.5,2,1.5));
  d = min(d, length(p.xz)-0.1);
  
  p.xz *= rot(0.5);
  p.xy *= rot(0.7);
  
  vec3 p2 = repeat(p, vec3(1.3));
  float d2 = abs(box(p2, vec3(0.3)));
  
  
  am = vec3(1,0.5,0.3);
  if(d2<0.1) am=repeatid(p, vec3(1.3));
  
  d = max(d, -d2);
  
  d -= d2*0.4;
  
  d *= 0.7;
  
  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv.y -=curve(time, 0.3)*0.1;
  
  uv *= 1+curve(time, 0.4);

  vec3 s=vec3(0,0,-20);
  vec3 r=normalize(vec3(uv,1));
  
  vec3 col=vec3(0);
  vec3 p=s;
  for(int i=0; i<100; ++i) {
    float d=map(p);
    if(d<0.001) break;
    if(d>100.0) break;
    p+=r*d;
  }
  float fog=1-clamp(length(p-s)/100,0,1);
    
 for(int j=0; j<20; ++j) {
  vec3 p2=p+r*0.01;
  vec3 r2=normalize(r + 0.1*(rnd(vec3(uv,j))-0.5));
  for(int i=0; i<100; ++i) {
    float d=-map(p2);
    if(d<0.001) break;
    if(d>100.0) break;
    p2+=r2*d;
  }
  
  
  col += rnd(am) * 0.03 / (0.3 + length(p2-p)) * fog;
}
  //col += map(p-r) * fog;

	out_color = vec4(col, 1);
}