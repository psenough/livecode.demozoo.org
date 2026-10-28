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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec2 n2(vec2 uv) {
  vec3 p=vec3(uv.x*342.23,uv.y*234.23, (uv.x+uv.y)*124.43);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z, p.y+p.z));
}

float vn(vec2 uv) {
  vec2 f=fract(uv);
  vec2 p=floor(uv);
  vec2 u=f*f*(3-2*f);
  
  float a = n2(p+vec2(0,0)).x;
  float b = n2(p+vec2(1,0)).x;
  float c = n2(p+vec2(0,1)).x;
  float d = n2(p+vec2(1,1)).x;
  
  return a + u.x*(b-a) + u.y*(c-a) +(a-b-c+d)*u.x*u.y;
}

float map(vec3 p) {
  p.y += 2;
  vec2 cid = floor(p.xz+1);
  //p.xz = mod(p.xz+1,vec2(2))-1;
  //p.y -= texture(texFFT,n2(cid).x).x*10;
  
  float d=1e7;
  for (float x=-1;x<=1;++x) for (float y=-1;y<=1;++y) {
    vec2 co = cid + vec2(x,y);
    float boing = texture(texFFTSmoothed,n2(co).x).x*2;
    vec3 q = abs(p-vec3(co.x,boing,co.y))-0.2;
    d=min(d, max(q.x,max(q.y,q.z)));  
  }
  
  return d-.4;
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
  float ttr = fGlobalTime;
  vec3 ro = vec3(atan(sin(ttr*.4))*3,3,-10+ttr), la=vec3(0,0,-4+ttr);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(f*2+r*uv.x-u*uv.y);
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 col=vec3(vn(uv*20));
  vec3 ld=normalize(vec3(1,-2,3));
  
  if (d<0.01) {
    vec3 p= ro+rd*t;
    vec3 n = gn(p);
    col=vec3(1)*clamp(0.7+dot(ld,n),0.3,1.);
    if (n.y >0) {
      col += 0.7*vn(1.4*p.xz+vec2(fGlobalTime*.5));
    }
  }
  
  out_color.rgb=col;
}