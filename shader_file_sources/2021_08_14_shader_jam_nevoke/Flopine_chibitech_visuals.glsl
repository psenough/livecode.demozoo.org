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

#define PI acos(-1.)
#define TAU (2.*PI)

#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define crep(p,c,l) p-=(c*clamp(round(p/c),-l,l))
#define pal(c,t,d) (vec3(0.5)+vec3(0.5)*cos(TAU*(c*t+d)))
#define rep(p,d) p=(mod(p,d)-d*0.5)
#define mo(p,d) p=abs(p)-d;if(p.y>p.x)p=p.yx

#define frt(sp,off) fract((fGlobalTime+off)*sp)
#define bouncy(sp,off) sqrt(sin(frt(sp,off)*PI))
#define swi(sp,off) floor(sin(frt(sp,off)*TAU)+1.)

struct obj{
  float d;
  vec3 sha;
  vec3 li;
};

obj minobj (obj a, obj b)
{return (a.d<b.d)?a:b;}

float box (vec3 p, vec3 c)
{
    vec3 q = abs(p)-c;
  return min(0.,max(q.x,max(q.y,q.z)))+length(max(q,0.));
}

float od (vec3 p, float d)
{return dot(p,normalize(sign(p)))-d;}

void moda(inout vec2 p, float rep)
{
  float per = TAU/rep;
  float a = mod(atan(p.x,p.y),per);
  p = vec2(cos(a),sin(a))*length(p);
}

obj cubes (vec3 p)
{
  float size = .25; 
  vec3 cid = round(p/size);
  crep(p,size,2.);
  float d = box(p,vec3(0.1));
  
  return obj(d,vec3(0.,0.05,0.2),pal(length(cid),vec3(0.5),vec3(0.,0.63,0.37)));
}

obj carp (vec3 p)
{
  p.z -= (fGlobalTime+texture(texFFTIntegrated,0.001).x*2.);
  
  float id = floor(p.z/1.2);
  p.y += .5;
  rep(p.z,1.2);
  float d = box(p,vec3(1.5,0.05,0.5)); 
  
  return obj(d,vec3(0.,0.1,0.),pal(id,vec3(0.1),vec3(0.4,0.6,0.)));
}

obj prim1 (vec3 p)
{
  obj scene = carp(p);
  
  float id = floor(p.z/4.);
  p.z += fGlobalTime;
  p.y -= bouncy(2.,id*0.1);
  rep(p.z,4.);
  
  return minobj(scene,cubes(p));
}

obj carp2 (vec3 p)
{
  p.z += (fGlobalTime+texture(texFFTIntegrated,0.001).x*2.);
  
  float id = floor(p.z/1.2);
  p.y += .5;
  rep(p.z,1.2);
  float d = box(p,vec3(1.5,0.05,0.5)); 
  
  return obj(d,vec3(0.3,0.1,0.4),vec3(1.,0.1,0.5));
}

obj prim2 (vec3 p)
{
   
   p.y += sin(p.z*0.3)*0.5;
  obj scene = carp2(p);
  
  float id = floor(p.z/6.);
  p.y -= bouncy(2.,id*0.2)*3.;
  rep(p.z,6.);
  p.yz *= rot(frt(1.,0.)*TAU);
  float d = mix(box(p,vec3(0.5)),od(p,0.6),0.5);
  
  scene = minobj(scene,obj(d,vec3(0.,0.01,0.1),vec3(0.1,0.8,1.)));
  return scene;
}

obj SDF (vec3 p)
{
  p.yz *= rot(-atan(1./sqrt(2.)));
  p.xz *= rot(PI/4.);
  if (swi(.5,0.)<0.5) {mo(p.xz,vec2(2.)); }
  vec3 pp=p;
  
  crep(p.x,10.,4.);
  obj scene = prim1(p);
  p=pp;
  p.x += 5.;
  crep(p.x,10.,4.);
  return minobj(prim2(p),scene);
}

vec3 getnorm (vec3 p)
{
  vec2 eps = vec2(0.001,0.);
  return normalize(SDF(p).d-vec3(SDF(p-eps.xyy).d,SDF(p-eps.yxy).d,SDF(p-eps.yyx).d));
}

void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy-v2Resolution.xy)/v2Resolution.y;

  
  
  float mask = step(0.4,texture(texFFT,(abs(uv.x)+abs(uv.y))*0.02).x*20.);
  uv += mask*0.1;
 
  float size = (swi(1.,0.)<0.5)?5.:10.;
  vec3 ro=vec3(uv*size,-20.),rd=vec3(0.,0.,1.),p=ro,col=vec3(mask),l=normalize(vec3(2.,4.,-3.));
  bool hit = false; obj O;
  
  for(float i=0.;i<64.;i++)
  {
    O = SDF(p);
    if(O.d<0.01)
    {
      hit=true; break; 
    }
    p += O.d*rd;   
  }
  
  if (hit)
  {
    vec3 n = getnorm(p);
    float light = max(dot(n,l),0.);
    col = mix(O.sha,O.li,light);
  }
  
  col = mix(col,1.-col,mask);
	out_color = vec4(sqrt(col),1.);
}