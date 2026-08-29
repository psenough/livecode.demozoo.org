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

#define T(s,t) texture(s,(t+.5)/textureSize(s,0))
#define ns2(s) T(texNoise,s).r
#define fft(f) T(texFFT,f).r
#define ffts(f) T(texFFTSmoothed,f).r
#define ffti(f) T(texFFTIntegrated,f).r

float t = fGlobalTime;

float vmax(vec3 v){return max(max(v.x,v.y),v.z);}
float vmax(vec2 v){return max(v.x,v.y);}
#define bx(v,s) vmax(abs(v)-s)
#define rm(a) mat2(cos(a),sin(a),-sin(a),cos(a))

#define rep(v,s) (mod(v,s)-s*.5)

float wat = 0.;

vec2 w(vec3 p) {
  vec2 ret = vec2(1e6, -1.);
  float r = length(p.xz);
  float h = ns2(p.xz*7.) * 4.;
  h += smoothstep(20., 3., r) * 6.; 
  float d = p.y - h + 3.;

  vec3 pp = p;
  pp.xz -= .01*p.y*p.y+vec2(3.);
  float pr = .1 * mod(pp.y, 1.5);
  float lppxz = length(pp.xz);
  float pd = lppxz - .6 - pr;
  pp.y -= 25.;
  pd = max(pd, pp.y);
  
  pp.y -= cos(lppxz*.2)*2.-1.8;
  //pp.y 
  float pld = length(pp) - 7.;
  pld = max(pld, pp.y);
  pld = max(pld, -.01-pp.y);
  //pld *= .5;

  float plr = atan(pp.x, pp.z);
  pld = max(pld, rep(plr*4., 5.));
  pld *= .4;

  pd = min(pd, length(pp-vec3(-1.,-1.,1.))-.8);
  pd = min(pd, length(pp-vec3(1.,-1.,1.))-.9);

  if (d<ret.x)ret=vec2(d,1.);
  if (pld<ret.x)ret=vec2(pld,2.);
  if (pd<ret.x)ret=vec2(pd,5.);
  //ipd = min(pd, pld);

  //d = length(p) - 1.;
  //p.xy *= rm(-t);//max(0., sin(-t)));
  //p.xz *= rm(t);
  //d = min(d, bx(p,vec3(.5)));

  d = min(d, p.y + .3*sin(ns2(p.xz*4.+t*7. + 3. * ffti(.4))*8.+.4*sin(t*4.)));
  if (d<ret.x)ret=vec2(d,0.);

  p.xz *= rm(-.4);
  p.xy *= rm(.2);
  p.y -= 5.;
  p.x += 4.;
  vec3 bs = vec3(3., 2., 2.);
  d = bx(p, bs);
  
  float chestbox = -bx(p.xz, bs.xz+.1);
  d = max(d, chestbox);
  
  float dzlato = 1e6;
  dzlato = p.y - ns2(p.xz*8.)*6.*(1.-.2*length(p.xz)) - 1.;
  dzlato = max(dzlato, -chestbox);
  
  p.y -= 3.4;
  p.z += 3.4;
  float dlid = 1e6;
  dlid = min(dlid, max(length(p.yz) - 2., abs(p.x)-3.));
  dlid = max(dlid, -max(length(p.yz) - 1.8, abs(p.x)-2.8));
  dlid = max(dlid, -dot(p.yz, normalize(vec2(-1.))));
  d = min(d, dlid);
  
  if (d<ret.x)ret=vec2(d,3.);
  if (dzlato<ret.x)ret=vec2(dzlato,4.);

  return ret;
}

vec3 wn(vec3 p) {
  vec3 e=vec3(0., .01, 1.);
  return normalize(vec3(
    w(p+e.yxx).x,
    w(p+e.xyx).x,
    w(p+e.xxy).x)-w(p).x);
}

vec2 tr(vec3 o, vec3 d, float l, float L) {
  vec2 dd;
  for (float i = 0.; i < 100.; i++){
    dd=w(o+d*l);l+=dd.x;
    if (l>L||dd.x<.001*l) break;
  }
  return vec2(l,dd.y);
}

vec3 sd = normalize(vec3(1., .4, 1.));
vec3 sunc = vec3(.7, .5, .6);

vec3 skyc(vec3 d) {
  return mix(
    vec3(.1, .4, .7),
    sunc,
    pow(max(0., dot(d,sd)), 70.));
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 C=vec3(0.);
  
  vec3 O=vec3(0., 5., 15.), D=normalize(vec3(uv, -2.));
  mat2 ry=rm(.2+.2*sin(t));
  D.yz *= rm(.3+.03*cos(t*.3));
  O.xz *= ry;
  D.xz *= ry;
  O += normalize(O) * 60.;
  
  float L=230.;
  vec3 kc=vec3(1.);
  for (int bc=0;bc<2;++bc){
    vec2 lm = tr(O,D,0.,L);
    vec3 sc = skyc(D);
    if (lm.x>L) {
      //c = mix(c, vec3(.1), lm.x/L);
      C += kc * sc;
      //C = mix(C, vec3(.1), clamp(0., 1., D.y * lm.x));
      break;
    }
    
    vec3 p = O+D*lm.x;
    vec3 n = wn(p);
      
    vec3 md = vec3(1.);
    if (lm.y == 0.)
      md = vec3(.3, .3, .8);
    if (lm.y == 1.)
      md = vec3(.7, .7, .1);
    if (lm.y == 2.)
      md = vec3(.2, .9, .3);
    if (lm.y == 3.) {
      md = vec3(.3, .1, .0)*.7 * (ns2(n.xz*1000.) + ns2(p.xy*100.));
      //md = vec3(.3, .1, .0);
    } if (lm.y == 4.) {
      md = vec3(1., 1., .0)*2.;
    } else if (lm.y == 5.) {
      md = vec3(.3, .1, .0)*.7 * (ns2(n.xz*1000.) + ns2(p.xy*100.));
    }

    vec3 c = vec3(0.);
    p+=n*.1;
    if (tr(p,sd,0.,10.).x>=10.) c += md * sunc * max(0., dot(sd, n));
    
    vec3 skydir = vec3(-sd.x,sd.y,-sd.z);
    c += .05 * md * skyc(skydir);// * max(0., dot(skydir, n));
    
    c = mix(c, sc, pow(lm.x/L,3.));
    
    C += c * kc;
    
    if (lm.y != 0.)
      break;
    
    O = p;
    D = reflect(D, n);
    kc *= mix(md, sc, lm.x/L);
  }

	out_color = vec4(sqrt(C), 0.);
}