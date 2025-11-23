#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

// HELLO TO INERCIA 2005

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float tm;

// from iq
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 mypal(float t) {
  return palette( t, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
}

mat2 rot(float p) {
  return mat2(cos(p),-sin(p),sin(p),cos(p));
}

vec2 min2(vec2 a,vec2 b) {
  return a.x<b.x ? a : b;
}

float gl = 1e7;

vec2 map(vec3 p) {
  p.xy *= rot(texture(texFFTSmoothed,0.055).x*4+p.z/100);
  p += 3.5;
  p = mod(p,7);
  p -= 3.5;
  vec2 cyg = vec2(length(p.xy)-0.1,1);
  gl = min(gl,cyg.x);
  vec2 bols =vec2(length(p)-1,0);
  return min2(cyg,bols);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x - vec3(map(p-e.xyy).x,map(p-e.yxy).x, map(p-e.yyx).x));
}


void main(void)
{
  tm = mod(fGlobalTime,10000);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col = texture(texInerciaBW,uv*vec2(1,-1)+vec2(sin(tm),cos(tm*0.7))).rgb*(0.1+texture(texFFT,0.1).x*10);
  vec3 ro=vec3(3.5+sin(tm)*3.14,50+texture(texFFTSmoothed,0.1).x*100,10*tm);
  vec3 la = vec3(3.5,0,ro.z+1);
  
  vec3 f = normalize(ro-la);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  
  vec3 rd = f+r*uv.x+u*uv.y;
  rd=normalize(vec3(uv,1));
  vec2 d;;
  float t=0;
  //vec3 col=vec3(0);
  
  vec3 ld = normalize(vec3(sin(fGlobalTime),-4,cos(tm)));
  
  for (int i=0;i<100;i++) {
    vec3 p=ro+rd*t;
    d = map(p);
    if  (d.x < 0.01) {
      vec3 n = gn(p);
      col += (0.1+clamp(dot(rd,n),0,1))*(0.5+texture(texFFT,(100-t)/100+tm/10).x*10)*mypal(t/10+floor((p.x+3.5)/7))*500/pow(t,1.5);
      col += pow(max(dot(reflect(ld,n),rd),0),30)/t; // from evvvvil
      rd = refract(rd, n,1.4);
      if (d.y ==1) {
        col = clamp(col+ vec3(1)/t,0,1);
        break;
        
      }
    }
    t += d.x;
  }
  col += (1+100*texture(texFFT,0.7).x)*exp(-gl*gl)*40/pow(t,1)*mypal(tm);
  
  out_color=vec4(col,1);
}