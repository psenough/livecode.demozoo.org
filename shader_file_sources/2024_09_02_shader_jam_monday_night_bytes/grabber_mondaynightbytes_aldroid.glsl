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

mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a),cos(a));
}

vec2 n2(vec2 uv) {
  vec3 p = vec3(uv.x*342.12,uv.y*324.21,(uv.x+uv.y)*346.12);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25);
}



vec3 bricks(vec2 uv) {
  float r = floor(uv.y/3.14+fGlobalTime);
  float bp = smoothstep(1.9,1.91,n2(vec2(r,17)).x*10+sin(uv.x/2+fGlobalTime*2));
  return mix(vec3(0.88),plas(vec2(r,1),fGlobalTime+r),bp);
}

float map(vec3 p) {
  float t = fGlobalTime*10;
  p.x += t+sin(t);
  float rt = p.x+5;
  p.x = mod(p.x+5,10)-5;
  rt -= p.x;
  p.yz *= rot(fGlobalTime*rt*0.0001+rt*2);
  vec2 q = vec2(length(p.xz)-2.5,p.y);
  return length(q)-0.3;
}

vec3 gn(vec3 p) {
  vec2 e= vec2(0.001,0);
  return normalize(
      map(p) - 
      vec3(
        map(p-e.xyy),map(p-e.yxy), map(p-e.yyx)
      )
    );
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
 rd.x *= mix(-1,1,floor(mod(texture(texFFTIntegrated,0.1).x/2,2)));
  float t=0,d;
  
  for (int i=0; i<100; ++i) {
    d = map(ro+rd*t);
    if (d<0.01) {
      ro = ro+rd*t;
      rd = reflect(rd,gn(ro));
      t += 0.1;
    }
      t += d;
     if (length(ro+rd*t) > 100) break;
  }

	vec2 m;
  vec3 p = ro+rd*t;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = length(uv);
  vec2 bgm = mix(rd.yx,rd.xz,floor(mod(texture(texFFTIntegrated,0.1).x,2)));
  vec3 col = bricks(bgm*vec2(-1,1)*3.14*5);
  
  if (d < 0.01) {
    col=vec3(0);
  }
  
  out_color=vec4(col,1);
}