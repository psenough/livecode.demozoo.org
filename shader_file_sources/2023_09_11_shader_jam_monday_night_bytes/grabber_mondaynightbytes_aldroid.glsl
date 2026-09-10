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

float fbm31(vec3 p) {
  vec3 f=floor(p),s=vec3(7,157,113);
  p-=f; vec4 h=vec4(0,s.yz,s.y+s.z)+dot(f,s);;
  p=p*p*(3.-2.*p);
  h=mix(fract(sin(h)*43758.5),fract(sin(h+s.x)*43758.5),p.x);
  h.xy=mix(h.xz,h.yw,p.y);
  return mix(h.x,h.y,p.z);  
}

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

float sdBox(vec3 p,vec3 r) {
  p = abs(p)-r;
  return max(p.x,max(p.y,p.z));
}

vec2 min2(vec2 a,vec2 b) {
  return a.x<b.x? a:b;
}

vec2 map(vec3 p) {
  float pg=fbm31(p);
  
  float flr=p.y+10+pg*(texture(texFFT,0.1).x)*10;
  
  p.y += abs(1-sin(fGlobalTime))*5;
  p.x +=sin(fGlobalTime)*5;
  p.z += -10+sin(fGlobalTime*2)*5;
  p.xz*=rot(fGlobalTime);
  float corb=mix(sdBox(p,vec3(2)),length(p)-2,texture(texFFTSmoothed,0.4).x*100);
  return min2(vec2(corb,1),vec2(flr,2));
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(
  map(p).x
  -vec3(
  map(p-e.xyy).x,
  map(p-e.yxy).x,
  map(p-e.yyx).x
  )
  );
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0;
  vec2 d;
  
  for (int i=0; i<100; ++i) {
    d=map(ro+rd*t);
    if (d.x<0.01) break;
    t += d.x;
  }
  
  vec3 bg=vec3(0.1,0.4,0.1)*fbm31(vec3(uv*10,fGlobalTime/10));
  
  vec3 col=vec3(bg);
  
  vec3 ld = normalize(vec3(3,4,-13));
  
  if (d.x< 0.01) {
    vec3 n=gn(ro+rd*t);
    if (d.y ==1) {
    col=vec3(0.1,0,0)+vec3(0.1,0.01,0.2)*dot(n,ld);
    col += pow(max(dot(reflect(-ld,n),-rd),0),30)*0.5;
    }
    col += min(1, pow(1+dot(n,rd),4))*0.23;
    col = mix(bg,col,exp(-.0000007*t*t*t)*4.3);
  }
  
	out_color = vec4(pow(col,vec3(0.45)),1);
}