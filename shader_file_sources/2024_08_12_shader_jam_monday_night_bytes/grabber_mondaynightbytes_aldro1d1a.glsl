#version 420 core

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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float f) {
  return mat2(cos(f),-sin(f),sin(f),cos(f));
}

float cb(vec3 p, vec3 b, float r) {
  vec3 q = abs(p) - b + r;
  return length(max(q,0)) + min(max(q.x,max(q.y,q.z)),0) - r;
}

float map(vec3 p) {
  float rm = -cb(p, vec3(20,20,400),4);
  float bx = cb(p-vec3(0,texture(texFFT,0.05).x*10,0),vec3(2),0.5);
  return min(rm,bx);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(sin(fGlobalTime/3)*6,0,-10);
  
  vec3 la = vec3(0);
  vec3 fw = normalize(la-ro);
  vec3 up = cross(fw,vec3(1,0,0));
  vec3 rt = cross(fw, up);
  vec3 rd = normalize(fw + rt *uv.x + up*uv.y);
  
  vec3 lo = vec3 (-1,4,sin(fGlobalTime*1)*100);
  float d,t=0;
  
  for (int i=0; i<100;++i) {
    d=map(ro+rd*t);
    if (d<0.01) break;
    t += d;
  }
  
  
  
  vec3 col=vec3(0.8);
  if (d< 0.01) {
    
    vec3 p = ro +rd*t;
    vec3 ld = normalize(lo-p);
    vec3 n = gn(p);
    col=vec3(0.9)*(0.7+dot(ld,n))*.8;
    col += pow(max(dot(reflect(-ld,n),-rd),0),10);
    col -= smoothstep(3.,3.4,mod(p.z-texture(texFFTIntegrated,0.1).x*10,4));
  }
  col = mix(vec3(0.7),col, exp(-.0000001*pow(t,3)));
	out_color = vec4(col,1);
}