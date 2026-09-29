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
uniform float fMidiKnob1;
uniform float fMidiKnob2;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//HI EVERYONE!

// Mercury SDF <3 - https://mercury.sexy/hg_sdf/
#define PI 3.14159265
#define TAU (2*PI)
#define PHI (sqrt(5)*0.5 + 0.5)
#define saturate(x) clamp(x, 0, 1)

float pModPolar(inout vec2 p, float repetitions) {
  float angle = 2*PI/repetitions;
  float a = atan(p.y, p.x) + angle/2.;
  float r = length(p);
  float c = floor(a/angle);
  a = mod(a,angle) - angle/2.;
  p = vec2(cos(a), sin(a))*r;
  // For an odd number of repetitions, fix cell index of the cell in -x direction
  // (cell index would be e.g. -5 and 5 in the two halves of the cell):
  if (abs(c) >= (repetitions/2)) c = abs(c);
  return c;
}

#define M1 1.0
#define M2 2.0
#define M3 3.0

vec3 glow = vec3(0);

struct SceneResult
{
  float d;
  float cid;
  float mid;
};

struct MarchResult
{
  vec3 position;
  vec3 normal;
  SceneResult sres;
};

float ffts = texture(texFFTSmoothed,80).r*.25;
float ffti = texture(texFFTIntegrated,.1).r*.25;
float time = fGlobalTime;

float sdBox(vec3 p, vec3 b)
{
  vec3 q = abs(p) - b;
  return length(max(q,0)) + min(max(q.x,max(q.y,q.z)),0);
}

float sdTriPrism( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

void rot(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// base from iq
SceneResult opU(SceneResult d1, SceneResult d2)
{
    return (d1.d < d2.d) ? d1 : d2;
}

// 3D noise function (IQ)
float noise(vec3 p){
  vec3 ip = floor(p);
    p -= ip;
    vec3 s = vec3(7.0,157.0,113.0);
    vec4 h = vec4(0.0, s.yz, s.y+s.z)+dot(ip, s);
    p = p*p*(3.0-2.0*p);
    h = mix(fract(sin(h)*43758.5), fract(sin(h+s.x)*43758.5), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

SceneResult scene(vec3 p) {
  SceneResult r;
  rot(p.xy,ffti*20);
  vec3 pp = abs(p);
  for (int i = 0; i < 2; ++i)
  {
    pp = abs(pp) - vec3(4.,4.,5.);
    rot(pp.xy,(time+20.*ffts)*.1);
    rot(pp.yz,time*.1);
  }
  float c = pModPolar(pp.xz,5);
  pp -= vec3(5,0,0);
  rot(pp.xz,ffti*2.);
   
  vec3 ppp = p;
  float cc = pModPolar(ppp.xz,5);
  ppp -= vec3(5.,cc*3.,0.);
  rot(ppp.yz,PI);
  rot(ppp.xz, -time);
  rot(ppp.xy,ffti*.20);
    
  SceneResult box;
  box.d = sdBox(pp,vec3(2,1.+ffts*20,1))+noise(pp);
  box.cid = c;
  box.mid = M1;
  
  SceneResult tp;
  tp.d = sdTriPrism(ppp,vec2(1.5+ffts*20.,.2));
  tp.mid = M2;

  vec3 pppp = abs(p);
  for (int i = 0; i < 4; ++i)
  {
    pppp = abs(pppp) - vec3(3.,6.,9.);
    rot(pp.xy, (time+texture( texFFT, pp.x ).r*1));
    rot(pp.yz, time*0.1);
  }
  
  SceneResult tp2;
  tp2.d = sdTriPrism(pppp,vec2(2.5+ffts*10.,.4));
  tp2.mid = M3;

  r = opU(opU(box,tp),tp2);
  
  glow += vec3(.8,.4,.2)*0.01/(0.01+abs(tp.d));
  glow += vec3(.9,.2,.6)*0.01/(0.9+abs(box.d));
  glow += vec3(.2,.4,.8)*0.01/(0.2+abs(tp2.d));
  
  return r;
}

vec3 calcNormal (in vec3 pos)
{
  vec2 e = vec2(0.0001,0.0);
  return normalize(vec3(scene(pos+e.xyy).d-scene(pos-e.xyy).d,
                        scene(pos+e.yxy).d-scene(pos-e.yxy).d,
                        scene(pos+e.yyx).d-scene(pos-e.yyx).d));
}

MarchResult raymarch(in vec3 ro, in vec3 rd)
{
  vec3 p = ro+rd;
  float s = .0;
  float id = M1;
  float t = 0.;
  SceneResult d;
  for (int i = 0; i < 100; ++i){
    d = scene(p);
    t += d.d;
    p += rd*d.d;
    s = float(i);
    if (d.d < 0.01 || t > 100.) {
      break;
    }
  }
  MarchResult res;
  res.position = p;
  res.normal = calcNormal(p);
  res.sres = d;
  res.sres.d = t;
  return res;
}

vec3 shade(MarchResult mr, vec3 rd, vec3 ld)
{
  float l = max(dot(mr.normal,ld),.0);
  float a = max(dot(reflect(ld,mr.normal),rd),.0);
  float s = pow(a,10);
  
  float m = mod(mr.sres.cid,8.);
  
  vec3 col = vec3(.8,.4,.2);
  if (mr.sres.mid == M1){
    if (m < 1.)
      col = vec3(.2,.6,.9);
    else if (m < 2.)
      col = vec3(.9,.6,.2)*.1;
    else
      col = vec3(.9,.2,.6)*.1;
  }
  else if (mr.sres.mid == M2)
  {
    col = vec3(.8,.2,.4);
  }
  else {
    col = vec3(1.,.5,.5)*.25;
  }
  return l * col * .5 + s * (col * vec3(1.1,1.2,1.2))*.8;
}

void main(void)
{
  
  vec3 cp = vec3(sin(10.*ffti)+10.,5.+sin(ffti*20.),cos(20.*ffti)+20.);
  vec3 ct = vec3(0);
  vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
  vec2 q = -1.0+2.0*uv;
  q.x *= v2Resolution.x/v2Resolution.y;
  
  vec3 cf = normalize(ct-cp);
  vec3 cr = normalize(cross(vec3(0,1,0),cf));
  vec3 cu = normalize(cross(cf,cr));
  vec3 rd = normalize(mat3(cr,cu,cf)*vec3(q,radians(90.0)));
  vec3 ld = -rd;  
  
  
  vec3 col = vec3(0);
  
  MarchResult m = raymarch(cp,rd);
  if (m.sres.d < 100.)
  {
    col = shade(m,rd,ld);
  }
  
  col += glow * .3;
  
  // Hi rimina! Using your code here!
  
  vec4 pcol = vec4(0.0);
  vec2 puv = vec2(20./v2Resolution.x, 20./v2Resolution.y);
  vec4 mults = vec4(0.1531, 0.11245, 0.0918, 0.051);
  pcol = texture2D(texPreviousFrame, uv) * 0.1633;
  pcol += texture2D(texPreviousFrame, uv) * 0.1633;
  for (int i = 0; i < 4; ++i)
  {
    pcol += texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * mults[i] +
            texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * mults[i] +
            texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * mults[i] +
            texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * mults[i];
  }
  col += pcol.rgb;
  col *=0.35;
  
  col = mix(col, texture2D(texPreviousFrame, uv).rgb,.5);
  
  col = smoothstep(-.1, 1., col);
  
  out_color = vec4(col,1);
  
}