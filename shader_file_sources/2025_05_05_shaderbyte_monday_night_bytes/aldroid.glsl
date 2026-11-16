#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float gl = 1e7;

vec3 erot(vec3 p, vec3 ax, float a) {
  return mix(dot(ax,p) * ax, p, cos(a)) + cross(ax,p)*sin(a);
}

vec2 n2(vec2 uv) {
  vec3 p = vec3(324.23*uv.x,243.23*uv.y, 352.23*(uv.x+uv.y));
  p = mod(p,vec3(2,3,5));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vn (vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f*f*(3-2*f);
  
  float a = n2(p + vec2(0,0)).x;
  float b = n2(p + vec2(1,0)).x;
  float c = n2(p + vec2(0,1)).x;
  float d = n2(p + vec2(1,1)).x;
  return a + u.x * (b-a) + u.y *(c-a) + u.x*u.y * (a - b - c + d);
}

float fbm(vec2 uv) {
  float a = 0.5;
  float res = 0;
  for (int i=0;i<4;++i) {
    res += vn(uv)*a;
    a *= 0.4;
    uv *= 2;
  }
  return res;
}

float map(vec3 p) {
  for (int i=0;i<5;++i) {
    p.xy += 15;
    p.xy = abs(p.xy);
    p.xy -= 15;
    p.z -= 14;
    p = erot(p,normalize(vec3(1)),1.4);
  }
  vec2 dsuv = vec2(atan(p.x,p.z),cos(p.y));
  float sph = length(p)-7-texture(texFFTSmoothed,0.1).x*10+fbm(dsuv);
  sph = abs(sph)-0.1;
  
  float t = fGlobalTime*.7;
  p.xz -= vec2(cos(t),sin(t))*3;
  
  p.x -= 2;
  
  float fs = 1;
  for (int i=0;i<4;++i) {
    p.y += 1 + sin(t*1.56);
    
    p = abs(p)-vec3(0.4,0.16,.1);
    p = erot(p,normalize(vec3(sin(t),cos(t),0.4)),t);
    p *= .94;
  }
  float subsph = length(p)-1;
  float newsph = length(p)-0.5;
  
  gl = min(gl,newsph);
  
  float sphho = max(sph,-subsph);
  return min(sphho, newsph);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
  float fgt = texture(texFFTIntegrated, 0.1).x;
  float fgt2 = texture(texFFTIntegrated, 0.4).x;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(sin(fgt*.9),0,5+cos(fgt))*5*(1.5+sin(10*texture(texFFTIntegrated,0.4).x));
  
  vec3 la = vec3(cos(fgt2)*2.,sin(fgt2*.9),0)*4;
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f, r);
  vec3 rd = normalize(f+r*uv.x-u*uv.y);
  
  float t=0, d;
  
  for (int i=0; i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (d >100) break;
  }
  
  vec2 bl = vec2(cos(t),sin(t))*3;
  
  vec3 ld = normalize(vec3(-bl.x,0,bl.y));
  
  vec3 bgcol = vec3(0);
  vec3 col=bgcol;
  if (d < 0.01) {
    vec3 n = gn(ro+rd*t);
    col = vec3(1)* dot(ld, n);
    col += pow(1+dot(rd,n),4);
    vec3 hal = normalize(ld-rd);
    col += pow(clamp(dot(n,hal),0,1),3);
  }
  col += vec3(1,1,0.5)*exp(-0.1*gl*gl*gl);
  bgcol = mix(bgcol,vec3(1,1,0.5),exp(-0.1*gl*gl*gl));
  col = mix(bgcol, col, exp(-0.001*t*t));
  
  
  out_color.rgb = col;

}