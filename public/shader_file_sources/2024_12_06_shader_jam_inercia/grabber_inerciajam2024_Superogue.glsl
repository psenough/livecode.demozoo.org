#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float H(vec3 p) {return fract(sin(p.x*847.627-p.y*463.994+p.z*690.238)*492.94);}
mat2 R(float a) {return mat2(cos(a),-sin(a),sin(a),cos(a));}

float box(vec3 p,vec3 d){return length(max(abs(p)-d,0));}


  float f = texture( texFFT, .1 ).r * 10;
  float ft = fGlobalTime + f;
  float t= fGlobalTime;

float S(vec3 p) 
{
  p.z+=t*3.;
  vec3 fp=floor(p);
  p=mod(p, 2.)-1.;
  float bd = box(p,vec3(H(fp/4)))-2;
  return max(bd, dot(p,sign(p))-1.25);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uvOriginal = vec2(uv.x,1.-uv.y);
  vec4 cLogo = texture(texInerciaLogo2024, clamp(uvOriginal*2-vec2(.5,.5),0,1));
	vec4 cLogo2 = texture(texInerciaLogo2024, uvOriginal);
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  t+=H(vec3(uv,t))*length(uv)/64;
  // -------------
  float i,z,l,d;
  
  float fov = (1-length(uv))+ smoothstep(.25,.1,sin(t/8)*8);
  vec3 p=vec3(0,0,-4),r=normalize(vec3(uv,fov)),e=vec3(.1,0,0),n;
  r.xy*=R(t/9);
  r.xz*=R(t/5);
  r.yz*=R(t/7);
  for (i=0,z=0,l=0,d=0;i++<160;p+=r*(d=S(p)/2),z+=d){
      if (abs(d)<1e-4) {
        n=normalize(d-vec3(S(p-e),S(p-e.yxy),S(p-e.yyx)));//+H(p)/99;
        p+=n/2;l+=max(0.,pow(dot(n,-r),2.));r=reflect(r,n);
      }
  }    
  vec3 ll=mix(vec3(.9,.7,.6),vec3(.1,.7,1.),uv.y) *l*3/z;
	vec4 c = vec4(ll,1) * (1-length(uv)/2) * (sin(uv.y*960)/2+.5);
	out_color = 1-(1-c)*(1-cLogo);
}