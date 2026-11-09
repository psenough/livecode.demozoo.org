#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define hr vec2(1.,sqrt(3))
#define PI acos(-1.)

#define hex(u) max(abs(u.x),dot(abs(u),normalize(hr)))
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

vec4 hexgrid (vec2 uv)
{
  vec2 ga=mod(uv, hr)-hr*.5, gb = mod(uv-hr*.5, hr)-hr*.5,
  guv = (length(ga)<length(gb))? ga:gb,
  gid = uv-guv;
  return vec4(guv,gid);
  }
  
  float extrude (vec3 p, float d, float h)
  {
    vec2 q = vec2(d,abs(p.z)-h);
    return min(0.0,max(q.x,q.y))+length(max(q,0.0));
    }

    float box (vec3 p, vec3 c)
    {return length(max(abs(p)-c,0.));}
    
float smin (float a, float b, float k)
    {
      float h = clamp(.5+.5*(b-a)/k,0.,1.);
      return mix(b,a,h)-k*h*(1.-h);
      }
    
      float sk (vec3 p)
      {
        //p.xz *= rot(fGlobalTime);
        p *= 2.5;
        vec3 pp = p;
        float d = length(p)-1.;
        d = max(-p.y-.33, d);
        p.x = abs(p.x)-.3;
        p.z += 1;
        d = max(-(length(p)-.33), d);
        
        p = pp;
        p.yz *= rot(PI/10.);
        p.z += .75;
        p.y += .3;
        vec3 sc = vec3(.5+p.y*.25, 0.6, 0.1); 
        d = smin(d, box(p,sc), 0.52);
        
        p.x = abs(abs(p.x)-.2)-.1;
        p.y += .7;        
        d = min(d, box(p,vec3(0.05,0.1, 0.05)));
        
        return d/2.5;
        }
      
      
float SDF (vec3 p)
{
  vec2 logpol = vec2(log(length(p.xy)), atan(p.x,p.y))/(PI/sqrt(3.));
    vec4 hg = hexgrid(logpol*2.-fGlobalTime);
  float d = extrude(p, .5-hex(hg.xy), 0.01)-0.1;
  d = min(d, sk(vec3(hg.xy,p.z)));
      return d;
}
      
      vec3 gn (vec3 p)
      {
        vec2 eps = vec2(0.01,0.0);
        return normalize(vec3(SDF(p)-vec3(SDF(p-eps.xyy),SDF(p-eps.yxy),SDF(p-eps.yyx))));
        }
    
        float AO (vec3 p, vec3 n, float e)
        {return clamp(SDF(p+e*n)/e,0.0,1.);}
        
void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy - v2Resolution.xy)/ v2Resolution.y;
	vec2 uu = gl_FragCoord.xy/v2Resolution.xy;
  vec3 ro = vec3(0.001,0.001, -3), rd=normalize(vec3(uv,1.)),p=ro, 
  col = vec3(0.);

  bool hit=false;
  for (float i=0.0; i<64.; i++)
  {
    float d = SDF(p);
    if (d<0.01)
    {
      hit=true; break;
      }
      p += d*rd*.8;
    
    }
  if (hit)
  {
    vec3 n = gn(p);
    float ao = AO(p,n,0.1)+ AO(p,n,0.15)+ AO(p,n,0.35);
    col = vec3(1.)*(1.-ao/3);
    }
  
	out_color = vec4(col, 1.);
    out_color += vec4(texture(texPreviousFrame, uu*.96+length(uv)*00.01).r,
    texture(texPreviousFrame, uu*.96+length(uv)*00.015).g,
    texture(texPreviousFrame, uu*.96+length(uv)*00.02).b,
    1.)*.3;
}