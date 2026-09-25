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

float rail(vec3 p) {
  p.x = -abs(p.x);
  vec3 q=p+vec3(2,5,0);
  q.x = abs(q.x);
  q = abs(q)-0.25;
  return max(q.x,q.y);
}

float eeper(vec3 p) {
  p += vec3(0,6,0);
  p.z -= 4*round(p.z/4);
  p = abs(p) - vec3(5,0.5,1);
  return max(p.x,max(p.y,p.z));
}

float gnd(vec3 p) {
  return p.y+7;
}

vec2 min2(vec2 a, vec2 b) {
  return a.x< b.x ? a : b;
}

vec2 map(vec3 p) {
  float rl = rail(p);
  float ee = eeper(p);
  float gn = gnd(p);
  
  return min2(vec2(gn,3), min2(vec2(rl,1),vec2(ee,2)));
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv.y += texture(texFFT,0.05).x*0.24;

  vec3 ro=vec3(sin(fGlobalTime)*4,2+sin(fGlobalTime*0.3),fGlobalTime*50);
  vec3 la = vec3(0,0,fGlobalTime*50 + 30); 
  vec3 f=normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  vec3 rd=f+r*uv.x-u*uv.y;
  float t=0;
  vec2 d;
  
  vec3 ld=normalize(vec3(3,4,-13));
  
  for (int i=0; i<200; ++i) {
    d = map(ro+rd*t);
    if (d.x < 0.01) break;
    t += d.x;
  }
  
  vec3 skcl = vec3(0.7-0.5*uv.y,0.4,uv.y+2)+texture(texPreviousFrame,uv).rgb;
  vec3 col = skcl;
  if (abs(uv.y)<texture(texFFT,abs(uv.x/8)).x) col = vec3(1,1,0);
  //if (uv.y < 0) col = vec3(0.2,0.5-uv.y,0.1);
  
  if (d.x < 0.01) {
    if (d.y == 1) col = vec3(1);
    else if (d.y == 2) col = vec3(0.3,0.1,0);
    else if (d.y == 3) col = vec3(00);
    vec3 n = gn(ro+rd*t);
    col *= 0.2 + dot(ld,n)*0.5;
    col = mix(skcl,col,0.5+0.5*exp(0.000001*-t*t*t*t));
  }
  
  
  out_color = vec4(col,1);
}