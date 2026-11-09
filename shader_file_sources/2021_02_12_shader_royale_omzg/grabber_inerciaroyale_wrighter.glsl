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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


#define iTime fGlobalTime
#define R v2Resolution
#define U fragCoord
#define T(u) texture(texPreviousFrame, (u)/R)

mat3 getOrthBas( vec3 dir){
  vec3 r = normalize(cross(vec3(0,1,0), dir));
  vec3 u = normalize(cross( dir, r));
  return mat3(r,u,dir);
  }

float cyclicNoise(vec3 p){
  float n = 0.;
  p *= getOrthBas(normalize(vec3(-4,2.,-2 + sin(iTime)*0.1)));
  float lac = 1.5;
  float amp = 1.;
  float gain = 0.5;
  
  mat3 r = getOrthBas(normalize(vec3(-4,2.,-2)));
  

  for(int i = 0; i < 8; i++){
    p += cos(p + 2 + vec3(0,0,iTime))*0.5;
    n += dot(sin(p),cos(p.zxy + vec3(0,0,iTime)))*amp;
    
    p *= r*lac;
    amp *= gain;
    }
    return n;
  }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  #define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
  
  vec2 U = gl_FragCoord.xy;
  
  U -= 0.5*R;
  //U *= rot(iTime*0.01);
  U *= 0.99 + sin(iTime)*0.00 - dot(U/R,U/R)*0.05;
  U += 0.5*R;
  out_color = T(U);
  #define getGrad(axis) vec2(e[axis]-w[axis],n[axis]-s[axis])
  float offs = 20. + sin(iTime + length(uv)*1.5)*40;
  vec4 n = T(U + vec2(0,1)*offs);
  vec4 s = T(U + vec2(0,-1)*offs);
  vec4 e = T(U + vec2(1,0)*offs);
  vec4 w = T(U + vec2(-1,0)*offs);
  
  vec2 grad = getGrad(0);
  
  float noisb = cyclicNoise(vec3(U/R*2.,1. + iTime*0.2 + sin(iTime)*1.));
  
  grad *= rot(noisb*0.2*sin(iTime) - iTime*0.);
  vec2 uu = U;
  uu += grad*22. + noisb*1.;
  out_color = T(uu);
  n = T(uu + vec2(0,1));
  s = T(uu + vec2(0,-1));
  e = T(uu + vec2(1,0));
  w = T(uu + vec2(-1,0));
  
  #define pal(a,b,c,d,e) ((a) + (b)*sin((c)*(d) + (e)))
  
  float nois = cyclicNoise(vec3(uu/R*40.,1. + iTime*0.2 + sin(iTime)*1.));
  
  vec3 nc = nois*pal(0.5,vec3(1.,0.2,1.),1,vec3(3,0 + nois*20.,4 + sin(iTime) + 2),nois*10. + iTime);
  out_color = mix(out_color,vec4(nc,1),0.01);
  //out_color += cyclicNoise(vec3(uv*20.,1));
  if(iTime < 0.4){
    out_color = vec4(0);
  }
}