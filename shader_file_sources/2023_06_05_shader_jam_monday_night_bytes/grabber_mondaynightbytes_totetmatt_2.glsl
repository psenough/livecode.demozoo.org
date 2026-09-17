#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texFeedback; // value written to feedback_value in previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
layout(location = 1) out vec4 feedback_value; // value that will be available in texFeedback in the next frame

vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.0,.1,.2))); ;}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3 col = vec3(0.);
  
  
   vec3 p,d=normalize(vec3(uv,1.));
  for(float i=0.,g=0.,e=0.;i++<99;){
    
      p=d*g;
      float z=p.z;
      p.z -=5.-fGlobalTime*20.;
      p.x +=asin(sin(fGlobalTime*2.));
      p = erot(p,vec3(0.,0.,1.),p.z*.1+fGlobalTime);
      p.y += sin(p.z*.1)*4.;
      p.xy = abs(p.xy)-3.1;
      p.z = asin(sin(p.z));
    
      float  h =length(p)-1.;
      h = min(min(length(p.xz),length(p.zy))-.1-sqrt(texture(texFFTSmoothed,floor(10*(p.y+p.x))/10).x*2),h);
      g+=e=max(.001,abs(h)*.7);
      col +=floor(pal(z*.1+p.z*.2-fGlobalTime)*20)/10*.0655/exp(i*i*e);
    }
	out_color = vec4(col,1.);
}