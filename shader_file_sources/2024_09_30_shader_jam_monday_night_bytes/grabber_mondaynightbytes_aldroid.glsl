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
  return mat2(cos(f), -sin(f), sin(f), cos(f));
}

vec2 n2(vec2 uv) {
  vec3 p= vec3 (uv.x*234.2,uv.y*323.2,uv.x*uv.y*234.32);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float map(vec3 p) {
  
  float smx = mod(p.y + 1,2)-1;
  
  float slats = length(smx)-0.5;
  
  float wav = length(p.xz) - 0.3-texture(texFFT,p.y/12-fGlobalTime).x*2;
  
  return min(min(max(-slats,length(p) -4), 4-p.y),wav);
}

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25);
}

vec3 gn (vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float ng = texture(texFFTIntegrated,0.1).x;
  uv *= rot(sin(ng)/2);

  vec3 ro=vec3(sin(ng)*20,cos(ng)*2,-10);
  
  vec3 la=vec3(cos(ng*0.3)*10,0,0);
  
  vec3 f=normalize(la-ro);
  vec3 r=cross(f,vec3(0,1,0));
  vec3 u=cross(f,r);
  vec3 rd = f +r*uv.x + u*uv.y;
  
  
  float d,t=0;
  for (int i=0; i<100; ++i) {
    d = map(ro+rd*t);
    if (d<0.01) {
      vec3 p = ro+rd*t;
      if (p.y>3.9) {
        vec2 z = n2(p.xz)*0.02;
        vec3 n = gn(p)+vec3(z.x,0,z.y);
        rd = reflect(rd,n);
        ro = p;
        t += 0.1;
      } else {
      break;
      }
    }
    t += d;
  }
  
  vec3 ld = normalize(vec3(4,3,-13));
  
  vec3 col = vec3(atan(rd.x,rd.y));
  
  if (d<0.01) {
    vec3 p = ro +rd*t;
    vec3 n = gn(p);
    col = plas(floor(p.yy/2)/20, fGlobalTime)*dot(p,ld);
  }
  
	out_color = vec4(col,1);
}