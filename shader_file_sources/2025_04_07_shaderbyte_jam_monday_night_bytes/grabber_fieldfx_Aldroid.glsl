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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 n2(vec2 uv) {
  vec3 p = vec3(uv.x*234.324, uv.y*423.23, (uv.x+uv.y)*343.23);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+32);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vn(vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f * f *(3-2*f);
  float a=n2(p+vec2(0,0)).x;
  float b=n2(p+vec2(1,0)).x;
  float c=n2(p+vec2(0,1)).x;
  float d=n2(p+vec2(1,1)).x;
  
  return a + (b-a)*u.x + (c-a)*u.y + (a - b - c + d) * u.x * u.y;
}

float fbm(vec2 uv) {
  float res = 0;
  float a=0.5;
  for (int i=0;i<4; ++i) {
    res += a * vn(uv);
    uv *=2;
    a *=.4;
  }
  return res;
}

float vor(vec2 uv) {
  vec2 p=floor(uv);
  vec2 f=fract(uv);
  
  float res = 1e7;
  for (float i=-1; i<=1; ++i) for (float j=-1; j<=1; ++j) {
    vec2 c = vec2(i,j);
    vec2 r = c - f + n2(p+c);
    float d = dot(r,r);
    res = min(d,res);
  }
  return sqrt(res);
}

float map(vec3 p, out vec3 uvw) {
  p.x += 6;
  p += 6;
  vec3 c = floor(p/12);
  p = mod(p,vec3(12));
  p -= 6;
  uvw = vec3(atan(p.z,p.x),p.y,c.x*2+c.y*3+c.z*5);
  return length(p)-2-sin(texture(texFFTSmoothed,(c.x+c.y+c.z)/10).x)*30;
}

vec3 lep(vec2 uv, float c) {
  
  float v = 0;
  vec2 vuv = uv*8;
  float a=0.5;
  for (int i=0;i<4; ++i) {
    v += vor(vuv+vec2(c,1))*a;
    a *= 0.4;
    vuv *= 1.5;
  }
  vec3 col = mix(vec3(0),vec3(.7,.4,.02),smoothstep(0.3,0.5,v));
  col = mix(col,vec3(0.8,.5,.3)*0.6,smoothstep(.200,.14,v));
  return col;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  vec3 ig1;
  
  return normalize(map(p,ig1)-vec3(map(p-e.xyy,ig1),map(p-e.yxy,ig1),map(p-e.yyx,ig1)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float mt1 = texture(texFFTIntegrated,0.1).x;
  float mt2 = texture(texFFTIntegrated,0.2).x;
  float mt3 = texture(texFFTIntegrated,0.43).x;
  float mt4 = texture(texFFTIntegrated,0.63).x;
  
  
  vec3 ro=vec3(0,mt2*10,mt1*10),rd=normalize(vec3(uv,1));
  
  vec3 la=ro+vec3(4-sin(mt3)*5,-3,4+cos(mt4)*4);
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  
  rd = normalize(f+r*uv.x+u*uv.y);
  
  float t=0,d;
  
  vec3 uvw;
  for (int i=0;i<100; ++i) {
    d = map(ro+rd*t, uvw);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  
  vec3 ld = normalize(vec3(.1,-1.5,-3));
  
  vec3 bgcol = mix(vec3(0.3,0.6,0.8),vec3(.9), -.2+smoothstep(0.4,0.6,fbm(rd.xy*8)));
  vec3 col=vec3(bgcol);
  
  if (d<0.01) {
    col = lep(uvw.xy*vec2(1,0.5)*0.5,uvw.z);
    vec3 n = gn (ro+rd*t);
    float dv=dot(n,ld);
    col *= clamp(dv+dv*dv+0.1,0,1);
    float fre = clamp(1+dot(n,rd),0,1);
    fre = pow(fre,4);
    col += fre*bgcol;
  }
  
  col = mix(bgcol,col,exp(-t*t*t*0.00001));
  
  out_color.rgb=col;
}