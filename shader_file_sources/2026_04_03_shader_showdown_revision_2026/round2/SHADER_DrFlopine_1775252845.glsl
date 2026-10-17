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
// bonjourhaaaaaan

struct qt {
  vec3 c; 
  vec3 s; 
  float d;
  
  };
  
#define rand(x) fract(sin(x)*264.3)
  #define flo(i,j) (floor((i)/(j))*(j))
#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))
  #define time fGlobalTime
  
qt tree (vec3 p, vec3 rd)
{
  qt q;
  q.s = vec3(1.);
  for (int i=0; i<3; i++)
  {
    q.s *= vec3(0.5, 1., 0.5);
    q.c = flo(p+rd*1e-2, q.s)+q.s*0.5;
    q.c.y = 0;
    if (rand(dot(q.c, vec3(1.,2.,3.)))>0.5) break;
    
    }
    
    vec3 src = -(p-q.c)/rd;
    vec3 dst = abs(q.s*0.5/rd);
    vec3 bv = src+dst;
    q.d = min(bv.x, bv.z);
    return q;
  }  

float box (vec3 p, vec3 c)
{
  vec3 q = abs(p)-c;
  return min(0., max(q.x, max(q.y, q.z)))+length(max(q, 0.));
  }  
float g= 0.;
float SDF (vec3 p, vec3 c, vec3 s)
  {
    float res = 0.05;
    vec2 u = fract(c.xz*res)-0.5;
    u *= rot(time);
    u += 0.5;
    
    float t = texture(texRevisionBW, u).x;
    float d;
    
    p.xz -= c.xz;
    if (t<=0.45)
    {
        p.y += 1.;
        p.y -= sin(time*9.+rand(dot(c.xz, vec2(2., 3.))))*0.4 + 0.44;
        d = box(p, s*0.45);
    }
    else
    {
      d = box(p, s*0.45);
      p.y -= 0.5+s.x*0.3;
      float c = length(p)-s.x*0.3;
      g += 0.001/(0.001+c*c);
      d = min(d,c);
    }
    
    return d;
    }
  
vec3 cam (vec3 ro, vec3 ta, vec2 uv, float fo)
{
  vec3 f = normalize(ta-ro);
  vec3 l = normalize(cross(vec3(0,1,0), f));
  vec3 u = normalize(cross(f,l));
  return normalize(f*fo + u*uv.y + l*uv.x);
}

vec3 gn (vec3 p, vec3 c, vec3 s)
{
  vec2 eps = vec2(0.01, 0.);
  return normalize(SDF(p, c, s) - vec3(SDF(p-eps.xyy,c,s),SDF(p-eps.yxy,c,s),SDF(p-eps.yyx,c,s)));
}
    
#define an (fGlobalTime * 15. + texture(texFFTIntegrated, 0.001).x)
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(5., 15., -6.+an), rd=cam(ro, vec3(6, 2. , an), uv, 1.), p=ro, col=vec3(0.), l=normalize(vec3(0.5, 1., 4.));
  
  float glen=0, rl=1e-2; qt q;
  
  for (float i=0.; i<200.; i++)
  {
    if (glen <= rl)
    {
      q = tree(p, rd);
      glen += q.d;
      }
    float d = SDF(p, q.c, q.s);
      rl = min(rl+d, glen);
      p = ro + rd*rl;
      
    if (d < 0.001)
    {
      vec3 n = gn(p, q.c, q.s);
      float spe = pow(max(dot(n,normalize(l-rd)), 0.), 30.);
      col = vec3(0.001)+spe;
    }      
      
    
  }
  vec2 uu = vec2(gl_FragCoord.xy / v2Resolution.xy); 
  col += g*0.01*vec3(1., rand(dot(q.c,vec3(2.,3.,5.)))*0.2, rand(dot(q.c,vec3(2.,3.,5.)))*0.8);
	out_color = vec4(sqrt(col), 1.) + texture(texPreviousFrame, uu)*clamp(exp(-fract(time*0.2)*2.5),0.,0.95);
}