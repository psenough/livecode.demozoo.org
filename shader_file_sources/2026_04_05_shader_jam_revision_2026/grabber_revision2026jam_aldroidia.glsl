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
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

float n2(vec2 uv) {
  vec3 p=fract(vec3(uv.x*213.32,uv.y*321.3, (uv.x+uv.y)*342.34));
  p += dot(p, p.yzx + 23.3);
  return fract(p.x*p.z+p.y*p.z);
}

float vn (vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f * f * (3 - 2*f);
  
  float a = n2(p+vec2(0,0));
  float b = n2(p+vec2(1,0));
  float c = n2(p+vec2(0,1));
  float d = n2(p+vec2(1,1));
  
  return a + (b-a)*u.x + (c-a)*u.y + (a- b -c + d) * u.x*u.y;
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

float map(vec3 p) {
  p.y=-abs(p.y);
  
  p.y += 5+cos(fGlobalTime*.93);
  
  p += sin(p.yzx + sin(p.zxy));
  p.x = mod(p.x + 4,8)-4;
  p.z = mod(p.z + 4,8)-4;
  vec3 q1=p/(1+4*texture(texFFT,0.1).x);
  float res = sdCapsule(q1, vec3(-1,0,0), vec3(1,0,0), .4);
  res = min(res,sdCapsule(q1, vec3(-4,0,0), vec3(4,0,0), .1));
  return res/2;
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

  float t1 = texture(texFFTIntegrated,0.43).x*10;
  vec3 la = vec3(0, 0,fGlobalTime*20);
	vec3 ro=vec3(14*sin(t1),0,fGlobalTime*20 -30);
  
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f, vec3(0,-1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(f*3+r*uv.x+u*uv.y);
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (d > 100) break;
  }
  vec3 bgcol=vec3(0.4)*vn(uv*20);
  
  bgcol = mix(vec3(1,0,0),bgcol, smoothstep(0.01,0.011,abs(uv.y*5)-texture(texFFT,uv.x/17+.03).x));
  
  vec3 col = bgcol;
  
  if (d<0.01) {
    vec3 n = gn(ro+rd*t);
    
    col = dot(n,rd)*vec3(1.4,0,0);
    
    col += vec3(1,1,.45)*pow(1-dot(n,rd),1);
  }
  
  col = mix(bgcol,col,exp(-t*t*t*0.000003));
  
  out_color.rgb=col;
}