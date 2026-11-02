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

#define time fGlobalTime
#define PI acos(-1.)
#define dt(sp) fract(time*sp)
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define crep(p,c,l) p=p-c*clamp(round(p/c),-l,l)

// CUCUBE PREQUEL

float box (vec3 p, vec3 c)
{return length(max(abs(p)-c,0.));}

float cyl(vec3 p, float r, float h)
{return max(length(p.xy)-r,abs(p.z)-h);}

void moda(inout vec2 p, float r)
{
  float per = (2.*PI)/r;
  float a = mod(atan(p.y,p.x),per)-per*0.5;
  p=vec2(cos(a),sin(a))*length(p);
}

float cucube (vec3 p)
{
  p += vec3(1.,-7.,4.);
  p.yz *= rot(dt(0.5)*2.*PI);
  p.xy *= rot(dt(0.2)*2.*PI);
  return box(p,vec3(0.4));
}

float pipe (vec3 p)
{
  crep(p.x,0.5,2.);
  float c = cyl(p.xzy, 0.2,1e10);
  float per = 2.;
  p.y = mod(p.y,per)-per*0.5;
  c = min(c,cyl(p.xzy,0.25,0.1));
  return c;
}

float g1=0.;
float SDF (vec3 p)
{
  float cucu = cucube(p);
  g1 += 0.01/(0.01+cucu*cucu);
  
  p.y -= dt(0.5)*30.;
  vec3 pp = p;
  float d = -cyl(p.xzy, 10.,1e10);
  float per = 15.;
  float id = floor(p.y/per);
  p.y = mod(p.y,per)-per*0.5;
  float a = mod(id,2.)==0.?dt(0.1):-dt(0.1);
  p.xz *= rot(a*2.*PI);
  d = min(d, abs(p.y)-(-1.+2.*texture(texRevision,p.xz*0.05+0.5).x)*0.05);
  
  p = pp;
  moda(p.zx, 5.);
  p.z -= 9.8;
  d = min(d,pipe(p));
  
  d = min(d, cucu);
  
  return d;
}

vec3 gc (vec3 ro, vec3 ta, vec2 uv)
{
  vec3 f = normalize(ta-ro);
  vec3 l = normalize(cross(vec3(0.,1.,0.),f));
  vec3 u = normalize(cross(f,l));
  return normalize(f + uv.x*l + uv.y*u);
}

float hex (vec2 uv)
{
  vec2 hr = vec2(1.,sqrt(3.)),a=mod(uv,hr)-hr*0.5,b=mod(uv-hr*0.5,hr)-hr*0.5,
  guv = dot(a,a)<dot(b,b)?a:b;
  return max(abs(guv).x,dot(abs(guv),normalize(hr)));
  }

vec3 gn (vec3 p)
{
  vec2 e = vec2(0.001,0.);
  return normalize(SDF(p)-vec3(SDF(p-e.xyy),SDF(p-e.yxy),SDF(p-e.yyx)));
}

float AO (float e, vec3 p, vec3 n)
{return SDF(p+e*n)/e;}

void main(void)
{
	vec2 uv = (2.*gl_FragCoord.xy-v2Resolution.xy)/ v2Resolution.y;
  vec2 uu = gl_FragCoord.xy/v2Resolution.xy;

  uv += step(0.45,hex(uv*0.5))*0.5;
  
  vec3 ro = vec3(0.001,10.,-5.),rd=gc(ro, vec3(0.),uv),p=ro,col=vec3(0.);
  
  float d,shad;
  for (float i=0.;i<64.;i++)
  {
    float d = SDF(p);
    if (d<0.001)
    {
      shad = i/64.;break;
    }
    
    p += d*rd*0.8;
    
  }
 
  float t = length(p-ro);
  vec3 n = gn(p);
  col = vec3(1.-shad)*0.5;
  float ao = AO(0.1,p,n)+AO(0.24,p,n)+AO(0.5,p,n);
  col *=ao/3.;
  
  col = mix(col,vec3(0.1,0.2,0.3),1.-exp(-0.002*t*t));
  
  col += g1*vec3(0.1,0.5,0.6)*0.2;
  
	out_color = vec4(col,1.);
  
  out_color += vec4(texture(texPreviousFrame,uu*0.95+0.01).r,
  texture(texPreviousFrame,uu*0.95+0.02).g,
  texture(texPreviousFrame,uu*0.95+0.03).b,
  1.)*0.4;
  
}