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

vec2 sdf(vec3 p){
    float tex = texture(texFFTSmoothed,1.).x*50.;

  vec3 p2 = p;
  p2 = mod(p2+vec3(0.,0.,fGlobalTime+abs(sin(fGlobalTime*2.)*5.)),10.)-5.;
  
  vec2 sp = vec2(length(p2)-4+tex,1.);
  
  
  #define cy(p) length(p)-.3*tex
  vec2 c = vec2(min(min(cy(p2.yz),cy(p2.xz)),cy(p2.xy)),1.);
  vec2 sp2 = vec2(length(p)-1.-tex*.7,3.);
  
    sp=sp.x<sp2.x?sp:sp2;
    sp=sp.x<c.x?sp:c;
  
return sp;
}

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

mat3 cam(vec3 ro){
  
  vec3 cw = normalize(vec3(0.)-ro),cu=normalize(cross(cw,vec3(.0,1.,0.))),cv = normalize(cross(cu,cw));
  return mat3(cu,cv,cw);
  }

void main(void)
{
  vec2 uv = (gl_FragCoord.xy/v2Resolution.xy-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  vec2 R2D = uv*R2D(fGlobalTime/16.);
  vec2 e = vec2(.001,-.001);
  vec3 ro = vec3(cos(fGlobalTime)*2.,sin(fGlobalTime)*2.,-5.);
  vec3 rd = cam(ro)*normalize(vec3(R2D,.5));
  vec3 col = vec3(0.);
  
  for(float i = 0.;i<2.;i++){
  vec2 dist = vec2(0.);

  for(float i = 0.;i++<128.;){
    vec3 p = ro+rd*dist.x;
    vec2 d = sdf(ro+rd*dist.x);
   // if(d.x<.1||dist.x>500.)break;
    if(d.x <.001){
      if(d.y > 2.){

        #define q(s) s*sdf(p+s).x
        vec3 n = normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));
        float dif = dot(rd,n);
        col = vec3(1.)+dif;
        rd = reflect(rd,n);
        ro = p + n *.001;
      }
      if(d.y < 2.){
        #define q(s) s*sdf(p+s).x
        vec3 n = normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));
        float dif = dot(rd,n);
        col = vec3(.5+.5*cos(fGlobalTime+uv.xyx+vec3(0,2,4)))+dif*2.;
        }
        
    }
    
    dist +=d;dist.y=d.y;
    }
        vec3 p = ro+rd*dist.x;
        #define q(s) s*sdf(p+s).x
        vec3 n = normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));
        float dif = dot(rd,n);
      if(dist.x>40.)if(dist.x<80)col=vec3(1.)+dif;
  
  }


	out_color =vec4(col,0.);
}