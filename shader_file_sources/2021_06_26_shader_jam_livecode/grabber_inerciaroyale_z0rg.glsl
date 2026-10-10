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

#define sat(a) clamp(a, 0.,1.)
mat2 r2d(float a) { float c= cos(a), s = sin(a); return mat2(c,-s,s,c);}

float _cir(vec2 p, float r)
{
  return length(p)-r;
}

float _sph(vec3 p, float r)
{
  return length(p)-r;
}

vec3 getCam(vec2 uv, vec3 rd)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+(r*uv.x+u*uv.y)*5.*(.8+.5*sin(fGlobalTime)));
}

vec2 _min(vec2 a, vec2 b)
{
  if (a.x < b.x)
    return a;
  return b;
}

float _cube(vec3 p, vec3 s)
{
  vec3 l = abs(p)-s;
  //l = abs(l)-s*.25;
 return max(l.x, max(l.y, l.z)); 
}
#define FFT(a) (texture(texFFT, a).x*100.)

vec2 map(vec3 p)
{
  vec2 acc= vec2(1000.,-1.);
  
  float a = atan(p.y,p.x)+fGlobalTime;
  acc = _min(acc,vec2(_sph(p, .5+.01*sin(a*5.)), 0.)); 
  p.xy *= r2d(.5);
  for (int i = 0; i < 15; ++i)
  {
    float r = 2.5;
    float fi = float(i);
    float orbit = fi+fGlobalTime*.5;
    vec3 pos = p + vec3(sin(orbit),0.,cos(orbit))*mix(1.5,2.5,sat(sin(fi*5.)*.5+.5));
    pos.xy *= r2d(fi+fGlobalTime);
    pos.xz *= r2d(fi+fGlobalTime*(1.+fi*.1));
    vec2 cube = vec2(_cube(pos, vec3(mix(0.025,0.1, sat(sin(fi*10.)*.5+.5)))),1.);
    acc = _min(acc, cube);
  }
  
  vec3 p2 = p;
  vec3 rep = vec3(2.);
  vec3 idx = floor(p2+rep*.5)/rep;
  p2 = mod(p2+rep*.5, rep)-rep*.5;
  p2.x += sin(idx.y*10.+fGlobalTime);
  float beat = .3;
  acc = _min(acc, vec2(_sph(p2, .1*mod(fGlobalTime, beat)/beat),2.));
  
  return acc;
}
vec3 accCol;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  vec3 p = ro;
  for (int i = 0; i < steps; ++i)
  {
    vec2 res = map(p);
    if (res.x < 0.01)
      return vec3(res.x, distance(ro, p), res.y);
    
    vec3 rgb = mix(vec3(1.,.5,.25).zyx, vec3(1.,.5,.25), sat(sin(length(p)*5.+fGlobalTime)));
    rgb *= 1.-sat(_sph(p, 15.)*100.);
    
    accCol += 0.1*rgb*(1.-sat(res.x/1.15));
    p+= rd*res.x;
  }
  return vec3(-1.);
}

vec3 getNorm(vec3 p, float d)
{
    vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}

vec3 rdr(vec2 uv)
{
  vec3 col = vec3(.1,.15,.3);
  col += vec3(.5,.3,.2)*(1.-sat(_cir((uv+vec2(.25))*3., .2))); 
  col += vec3(.5,.3,.2)*(1.-sat(_cir((uv+vec2(.25,-.25))*3., .2))); 
  col += vec3(.5,.3,.2).zxy*(1.-sat(_cir((uv+vec2(-.25,-.25))*2., .3)));
  
  col *= sat(length(uv*2.)+.5);
  float rad = 5.0+sin(fGlobalTime*16.)*sat(sin(fGlobalTime*.1)*20.);
  float t = fGlobalTime*.25;
  vec3 ro = vec3(sin(t)*rad,-2.,cos(t)*rad);
  vec3 ta = vec3(0.,0.,5.*sin(fGlobalTime*.25));
  vec3 rd = normalize(ta-ro);
  ro.xz *= r2d(sin(fGlobalTime));
  
  rd = getCam(uv, rd);
  
  rd.xz *= r2d(sin(fGlobalTime));
  accCol = vec3(0.);
  vec3 res = trace(ro, rd, 64);
  if (res.y > 0.)
  {
      vec3 p = ro+rd*res.y;
      vec3 n = getNorm(p, res.x);
      col = n*.5+.5;
      vec3 lpos = vec3(5.,-5.,1.);
      vec3 ldir = lpos-p;
      vec3 h = normalize(rd+ldir);
      col = vec3(.1,.15,.3);

      float stp = 0.1;
    float dt = dot(h, n);
    dt = floor(dt/stp)*stp;
      col += vec3(.5,.3,.2)*pow(sat(dt),1.);
  }
    col += accCol;
  
  return col;
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy-vec2(.5)*v2Resolution.xy)/v2Resolution.xx;

  vec3 col = rdr(uv);
  col = pow(col, vec3(2.45));
  col = mix(col, texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).xyz,.85*sat(sin(uv.y*40.+fGlobalTime)+.75));
  col = mix(col, col.zxy, sat(sin(uv.x*10.+fGlobalTime)));

  col = mix(col, col.xxx, 1.-sat((sin(uv.y*10.+fGlobalTime)+.75)*400.));
  col *= pow(FFT(.2),.15);
	out_color = vec4(col, 1.);
}