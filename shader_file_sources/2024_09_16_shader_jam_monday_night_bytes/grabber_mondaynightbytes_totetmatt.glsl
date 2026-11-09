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
float bpm = fGlobalTime*118/60;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float box(vec2 p,vec2 b){p=abs(p)-b;return length(max(p,vec2(0.)))+min(0.,max(p.x,p.y));}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 pcg3d(vec3 p){
    uvec3 q = floatBitsToUint(p)*1234567891u+12345678u;
   q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  q^=q>>16u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1u);
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
 uv=erot(uv.xyy,vec3(0.,0.,1.),tanh(cos(bpm*.25+uv.y)*25)/6.28).xy;
  uv*=1-.5*step(.5,step(-abs(uv.x)+.7,texture(texFFTSmoothed,abs(uv.y*.25)).r));
  vec3 rrnd = pcg3d(vec3(uv,fGlobalTime));
   vec3 srnd = pcg3d(floor(vec3(uv.xyy*10)));
   uv*=4.+1*tanh(sin(bpm+srnd.x*.5)*5);
  vec3 col = vec3(0.);
  for(float i=0,im=255;i<im;i++){
    vec3 rnd = pcg3d(vec3(i));
    vec2 uuv = uv;
       float lbpm = floor(bpm+rnd.x)+smoothstep(.4,.6,fract(bpm+rnd.x+rrnd.y*.1));
    float iff = texture(texFFTIntegrated,i/im).x;
    uuv.x += (rnd.x-.5)+.5*sin(rnd.x*6.28+bpm*.2+rnd.z*rrnd.x*.1)+sin(iff+bpm);
    uuv.y += rnd.y-.5 + tan(-lbpm*.125-iff*4+i);
 
  uuv = erot(uuv.xyy,vec3(0.,0,1.),rrnd.x*.1+i+lbpm*2*(length(rnd)-1.)).xy;
  float txt = texture(texFFTSmoothed,i/im*5).r;
  float d=  rnd.x < .9 ? box(uuv,vec2(.1)+sqrt(txt)):length(uuv)-.1;
  d = (.001+(txt))/(.001+abs(d));
  col+=mix(vec3(.3,.5,1.),vec3(1.,.5,.3),fract(rnd.z+fGlobalTime))*d*7*exp(-10*fract(bpm*.25+i/im))/5;
  }

  ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off = ivec2(10.*(srnd.xy-.5));
  
  vec3 pcol = vec3(
    texelFetch(texPreviousFrame,gl,0).r,
  texelFetch(texPreviousFrame,gl+off,0).g,
  texelFetch(texPreviousFrame,gl+off,0).b
  );
  
  
  
  
  
  /*
  
   SORRY FOR THE FLASH
  */
  
  
  
  
  
  col +=+fwidth(col*25);
  col = mix(col,pcol,1.3*exp(-2*fract(bpm*.25+.5)));
    col = mix(col,1.7-col,exp(-5*fract(bpm*.25)));
  
	out_color = vec4(col,1.);
}