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

// aldroid here!

// <3 love shadow party

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  return mat2(cos(a),-sin(a), sin(a),cos(a));
}

vec2 min2(vec2 a, vec2 b) {
  return (a.x<b.x) ? a : b;
}

float bodv;

float bod(vec3 p) {
  p.x /= 2;
  bodv = p.x;
  return length(p) -2;
}

float ey(vec3 p) {
  return length(p)-0.25;
}

float wng(vec3 p) {
  return max(length(p.xz*vec2(1,.5))-2,abs(p.y)-0.01);
}

vec2 bee(vec3 p) {
  p.xz *= rot(2);
  p.x -= 2.;
  float b = bod(p);
  float e1=ey(p-vec3(3.2,0.6,1));
  float e2=ey(p-vec3(3.2,0.6,-1));
  vec3 q1=vec3(p);
  vec3 q2=vec3(p);
  float wingbob = texture(texFFTIntegrated,0.05).x*10;
  q1.yz *= rot(sin(wingbob)*0.2);
  q2.yz *= rot(-sin(wingbob)*0.2);
  float wng1 = wng(q1-vec3(0,1.4,3));
  float wng2 = wng(q2-vec3(0,1.4,-3));
  return min2(
      min2(
        vec2(b,0), 
        vec2(min(e1,e2),1)
      ),
      vec2(min(wng1,wng2),3)
  );
}

vec2 fwr(vec3 p) {
  float petal = max(length(p.xy)-2,abs(p.z)-0.05);
  float pistil = length(p)-0.3;
  float stem = max(length(p.xz)-0.03,abs(p.y+2)-4);
  return min2(
    vec2(petal,4),
    min2(vec2(pistil,1),
      vec2(stem,2)
    )
  );
}

vec2 map(vec3 p) {
  vec2 be = bee(p-vec3(0,sin(sin(fGlobalTime/30)+fGlobalTime),10)); // BEEP!
  vec2 fw = fwr(p-vec3(3,0,0));
  return min2(be,fw);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x - vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  
  vec3 ld = normalize(vec3(12,4,-4));
  
  vec2 d;
  float t;
  
  
  for (int i=0; i<100; ++i) {
    d = map(ro+rd*t);
    if (d.x < 0.01) break;
    t += d.x;
  }
  
  vec3 col = vec3(0.4,0.75,0.4+uv.y/2+0.5);
  
  if (d.x<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    if (d.y == 0) {
      col=mix(vec3(1,1,0),vec3(0),clamp(sin(bodv*3)*3,-0.5,0.5)+0.5)*(0.3+dot(n,ld));
      col += pow(max(dot(reflect(ld,n),rd),0),30);
    }
    else if (d.y==1) {
      col=vec3(1)*(0.3+dot(n,ld));
    }
    else if (d.y==2) {
      col=vec3(0.,0.7,0.)*(0.3+dot(n,ld));
    } else if (d.y==3) {
      col=vec3(0.2);
    } else if (d.y==4) {
      col=vec3(1,0,0)*(0.3+dot(n,ld));
    }
  }
  
	out_color = vec4(col,1);
}