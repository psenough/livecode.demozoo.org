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

float bbox(vec2 uv, vec2 a, vec2 b, float t){
    float l = length(b-a);
    vec2 d = (b-a)/l;
    vec2 q = uv - (a+b)*.5;
  
    q = mat2(d.x,-d.y,d.y,d.x)*q;
    float tt =texture(texFFT,abs(q.x+q.y*20.)*.01).r*.2;
    q = abs(q) - vec2(l+(t/tt)*.0001,t-tt*tt)*.5;
    return length(max(q,vec2(0.))) + min(max(q.x,q.y),0.);
  }
  
  
  float left_fu(vec2 uv){
   float h =  bbox(uv,vec2(-.1,-.2), vec2(-.1,.1),.01);
    
    float t = bbox(uv,vec2(-.2,.2), vec2(.0,.2),.01);
    h = min(t,h);
    
     t = bbox(uv,vec2(.0,.2), vec2(-.2,.1),.01);
    h = min(t,h);
    
     t = bbox(uv,vec2(-.05,.1), vec2(.01,.05),.01);
    h = min(t,h);
    
      t = bbox(uv,vec2(-.15,.30), vec2(-.10,.25),.01);
    h = min(t,h);
    return h;
    }
       
  float right_fu(vec2 uv){
     float h =  bbox(uv,vec2(.35,.25), vec2(.05,.25),.01);
    
      float t = abs(bbox(uv,vec2(.3,.13), vec2(.1,.13),.1))-.01;
      h = min(t,h);

    
     uv +=vec2(.05,.0);
      t = bbox(uv,vec2(.25,.00), vec2(.25,-.20),.01);
      h = min(t,h);
    uv *=.5;
   
    t = abs(bbox(uv,vec2(.2,-.05), vec2(.05,-.05),.1))-.001;
      h = min(t,h);
    
     t = bbox(uv,vec2(.2,-.05), vec2(.05,-.05),.001);
      h = min(t,h);
    return h;
    
  }
  float fu(vec2 uv){
    float h =  left_fu(uv);
    float r = right_fu(uv);
    h = min(h,r);
    
    
    return h ;
      
    }
    
vec3 pal(float t){

    return vec3(.5)+.5*cos(2.*3.141592*(1.*t+vec3(.0,.3,.7)));
  }
  
  
 float mandel(vec2 uv){
     float tt = texture(texFFT,.3).r*5.;
      vec2 c = vec2(.41-tt,.42+tt);
      vec2 z = uv;
      float limit = 200.;
      float cpt =  0.;
   
   for(float i = 0.;i<=limit; i++){
   
        z = vec2(z.x*z.x-z.y*z.y,2.*z.x*z.y)+c;
        if(length(z) >2) break;
        cpt ++;
     
     }
     
     return cpt /limit;
   }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
 float t1 = texture(texFFTSmoothed,.3).r*100.;
 
  float t2 = texture(texFFTSmoothed,.7).r*100.;
  uv *=(fract(-fGlobalTime*.5+length(uv)));
  uv *=2.;
  uv.x +=fract(fGlobalTime+t1*.1);
   uv.y += sin(fGlobalTime)+t2*10.;
  vec2 id = floor(uv);
  uv = fract(uv)-.5;
 float d = fu(uv);
   float mandal = mandel(abs(uv)+.1);
  d = abs(.01/(d));
  if(mod(id.x,2.) ==0.){
     d = 1.-d;
  }
  vec3 col = vec3(d)*pal(mandal*10.+d*.001+fract(fGlobalTime)+uv.x);
	out_color = vec4(sqrt(col),1.0);
}