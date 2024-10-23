#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
/*
* --
* Surprise les potos !
* --





WARNING : >>>> IT MIGHT FLASHES A LOT LATER IN THE JAM <<<<

^^^^^^
I TOLD YOU


C'EST QUOI LE BPM ?
*/
float bpm = fGlobalTime*180/60.*3;
vec3 pcg3d(vec3 p){
    uvec3 q=floatBitsToUint(p)*1234567890u+1234567u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
    q^=q>>16u;
      q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
    return vec3(q)/float(-1u);
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
    vec3 fuv = pcg3d(vec3(floor(uv.xy*20),floor(bpm*.25)));
  float bbpm = floor(bpm)+smoothstep(.1,.9,fract(bpm+fuv.x*.1));
  float wheeee = tanh(sin(bbpm*.25)*5);
  uv *= 1.5+.5*exp(-3*smoothstep(.1,.9,fract(bpm*.5)));
  uv = erot(uv.xyy,vec3(0.,0.,1.),floor(wheeee*5)).xy;
  fuv = pcg3d(floor(uv.xyx*20));
  vec3 col = vec3(0.);
  
   
  float im=24.;
  for(float i=0.;++i<im;){
        vec3 rnd  = pcg3d(vec3(floor(vec2(bpm)),i));
      vec2 uuv = uv;
       uuv +=(rnd.zy-.5)*2;
       uuv.y +=i/im*.5;
       uuv=abs(uuv)-3.5*(rnd.x-.5);
       uuv= uuv.y<uuv.x ? uuv.xy:uuv.yx;
       float feufeute = sqrt(texture(texFFTSmoothed,uuv.x*.2+i/im+exp(-3*fract(bpm*(1-i/im)+i/im))).r);
       
      float d= abs(rnd.x < .9 ? uuv.y:uuv.x)-step(.05,feufeute)-.1;
      d=  length(rnd) < 1.1 ? length(uuv)-.1-feufeute : d;
      d= .01/(.01+d);
      col += exp(-3*fract(bpm+uv.y*.1+i/im))*mix(vec3(.2,1.,.5),vec3(.1,.5,.9),exp(-3*fract(i/im+bpm+feufeute*10)))*d;
      
  }
  
  ivec2 gl=  ivec2(gl_FragCoord.xy);
  

  ivec2 off = ivec2((fuv.xy-.5)*(5*fuv.z));
  vec3 pcol = vec3(texelFetch(texPreviousFrame,gl+off,0).r,
  texelFetch(texPreviousFrame,gl-off,0).g,
  texelFetch(texPreviousFrame,gl-off,0).b);
  
if(fract(bpm+fuv.z*.1)<.5){
    	col = .1-col;
    }
    if(fuv.y<fuv.x)col = sqrt(col);
  col = mix(col,pcol,exp(-(-fuv.x*sqrt(texture(texFFTSmoothed,length(fuv)+bpm).r)*10+3)*smoothstep(.1,.9,fract(bpm*.5))));

  out_color = vec4((col)+0.5*fwidth(col),1.);
}