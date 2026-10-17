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
#define circ(u,s) (length(u)-s)
#define PI acos(-1)
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define hash21(x) fract(sin(dot(x,vec2(134.2, 234.1)))*467.1)
#define pal(t,c) (vec3(.6)+vec3(.3)*cos(PI*2*(c*t+vec3(.4,.6,.8))))

float tru (vec2 uv)
{
  vec2 id = floor(uv);
  uv = fract(uv)-.5;
  if(hash21(id*.1)>.6) uv.x *= -1.;
 
  if(hash21(id*.2)>.5)
  {
    vec2 uu = uv;
    float s = (uv.x>-uv.y) ? 1.:-1.;
  uv -= .5*s;
    float d = abs(circ(uv, .5));
    
    uv = uu;
    uv = abs(uv)-.5;;
    d = min(d, circ(uv,.0));
    
  return d;
  
    }
  else
  {
    uv = mod(uv,.5)-.25;
    float s = (uv.x>-uv.y) ? 1.:-1.;
  uv -= .25*s;
  return .25-abs(circ(uv, .25));
    }
  
  
  }
void mo (inout vec2 p, vec2 d)
  {
    p = abs(p)-d;
    if(p.y>p.x)p=p.yx;;
    }
  
  float extrude (vec3 p, float d, float h)
  {
    vec2 q = vec2(d, abs(p.z)-h);
    return min(0., max(q.x, q.y))+length(max(q,0.));
    }
  
    float SDF (vec3 p)
    {
      p.xy *= rot(p.z*.1);
      
      p.yz *= rot(PI/5.);
      p.z += fGlobalTime*3.+texture(texFFTSmoothed, 0.01).x*10.;
      
      mo(p.xy,vec2(2.5));
      mo(p.xz,vec2(2.));
      
      float d = extrude(p, abs(abs(tru(p.xy)-.25)-.1), 0.01)-.05;
      d = min(d,extrude(p, tru(p.xy), 0.01+texture(texFFT, 0.01).x*.5)-.05) ;
      return d;;
      }
    
      vec3 gn (vec3 p)
      {
        vec2 eps = vec2(0.01,0);;
        return normalize(SDF(p)-vec3(SDF(p-eps.xyy),SDF(p-eps.yxy),SDF(p-eps.yyx)));
        }
      
        float AO (vec3 p, vec3 n, float e)
        {return clamp(SDF(p+e*n)/e,0.,1.);}
        
void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy-v2Resolution.xy) / v2Resolution.y;
  vec2 uu = gl_FragCoord.xy/v2Resolution.xy;
  vec3 ro = vec3(0.001,-1.,-3.), rd=normalize(vec3(uv,1.)),p=ro,
  col=vec3(0.);
  
  bool hit = false;
  float t=0.;
  for(float i=0.; i<64.; i++)
  {
    p = ro+t*rd;
    float d = SDF(p);
    if (d<0.01)
    {
      hit=true;
      break;
      }
      t += d*.8;
    }
  if (hit)
  {
    vec3 n = gn(p);
    float ao = AO(p,n,0.1)+AO(p,n,0.2)+AO(p,n,0.25);;
    col = vec3(1.-ao/3.)*pal(p.y, vec3(.1))*texture(texFFTSmoothed, 0.01).x*10.;
    }
    col = mix(col, vec3(.1), 1.-exp(-0.001*t*t));
  //vec3 col = vec3(tru(uv*5.));
	out_color = vec4(col,1.);
    out_color += vec4(texture(texPreviousFrame, uu*.96+length(uv)*0.01).r,
    texture(texPreviousFrame, uu*.96+length(uv)*0.015).g,
    texture(texPreviousFrame, uu*.96+length(uv)*0.02).b,
    1.)*.5;
}