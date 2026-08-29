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
// flopine

#define PI acos(-1.)
#define rot(a) mat2(cos(a),sin(a), -sin(a), cos(a))
#define dt(sp) fract(fGlobalTime*sp)
#define swia(sp) floor(sin(dt(sp)*2.*PI)+1.)

struct obj {
  float d;
  vec3 c;
  };
  
  void mo (inout vec2 p, vec2 d)
  {
    p = abs(p)-d; if(p.y>p.x) p=p.yx;
    }
  
  float cube (vec3 p, vec3 c)
  {
    vec3 q = abs(p)-c;
    return length(max(q,0.));
    }
    
  obj minobj(obj a, obj b)
  {
    if (a.d<b.d) return a;
    else return b;
    }
    
    obj prim1 (vec3 p)
    {
      float d = 1e10, size = .1;
      for (int i=0; i<4.; i++)
      {
        float ratio = float(i)/5.;
        p.xy *= rot(fGlobalTime+ratio*.5);
        mo(p.xz, vec2(.2*ratio+.3));
        mo(p.xy,vec2 (.5*ratio));
        d = min(d,cube(p, vec3(size)));
        size += .01;
       }
      
      return obj(d, vec3(.1,.8,.6));
      }
      
      obj prim2 (vec3 p)
      {
        float d = 1e10;
        for (int i=0; i<4; i++)
        {
          p.xz *= rot(fGlobalTime);
          mo(p.yz, vec2(.5));
          mo(p.xz, vec2(.8));
          d = length(p.xy)-.05;
          }
          return obj(d,vec3(1.,0.,0.));
        }
        
        
      obj SDF (vec3 p)
      {
        p.yz *= rot(-atan(1./sqrt(2.)));
        p.xz *= rot(PI/4.);
        
        return minobj(prim1(p), prim2(p));
        }
    
        vec3 gn (vec3 p)
        {vec2 eps = vec2(0.001,0.);
          return normalize(SDF(p).d-vec3(SDF(p-eps.xyy).d,SDF(p-eps.yxy).d, SDF(p-eps.yyx).d));
          }
       

          
void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  if(swia(1.)<.5) mo(uv, vec2(0.45));
  
  
  float prout = texture(texFFT, length(uv)*.2).x;
  uv += prout*.4;
  
  vec3 ro = vec3(uv*5., -30.), rd=vec3(0.,0.,1.), p=ro, col=vec3(0.), l=normalize(vec3(1.,1.5,-1.));
  bool hit=false;
  obj O;
  for (float i=0.; i<100.; i++)
  {
    O = SDF(p);
    if (O.d <0.001)
    {
      hit = true; break;
      }
      p += O.d*rd;
    
    }
  if (hit)
  {
    vec3 n = gn(p);
    float light = dot(n,l)*.5+.5;
    col = O.c*light;
    }
  float mask = texture(texFFT, 0.01).x;
    col = (mask<.05)? pow(col, vec3(0.1)):col;
	//col = (mask<.05)? 1.-col:col;
	
	out_color = vec4(sqrt(col),1.);
}