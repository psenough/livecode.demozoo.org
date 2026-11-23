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

#define hr vec2(1.,sqrt(3.))
#define circle(u,s) (length(u)-s)
#define sm(t,v) smoothstep(t,t*1.05, v)
#define noise(u) textureLod(texTex2, u, 0.).x
#define hash21(u) fract(sin(dot(u,vec2(164.7, 241.8)))*1675.1)

#define PI acos(-1.)
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

#define crep(p,c,l) p-= c*clamp(round(p/c), -l, l)
#define rep(p,c) p=mod(p, c)-c*.5
#define time fGlobalTime
#define dt(sp,off) fract((time+off)*sp)
#define swi(sp,off) floor(sin(dt(sp,off))*PI)


layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


struct obj{
float d;
vec3 sc;
vec3 lc;
};

obj objmin (obj a, obj b)
{
  if (a.d<b.d) return a;
  return b;
  }

void mo(inout vec2 p, vec2 d)
{
  p = abs(p)-d;
  if (p.y>p.x) p=p.yx;
  }

float box (vec3 p, vec3 c)
{
  vec3 q = abs(p)-c;
  return min(0.,max(q.x,max(q.y,q.z)))+length(max(q, 0.));
  }

float htr (vec2 uv)
{
  //uv = abs(uv)-.5;
  mo(uv,vec2(.25));
  vec2 ga = mod(uv,hr)-hr*.5, gb=mod(uv-hr*.5,hr)-hr*.5, 
  guv = (dot(ga,ga)<dot(gb,gb))?ga:gb, gid = uv-guv;
  if (noise(gid*.15)<.25) guv.x *= -1.;
  
  //float d = sm(0.1, abs(guv.x*sqrt(3.)+guv.y));
  float d = abs(guv.x*sqrt(3.)+guv.y)-.05;
  
  float s = (guv.x > -guv.y) ? 1.: -1.; 
  guv -= vec2(1., 1/sqrt(3.))*.5*s ;
  
 // d *= sm(0.05, abs(circle(guv, sqrt(3.)/6.)) );
  d = min(d, abs(circle(guv, sqrt(3.)/6.)));
  return d;
}

float st (vec2 uv)
{
    mo(uv, vec2(.35));
    vec2 id = floor(uv);
    uv = fract(uv)-.5;
  
  if (hash21(id)<.5) uv.x = -uv.x;
  float s = (uv.x > -uv.y)? 1.:-1.;
  
  uv -= .5*s;
  
  return abs(circle(uv, .5));
  
  }

float extrude (vec3 p, float d, float h)
{
  vec2 q = vec2(d, abs(p.z)-h);
  return min(0., max(q.x,q.y))+length(max(q,0.));
  }

obj SDF (vec3 p)
{
  
  p.yz *= rot(-atan(1./sqrt(2.)));
  if (swi(0.5, 0.)<.5) p.xz*= rot(PI/4.);
  
  p.x -= time;
  
  vec3 pp = p;
  p.y -= .5;
  float pt = extrude(p.xzy, htr(p.xz), 0.05+texture(texFFTSmoothed, 0.01).x)-.03;
  obj textru = obj(pt, vec3(0., 0.2,0.3), vec3(.5, .9,.2));
  
  p.y += .3;
  obj tt = obj(extrude(p.xzy, st(p.xz), .2+texture(texFFTSmoothed, 0.008).x)-.025,  vec3(0., 0.1, .5), vec3(0.4, .6, .8));
  
  float per = 1.5;
  p = pp;
  p.y += length(texture(texTex4, p.xz*.02))*.2;
  rep(p.xz, per);
  
  obj ground = obj(box(p, vec3(.71)), vec3(0.1,.0,.0), vec3(.8, .15, .1));
  obj scene = ground;
  scene = objmin(scene, textru);
  
  return scene;
  }

  
vec3 gn (vec3 p)
{
  vec2 eps = vec2(0.01, 0.);
  return normalize(SDF(p).d-vec3(SDF(p-eps.xyy).d,SDF(p-eps.yxy).d,SDF(p-eps.yyx).d));
  }
  
  float AO (vec3 p, vec3 n, float e)
  {return clamp(SDF(p+e*n).d/e, 0., 1.);}
  
  float spec (vec3 rd, vec3 l, vec3 n, float e)
  {return pow(max(dot(n, normalize(l-rd)),0.), e);}
  
void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy-v2Resolution.xy)/v2Resolution.y;
  
  if (swi(.125, 0.)<.5) mo(uv, vec2(1.));
  float size = (swi(.25, 0.)<.5) ? 4. : 2.;
  
  vec3 ro =vec3(uv*size, -30.), rd=vec3(0.,0.,1.), p=ro, 
  col=vec3(0.), l=vec3(0.5, 1., -2.);
  
  bool hit = false; obj O;
  for(float i=0.; i<64.; i++)
  {
    O = SDF(p);
    if (O.d<0.01)
    {
       hit=true; break;
      }
    p += O.d*rd*.5;
    }
  
  //uv *= 5.;
  //vec3 col = vec3(htr(uv)); 
  //
	if (hit)
  {
    vec3 n = gn(p);
    float li = max(dot(n,normalize(l)), 0.);
    float ao = AO(p,n,0.015)+AO(p,n,0.1)+AO(p,n,0.15);
    float sp =spec(rd, l, n, 25.);
    col = mix(O.sc, O.lc,li);
    col +=sp;
    col *= ao/3.;
    
  }
  col = mix(col, col+vec3(0.2, 0.4, .7), texture(texFFT, abs(uv.x*.15)+abs(uv.y*.15)).x*20.);
    out_color = vec4(sqrt(col), 1.);
}