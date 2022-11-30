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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define mod01 floor(mod(time, 4))
#define mod02 floor(mod(time*2.0, 8))
#define fra01 smoothstep(0.25, 0.75, fract(mod(time * 2.0, 4)))

float fft = 0.0;
float fftSmooth = 0.0;

struct Matter 
{
    float m;
  float glow;
  bool reflected;
  int reflectNum;
  float distMat;
};

struct Ray
{
    vec3 t;
    vec3 o;
    vec3 p;
    vec3 dir;
    float dist;
};


struct Res
{
    vec3 col;
};

Res res;
Ray ray;
Matter mat;

mat2 rot(float a)
{
    float ca = cos(a);
    float sa = sin(a);
  
    return mat2(ca, sa, -sa, ca);
}

float sphere(vec3 p, float s)
{
    return length(p) - s;
}

float box(vec3 p, vec3 s)
{
    p = abs(p) - s;
    return max(p.x, max(p.y, p.z));
}

vec3 opRepLim( vec3 p, in float c, in vec3 l)
{
    return p-c*clamp(round(p/c),-l,l);
}

float opRepLim( float p, float c, float l)
{
    return p-c*clamp(round(p/c),-l,l);
}

void map(inout Matter ma, vec3 p)
{
    float mat01 = 10.0, mat02 = 10.0;
    vec3 p01 = p, p02 = p;
  p01.xy *= rot(-1.0 * fra01 + mod01 * -1.0);
  
  p01.x = opRepLim(p01.x, 0.5 + fftSmooth * 2000.0, 20.0);
  
  p02.xy *= rot(fra01 * 1.00 + mod01 * 1.00);
  
  p02 = opRepLim(p02, 0.5 + fftSmooth * 2000.0, vec3(20.0));
  
  if(ma.reflected == false && ma.reflectNum < 1)
  {
    mat01 = sphere(p, 2.15 + fftSmooth * 1600.0 + mod02 * 0.5 );
    ma.glow += 0.15/(0.05+abs(mat01));
    ma.m = mat01;
    return ;
  }
  
  if(ma.reflectNum < 2)
  {
    mat01 = box(p, vec3(2.05 + mod02 * 0.25 + fra01 * 0.55));
    ma.glow += 0.15/(0.05+abs(mat01));
    ma.m = mat01;
    return ;
  }
  
  if(ma.reflectNum < 3)
  {
    mat01 = sphere(p, 1.75 + 0.25 * fra01 + 0.25* mod01);
    ma.glow += 0.15/(0.05+abs(mat01));
    ma.m = mat01;
    return ;
  }
  
  
  
  mat02 = sphere(p02, 0.5+ fftSmooth * 1000.0);
  
    mat01 = box(p01, vec3(0.01 + fftSmooth * 500.0, 5.0, 0.05 ));
    ma.glow += 0.25/(0.05+abs(mat01));
    
    ma.distMat = 1.0 - mat02 * 2.0;
    
    mat01 = max(mat01, mat02);
    
    ma.m = mat01;
}

vec3 oklab_mix( vec3 colA, vec3 colB, float h )
{
    // https://bottosson.github.io/posts/oklab
    const mat3 kCONEtoLMS = mat3(                
         0.4121656120,  0.2118591070,  0.0883097947,
         0.5362752080,  0.6807189584,  0.2818474174,
         0.0514575653,  0.1074065790,  0.6302613616);
    const mat3 kLMStoCONE = mat3(
         4.0767245293, -1.2681437731, -0.0041119885,
        -3.3072168827,  2.6093323231, -0.7034763098,
         0.2307590544, -0.3411344290,  1.7068625689);
                    
    // rgb to cone (arg of pow can't be negative)
    vec3 lmsA = pow( kCONEtoLMS*colA, vec3(1.0/3.0) );
    vec3 lmsB = pow( kCONEtoLMS*colB, vec3(1.0/3.0) );
    // lerp
    vec3 lms = mix( lmsA, lmsB, h );
    // gain in the middle (no oaklab anymore, but looks better?)
 // lms *= 1.0+0.2*h*(1.0-h);
    // cone to rgb
    return kLMStoCONE*(lms*lms*lms);
}

vec3 normals(vec3 p)
{
  vec2 uv = vec2(0.01, 0.0);
  
   Matter m02, m03, m04;
  
    map(m02, ray.p + uv.xyy);
    map(m03, ray.p + uv.yxy);
  map(m04, ray.p + uv.yyx);
  
  return normalize(mat.m - vec3(m02.m, m03.m, m04.m));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  mat.reflected = false;
  
  mat.distMat = 1.0;
  
  float zoom = 25.0 * midi01;
  
  ray.o = vec3(zoom * sin((mod01 + fra01) * 0.5), zoom * midi03, zoom * cos((mod01 + fra01) * 1.5)), ray.t = vec3(0.0);
  vec3 fr = normalize(ray.t-ray.o);
  vec3 ri = normalize(cross(vec3(0.0, 1.0, 0.0), fr));
  vec3 up = normalize(cross(fr, ri));
  
  ray.dir = normalize(fr + uv.x * ri + uv.y * up);
  ray.p = ray.o + ray.dir * 0.25;
  
fftSmooth = texture(texFFTSmoothed, 0.1).x * 1.0;
  
  res.col = vec3(0.55 + fftSmooth * 250.0);
	
  for(int i = 0; i < 100 * midi06; ++i)
  {
    float add = 1.0;
      map(mat, ray.p);
    
    res.col -= oklab_mix(vec3(1.0 * abs(sin(time * 0.1)),1.0 * abs(sin(time * 0.05)), 1.0), vec3(1.0,0.5 * abs(sin(time * 0.25)), 1.0 * abs(sin(time * 0.1))), max(pow(sin(ray.p.z * 0.01) + sin(time * 0.55), 2.0), 0.0)) * mat.glow * 0.001 * (midi08 - max(fftSmooth * 500.0, 0.0)) * max(mat.distMat, 1.0);
    
   
    
    if(mat.m < 0.01)
    {
      if(mat.reflectNum < 3)
      {
          mat.reflected = true;
          vec3 n = normals(ray.p);
          ray.dir = reflect(-n, ray.dir);
          mat.reflectNum++;
        continue;
      }
      
        add = 4.0 * midi05 + 1.0;
    }
    
    ray.p += ray.dir * 0.5 * (midi07 + abs(sin(time * 0.5) * 2.0)) * add + ray.dir * fftSmooth * 10.0; 
  }
  
	out_color = vec4(res.col * midi10, 1.0);
}