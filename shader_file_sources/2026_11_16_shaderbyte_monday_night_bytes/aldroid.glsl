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

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25);
}

float fbm(vec2 uv) {
  float res=0;
  float a=0.5;
  for (int i=0;i<4;++i) {
    uv.x -= 0.1*fGlobalTime*(i+1)*sign(uv.x);
    res += texture(texNoise, uv).x *a;
    a *= 0.4;
    
    uv *= 2;
  }
  return res;
}

vec3 erot(vec3 p, vec3 ax, float a) {
  return mix(ax*dot(p,ax), p, cos(a)) + cross(ax,p) * sin(a);
}

float map(vec3 p) {
  vec3 q = abs(p)-vec3(0.1,2.,0.1);
  for (int i=0;i<3;++i) {
    q = erot(q,vec3(0,0,1),3.1415/3+sin(fGlobalTime*(3+i)/4.)*0.1);
    q.y = abs(q.x);
  }
  q.y -= 1;
  float xt = max(q.x,max(q.y,q.z));
  return xt;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01, 0.);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float tt = mix(mix(atan(sin(fGlobalTime/40.0)) * 1.0, fGlobalTime, (uv.y+1.)/20), fGlobalTime, 1-texture(texFFT, 0.4).x);
  
  float ttt = fGlobalTime/4;
  float tttt = fGlobalTime/7;
  vec3 ro=vec3(sin(tt)+10*sin(ttt),0,-20+cos(tt)+cos(ttt)*15);
  vec3 la=vec3(sin(tttt),0,cos(tttt));
  vec3 f = normalize(la-ro);
  vec3 r = cross(f, vec3(0,1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(f*2 + r*uv.x + u*uv.y);
  float t=0,d;
  
  vec3 ld = normalize(vec3(1,2,-3));
  vec3 col=plas(rd.xz,fGlobalTime)*fbm(uv)*2;
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) {
      col += 0.3* plas(rd.xz, fGlobalTime)*dot(ld, gn(ro+rd*t));
      ro = ro+rd*t;
      rd = reflect(rd, ro);
      t=0.1;
      
    }
    t += d;
    if (t>100) break;
  }
  
  
  
  if (d<0.01) {
    //col = vec3(1.)*dot(ld, gn(ro+rd*t));
  }
  
	out_color.rgb = col;
}