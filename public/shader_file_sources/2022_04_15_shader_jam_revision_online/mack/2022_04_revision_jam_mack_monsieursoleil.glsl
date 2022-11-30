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
uniform float midi01;
uniform float midi02;
uniform float midi03;
uniform float midi04;
uniform float midi05;
uniform float midi06;
uniform float midi07;
uniform float midi08;
uniform float midi09;
uniform float midi10;
uniform float midi11;
uniform float midi12;
uniform float midi13;
uniform float midi14;
uniform float midi15;
uniform float midi16;
uniform float midi17;
uniform float midi18;
uniform float midi19;
uniform float midi20;
uniform float midi21;
uniform float midi22;
uniform float midi23;
uniform float midi24;
uniform float midi25;
uniform float midi26;
uniform float midi27;
uniform float midi28;
uniform float midi29;
uniform float midi30;
uniform float midi31;
uniform float midi32;
uniform float midi33;
uniform float midi34;
uniform float midi35;
uniform float midi36;
uniform float midi37;
uniform float midi38;
uniform float midi39;
uniform float midi40;
uniform float midi41;
uniform float midi42;
uniform float midi43;
uniform float midi44;
uniform float midi45;
uniform float midi46;
uniform float midi47;
uniform float midi48;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

struct Matter
{
  float m;
  float glow;
  float glow02;
  int type;
  bool reflec;
};

struct Ray
{
  vec3 p;
  vec3 dir;
};
vec3 res;
Matter mat;
Ray ray;

mat2 rot(float a)
{
    float ca = cos(a);
  float sa = sin(a);
  
  return mat2(ca, sa, -sa, ca);
}

float sphere(vec3 p, float r)
{
  return length(p) -r;
}

float box(vec3 p, vec3 r)
{
  p= abs(p) -r;
  return max(p.x, max(p.y, p.z));
}

vec3 opRepl(vec3 p, float c, vec3 l)
{
  return p-c*clamp(round(p/c), -l,l);
}

vec2 opRepl(vec2 p, float c, vec2 l)
{
  return p-c*clamp(round(p/c), -l,l);

}

vec3 rand(vec3 p)
{
  return fract(sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)), dot(p, vec3(57.0, 113.0, 1.0)), dot(p, vec3(113.0, 1.0, 57.0))))*4356.23569);
}

vec3 voronoi(vec3 x)
{
  vec3 p = floor(x);
  vec3 f = fract(x);
  
  float id = 0.0;
  vec2 res = vec2(100.0);
  for(int k = -1; k<=1;++k)
  for(int j = -1; j<=1;++j)
  for(int i = -1; i<=1;++i)
  {
      vec3 b = vec3(float(i), float(j), float(k));
    
vec3 r = vec3(b)-f+rand(p+b);
    float d = dot(r,r);
    
    if(d<res.x)
    {
      res = vec2(d, res.x);
    }else if(d<res.y)
    {
      res.y =d;
    }
    
}
    
    return vec3(sqrt(res), abs(id));
}

void map(inout Matter ma, vec3 p)
{
   float ff = texture(texFFTSmoothed, 0.05).x*5.0 + 0.7;
    float mat01 = 10.0, mat02 = 10.0, mat03 = 10.0, mat04 = 10.0, mat05 = 10.0;
  vec3 p01 = p, p02 = p ;
  
  float s = 5.0*midi09;
  float amp = 0.99;
  //float n = noise(p) * 10.0 * midi10;
  
  
  
  p01-=vec3(0.0, 0.0, fGlobalTime);
  vec3 p03 = p01;
  vec3 p04 = p01;
  p03.xz *= rot(p.y);
  p03.xy *= rot(smoothstep(fGlobalTime * 3.0, 0.35, 0.65));
  p03.xz *= rot(smoothstep(fGlobalTime * 3.0, 0.35, 0.65));
  
  for(int i = 0; i < 1.0 * floor(abs(sin(fGlobalTime* 2.0)) * 5.0); ++i)
  {
      p03.xy *= rot(s+p.z);
    p03.x+= 0.5 *s;
    p03.y+= 0.5*s;
    //p03.xz *= rot(s);
      p = abs(p) + 0.2 * sin(fGlobalTime) *s;
    s*= amp;
    
  }
  
   p04.xy *= rot(p.z * 1.0);
  p04.xy *= rot(fGlobalTime);
    p04.xy *= rot(smoothstep(fGlobalTime * 2.0, 0.35, 0.65));
   p04.xz *= rot(smoothstep(fGlobalTime * 2.0, 0.35, 0.65));
  for(int i = 0; i < 1.0 * floor(abs(sin(fGlobalTime* 2.0)) * 5.0); ++i)
  {
      p04.xz *= rot(s+p.z)*ff;
    p04.x+= 0.2 *s;
    p04.y+= 0.1*s;
    //p03.xz *= rot(s);
      p = abs(p) + 0.2 * sin(fGlobalTime) *s;
    s*= amp;
    
  }
  
  p01.xz *=rot(fGlobalTime);
  
  p01.xy = opRepl(p01.xy, 1.0, vec2(2.5));
  p01.xz = opRepl(p01.xy, 1.0, vec2(2.5));
 
  
  mat01 = sphere(p03, 1.2*ff + 1.2);
  mat01 = box(p03, vec3(1.2*ff + 0.2, 0.5,3.5 * ff));
  mat01 = min(mat01, box(p04, vec3(1.2*ff + 0.2, 0.5,1.5 * ff)));
  mat05 = sphere(p-vec3(0.0,0.0,fGlobalTime), 3.0*ff);
  
  
   mat02 = box(p01, vec3(0.15*ff, 0.1*ff, 0.1*ff));
  mat02 = max(mat05, mat02);
  mat01 = min(mat01, mat02);
  
  mat01 = max(mat01, -sphere(p-vec3(0.0, 0.0, fGlobalTime), 1.95*ff+ 1.0));
  
  mat04 = sphere(p-vec3(0.0,0.0,fGlobalTime), 1.5*ff + 0.0);
  if(mat04 < 1.0)  
  {
    p02.xz*= rot(fGlobalTime*0.025);
    p02.xy*= rot(fGlobalTime*0.025);
    vec3 v = voronoi(0.1*p02*sin(fGlobalTime * 0.01) * 2.0);
    float f = clamp(10.0 * (v.y-v.x), 0.0, 1.0);
   // mat04 -= f*0.525;
    mat04 -= f*2.0;
    mat04 = max(-mat01, mat04);
    
    ma.glow02 += 0.001/(0.05+abs(mat04)) * ma.glow;
    ma.m = mat04;
    ma.type = 1;
    //return;
  }
  
  ma.type = 0;
  
   mat03 = sphere(p-vec3(0.0,0.0,fGlobalTime), 3.0-ff);
//mat03 = min(mat03, -box(p-vec3(0.0,0.0,fGlobalTime), vec3(6.0)));
  if(mat03<0.01&& !ma.reflec)
  {
    //ma.glow += 0.15/(0.05+abs(mat03));
     ma.m = mat03;
    ma.type = 2;
    return;
  }
  
  
  
  ma.glow += 0.15/(0.05+abs(mat01));
  
  ma.m = mat01;
  
}

vec3 normals(vec3 p)
{
  vec2 uv = vec2(0.01, 0.0);
  
  Matter ma02,ma03,ma04,ma05,ma06,ma07;
  
  map(ma02, p+uv.xyy);
   map(ma03, p-uv.xyy);
   map(ma04, p+uv.yxy);
   map(ma05, p-uv.yxy);
   map(ma06, p+uv.yyx);
   map(ma07, p-uv.yyx);
  
  return normalize(vec3(ma02.m- ma03.m, ma04.m- ma05.m, ma06.m- ma07.m));
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 o = vec3(cos(fGlobalTime + smoothstep(fGlobalTime * 0.5, 0.45, 0.65) + floor(fGlobalTime * 2.0) * 5.0)*10.0,sin(fGlobalTime + smoothstep(fGlobalTime * 2.0, 0.45, 0.65)+ floor(fGlobalTime * 0.5) * 1.0)*5.0,5.0 + fGlobalTime), t= vec3(0.0, 0.0, fGlobalTime);
  vec3 fr = normalize(t-o);
  vec3 ri = normalize(cross(fr, vec3(0.0, 1.0, 0.0)));
  vec3 up = normalize(cross(fr, ri));
  ray.dir = normalize(fr + uv.x * ri + uv.y * up);
  ray.p = ray.dir * 0.25 + o;
  
  mat.reflec = false;
  
  res = vec3(1.0) * midi04;
  
  for(int i = 0; i< 200*midi01;++i)
  {
   ray.p.xz *= rot(0.00008); 
    ray.p.xy *= rot(0.00008); 
    
    map(mat, ray.p);
    
    if(mat.m<0.01)
    {
      if(!(mat.type == 1))
        mat.m = 10.05 * midi05;
      
      if(!mat.reflec && mat.type == 2)
      {
          mat.reflec = true;
          vec3 N = normals(ray.p);
          ray.dir = reflect(ray.dir, -N);
          mat.m = 0.05;
      }
    }
    
    res += vec3(1.0 * sin(fGlobalTime + uv.x), 0.5 * sin(fGlobalTime + uv.y), 0.5) * 0.0003 * mat.glow * midi03 * pow((uv.y + sin(fGlobalTime *1.5)), 2.0);
     res += vec3(uv.x*2.0 + sin(fGlobalTime), uv.y * cos(fGlobalTime) * 2.0, 0.5) * 0.02 * pow(mat.glow02, 4.0) * midi03;
    ray.p += ray.dir * 1.0 * mat.m * midi02;
  }
 
  
  
  
	out_color = vec4(res, 1.0);
}