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
uniform sampler2D texRnd;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float bpm = fGlobalTime*170/60*.25; // PLEASE DROP THE BEATS !!!!!!!!!!
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 puv = uv;
   uv*=1+exp(-10*fract(bpm));
  vec3 col = vec3(0.);	
  
  for(float i=0.,im=32;i++<im;){
     float sc  =i/im;
     float m = mix(.5,10.,sc);
     vec2 p=uv*m;
     p*=rot(sin(i)+bpm);
     p.x+=atan(sin(bpm)*2.)*.5;
     p.y+=atan(cos(bpm)*2.)*.5;
     
     p= abs(p)-.5;
    float d = length(p)-.1/m;
     d=  min(d,abs(p.x)+.2*fract(bpm*.25+sc));
    d = (.001+.05*exp(-7*fract(bpm*.5+sc*2)))/(.001+max(d,0));
    col+=d*.5;    
    
  }
  
  
  puv*=1.0+texture(texFFTSmoothed,.3).r;
  puv*= vec2(v2Resolution.y / v2Resolution.x, 1);
  puv+=.5;
  if(mod(bpm*1.33,8) <4)col = 1-col+max(vec3(0),+fwidth(col));
  vec2 off= vec2(.01,-.01)*rot(floor(-bpm));
  vec3 pcol = vec3(
  textureLod(texPreviousFrame,puv+off,0.).r,
  textureLod(texPreviousFrame,puv-off*1.5,0.).g,
  textureLod(texPreviousFrame,puv-off,0.).b
  );
   col = mix(col,pcol,0*dot(sin(uv*200),cos(uv.yx*5000+bpm*.33))+(.5+min(length(uv)*length(uv),.4))*exp(-3*fract(bpm)));
  col += cross(sin(col),cos(col.yzx))*2.;
  out_color = vec4(col,1.);
}