#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCIX;
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texLcdz;
uniform sampler2D texNfp;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texSession2024;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
//************************
// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //
//************************
























////************************
// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //
//************************
// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //
//************************
// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //// TOUS A POUALE !      //
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 pcg3d(vec3 p){
  
   uvec3 q= floatBitsToUint(p)*123457u+1234567890u;
    q.x +=q.y*q.z;q.y +=q.x*q.z;q.z +=q.y*q.x;
  q^=q>>16u;
  q.x +=q.y*q.z;q.y +=q.x*q.z;q.z +=q.y*q.x;
  return vec3(q)/float(-1U);
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  float bpm = 128*fGlobalTime/60.;

  float mbpm=bpm;
    vec3 rrnd = pcg3d(vec3(uv.xy,bpm));
    
 uv=erot(uv.xyy,vec3(0.,0.,1.),floor(bpm+rrnd.x*.1)).xy;  
  
  vec2 uuv = uv;
    vec2 id = floor(uv*5.);
  vec3 irnd = pcg3d(id.xyy);
 uv*=3-length(uv);

 
vec3 col = vec3(0.);
 float t = fGlobalTime;
  for(int c=0;c<3;c++){
    vec2 uuv = uv;
    
     bpm = floor(bpm)+smoothstep(.1,.9,fract(bpm));
    
     uuv*=exp(-fract(bpm*.25));
         uuv =erot(uuv.xyy,vec3(0.,0.,1.),tanh(sin(bpm)*4)).xy;
    vec3 rnd = pcg3d(floor(vec3(uuv.xy*20.,bpm)));
    float v= texture(texFFTSmoothed,rnd.x).r;
    float d = 5*sqrt(texture(texFFTSmoothed,rnd.x).r)*sqrt(v);
    col[c]+=d;
  }

  //if(fract(bpm+irnd.x+fGlobalTime)<.1) col = .01/(.01+col);
  
  
  col = abs(uuv.y)>((step(abs(uuv.y)-.3,texture(texFFTSmoothed,log(1+abs(uuv.x)*.1)).r))) ? col*col+fwidth(col*5):col;
  
 ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off= ivec2(sign(uv)*length(uv*.4)*5);
  vec3 pcol = vec3(
    texelFetch(texPreviousFrame,gl+off,0).r,
  texelFetch(texPreviousFrame,gl-off,0).g,
  texelFetch(texPreviousFrame,gl-off,0).b
  );
  col = mix(sqrt(col),fwidth(pcol),.6*exp(-3*fract(bpm)));
  
   if(fract(bpm*4.)>.5) col = .01/(.01+col);
	out_color = vec4((col),1.);
}