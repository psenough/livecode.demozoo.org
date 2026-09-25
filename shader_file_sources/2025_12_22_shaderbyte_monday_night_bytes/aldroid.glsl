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
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

vec3 erot (vec3 p, vec3 ax, float a) {
  return mix(dot(ax,p)*ax, p, cos(a)) + cross(ax,p) * sin(a);
}

vec2 n2(vec2 uv) {
  vec3 p = vec3 (324.234*uv.x,321.324*uv.y,432.34*(uv.x+uv.y));
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vn(vec2 uv) {
  vec2 f = fract(uv);
  vec2 u = f * f * (3-2*f);
  vec2 p = floor(uv);
  
  float a = n2(p + vec2(0,0)).x;
  float b = n2(p + vec2(1,0)).x;
  float c = n2(p + vec2(0,1)).x;
  float d = n2(p + vec2(1,1)).x;
  
  return a + (b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y;
}

float fbm(vec2 uv) {
  float res =0;
  float a = 0.5;
  for (int i=0;i<3;++i) {
    res += a * vn(uv);
    uv *= 2;
    a *= .4;
  }
  return res;
}

void fold(inout vec3 p) {
  p=abs(p);
  float k = dot(p,vec3(1,-1,0));
  if (k<0.0) {
    p -= 2*k*normalize(vec3(.4,-.1,0));
  }
}

float kps;

float kfs(vec3 p) {
  vec3 q = p;
  
  float scl = 1;
  float SC = 2;
    float mt1 = 2 + sin(texture(texFFTIntegrated,0.3).x);
    float mt2 = 2 + sin(texture(texFFTIntegrated,0.7).x);
    mt1 *= 1.4+texture(texFFTSmoothed,0.1).x*100;
    mt2 *= 1.4;
  
  for (int i=0;i<4;++i) {
    fold(q);
    
    
    q = erot(q, normalize(vec3(.4+mt1,.8,.2)),.2);
    q = erot(q, normalize(vec3(0,1,0)),.2);
    
    q *= SC;
    
    q -= vec3(.4,.3+texture(texFFTSmoothed,0.1).x*0,.2)*(SC-1);
    
    scl *= SC;
  }
  
  q.z += 1;
  q = abs(q) -vec3(2+mt2,1.1,.5);
  float d = max(q.x,max(q.y,q.z));
  return d/scl;
}

float map(vec3 p) {
  
  //p = erot(p,vec3(0,1,0),fGlobalTime);
  float kf = kfs(p-vec3(0,0,kps));
  float fl = p.y + 3-fbm(p.xz)*(1-cos(p.y*3))*4;
  fl /= 4;
  return min(kf,fl);
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float bt = fGlobalTime;
  
  kps = fGlobalTime;
  
  vec3 ro= vec3(sin(bt/10),0,kps-10);
  
  vec3 la = vec3(0,0,kps);
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,-1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(3*f + uv.x*r + uv.y*u);
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
    
  }
  vec3 p = ro+rd*t;
  
  vec3 lp = vec3(0,0,kps);
  float li = length(p-lp);
  
  vec3 ld = normalize(p-lp);
  
  vec3 bgcol = plas(rd.xy+vn(rd.xy*10),fGlobalTime/4)*.06;
  bgcol = mix(bgcol,vec3(0),smoothstep(0.2,-0.0,rd.y));
  
  vec3 col = bgcol;
  if (d<0.01) {
    vec3 n = gn(p);
    col = dot(ld,n)*plas(vec2(uv.y,dot(ld,n)),fGlobalTime/19)*(1+2*smoothstep(.6,.5,abs(p.y)))*.8/(sqrt(li));
  }
  
  col = mix(bgcol,col,exp(-t*t*t*0.000001));
  
  col = pow(col,vec3(0.4545));
  
  col += n2(uv+vec2(fGlobalTime)).x*.1;
  
	out_color.rgb = col;
}