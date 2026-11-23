#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI 3.141592
#define TAU 6.2831

#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define mo(puv,d) puv = abs(puv)-d; if(puv.y>puv.x) puv=puv.yx
#define rep(puv, per, nm) puv = puv-per*clamp(round(puv/per),-nm,nm)  

#define BPM (100./60.)
#define time fGlobalTime
#define dt(speed) fract(time*speed)
#define switanim(sp) floor(sin(dt(sp)*TAU)+1.)
#define bouncy(sp) sqrt(abs(sin(dt(sp)*TAU)))

float box (vec3 p, vec3 c)
{
  vec3 q = abs(p)-c;
  return min(0.,max(q.x,max(q.y,q.z)))+length(max(q,0.));
}

float sc (vec3 p, float d)
{
  p = abs(p);
  p = max(p,p.yzx);
  return min(p.x,min(p.y,p.z))-d;
}

int mat; float g1=0.;
float SDF (vec3 p)
{
  p.yz *= rot(-atan(1./sqrt(2.)));
  p.xz *= rot(PI/4.);
  
  rep(p.yz, 8., 2.);
  
  mo(p.xz, vec2(1.));
  p.x -= 0.5;
  float a = bouncy(BPM/8.)*3.;
  p.xz += vec2(cos(a), sin(a*0.8));
  //p.xz *= rot();
  mo(p.yz, vec2(1.5));
  
  float spheres = max(-sc(p,0.2),length(p)-0.8);
  g1 += 0.001/(0.001+spheres*spheres);
  float cages = max(-sc(p,0.8),box(p,vec3(1.)));
  float d = min(spheres,cages);
  
  if (d == spheres) mat = 1;
  if (d == cages) mat = 2;
  
  return d; 
}


vec3 getnorm(vec3 p)
{vec2 eps = vec2(0.001,0.);
  return normalize(SDF(p)-vec3(SDF(p-eps.xyy),SDF(p-eps.yxy),SDF(p-eps.yyx))); 
  }

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float size = (switanim(BPM/8.)< 0.5) ? 5.:25.;
  
  vec3 ro = vec3(uv*size,-50.), p = ro, rd = vec3(0.,0.,1.), col = vec3(0.), l = vec3(-1.,2.,-2.), n;

  bool hit = false; float shad = 0.;
  
for(float i=0.; i<64.; i++)
{
  float d = SDF(p);
  if (d<0.001)
  {
    n = getnorm(p);
    hit = true;
    if (mat == 2) rd = reflect(rd,n)*0.8+0.2; 
    //break;
  }
  p += d*rd*0.7;
}  
  
if (hit)
{
  //vec3 n = getnorm(p);
  float lighting = max(dot(n,normalize(l)),0.);
   if (mat == 1) col = mix(vec3(0.4,0.,0.5),vec3(0.,0.5,0.6),lighting);
  if (mat == 2) col = vec3(0.);
  }
float a = dt(BPM/8.)*TAU;
  col += g1*texture(texNoise,uv*5.+vec2(cos(a),sin(a))).r*vec3(0.8,0.5,0.1);
  out_color = vec4(sqrt(col),1.);
}