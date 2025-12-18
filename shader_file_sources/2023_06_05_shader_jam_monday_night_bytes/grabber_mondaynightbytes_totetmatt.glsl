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
float hashwithoutsine12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 303.33);
    return fract((p3.x + p3.y) * p3.z);
}
float bpm = texture(texFFTIntegrated,.3).r;
vec3 tile1(vec2 uv){
    float d = length(uv)-.3;
    return vec3(1.)*smoothstep(.02,.01,abs(d)-.01);
  }
  
vec3 tile2(vec2 uv){
  vec2 p =abs(uv)-vec2(.25);
   float d = length(max(p,vec2(0.)))+min(0,max(p.x,p.y));
    return vec3(1.)*smoothstep(.002,.001,abs(d)-.1);
  }
  
  mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
  
  
float channel(vec2 uv){
    
    uv.x += (floor(bpm)+pow(smoothstep(.0,1.,fract(bpm)),2.))*40;

  
  vec2 id = floor(uv);
  
  float q = hashwithoutsine12(id);
   float qq = hashwithoutsine12(uv);
  if(q<.5){
       uv*=2.;
    }
      if(q<.25){
       uv*=2.;
    }
  uv = fract(uv)-.5;
  bpm+=qq*.01;
  bpm = floor(bpm)+smoothstep(0.,1.,pow(fract(bpm),2.));
  
  float txt = mod(sqrt(texture(texFFTSmoothed,q+atan(id.x,id.y)*.5+bpm).r),1.5);
  vec3 col;

    col = vec3(0.);
 
  if(txt<.1 && txt >.05) {
    col = tile1(uv);
    
    }
    else if(txt<.11 && txt >.1){
      
       col = tile2(uv);
      }

    if(txt > .15) {
      
      col = vec3(1.);}

   return col.x;
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  if(abs(uv.y)<.35){ 
    uv*=15.+asin(sin(bpm))*5.5; 
  } else {
    
     uv*=50.*sin(floor(fGlobalTime+length(uv)+dot(floor(sin(uv.yx*11.)),floor(cos(uv.xy*13.)))));
    }
    uv*=rot(floor(bpm+.1*hashwithoutsine12(uv)));
    
    vec3 col = vec3(0.);
    
    col.r = channel(uv);
	 col.g = channel(uv);
     col.b = channel(uv);
    
    if(mod(fGlobalTime,1.)>.9){
        col = 1-col;
      }
    out_color = vec4(col,1.);
}