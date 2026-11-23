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

float vmax(vec3 p){return max(max(p.x,p.y),p.z);}
#define box(p,s) vmax(abs(p)-(s))
#define R(a) mat2(cos(a),sin(a),-sin(a),cos(a))


// https://iquilezles.org/articles/smin/
// quadratic polynomial
float smin( float a, float b, float k )
{
    k *= 4.0;
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - h*h*k*(1.0/4.0);
}

float bx(vec3 p, float s, float a1, float a2) {
  p.xz *= R(a1);
  p.xy *= R(a2);
  return box(p,s);
}

float t = 0.;
float w(vec3 p){
  float d = 1e6;
  
  d = smin(d, length(p-vec3(sin(t*.2),cos(t*.5),sin(t*.1)))-.5, .2);
  d = smin(d, length(p-vec3(sin(t*.3),cos(t*.4),sin(t*.5)))-.4, .2);
  d = smin(d, length(p-vec3(sin(t*.4),cos(t*.5),sin(t*.6)))-.6, .2);
  
  d = smin(d, bx(p-vec3(sin(t*.1),cos(t*.2),sin(t*.3)),.4,t,   t*.3), .2);
  d = smin(d, bx(p-vec3(sin(t*.5),cos(t*.3),sin(t*.1)),.2,t*.9,t*.6), .2);
  d = smin(d, bx(p-vec3(sin(t*.6),cos(t*.8),sin(t*.7)),.3,t*.8,t*.7), .2);
  
  return d;
}

float tr(vec3 o,vec3 d,float l,float L){
  for (float i=0;i<100.;++i){
    float dw=w(o+d*l);l+=dw;
    if(dw<.001*l||l>L)break;
  }
  return l;
}
const vec3 e=vec3(0.,.001,1.);

vec3 wn(vec3 p){
  return normalize(vec3(w(p+e.yxx),w(p+e.xyx),w(p+e.xxy))-w(p));
}

void main(void) {
  t=fGlobalTime;
  vec2 uv = gl_FragCoord.xy/v2Resolution * 2. - 1.; uv.x *= v2Resolution.x / v2Resolution.y;
  vec3 C = vec3(0.);
  vec3 O=vec3(0.,0.,3.),D=normalize(vec3(uv,-2.));
  float L=10.;  
  vec3 kc=vec3(1.);
  for (float r=0.; r<8.;++r){
    float l=tr(O,D,0.,L);
    if (l<L){
      vec3 p=O+D*l,n=wn(p);
      vec3 refl = reflect(D,n);
      O = p + n * .01;
      D = refl;
    }else{
      vec2 ts=D.xy*.5-.5;ts.y*=-1.;
      C += kc * texture(texInerciaLogo2024, ts).rgb;
      break;
    }
  }
  
	out_color = vec4(sqrt(C), 0.);
}