#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;

uniform sampler2D texInercia2025;

uniform sampler2D texInerciaBW;

uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = 120*fGlobalTime/60;
vec4 getTexture(sampler2D sampler, vec2 uv){

     vec2 size = textureSize(sampler,0);
     float ratio = size.x/size.y;
     return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
}
vec3 hash3d(vec3 p){
    uvec3 q = floatBitsToUint(p);
    q +=((q>>16u)^q.yzx)*1111111111u;
    q +=((q>>16u)^q.yzx)*1111111111u;
    q +=((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
}
vec4 scroller(vec2 uv){  
   uv*=5.;

   return getTexture(texInerciaBW,uv);
  
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box(vec3 p,vec3 b){p=abs(p)-b;return length(max(p,vec3(0)))+min(0.,max(p.y,max(p.x,p.z)));}
float diam(vec3 p,float s){p=abs(p);return (p.x+p.y+p.z-s)*inversesqrt(3);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec4 inerciabw = scroller(uv);
  vec4 inercia = getTexture(texInercia2025,uv);
vec3 rnd = hash3d(vec3(floor(uv.x*3.),0x898989,-1u));
  vec3 trnd = hash3d(vec3(floor(bpm*.125+rnd.x*.1),0x465798,-1U));
  vec3 col = vec3(0.);
  float seq = uv.y+rnd.x-sqrt(texture(texFFTSmoothed,mix(.01,.4,rnd.z)).r)*5;
  // col = .1*mix(col,sqrt(inercia.rgb),inercia.a)*inerciabw.a*5*exp(-5*fract(seq+bpm)) ;
  
  
  vec3 ro = vec3(uv,-1)*5,rd=vec3(0,0,1);
  
  for(float i=0.,e=0.,g=0.;i++<99.;){
    
       vec3 p= ro+rd*g;
        p.z -=2;
       p = erot(p,vec3(1,0,0),.785/2.);
           p = erot(p,vec3(0,-1,0),.785/2.);
 
        p = erot(p,vec3(0,1,0),trnd.x*6.28);
        p.xz += bpm;
       vec3 tp=p;
    tp.xz -=bpm;
       vec3 hp=p;
      hp.y -= sqrt(texture(texFFTSmoothed,bpm*.1+
          mix(.01,.5,.5+.5*dot(sin(hp.xz*.2),cos(hp.zx*.1)))).r);
    ;
       hp.xz= fract(hp.xz)-.5;
      
       float h=  min(length(hp.yz),length(hp.xy))-.01;
       
        tp.y -= abs(sin(bpm))+.1;
        tp = erot(tp,vec3(0,1,0),-.785);
    float ty = sign(tp.x);
     tp.x = abs(tp.x)-.5; 
        tp = erot(tp,vec3(1,0,0),smoothstep(.0,1.,fract(-bpm/3.14))*3.14);
        float t = ty<0 ? diam(tp,.5+exp(-10*fract(bpm+.5))):box(tp,vec3(.2+exp(-10*fract(bpm))));
        h= min(h,t);
       float gr= dot(p,vec3(0,1,0));
       h = min(gr,h);
       g+=e=max(.001,h);
     vec4 txt = getTexture(texInercia2025,p.xz*.2);
         if(h!=gr) txt=mix(vec4(.4,.95,.2,1.),vec4(.95,.4,.2,1.),mod(floor(p.x*5)+floor(p.z*5),2));           
      col +=vec3(1.)*mix(vec3(.1),sqrt(txt.rgb),txt.a)*.0325/exp(.2*i*i*e);
    }
  ivec2 gl = ivec2(gl_FragCoord.xy);
   ivec2 off = ivec2(-1,1);
  vec3 pcol = vec3(
       texelFetch(texPreviousFrame,gl+off,0).r,
       texelFetch(texPreviousFrame,gl-off,0).g,
       texelFetch(texPreviousFrame,gl-off,0).b
    );
  col = mix(col,pcol,exp(-.85*fract(bpm*.25+rnd.x)));
	out_color = vec4(col,1.);
}