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

float nz(vec2 uv) {
  vec3 p = vec3(uv.x,uv.y,uv.x*uv.y) * vec3(345.23,213.32,456.23);
  p = mod(p,vec3(3,5,7));
  p *= dot(p,p+32.2);
  p=fract(p);
  return fract(p.x*p.z+p.y*p.z);
}

float bm(vec2 uv) {
  vec2 i = floor(uv);
  vec2 f = fract(uv);
  
  float a=nz(i);
  float b = nz(i+vec2(1.,0));
  float c = nz(i+vec2(0,1.));
  float d = nz(i+vec2(1.));
  
  vec2 u = f * f * (3.0 - 2. *f);
  
  return mix(a, b, u.x) + (c-a)*u.y * (1.0 - u.x)+ (d-b)*u.x*u.y;
}

float fbm(vec2 uv) {
  float ret = 0;
  float a = .8;
  float f = 0;
  
  for (int i=0; i<4; ++i) {
    uv += vec2(fGlobalTime*0.2*i,0);
    ret += a * bm(uv);
    uv *= 2;
    a *= 0.5;
  }
  return ret;
}

float map(vec3 p) {
  return length(p)-3-texture(texFFT,0.05).x*5;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 tuv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  vec3 ro=vec3(0,0,-10), rd=normalize(vec3(uv,1));
  
  vec3 ld = normalize(vec3(0.5,0.5,-1));
  
  float d,t=0;
  
  for (int i=0; i < 100; ++i) {
    d = map(ro+rd*t);
    if (d<0.01)break;
    t += d;
  }
  vec3 col = mix(vec3(0,0,0.5),vec3(0,0.1,0),smoothstep(0.5,0.4,fbm(10+uv*10)));
  
  col = mix(col,vec3(1),texture(texFFT,abs(uv.x)).x-abs(uv.y));
  
  if (d< 0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    vec2 wuv = vec2(atan(p.z,p.x), p.y);
    col = mix(vec3(0,0,0.7),vec3(0,0.3,0),smoothstep(0.5,0.4,fbm(10+wuv)))*dot(ld,n);
    col += pow(max(dot(reflect(ld,n),rd),0),30)*0.1;
  } else {
    col += nz(uv+fGlobalTime)*texture(texFFT,0.05).x*30;
  }
  
  col = pow(col,vec3(0.45));
  col += vec3(
    texture(texPreviousFrame,tuv+vec2(0.004,0.)).g,
    texture(texPreviousFrame,tuv+vec2(0.008,0.)).b,
    texture(texPreviousFrame,tuv+vec2(0.012,0.)).r
  )*.1;
  col=mix(col,vec3(0),pow(length(uv),5));
  
  if (uv.x>-2/6 || uv.y<-2/6) {
    col -= texture(texPreviousFrame,(tuv-5/6)*3+vec2(fGlobalTime,0)).rgb*0.4;
  }
  
  out_color=vec4(col,1);
  
}