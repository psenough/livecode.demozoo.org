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

float hash(float v){return fract(sin(v)*82357.4367);}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 C=vec3(0.);
  
  
  vec3 S=vec3(10., 5., 40.);
  
  float s = fGlobalTime+uv.x+uv.y;
  float NS = 8.;
  for(float si=0.;si<NS;++si){
    vec3 O=vec3(0., 0., 15.), D=normalize(vec3(uv, -2.));
  vec3 kc=vec3(1.);
  for(float ri=0.;ri<3.;++ri)
  {
    s = fract(s);
    float l=1e6, cl;
    vec3 N;
    cl = (sign(D.x)*S.x - O.x) / D.x; if (cl < l) { l = cl; N=vec3(-sign(D.x),0.,0.); }
    cl = (sign(D.y)*S.y - O.y) / D.y; if (cl < l) { l = cl; N=vec3(0.,-sign(D.y),0.); }
    cl = (sign(D.z)*S.z - O.z) / D.z; if (cl < l) { l = cl; N=vec3(0.,0.,-sign(D.z)); }
    
    vec3 p=O+D*(l-0.01);
    
    float mr = .01;
    vec3 me = (N.z > 0.) ? vec3(fract(p)) : vec3(0.);
    vec3 ma = vec3(.5);
    
    float gc = hash(floor(fGlobalTime) + dot(floor(p/2.),vec3(.345,.3,.4)));
    
    
    if (N.x != 0.) { mr = .1; }
    if (N.y != 0.) { mr = .0 + .1 * gc; }
    if (N.y < 0.) { ma*=.5; }
    
    C += kc*me;
    kc *= ma;
    
    O=p;
    D=normalize(mix(
      reflect(D,N),
      vec3(hash(s+=p.z),hash(s+=p.x),hash(s+=p.y))*2.-1.,
      mr
    ));
    ;
    
  }}
  
  //C=vec3(hash(uv.x));
	out_color = vec4(sqrt(C/NS), 0.);
}