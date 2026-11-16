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

float time=0;
vec3 rnd(vec3 p) {
  return fract(sin(p*435.045+p.yzx*856.493+p.zxy*532.364)*574.466);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float ffti(float t) {
  return texture(texFFTIntegrated, fract(t)*0.1+0.01).x*0.2;
}

void cam(inout vec3 p){
  
    p.yz *= rot(sin(ffti(0.013)*0.44)*0.6);
    p.xz *= rot(ffti(0.026)*0.1);
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float id = floor(ffti(0.01)*0.3 + fGlobalTime*0.02 - length(uv)*0.2);
  vec3 idx = rnd(vec3(id,0,1));
  time = mod(fGlobalTime + idx.x*300, 300);
  
  uv.y -= texture(texFFTSmoothed, 0.01).x;
  
  vec2 uv3=uv;
  
  if(mod(id,3)<1) uv.x=abs(uv.x);
  if(mod(id,5)<2) uv.y=abs(uv.y);
    
  float mumu=1;
  if(idx.z>0.5) {
    float ss=(idx.z-0.4)*130;
    vec2 muv=abs(fract(uv*ss)-0.5);

    if(mod(id,9)<4) mumu = smoothstep(0.12,0.11,min(muv.x,muv.y))*1.2;
    uv=floor(uv*ss)/ss;    
  }
  
  uv.x += (idx.y-0.5);

  vec3 col=vec3(0);
  
  vec3 s=vec3(0,0,-20);
  float fov = sin(time*0.1)*0.5+0.6;
  vec3 r=normalize(vec3(uv, fov));
  cam(s);
  cam(r);
  const int steps = 200;
  float st = 50.0f / steps;
    
  vec3 p=s - r * st * rnd(vec3(uv,fract(time))).x;
  for(int i=0; i<steps; ++i) {
    
    vec3 p2 = p;
    for(int j=0; j<3; ++j) {
      p2.xy *= rot(ffti(0.01+j*0.05)*0.3+j + p.z*0.02);
      p2.xz *= rot(ffti(0.015+j*0.7)*0.2-j + p.y*0.02);
      p2.xz = abs(p2.xz)-7-sin(time)*5;
    }
    float dec = abs(sin(p2.x*0.1+time)+sin(p2.z*0.09+time*0.8))*5;
    p2.y = abs(p2.y)-dec;
    p2.y = abs(p2.y)-dec*0.5;
    vec2 uv2=p2.xz*0.05;
    float v = floor(abs(uv2.x)*30)/30;
    float fade = 0.1/(0.1+max(0.1,abs(p2.y)));
    float swit = floor(ffti(0.01)*3+v*30);
    col += rnd(vec3(v+0.1,swit,0)) * step(abs(uv2.y)*0.5, texture(texFFTSmoothed, v*0.1+0.01).x-0.01) * 0.2 * fade;  
    
    p+=st*r;
  }
  
  col *= 1.2-length(uv3);
    
  col=smoothstep(0,1,col);
  col=pow(col, vec3(0.4545));
  
  col *= mumu;
  
  if(length(uv3)>0.2+4*texture(texFFTSmoothed, fract(floor(uv.y*30+time*10)*0.1)*0.1+0.01).x) col=1-col;
  
  if(mod(id,7)<3) col=1-col;
  
	out_color = vec4(col, 1);
}