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
float _seed;
float hash11(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}
float rand()
{
  return hash11(_seed++);
}
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define sat(a) clamp(a, 0., 1.)
#define FFT(a) (texture(texFFT, a).x*4.)
vec3 getCam(vec2 uv, vec3 rd)
{
  vec3 r = normalize(cross(rd, vec3(0., 1., 0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+(r*uv.x+u*uv.y)*1.);
}
vec2 _min(vec2 a, vec2 b)
{
  if (a.x < b.x)
    return a;
  return b;
}
mat2 r2d(float a)
{
  float c=cos(a),s=sin(a);
  return mat2(c,-s,s,c);
}
float _cube(vec3 p, vec3 s)
{
  vec3 l = abs(p)-s;
  return max(l.x, max(l.y, l.z));
}
vec2 map(vec3 p)
{
  vec2 acc = vec2(100000., -1.);
  
  vec3 op = p;
  vec3 rep = vec3(15.);
  //p = mod(p+rep*.5,rep)-rep*.5;
  acc = _min(acc, vec2(length(p)-1., 0.));
  for (int i = 0; i < 8; i++)
  {
    vec3 p2 = p;
    
    p2 = abs(p2)-vec3(1.2,0.,0.);
    p2.xy *= r2d(-fGlobalTime*.5+i);
    p2+= (float(i)-8)*1.5;
    p2 = abs(p2);
    p2.xy *= r2d(fGlobalTime+i);
    p2.yz *= r2d(fGlobalTime*.8+i);
    float sz = mix(.2,1., float(i)/8.);
    float cube = _cube(p2, vec3(sz, sz, 2.));
    //cube = mix(cube, length(p2)-sz, sin(float(i)+fGlobalTime));
    acc = _min(acc, vec2(cube, 0.));
  }
  
  float box = -_cube(op, vec3(19.));
  acc = _min(acc, vec2(box, 2.));
  
  acc = _min(acc, vec2(-p.y+1., 1.));
  

  return acc;
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01, 0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}
vec3 accCol;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  accCol = vec3(0.);
    vec3 p = ro;
  for (int i = 0; i < steps && distance(p, ro) < 50.;++i)
  {
    vec2 res = map(p);
      if (res.x < 0.01)
        return vec3(res.x, distance(p, ro), res.y);
      p+=rd*res.x*.5;
      vec3 rgb = vec3(.2,.4,.8);
      rgb = mix(rgb, rgb.zxy, sin(length(p)-fGlobalTime));
      if (res.y < 1.)
        accCol += rgb*(1.-sat(res.x/.5))*.2*sat(sin(p.y*20.))*.85;
    }
    return vec3(-1.);
}
vec3 getmat(vec3 p, vec3 n, vec3 rd, vec3 res)
{
  vec3 col = vec3(0.);//n*.5+.5;
  if (res.z == 1.)
    col = vec3(0.);
  if (res.z == 0.)
    col = vec3(.0);
  
  if (res.z == 0.)
  {
    col += vec3(1.,0.4,0.2)*sat(sin(p.z*10.)*sin(p.y*10.)*100.);
  }
  if (p.y < -8.)
  {
    float beat = 1./8.;
    float flicker = mod(fGlobalTime, beat)/beat;
    float flick = mix(1.,flicker, sat(sin(fGlobalTime*.5)));
    col = vec3(1.)*sat((sin(p.z*2.)-.5)*100.)*3.*flick;
  }
  return col;
}

vec3 rdr(vec2 uv)
{
  vec3 col = vec3(0.);
  float stpt = 1.;
  float stptime = floor(fGlobalTime/stpt)*stpt;
  uv *= r2d(sin(hash11(stptime)));
    float t = fGlobalTime;
  float d = 18.;
  float zbeat = 1./2.;
  float zz = mod(fGlobalTime, zbeat)/zbeat;
  vec2 off = (vec2(rand(), rand())-.5)*.1;
  vec3 ro = vec3(sin(t*.3)*d+off.x,-3.+off.y,-5.+zz);
  vec3 ta = vec3(0.);
  vec3 rd = normalize(ta-ro);
  rd = getCam(uv, rd);
  
  vec3 res = trace(ro, rd, 64);
  float depth = 100.;
  if (res.y > 0.)
  {
    depth = res.y;
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(p, res.x);
    col = vec3(.2,.4,.9);
    col = getmat(p,n,rd,res);
    
    vec3 refl = reflect(rd, n);
    float spec = texture(texTex1, p.xz).x;
    refl = normalize(refl+(vec3(rand(), rand(), rand())-.5)*.1*spec);
    vec3 resrefl = trace(p+n*0.01,refl, 32);
    if (resrefl.y > 0.)
    {
      vec3 prefl = p+refl*resrefl.y;
      vec3 nrefl = getNorm(prefl, resrefl.x);
      col += getmat(prefl, nrefl, refl, resrefl);
    }
  }
  col += accCol;
  col = mix(col, vec3(.2,.4,.8)*.5, 1.-exp(-depth*0.02));  
  
  
  vec2 rep = vec2(.5);
  uv = mod(uv+rep*.5, rep)-rep*.5;
    float shape = length(uv)-.02*FFT(uv.x*.1);
  col += vec3(.89,.2,.3)*(1.-sat(shape*400.));

  
  
  return col;
}

void main(void)
{
  vec2 ouv = gl_FragCoord.xy/v2Resolution.xy;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  _seed = fGlobalTime+texture(texNoise, uv*10.).x;
  
  uv *= r2d(fGlobalTime*.5);
    uv = abs(uv);
  vec3 col = rdr(uv);
  col += rdr(uv+col.xy*.1+(vec2(rand(), rand())-.5)*.05)*.5;
  col = mix(col, texture(texPreviousFrame, ouv).xyz,.15);
  //col = mix(col, col.yxz, sat(length(uv)));
  col = sat(col);
  col = pow(col, vec3(1.));
	out_color = vec4(col, 1.);
}