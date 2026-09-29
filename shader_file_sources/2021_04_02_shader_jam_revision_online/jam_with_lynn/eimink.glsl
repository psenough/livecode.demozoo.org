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
 
const int STEPS = 64;
const float E = 0.0001;
const float FAR = 40.0;
 
vec3 glow = vec3(0);
 
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
 
void rot(inout vec2 p, float a) {
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}
 
float sphere (vec3 p, float s)
{
  return length(p)-s;
}
 
float box(vec3 p, vec3 r)
{
  vec3 d = abs(p) - r;
  return length(max(d,0.) + min(max(d.x, max(d.y,d.z)),0.0));
}

float tun2(vec3 p){
    vec3 pp = p;
    vec3 t = vec3(2.) - abs(vec3(length(pp.xz),length(p.xy),1.0));
    return max(t.x,t.y)+.1;
    return min(max(t.x,t.y),0.0);
}

float scene(vec3 p)
{
  vec3 pp = p;
  float m = texture(texFFT,165).r*50;
  float ms = texture(texFFTIntegrated,85).r;
  for (int i = 0; i < 5; ++i)
  {
    pp = abs(pp) - vec3(1.,4.,5.);
    rot(pp.xy, fGlobalTime+texture( texFFTSmoothed, pp.x ).r*10);
    rot(pp.yz, fGlobalTime*0.1+texture(texFFTSmoothed, p.x).r*5.);
  }
  float a = box(pp, vec3(1.,.4,4.));
  float b = sphere(pp, m);
  rot(pp.xz,fGlobalTime);
  float c = box(pp, vec3(6.,8.,12.));
  rot(p.xz,m);
  rot(p.xy,fGlobalTime+ms);
  float d = abs(box(p,vec3(3.+sin(m*4.),.5,.5)));
  float e = abs(box(p,vec3(1.5,.5,3.+cos(ms))));
  float f = abs(box(p,vec3(1.5,3.+sin(m)+tan(ms*2.),.5)));
  float h = min(tun2(pp),.7);
  float g = max(h,min(f,min(d,e)));
  glow += vec3(.8,.4,.2)*0.01/(0.09+abs(a));
  glow += vec3(.4,.8,.1)*0.01/(0.9+abs(c));
  glow += vec3(.1,.2,.8)*0.1/(0.01+abs(g+h));
  return max(g,min(c,min(a,b)));
}
 
vec3 march (vec3 ro, vec3 rd)
{
  vec3 p = ro;
  float t = E;
  vec3 col = vec3(0);
  for (int i = 0; i < STEPS; ++i) {
    float d = scene(p);
    t += d;
    if ( d < E || t > FAR) {
      break;
    }
    p += rd*d;
  }
  if (t < FAR)
  {
    col = normalize(p)*vec3(.2,.2,.6)*.9;
  }
  return col;
}
 
vec4 plas( vec2 v, float time )
{
    float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
    return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
 
void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    vec2 q = -1.0+2.0*uv;
  q.x *= v2Resolution.x/v2Resolution.y;
 
  vec3 cp = vec3(0.,0.,10.);
  vec3 ct = vec3(0.,0.,0.);
   
  vec3 cf = normalize(ct-cp);
  vec3 cr = normalize(cross(vec3(0.,1.,0.),cf));
  vec3 cu = normalize(cross(cf,cr));
  vec3 rd = normalize(mat3(cr,cu,cf)*vec3(q,radians(60.0)));
  rot(cp.xy,fGlobalTime);
  vec3 c = march(cp,rd);
  c += glow;
  c += texture( texPreviousFrame, uv).xyz*.2;
   
    vec2 m;
    m.x = atan(q.x / q.y) / 3.14;
    m.y = 1 / length(q) * .2;
    float d = m.y;
 
    float f = texture( texFFTSmoothed, d ).r * 100;
    m.x += sin( fGlobalTime ) * 0.1;
    m.y += fGlobalTime * 0.25;
     
    out_color = vec4(c,1);
}