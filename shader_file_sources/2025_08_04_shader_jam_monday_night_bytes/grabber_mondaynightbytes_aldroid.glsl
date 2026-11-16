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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float fbm(vec2 uv) {
  float res=0;
  float a=0.5;
  for (int i=0;i<3;++i) {
    res += a* texture(texNoise, uv).x;
    a *= 0.4;
    uv *= 2;
  }
  return res;
}

float sdTriPrism( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float gl(vec3 p) {
  
  p.y -= clamp(p.y,0.,1.5);
  return length(p)-0.05;
  
}

float mbd(vec3 p) {
  p.xy *= rot(sin(texture(texFFTSmoothed,0.6).x*10));
  float q = length(p.xz);
  float bd = max(dot(vec2(.3,.1),vec2(q,p.y)),-1-p.y);
  return bd;
}

float pp(vec3 p) {
  p.xy *= rot(sin(fGlobalTime)*0.1);
  p.y -=2.7;
  float bd =mbd(p);
  float hd = length(p-vec3(0,.1,0))-.2;
  float lg = gl(p+vec3(0,1.5,0));
  //p.y = abs(p.y);
  p.xz *= rot(sin(0.2+sin(fGlobalTime)*0.1));
  float am = gl(p.xzy+vec3(0.,1.3,0.2));
  p.xz *= rot(sin(-0.4+sin(fGlobalTime)*0.2));
  am = min(gl(vec3(1,-1,1)*p.xzy+vec3(0.,1.3,0.2)), am);
  return min(min(bd,hd),min(lg,am));
}

float map(vec3 p) {
  vec2 uv = vec2(sin(p.y*3.1415/4),atan(p.z,p.x));
  float hl = length(p+vec3(0,16,0))-17-fbm(uv)-fbm(p.xz/5);
  
  vec3 q = p.zyx;
  q += vec3(-3,-3,mod(fGlobalTime*3,30)-15);
  q.xz *= rot(sin(fGlobalTime*0.9));
  q.yz *= rot(sin(fGlobalTime*0.9)*0.4);
  
  float tnt = sdTriPrism(q,vec2(1,1.5));
  //return tnt;
  return min(min(hl,pp(p)),tnt);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float bt = -fGlobalTime*.5 + texture(texFFTIntegrated,0.1).x;
  bt *= 2;
  
  vec3 ro=vec3(sin(fGlobalTime*0.01),0,-10),rd=normalize(vec3(uv,1));
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
  }
  
  vec3 col = mix(vec3(0.8,0.85,0.95),vec3(0.9,0.9,0.9),clamp((1-uv.y),0,1));
  
  vec3 ld = normalize(vec3(2,3,-2));
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    col= mix(vec3(0.1,0.4,0.2),vec3(0.2,0.1,0.0),smoothstep(10.1,5.,length(p)));;
    vec3 n = gn(p);
    col *= 0.5+dot(n,ld);
    float sp = pow(max(dot(reflect(-ld,n),-rd),0),30);
    col += sp*vec3(0.4,0.5,0.5);
  }
  
  out_color.rgb=col;
}