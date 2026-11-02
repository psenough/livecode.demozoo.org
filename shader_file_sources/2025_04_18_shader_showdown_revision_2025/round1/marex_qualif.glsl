#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//Enjoy this Shader Showdown everyone !!!

float frac(vec2 c){
  
  float n = 0.;
  vec2 z = c;
  
  for(float i = 0.; i<128.; i++){
    
    z = vec2( z.x * z.x - z.y * z.y, 2.1 * z.x* z.y)+vec2(-.8+sin(fGlobalTime/1.5)*.005,.156);
    
    if(dot(z,z)>(100.+100.))break;
    
    n += 1.;
    
    if(z.x * z.x - z.y * z.y > 9999.){
      
      return i/200.;
      
      }
    
    }
  return n-log(log(length(z))+log(100.))*log(1.);
  }
  
  float Obox(in vec2 p, in vec2 a, in vec2 b, float th){
    
    float l = length(b-a);
    vec2 d = (b-a)/l;
    vec2 q = (p-(a+b)*.5);
         q = mat2(d.x,-d.y,d.y,d.x)*q;
         q = abs(p)-vec2(l,th)*.5;
    
    return length(max(q,0.))+min(max(q.x,q.y),0.);
    }

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

void main(void)
{
  vec2 uv = (gl_FragCoord.xy /v2Resolution -.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  vec2 R2D = uv*R2D(fract(fGlobalTime*135./60.)/10.);
  vec3 col = .5+.5*cos(fGlobalTime+uv.xyx+vec3(0,2,4));
  
  vec3 FOG = vec3(.001)/length(uv)*200.;
  vec3 FOG2 = vec3(.001)/length(uv)*5000.;
  
  vec2 p = (gl_FragCoord.xy - .5 * vec2(v2Resolution.x,v2Resolution.y))/1000.;
  
  float color = frac(p+R2D);
  
  float box = ceil(Obox(R2D*20.,vec2(.1),vec2(.1),.15));
  
  vec4 final = vec4(box*(R2D.x*2.+R2D.y+2)*vec3(.1)-length(R2D)-length(cos(R2D.x)-sin(R2D.y)-mod(fGlobalTime/10.,3.5)+1.),0.);
  
  
  
	out_color =vec4(FOG*FOG2*color*col*.001,0.)/final*.1;
}