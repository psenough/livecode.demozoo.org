#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


#define TAU 6.2831853071795864769
#define PI  3.1415926535897932384
#define t   fGlobalTime
#define sat(a) clamp(a, 0., 1.)
float hash11(float seed) { return fract(sin(seed*123.456789)*123.456); }
float sin3(float x) { return sin(x)*sin(x)*sin(x); }
float tsin(float x) { return tan(sin(x))/tan(1.); }
float ststs(float x) { return sin(tan(sin(tan(sin(x))))); }
float s3c3(float x) { return sin(x)*sin(x)*sin(x)+cos(x)*cos(x)*cos(x); }
float ass(float x) { return asin(sin(x))/(PI/2.); }
float cir(float x) { return -sign(mod(.5*x,2.)-1.)*sin(acos(mod(x, 2.) - 1.)); }
float stshc(float x) { return sin(tan(sinh(cos(x)))); }
float wtf(float x) { return -1.+2.*fract(atan(atanh(fract(x*.5))/tan(x*.5))); }
vec4 polar(vec2 v) { return vec4(length(v), 0., 0., atan(v.y, v.x)); } // r=radius, a=angle
mat2 rot(float a) { float c=cos(a), s=sin(a); return mat2(c, s, -s, c); }





vec3 getTexture(vec2 uv){
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions,uv*vec2(1,-1*ratio)-.5).rgb;
}
vec3 getTexture2(vec2 uv){
    vec2 size = textureSize(texShort,0);
    float ratio = size.x/size.y;
    return texture(texShort,uv*vec2(1,-1*ratio)-.5).rgb;
}

vec2  smin_(float a, float b, float k) // quadratic with mix, non-associative
{   // https://iquilezles.org/articles/smin/
    float h = max( k-abs(a-b), 0.0 )/k;
    float m = h*h*0.5;
    float s = m*k*0.5;
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}


float k;
float kk;
vec2 guv;
float map(vec3 p)
{
  //p += 1.1*sin(p.xzy);
  
  p = abs(p);
  kk = 0.;
  float dd = 1000.;
  for (int i = 0; i < 4; i++)
  {
    float r = float(i) * TAU/4.;
    p.xy *= rot(r);
    
    
  p -= vec3(1, 1, 0);
  float d = length(p) - (.9+.4*cos(t*2.3));
  p -= vec3(.5, .5+1.3*sin(t*.7), 0.5);
  float d2 = length(p) - (.7+.3*sin(t*2.5));
  
  vec2 s = smin_(d, d2, .38);
  
  d = s.x;
  k = s.y + .4*dot(cos(p*5.), sin(5.*p.zxy))  + float(i) + polar(guv).a*.4;
  kk += k * s.y;
  
  d = -smin_(-d, (length(p-vec3(0,0,0.3))-.9+.2*sin(t*1.1)), 0.2).x;
    
    
    dd = smin_(dd, d, .8).x;
  }

  return dd;
}

vec3 normal(vec3 p) { vec2 e=vec2(.001,0.); return normalize(
        vec3(map(p+e.xyy),map(p+e.yxy),map(p+e.yyx)) -
        vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)) ); }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec4 pol = polar(uv);
  vec2 uvo = uv;

	float d = pol.r;
	float f = texture( texFFT, d ).r * 100;
 
  
  uv = s3c3(t*1.2)>-.0 ? uv : abs(uv);
  guv = uv;

    float te = getTexture2(uv * rot(0.3*wtf(t)+sin(t))).x;
  float c = 1.-length(uv) - te;
  vec3 col = c*(0.5+0.5*sin(vec3(pol.a+t*.2+vec3(0,2+cos(t),4+sin(t)))));
  
  uv *= rot(t*.4);
  
  vec3 ro=vec3(0,0,-5);
  vec3 rd=normalize(vec3(uv,1.));
  vec3 p=ro;
  for (int i=0;i<50;i++)
  {
    float d=map(p);
    if (d>20.) break;
    if (d<.001)
    {
      vec3 n = normal(p);
      vec3 ldir=normalize(vec3(sin(t), cos(t), 1.));
      float diff = sat(dot(n, -ldir +0.*.2*sin(10.*p)));

      vec3 h = -normalize(rd + ldir);
      float blinnPhong = pow(sat(dot(h, n)), 200.);

      col = diff*vec3(0.5+0.5*sin(
        vec3(1+sin3(t),2+s3c3(t*1.4),4+s3c3(t*1.7))
        +t
        +k*(1.5+7.*s3c3(t*0.6))
        //+pol.a*3.+te*(3.+sin(t))
        +polar(uvo).a
      ))
      +blinnPhong;
      break;
    }
    p+=rd*d;
    //col = 0.01*vec3(.9, .6, .2);
  }
  
	out_color.xyz = tanh(col);
}