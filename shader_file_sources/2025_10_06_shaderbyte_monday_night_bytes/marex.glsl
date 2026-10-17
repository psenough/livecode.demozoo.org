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

float smin(float a,float b){
  
  float r = exp2(-a/2.)+exp2(-b/2.);
  return -2*log2(r);
  }

float sdf(vec3 p){
  
  float tex = texture(texFFTSmoothed,floor(length(p.z))).x*30.;
  
  vec3 p2 = p;
  p.xy = mod(p.xy,5.)-2.5;
  p.z = mod(p.z+fGlobalTime,5.)-2.5;
  
  p2.xy = mod(p2.xy,150.)-75.;
  p2.z = mod(p2.z+fGlobalTime*50.,150.)-75.;
  
  float sp = length(p)-1.;
  float sp2 = length(p2)-1.*tex*15-10.;
  
  return max(sp2,sp);
  }
  
mat3 cam(vec3 ro){
  
  vec3 cw = normalize(vec3(0.,1.,0.)-ro),cu=normalize(cross(ro,vec3(1.))),cv=normalize(cross(cu,cw));
  return mat3(cu,cv,cw);
  }
  
mat2 R2D (float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}
void main(void)
{
  vec2 uv = (gl_FragCoord.xy/v2Resolution.xy-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  vec2 R2D = uv*R2D(fGlobalTime/16.);
  float tex = texture(texFFTSmoothed,uv.y*.2+.5).x*20.;
  vec3 ro = vec3(abs(cos(fGlobalTime)*200.),abs(sin(fGlobalTime)*200.),-50.);
  vec3 rd = cam(ro)*normalize(vec3(R2D,-sin(fGlobalTime*200/60.)));
  float dist = 0.;
  vec3 col = vec3(0.);

  for(float i = 0.;i++<128.;){
    float d = sdf(ro+rd*dist);
    if(d<.001||dist>499.99)break;
    dist += d;
    }
  
    if(dist <500.){
      vec2 e = vec2(.001,-.001);
      vec3 p = ro+rd*dist;
      #define q(s) s*sdf(p+s)
      vec3 n = normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));
      vec3 ld =normalize(vec3(cos(fGlobalTime*.5),sin(fGlobalTime*.5),-.1));
      float dif = max(0.,dot(ld,n));
      col = vec3(.5+.5*cos(uv.xyx+fGlobalTime+vec3(0,2,4)))*dif*2.;
      
      }
    
	out_color =vec4(col,0.);
}