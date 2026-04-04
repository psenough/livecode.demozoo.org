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
uniform sampler2D texCreative;
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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define sat(a) clamp(a, 0., 1.)
#define FFTS(a) (texture(texFFTSmoothed, a).x*100.)
#define FFTI(a) (texture(texFFTIntegrated, a).x*1.)
#define rot(a) mat2(cos(a+vec4(0.,11.,33.,0.)))

float cube(vec3 p, vec3 s)
{
 vec3 l = abs(p)-s;
  
  return max(l.x, max(l.y, l.z));
}

float map(vec3 p)
{
  p.x = abs(p.x);
  p.xy *= rot(FFTI(.4)*.3);
  float vx = .1;
  p = floor(p/vx)*vx;
  vec3 op = p;
 p.z += FFTI(.2)*55.;
  vec2 rep = vec2(15.);
  vec2 id = floor((p.xz+rep*.5)/rep);
  p.y += sin(length(id)*.3+FFTI(.1))*5.;
  p.xz = mod(p.xz+rep*.5,rep)-rep*.5;
  p.xy *= rot(fGlobalTime);
  p.yz *= rot(fGlobalTime*.8);
  
  
  float wa = -(abs(op.y)-20.);
  
  float sz = FFTS(id.y*.1)*.2+1.;
  return min(wa, cube(p, vec3(sz)))/vx;
}

vec3 getNorm(vec3 p)
{
  vec2 e = vec2(0.01, 0.);
  return normalize(vec3(map(p))-vec3(map(p-e.xyy), map(p-e.yxy), map(p-e.yyx)));
}

vec3 accCol;
float trace(vec3 ro, vec3 rd)
{
  vec3 p = ro;
  vec3 accCol = vec3(0.);
  for (int i = 0; i < 129; i++)
  {
    float d = map(p);
    if (d < 0.01)
    {
      return distance(p,ro);
    }
    if (abs(p.y) < 10.)
      accCol += vec3(1.,.3,.5)*(1.-sat(d/1.5))*.15;
    p+= rd*d;
  }
 
  return -1.;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

  vec2 uv2 = uv;
  uv *= rot(FFTI(0.)*.3);
  
    vec2 txs = textureSize(texEvilbotTunnel,0);
    vec4 tx = sqrt(texture(texEvilbotTunnel,clamp(uv*vec2(txs.y/txs.s,-1)*(5-5*exp(-fract(fGlobalTime*.25))),-.5,.5)-.5));
	float f = texture( texFFT, d ).r * 100;
	m.x += sin(fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
  
  
  

vec3 col = vec3(1.,.2,.4)*(1.-sat(length(uv)))*FFTS(.1);
	
  vec3 ro = vec3(0., 05., -5.);
  vec3 rd = normalize(vec3(uv, 1.));
  rd.yz *= rot(-.5);
  float dist = trace(ro, rd);
  vec3 acc = accCol;
  if (dist > 0.)
  {
    vec3 p = ro+rd*dist;
    vec3 n = getNorm(p);
    if (abs(p.y) <10.)
      col = n*.5+.5;
    col *= sin(p+FFTI(.1))+1.;
    col *= sat(sin(p.z*.2+FFTI(.1)*100.));
    vec3 refl = reflect(rd, n);
    float distrefl = trace(p+n*0.01, refl);
    if (distrefl > 0.)
    {
      vec3 prefl = p+n*0.01 + refl*distrefl;
      vec3 nrefl = getNorm(prefl);
      col += (n*.5+.5)*.5;
      col += accCol;
    }
  }
  col += mix(acc, acc.zxy, sat((abs(uv2.x)-.25)*100.));
  out_color = vec4(col, 1.);
}