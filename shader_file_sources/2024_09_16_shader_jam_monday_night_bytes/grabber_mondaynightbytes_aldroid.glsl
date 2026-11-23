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

vec2 n2(vec2 uv) {
  vec3 p=vec3(uv.x,uv.y,uv.x+uv.y) *vec3(234.32,431.34,324.2);
  p = mod(p,vec3(3,5,7));
  p *= dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

float map(vec3 p) {
  p+=vec3(texture(texFFTIntegrated,0.05).x*10,0,0);
  p=sin(p/10+sin(p)/cos(fGlobalTime)*0.01)*10;
  p.xy *= rot(fGlobalTime/7);
  p.xz *= rot(fGlobalTime/5);
  vec3 q = abs(p)-3;
  return max(q.x,max(q.y,q.z));
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
  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0,d;
  for (int i=0; i<100;++i) {
    d=map(ro+rd*t);
    if (d<0.01) break;
    t += d;
  }
  vec3 bgcol=plas(uv/4,fGlobalTime/6)+vec3(n2(floor(uv*200)/200+sin(fGlobalTime)).x)*0.5;
  vec3 col = bgcol;
  if (d<0.01) {
    vec3 n = gn(ro+rd*t);
    col = plas(vec2(1.1,floor(texture(texFFTIntegrated,0.1).x)*10),3.3)*dot(n,rd)*1.2;
    ;
  }
  
  col = mix(bgcol, col,exp(-0.0000001*pow(t,3)));
  
	out_color = vec4(col,1);
}