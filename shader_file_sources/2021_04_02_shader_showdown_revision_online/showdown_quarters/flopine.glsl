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
#define PI acos(-1.)
#define time fGlobalTime
#define dt(sp) fract(time*sp)
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define bouncy(sp) sqrt(sin(dt(sp)*PI)) 
#define BPM 174./60.
#define mo(p,d) p=abs(p)-d;if(p.y>p.x)p=p.yx

float box (vec3 p, vec3 c)
{
  vec3 q = abs(p)-c;
  return min(0.,max(q.x,max(q.y,q.z)))+length(max(q,0.));
}

float stmin(float a, float b, float k, float n)
{
  float st = k/n;
  float u = b-k;
  return min(min(a,b),0.5*(u+a+abs(mod(u-a+st,2.*st)-st)));
}

float cucube (vec3 p)
{
  p.y -= bouncy(BPM/2.)*4.;
  p.yz *= rot(dt(BPM/4.)*PI);
  return box(p,vec3(1.));
}

void moda(inout vec2 p, float r)
{
  float per = (2.*PI)/r;
  float a = mod(atan(p.y,p.x),per)-per*0.5;
  p = vec2(cos(a),sin(a))*length(p);
 }

 float g1=0.,g2=0.;
float SDF (vec3 p)
{
  p.yz *= rot(-atan(1./sqrt(2.)));
  p.xz *= rot(PI/4.);
  
  float cucu = cucube(p);
  g1 += 0.01/(.01+cucu*cucu);
  
  p.z += time*5.;
  float set = max(p.y-4.,abs(box(p,vec3(10.,5.,1e10)))-0.2);
  float per = 7.;
  p.x = abs(p.x)-9.;
  p.z = mod(p.z,per)-per*0.5;
  set = stmin(set, box(p,vec3(0.5,5.,0.5)),0.6,3.);
  
  p.z = mod(p.z,per)-per*0.5;
  p.x -= .5;
  moda(p.yz,3.);
  
  mo(p.xy,vec2(1.));
  set = min(set,box(p,vec3(0.15,1.5,0.15)));
  
  float d = min(cucu, set);
  
  return d;
}

vec3 gn (vec3 p)
{
  vec2 e = vec2(0.01,0.);
  return normalize(SDF(p)-vec3(SDF(p-e.xyy),SDF(p-e.yxy),SDF(p-e.yyx)));
}

float AO (float e, vec3 p, vec3 n)
{return SDF(p+e*n)/e;}

void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy-v2Resolution.xy)/ v2Resolution.y;
	vec2 uu = gl_FragCoord.xy/v2Resolution.xy;
  
  
  vec3 ro = vec3(uv*10.,-30.), rd=normalize(vec3(0.,0.,1.)), p=ro, col = vec3(0.015),l=normalize(vec3(1.,2.,-2.));
  bool hit = false;
  float d, shad;
  for (float i=0.;i<64.;i++)
  {
    d = SDF(p);
    if (d<0.001)
    {
      hit = true; shad = i/64.; break;
    }
    p += d*rd;
  }

  if (hit)
  {
    vec3 n = gn(p); float light = dot(n,l)*0.5+0.5;
    float ao = AO(0.1,p,n)+AO(0.2,p,n)+AO(0.45,p,n);
    col = vec3(light)*0.2;
    col *= ao/3.;
  }
  col += g1*vec3(0.1,0.7,0.5)*0.2;
  
  vec2 off = texture(texNoise,texture(texNoise,uv-time*0.1).xy+time*0.3).xy;
  
	out_color = vec4(sqrt(col),1.);
  
  out_color += vec4(texture(texPreviousFrame,uu*0.95+off*0.3).r,
  texture(texPreviousFrame,uu*0.95+off*0.1).g,
  texture(texPreviousFrame,uu*0.95+off*0.1).b,
  1.)*0.4;
  //out_color = vec4(off,0.,1.);
}