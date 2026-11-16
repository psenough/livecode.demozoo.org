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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define FFT(a) (texture( texFFT, a).r * 100)
#define FFTI(a) (texture( texFFTIntegrated, a).r)
#define sat(a) clamp(a, 0.,1.)
vec2 _min(vec2 a, vec2 b)
{
  if(a.x < b.x)
      return a;
  return b;
}

mat2 r2d(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }

float _cube(vec3 p, vec3 s)
{
  vec3 l = abs(p)-s;
  return max(l.x, max(l.y, l.z));
}

vec2 map(vec3 p)
{
  vec2 acc = vec2(1000.,-1.);
  
  acc = _min(acc, vec2(-p.y+.5-.1*abs(sin(length(p.xz*3.)))*sat(length(p.xz)), 1.));
  p.xz *= r2d(p.y+fGlobalTime);
  acc = _min(acc, vec2(_cube(p, vec3(1.,5.,.1)), 0.));
  
  return acc;
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}

float hash11(float p)
{
  p = fract(p*.1031);
  p *= p+33.33;
  p *= p+p;
  return fract(p);
}
float seed;
float rand()
{
  seed++;
  return hash11(seed);
}

vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+r*uv.x+u*uv.y);
}
vec3 accCol;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  accCol = vec3(0.);
  vec3 p = ro;
  for (int i = 0; i < steps; ++i)
  {
    vec2 res = map(p);
    if(res.x < 0.01)
        return vec3(res.x, distance(p, ro), res.y);
    accCol += vec3(sin(length(p.xz)*3.+FFTI(.2)*10.)*.5+.5, .2,sin(p.x*10.)*.2+.8)*(1.-sat(res.x/.5))*.05;
    p+=rd*res.x;
    
  }
  return vec3(-1.);
}

vec3 getMat(vec3 rd, vec3 res, vec3 p, vec3 n)
{
  vec3 col = vec3(0.);
  col = n*.5+.5;
  if (res.z == 0.)
  {
    col = mix(vec3(.6,.3,.1), vec3(.9,.1,.1), sat(-p.y-1.5))*2.;
  }
  if (res.z == 1.)
  {
      vec3 lpos = vec3(10.);
      vec3 ldir = p-lpos;
      vec3 h = normalize(rd+ldir);
      col = vec3(.2)*pow(sat(dot(h, n)),3.);
    
    col += sat((sin(-FFTI(.1)*10.+length(p.xz)*1.)-.95)*100.)*mix(vec3(.6,.3,.1).zxy, vec3(.9,.3,.1), sin(fGlobalTime)*.5+.5);
    
  }
  return col;
}

vec3 rdr(vec2 uv)
{
  vec3 col = vec3(0.);
float dist = 20.*sin(fGlobalTime*.2);
  float t = fGlobalTime*.25;
vec3 ro = vec3(sin(t)*dist,-3.+1.*sin(t*1.5),cos(t)*dist);
  vec3 ta = vec3(0.,0.,0.);
  vec3 rd = normalize(ta-ro);
  rd = getCam(rd, uv);
  vec3 res = trace(ro,  rd, 128);
  vec3 glow = vec3(0.);
    if (res.y > 0.)
    {
      vec3 p = ro+rd*res.y;
      vec3 n = getNorm(p, res.x);
      
      col = getMat(rd, res, p, n);
      glow = accCol;
      float gloss = 0.01+.1*texture(texTex4, p.xz*.1).x;
      vec3 refl = normalize(reflect(rd, n)+gloss*((vec3(rand(), rand(), rand())-.5)*2.));
      if (res.z == 1.)
      {
      vec3 resrefl = trace(p+n*0.01, refl, 128);
      if (resrefl.y > 0.)
      {
        vec3 prefl = p+refl*resrefl.y;
        vec3 nrefl = getNorm(prefl, resrefl.x);
        col += getMat(refl, resrefl, prefl, nrefl);
      }
      }
    }
    col += glow;
  return col;
}
float _sqr(vec2 uv, vec2 s)
{
  vec2 p = abs(uv)-s;
  return max(p.x, p.y);
}
void main(void)
{
	vec2 uv = (gl_FragCoord.xy-.5*v2Resolution.xy)/v2Resolution.xx;
  vec2 ouv2 = uv;
  float stpuv = .01;//+.1*length(uv);
  uv = floor(uv/stpuv)*stpuv;
  
  seed = texture(texTex2, uv).x;
  seed += fract(fGlobalTime);
  vec2 ouv = uv;
  float an = atan(uv.y, uv.x);
  float astp = 3.14159265*2./mod(floor(fGlobalTime), 10.);
  float a= mod(an+astp*.5, astp)-astp*.5;
  
  
  
  uv += vec2(sin(FFTI(.1)), cos(FFTI(.1)))*.1;
  uv *= r2d(FFTI(.5)*.1);
    
  if (abs(uv.y)-.1 > 0.)//mod(fGlobalTime, 2.) < 1.)
  {
  uv = vec2(sin(a), cos(a))*length(uv);
  uv += vec2(sin(FFTI(.1)), cos(FFTI(.1)))*.5;
  uv *= 1.-length(uv);
  }
  vec3 col = rdr(uv);
  if (abs(uv.y)-.1 > 0.)
    col = (1.-col.yzx)*.15;
  
    
  
  col = mix(col, vec3(0.), 1.-sat((abs(uv.y-.2)-.001)*400.));
  float flicker = .1;
  col = mix(col, col.xxx, sat(mod(fGlobalTime,flicker)/flicker)*sat(sin(fGlobalTime*.1)*10.));
  col = mix(col, col.xxx, sat(sin(fGlobalTime))-sat((abs(ouv.x)-.1)*400.));
  
  float rep = .02;
  vec2 idx = floor((ouv+rep*.5)/rep);
  ouv = mod(ouv+rep*.5,rep)-rep*.5;
  ouv *= r2d(FFTI(idx.x*.05)*2.25+idx.x*.5);
  float shape = _sqr(ouv, vec2(.03-0.03*sat(length(uv*3.))));
  
  col *= 1.-sat((shape)*400.);
  
  float an2 = atan(ouv2.y, ouv2.x);
  col *= sat(max(sin(an2*10.+fGlobalTime+sin(length(ouv2)*20.-fGlobalTime*10.)), sin(fGlobalTime+length(ouv2)-.2)));
  
  out_color = vec4(col, 1.);
}