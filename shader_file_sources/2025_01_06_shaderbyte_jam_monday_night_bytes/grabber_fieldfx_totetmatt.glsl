#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float bpm = fGlobalTime*130/60;
// FFT not working :'(
float box2(vec2 p,vec2 b){p=abs(p)-b;return length(max(vec2(0.),p))+min(0.,max(p.x,p.y));}
vec3 pcg3d(vec3 p){
    uvec3 q= floatBitsToUint(p)*123456780u+1234598522u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
    q^=q>>16u;
  q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1U);
}
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  

  vec3 nrnd = tanh(pcg3d(vec3(uv,bpm)));
    vec3 frnd = tanh(pcg3d(vec3(floor(uv*50)/50,bpm)));
    vec3 trnd = pcg3d(vec3(floor(bpm+nrnd.x*.1)));

  vec3 col = vec3(0);
 

  uv*=rot(fGlobalTime);

 
  float bbpm = bpm;

  for(int c=0;c<3;c++){
    vec3 crnd = pcg3d(vec3(c));

 // bbpm = floor(bpm) + smoothstep(0.,1.,bpm);
        bbpm += exp(-3*fract(crnd[c]-.5+bpm+nrnd.x*.01));
  for(float i=0.,im=64.;i++<im;){
    
    float sc=  i/im;
    vec3 irnd = tanh(pcg3d(vec3(i,floor(bpm+nrnd.x*.1),i))-.5);
    vec2 p = uv;
    //p*=pow(tan(bpm*.5+sc),3.);
    p*=.1+4.*exp(-3*fract(sign(sin(bpm))*(floor(bpm)+smoothstep(.3,.6,fract(bpm)))*.5+sc));
     p *=rot(irnd.x*6.28);
  p += (irnd.xy)+vec2(1.,0)*tan(texture(texFFTIntegrated,sc).r+bbpm/7);
    float d=10 ;

     if(mod(bpm+crnd.x*.1,4)<2){ 
       d = min(d,abs(p.x+.1*asin(sin(uv.x*5))));
         d=.005/(.001+max(0.,d))/2;
     }else {
    if(irnd.x < irnd.y ){
       vec2 pp=p;
      
       d = abs(length(p)-.1);
    } else if(irnd.z > irnd.y) {
        d = abs(box2(p,vec2(.1)));
    } else{
       p*=rot(exp(-fract(bpm))*6.28);
        d = abs(min(box2(p,vec2(.01,.1)),box2(p,vec2(.1,.01))));
      };
        d=.005/(.001+max(0.,d));
    }
    
    
    

  
  col[c] +=d*exp(-3*fract(bpm+sc));;
  }
  }

  
  if(mod(bpm,8)<4) col =1-col;
  
  ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off = ivec2(10*(frnd.zy-.5));
  vec3 pcol = vec3(
  texelFetch(texPreviousFrame,gl+off,0).r,
  texelFetch(texPreviousFrame,gl-off,0).g,
  texelFetch(texPreviousFrame,gl-off,0).b);
  col  = mix(col,pcol,exp(-1*fract(bpm))+0*sqrt(texture(texFFTSmoothed,nrnd.x).r));
	out_color = vec4(col,1.);
}