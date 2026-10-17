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
uniform sampler2D texRevision;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float bpm = fGlobalTime*160/60;
vec3 hash3d(vec3 p){
    uvec3 q = floatBitsToUint(p);
    q = ((q>>16u)^q.yzx)*1111111111u;
    q = ((q>>16u)^q.yzx)*1111111111u;
    q = ((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1u);
  }
  
vec3 stepNoise(float t,float n){
  
     float u = smoothstep(.5-n,.5+n,fract(t));
    return mix(hash3d(vec3(floor(t),-1U,1)),hash3d(vec3(floor(t+1),-1U,1)),u);
  }
  
vec3 path(vec3 p){
    vec3 o = stepNoise(p.z*.125,.5)-.5;
    return o*4;
  }
 vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);;}
 float diam2(vec2 p,float s){p=abs(p);return (p.x+p.y-s)*inversesqrt(3.);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec3 col = vec3(0.);
  vec3 ro=vec3(0.5,0,-5),rt=vec3(0);
  
  ro.z +=bpm*4;
  rt.z +=bpm*4;
  
  ro -=path(ro);
  vec3 z = normalize(rt-ro),x= vec3(z.z,0.,-z.x);
  vec3 rd = mat3(x,cross(z,x),z)*normalize(erot(vec3(uv,1.),vec3(0,0,1),bpm*.5));
  for(float i=0.,e=0.,g=0.;i++<50;){
      
    vec3 p = ro+rd*g;
    p= mix(floor(10*p)/10,p,step(.5,stepNoise(-bpm*.125+p.z,.5).x));
    p += path(p);
    float h = -mix(diam2(p.xy,2.),(length(p.xy)-1.),.5+.5*sin(p.z*.5));
   
    p.xy=abs(p.xy);

    h = min(min(length(p.xy),length(p.yz))-.1,h);
    g+=e=max(.001,(h));
    uvec3 pp=uvec3(abs(cross(sin(p),cos(p.yzx)))*128);
    col +=vec3(((pp.x&pp.z&pp.y)%128)/128.)*(.01+.9*exp(-3*fract(-bpm+p.z*.01+3*sqrt(texture(texFFTSmoothed,p.z*.1).r))))/exp(i*i*e);
  }
  //col = sqrt(col);
  col = mix(vec3(.4,.1,.95)*.1,vec3(.95,.4,.1),col);
	out_color = vec4(sqrt(col)+dFdx(col)*vec3(-1,1,1),1.);
}



























