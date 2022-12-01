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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define FFTI(a) (texture(texFFTIntegrated, a).x*.1)
#define FFTS(a) (texture(texFFTSmoothed, a).x*4.)
#define sat(a) clamp(a, 0., 1.)
#define PI 3.14159265

float _seed;
float hash11(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}

float rand()
{
  return hash11(_seed++);
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
  return mix(max(l.x, max(l.y, l.z)), length(p)-s.x, 0.);
}

mat2 r2d(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c);}

float _cucube(vec3 p, vec3 s, vec3 th)
{
    vec3 l = abs(p)-s;
    l.xy *= r2d(fGlobalTime);
    float cube = max(max(l.x, l.y), l.z);
      th.xy *= r2d(fGlobalTime);

    l = abs(l)-th;
    float x = max(l.y, l.z);
    float y = max(l.x, l.z);
    float z = max(l.x, l.y);
    
    return max(min(min(x, y), z), cube);
}

vec2 map(vec3 p)
{
  vec3 op = p;
  vec2 acc = vec2(10000.,-1.);
  
  p.xz *= r2d(fGlobalTime);
  
  acc = _min(acc, vec2(length(p+vec3(0.,0.,-15.))-1., 0.));
 
  p.xz *= r2d(.5*sin(.1*p.y));
  p.xz += vec2(sin(fGlobalTime), cos(fGlobalTime*5.1+p.y*.1))*.01;
  float rad = 20.;
  vec3 pdart = p+vec3(0.,FFTI(.05)*20.+fGlobalTime*85.,0.);
  float adart = atan(pdart.z, pdart.x);
  float stpdart = PI*2./20.;
  float sector = mod(adart+stpdart*.5,stpdart)-stpdart*.5;
  pdart.xz = vec2(sin(sector), cos(sector))*length(pdart.xz);
  float repyd = 5.;
  float idda = floor((pdart.y+repyd*.5)/repyd);
//  pdart.xz *= r2d(idda);
  float rada = mix(10.,40.,sin(idda)*.5+.5);
  pdart -= vec3(0.,45.,rada);
  pdart.y = mod(pdart.y+repyd*.5,repyd)-repyd*.5;
  float dart = _cube(pdart, vec2(.1,5.).xxy);
  acc = _min(acc, vec2(length(pdart-vec3(0.,0.,-5.))-0.25,-1.));
  
  acc = _min(acc, vec2(dart, 0.));
  
  vec3 pcube = p+vec3(0.,fGlobalTime*55.,0.);
  float stpcube = PI*2./4.;
  float sectorcube = mod(adart+stpcube*.5,stpcube)-stpcube*.5;
  pcube.xz = vec2(sin(sectorcube), cos(sectorcube))*length(pcube.xz);
  float repyc = .5;
  float radb = mix(5.,20.,sin(repyc)*.5+.5);
  pcube -= vec3(0.,0.,radb);

  pcube.y = mod(pcube.y+repyc*.5,repyc)-repyc*.5;
  acc = _min(acc, vec2(_cube(pcube, vec3(.5,.2,2.)), 1.));
  
  float tunnel = -(length(p.xz)-rad);
  acc = _min(acc, vec2(tunnel, 0.));
  
  vec3 pcc = op-vec3(0.,55.,0.);
  

//  pcc.xz *= r2d(fGlobalTime);
  pcc.xz = abs(pcc.xz);
  //pcc.xz *= r2d(fGlobalTime);
  //pcc.yz *= r2d(.5*fGlobalTime);
  pcc.y = mod(pcc.y+repyc*.5, repyc)-repyc*.5;
  acc = _min(acc, vec2(_cucube(pcc-vec3(0.,15.,0.), vec3(1.), vec3(.01)), -5.));
  
  return acc;
}

vec3 getCam(vec3 rd, vec2 uv)
{
  float fov = 2.;
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+fov*(r*uv.x+u*uv.y));
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x)); 
}
vec3 accLight;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  accLight = vec3(0.);
  vec3 p  = ro;
  for (int i = 0; i < steps; ++i)
  {
    vec2 res = map(p);
    if (res.x < 0.01)
      return vec3(res.x, distance(p, ro), res.y);
    if (res.y < 0.)
      accLight += (vec3(172, 38, 235)/255.)*0.1+vec3(sin(distance(p, ro)*1.+fGlobalTime)*.5+.5, .5, .1)*(1.-sat(res.x/15.5))*.5*sat(sin(p.y*.05+5.*fGlobalTime));
    rd = normalize(rd+normalize(p)*.1);
    p+=rd*res.x*.25;
  }
  return vec3(-1.);
}

vec3 rdr(vec2 uv)
{
  vec3 background = (vec3(212, 140, 32)/255.).zxy;
  vec3 col = background;
  
  vec3 dof = vec3(rand()-.5, rand()-.5, 0.)*.1*FFTS(.05)*1.;
  vec3 ro = vec3(0.,-5.,-5.)-dof*.1;
  vec3 ta = vec3(sin(fGlobalTime)*5.,85.,0.);
  vec3 rd = normalize(ta-ro);
  
  rd += dof*.1;
  rd = getCam(rd, uv);

  float depth = 150.;
  vec3 res = trace(ro, rd, 128);
  if (res.y > 0.)
  {
    depth = res.y;
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(p, res.x);
    col = n*.5+.5;
    
    col = (vec3(23, 24, 51)/255.).zxy*sat(dot(normalize(vec3(n.x, -1., n.z)), n));
  }
  col += accLight;
  col = mix(col, background, 1.-sat(exp(-depth*depth*0.001)));
  return col;
}

vec3 rdr2(vec2 uv)
{
  vec3 col = vec3(0.);
  vec2 dir = normalize(vec2(1.));
  float str = 0.1*FFTS(.2)*1.;
  
  col.x = rdr(uv+dir*str).x;
  col.y = rdr(uv).y;
  col.z = rdr(uv-dir*str).z;
  return col;
}
float lenny(vec2 v)
{
  return abs(v.x)+abs(v.y);
}
void main(void)
{
  _seed = texture(texNoise, gl_FragCoord.xy/v2Resolution.xy).x+fGlobalTime;
	vec2 uv = (gl_FragCoord.xy-.5*v2Resolution.xy)/v2Resolution.xx;
  vec2 ouv2 = uv;
  vec2 ouv = uv;
  //uv *= r2d(-fGlobalTime*.5);
  //uv = abs(uv);
  //uv -= vec2(.2+uv.y, 0.);
  uv *= r2d(.1*fGlobalTime);
  //uv = abs(uv);
  //uv *= r2d(sin(mix(lenny(uv), length(uv), -2.)*15.-fGlobalTime));
 float stp = .2*length(uv);
  vec2 uv2 = floor(uv/stp)*stp;
    uv2 *= r2d(.01*fGlobalTime);
  uv2 = abs(uv2);
  //uv *= r2d(FFTI(.1)*10.);
  //uv = abs(uv);
  //uv -= vec2(.25);
  
  vec3 col = rdr2(uv+rdr(uv).xy*.1)*1.;
  col += rdr(uv2)*.25;
  col *= 1.-sat(length(uv));
  //col = mix(vec3(0.), vec3(199, 242, 58)/255., col*.4);
  col = pow(col, vec3(2.45));
  //col *= vec3(199, 242, 58)/255.;
  float beat = 1./8.;
//  col += (mod(fGlobalTime, beat)/beat)*sat(FFTS(.1)*col)*45.;
  float repy = .05;
  float idy = floor((ouv.y+repy*.5)/repy);
  col = mix(col, col.zxy, mod(idy+int(fGlobalTime*8.),5.)/5.);

col = mix(col, texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).xyz, .5);
  col.xy *= r2d(fGlobalTime*.5);
  col = abs(col);
  ouv *= r2d(ouv.x*5.*sin(fGlobalTime*.5));
  ouv.y += fGlobalTime*2.1;
  col = mix(col, col.zxy, sat((min(sin(ouv.y*100.), sin(ouv.x*100.))+.97)*5.));
  
  float repx = .1;
  ouv2.x = abs(ouv2.x);
  float idx = floor((ouv2.x+repx*.5)/repx);
  col *= 1.-sat((abs(ouv2.y)-.1-FFTS(idx/10.))*10.);
  
	out_color = vec4(col.yxz, 1.);
}