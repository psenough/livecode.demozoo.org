#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 erot(vec3 p, vec3 ax, float a) {
  return mix(ax*dot(p,ax), p, cos(a)) + cross(p,ax)*sin(a);
}

vec2 n2(vec2 uv) {
  vec3 p=vec3(uv.x*324.23,uv.y*224.34,(uv.x+uv.y)*132.23);
  p = mod(p,vec3(5,2,3));
  p *= dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float cyl(vec3 p, float r, float h) {
  vec2 d=abs(vec2(length(p.xz),p.y)) - vec2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float gl;

float map(vec3 p) {
  p.y =-abs(p.y);
  p += sin(p.yzx + sin(p.zxy));
  p.x = mod(p.x+2,4)-2;
  p.z = mod(p.z+2,4)-2;
  vec3 q = p;
  q.y += 2;
  float crad = 2;
  float c1 = cyl(q,crad,0.1);
  p = erot(p,normalize(vec3(0,1,1)),texture(texFFTIntegrated,0.1).x);
  q = p;
  q.x += crad*.8;
  //q.y += -2;
  
  float c2 = cyl(q,crad*.05,4);
  gl += 1/c2;
  
  return min(c1,c2);
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
  
}

void main(void)
{
  gl = 0;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y/v2Resolution.x, 1);
  uv /=20*abs(cos(sin(fGlobalTime)));
  
  if (uv.y<0 && cos(fGlobalTime)<-0.4)uv.x -= 0.04;
  
  float rv = 0.4+sin(texture(texFFTIntegrated,0.3).x*10)*0.4;
  uv = vec2(uv.x*cos(rv) - uv.y*sin(rv), uv.x*sin(rv) + uv.y*cos(rv));
  
  
  vec3 ro=vec3(fGlobalTime,0,texture(texFFT,0.1).x*25-10), rd = normalize(vec3(uv,1));
  float t=0, d;
  
  for (int i=0; i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 col=vec3(smoothstep(0.0,0.011,texture(texFFT,0.7).x))*2;
  
  vec3 ld = normalize(vec3(3,2,1));
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    col = vec3(1)*dot(ld,n);
  }
  
  if (length(col)>1.5) col = vec3(1,0,0);
  col += vec3(1,1,0)*exp(-gl*0.1);
  col = pow(col,vec3(.8)) + n2(uv*200+sin(fGlobalTime)).x*0.09;
  col = mix(col,vec3(2),1-cos(uv.y*10));
  out_color.rgb = col;
}