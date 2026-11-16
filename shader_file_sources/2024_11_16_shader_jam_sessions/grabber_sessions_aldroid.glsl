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


// ALDROID HERE! GLHF all, and love to the organisers and everyone at SESSIONS!


layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec2 n2(vec2 uv) {
  vec3 p = vec3(345.23*uv.x,432.23*uv.y, 342.32*(uv.x+uv.y));
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float np(vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f*f*(3-2*f);
  
  float a = n2(p + vec2(0,0)).x;
  float b = n2(p + vec2(1,0)).x;
  float c = n2(p + vec2(0,1)).x;
  float d = n2(p + vec2(1,1)).x;
  return a + (b-a)*u.x + (c-a)*u.y + (a - b - c + d)*u.x*u.y;
}

float fbm(vec2 uv) {
  float a = 0.5;
  float res = 0;
  for (int i=0;i<4; ++i) {
    res += a * np(uv);
    uv*= 2;
    a *= 0.4;
  }
  return res;
}

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

vec3 logotex(vec2 uv) {
  vec2 frags = vec2(8);
  uv += 0.5;
  vec2 uvp = floor((uv-.5)*frags)+frags/4;
  vec2 uvf = fract(uv*frags);
  vec2 nz = n2(uvp);
  vec2 uva = (mix(uvp,nz,pow(sin(texture(texFFTIntegrated,0.1).x),2))+uvf)/frags;
  vec3 col = texture(texSessions,uva).xyz;
  return col;
}

float gl;

float map(vec3 p, out vec3 uvw, out float mat) {
  p.xy *= rot(sin(texture(texFFTIntegrated,0.3).x));
  p.xz *= rot(sin(texture(texFFTIntegrated,0.5).x*0.1)*0.0001);
  p.z += 19;
  p.x +=4;
  p.y = abs(p.y);
  p.xy *= rot(sin(texture(texFFTIntegrated,0.3).x));
  
  vec3 q = p;
  q.z = mod(q.z,8)-4;
  q.x = abs(q.x)-4;
  float bal = length(q)-1-texture(texFFT,0.1).x*10;
  gl += bal;
  
  float wal = mod(4-p.z+texture(texFFT,0.1).x*10,8);
  
  uvw = p;
  mat = 0;
  float res = bal;
  if (wal < bal) {
    mat = 1;
    res = wal;
    uvw = p;
    
  }
  return res;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.001,0);
  vec3 ig1;
  float ig2;
  return normalize(map(p,ig1,ig2)- vec3(map(p-e.xyy,ig1,ig2),map(p-e.yxy,ig1,ig2),map(p-e.yyx,ig1,ig2)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  gl=0;
  vec3 ro=vec3(0,0,fGlobalTime*10),rd=normalize(vec3(uv,1));
  
  float t=0,d;
  
  vec3 uvw;
  float mat;
  
  vec3 trc= vec3(0);
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t, uvw,mat);
    if (d<0.01) {
      if (mat == 1) {
        t += 0.1;
        vec3 p =(ro+rd*t);
        vec3 waco = mix(vec3(fbm(p.xy))*vec3(0.8,0.3,0.0),logotex(uvw.xy)*vec3(1,1,0),pow(texture(texFFTSmoothed,0.1).x*6,2)*18);
        trc += waco*exp(-t*t*t*0.001);
      } else {
        break;
      }
    }
    t += d;
    if (t >100)break;
  }
  
  
  vec3 col = logotex(uv);
  
  vec3 ld = normalize(vec3(1,1,1));
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    col=vec3(0,0.5,1)*dot(ld,n);
    vec3 hal = normalize(ld-rd);
    col += pow(clamp(dot(n,hal),0.,1.),4);
    col += pow(clamp(1+dot(n,rd),0,1),4)*0.5;
    
  }
  //col += exp(-gl*gl*gl*0.001)*100;
  col = mix(vec3(0),col,exp(-t*t*t*0.0001));
  col += trc;
  
  col += n2(uv+fGlobalTime).xxx*0.1;
  col = mix(col,vec3(0),pow(length(uv),2));
  col = pow(col,vec3(0.4545));
  out_color=vec4(col,1);
}