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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI acos(-1.)
#define crep(p,c,l) p-=c*clamp(round(p/c),-l,l)
#define cube(p,c)length(max(abs(p)-c,0.))
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define hash21(p) fract(sin(dot(p,vec2(12.5,23.8))*1465.5))
#define palette(t,c,d) (vec3(0.5)+vec3(0.5)*cos(2.*PI*(c*t+d)))

float prim1 (vec3 p, float sy)
{
  crep(p.xz, .35,1.);
  return max(-length(p.xz)+.1, cube(p, vec3(.15, sy, 0.15)));
  }
  
  vec2 edge (vec2 p)
  {
    vec2 p2=abs(p);
    if (p2.x>p2.y) return vec2((p.x<0.)?-1.:1.,0.);
    else return vec2(0.,(p.y<0.)?-1.:1.);
    }
  
  float prims (vec3 p)
{
  vec2 center = floor(p.xz)+.5;
  vec2 neigh = center + edge(p.xz-center);
  
  float sy = mix(0.2,0.6,hash21(center));
  vec3 mep = p-vec3(center.x, 0., center.y); 
  float me = prim1(mep, sy);
  vec3 nep = p-vec3(neigh.x, 0., neigh.y); 
  float ne = cube(nep, vec3(0.499,1.,0.499));
  return min(me,ne);
  }

  vec2 id; float g1=0.;
  float cyls (vec3 p)
  {
    id = floor(p.xz/0.33);
    float per = 0.335;
    p.xz = mod(p.xz, per)-per*.5;
    float sy = .3+sin(length(id)-fGlobalTime*4.)*.3;
    float d =  max(length(p.xz)-0.08, abs(p.y)-sy);
    g1 += 0.001/(0.001+d*d);
    return d;
    }
  
float SDF (vec3 p)
{
  p.yz *= rot (-atan(1./sqrt(2.)));
  p.xz *= rot(PI/4.);
  
  return min(cyls(p),prims(p));
  }
  
  vec3 gn (vec3 p)
  {vec2 eps = vec2(0.01,0.);
    return normalize(SDF(p)-vec3(SDF(p-eps.xyy),SDF(p-eps.yxy),SDF(p-eps.yyx)));
    
    }
float mask (vec2 uv)
    {
      uv *= 1.5;
      float m = texture(texFFT, floor((abs(uv.x)+abs(uv.y))*16.)/16.).x;
      return m;
      }
    
void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
float dither = hash21(uv);
  vec3 ro = vec3(uv*4.,-30.), rd=vec3(0.,0.,1.),p=ro,col=vec3(0.), l=vec3(1.,1.,-1.);
  bool hit = false;
  
  for (float i=.0; i<150.; i++)
  {
    float d = SDF(p);
if (d<0.001)
{
    hit = true; break;
  }  
  d *= .9+dither*0.1;
  p += d*rd;
    }
  
    if (hit)
    {
      vec3 n = gn(p);
      float light = dot(n,l)*.1+.1;
      col = vec3(light);
      }
	col += g1*palette(hash21(id),vec3(0.5),vec3(0.,0.36,0.64))*.3;
      
  col = (mask(uv)<.02)?col:clamp(1.-col,0.,1.);
      //col = vec3(mask(uv));
	out_color = vec4(sqrt(col),1);
}