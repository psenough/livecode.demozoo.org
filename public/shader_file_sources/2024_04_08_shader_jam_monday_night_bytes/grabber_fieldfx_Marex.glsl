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

const vec2 ep= vec2 (.00035,-.00035);
const float far=80;

float box1(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
float box2(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
float sphere(vec3 p,float r){return length(p)-r;}


float map(vec3 p){
  float Box1=box1(p-vec3(sin(fGlobalTime*20.)-10.,0,10),vec3(sin(fGlobalTime*5)/2.+2));
  float Box2=box2(p-vec3(-sin(fGlobalTime*20.)+10.,0,10),vec3(sin(fGlobalTime*5)/2.+1));
  float Sphere=sphere(p+vec3(sin(fGlobalTime*10.)*5.,0,0),2.);
  float scene= min(Box1/Box2,Sphere);
  return scene;
}
  
  float raycast(vec3 rayOrigin, vec3 rayDirection ){
    float dist,result=0.;
    for(int i=0;i<128;i++){
      dist=map(rayOrigin+rayDirection*result);
      if(dist<.0001||result>far) break;
      result+=dist;
  }
return result;
}


mat2 rotate2d(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}

void main(void)
{
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv = uv*sin(fGlobalTime)*2;
  
  vec2 rotatedUV=uv*rotate2d(abs(sin(fGlobalTime*2))*2.5);
  vec2 rotatedUV2=uv*rotate2d(-fGlobalTime);

  float pattern =sin(fGlobalTime*20+rotatedUV2.x/rotatedUV2.y*20.);
  
  vec3 rayOrigin=vec3(0,0,-10);
  vec3 rayDirection=normalize(vec3(rotatedUV,-abs(sin(fGlobalTime*10))/2.+1.));
  vec3 backgroundColor=vec3(-abs(sin(fGlobalTime*5.))+0.25*pattern*2.);
  vec3 color=backgroundColor;
  float result=raycast(rayOrigin,rayDirection);
  if(result<far){
    color=vec3(0.5+0.5*cos(fGlobalTime+uv.xyx+vec3(0,3,3)));
  }
  
	out_color =vec4 (pow(max(color*3,0.),vec3(.4545*3)),1);
}