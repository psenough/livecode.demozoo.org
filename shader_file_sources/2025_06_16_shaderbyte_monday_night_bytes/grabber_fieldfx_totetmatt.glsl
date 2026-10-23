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
uniform sampler2D texTest;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fBeat;
uniform float rColor;
uniform float gColor;
uniform float bColor;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 hash3d(vec3 p){
    uvec3 q = floatBitsToUint(p);
    q =((q>>16u)^q.yzx)*1111111111u;
    q =((q>>16u)^q.yzx)*1111111111u;
    q = ((q>>16u)^q.yzx)*1111111111u;
    return vec3(q)/float(-1U);
  }
vec3 stepn(float t,float n){
     float u = smoothstep(.5-n,.5+n,fract(t));
     return mix(hash3d(vec3(floor(t),-1U,1)),hash3d(vec3(floor(t+1),-1U,1)),u);
  }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
   uv *=1-step(.3,abs(uv.y))*.1*hash3d(floor(uv.xyy*56)).x;
  vec3 col = vec3(0.);
  for(int i=0;i<3;i++){
     vec3 srnd = stepn(floor(fGlobalTime*128/60+i),.3);

     vec3 rnd = hash3d(vec3(i+exp(-3*fract(fGlobalTime+uv.y*mix(.01,.00001,srnd.x))),-1U,1))-.5;
          float pump = exp(-fract(fGlobalTime*128/60+length(srnd)));
    vec2 uuv= uv+rnd.x*srnd.y*.1;
    float ffi = texture(texFFTIntegrated,.3).r*4;
    float d = abs(uuv.y+asin(sin(uuv.x*4+ffi+srnd.z))*.25*pump)-.01*pump;
    float sc= .5;
    for(float j=0.;j++<4.;){
        d = min(d,abs(uuv.y+asin(sin(uuv.x*4*sc+ffi+srnd.z*sc))*.25*pump)-.01/sc);
     
      sc*=1.1+srnd.x;
      }
    vec3 stp = (stepn(uuv.x*7+ffi,.1));
    float ff = sqrt(texture(texFFTSmoothed,stp.x).r);
       d = min(d,abs(length(uv+vec2(cos(fGlobalTime),sin(fGlobalTime))*(srnd.yz-.5)*.5)-.1)-.1);
    d = smoothstep(.001*pump,.0015*pump,d-ff);
    col[i]=d;
  }
  vec3 s = hash3d(floor(vec3(uv*50,fGlobalTime*128/60)))-.5;
  ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off = ivec2(0*s.xy);
  vec3 pcol = vec3(
     texelFetch(texPreviousFrame,gl-off,0).r,
  
     texelFetch(texPreviousFrame,gl+off,0).g,
  
     texelFetch(texPreviousFrame,gl+off,0).b
  );
   col = mix(col,1-col,(1-step(.05,abs(uv.y+.5*(hash3d(vec3(floor(fGlobalTime*128/60*2)))-.5))))*exp(-3*fract(fGlobalTime*128/60)));
  col = mix(col-fwidth(length(col))*10,pcol,.5+3*exp(-10*fract(fGlobalTime*128/60/4)));
	out_color = vec4(col,1.);
}
























  












// See you, Shader Cowboy !


