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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texTex;
layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = fGlobalTime*135/60;
vec3 hash3d(vec3 p){
    uvec3 q = floatBitsToUint(p)*1234567890u+1346798520u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
    q^=q>>16u;
      q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1U);
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float stepNoise(float x,float n){
  n= max(n,5);
  float i = floor(x);
  float s = .2;
  float u = smoothstep(.5-s,.5+s,x-i);
  float r = mix(floor(hash3d(vec3(i)).x*n),floor(hash3d(vec3(i+1)).x*n),u);
  return r/(n)-.5;  
}
float box2(vec2 p,vec2 b){p=abs(p)-b;return length(max(vec2(0),p))+min(0.,max(p.x,p.y));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

vec3 col = vec3(0.);
  
  vec2 uuv = uv;

vec3 supernoise = hash3d(vec3(uv,bpm));
vec3 bNoise = vec3(stepNoise(bpm*.25,1.),stepNoise(bpm*.33+951,1.),max(.1,stepNoise(bpm*.33+5555,.9)));

  
  vec3 ro=vec3(0.,5.,-5.),rt=vec3(0);
  ro+= stepNoise(bpm*.25+supernoise.x*.1,10);
  ro=erot(ro,normalize(vec3(0.,1,.1)),stepNoise(bpm*.25+654+supernoise.x*.05,6.28)*6.28);
  rt=bNoise*10;
  vec3 z =normalize(rt-ro),x = vec3(z.z,0.,-z.x),y=cross(z,x);
  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,.5+.5*stepNoise(bpm*.125-654,2)));
  float i=0.,e=0.,g=0.;
  vec3 p;
  for(;i++<50.;){
      p = ro+rd*g;
     float h =  length(p)-1.-sqrt(texture(texFFTSmoothed,.3).r)*5-exp(-3*fract(bpm));
           
       vec3 pp= cross(abs(erot(abs(p)-1.,vec3(0.,1,0),bpm*.125+p.y*.1+bNoise.x))-.5,vec3(1))*inversesqrt(3.);
     pp = erot(pp,vec3(0,1,0),bpm+pp.z);
    pp+=dot(sin(p),cos(p.yzx+fGlobalTime))*.1;
     h=  min(length(pp.xz)-.1,h);
     float t = dot(p,vec3(0.,1,0))-textureGrad(texNoise,p.xz*.05,vec2(.1),vec2(.5)).x*(4+texture(texFFTSmoothed,.3).r*100);
       h= min(abs(h),t);
      g+=e=max(.001,h);
      if(h==t){
    
      col+=10*mix(vec3(.2,.2,.1),vec3(.1,.2,.2),p.y*.5)*mod(floor(p.y*10),2)*.0125/exp(3*i*i*e);
      
          } else {
            col += exp(-5*fract(bpm+.5-length(p*.25)+length(pp*25)))*bNoise*(.1+mod(floor(pp.x*5)+floor(pp.z*5),2))/exp(i*i*e);;
                 col += dFdx(col)*vec3(-1,1,1)/exp(i*i*e);
            }
    
      
    }
 
   vec3 pcol = texelFetch(texPreviousFrame,ivec2(gl_FragCoord.xy),0).rgb;
    
    

   float d = box2(erot(uv.xyy,vec3(0,0,1.),mix(0.,3.14,bNoise.x)*0).xy-(bNoise.xy),vec2(bNoise.z,bNoise.z*v2Resolution.y/v2Resolution.x)*2);
    if(d<=0){
      vec3 ccol = (.2+col)*supernoise;
        vec3 uuvrnd = hash3d(vec3(floor(p.xzx/g)));
     
    ccol *= textureLod(texTex,p.xz*.105*(g)+vec2(0,bpm*(uuvrnd.x-.5)),0).a*5*vec3(0,1,0)*.1;
       col = fwidth(2*sqrt(mix(col*col,ccol,.9-supernoise*.2)));
    } 
       col = mix(col,vec3(.3,.3,.3),1-exp(-(.001)*g*g*g));
  
	out_color = vec4(mix(col,pcol,supernoise),1.);
}
/**
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!

==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !! Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 
==========================================================================================
Come To Revision 2025
Do not fear being a Livecoder for shadershowdown !!  Ask me for more info ! 















*/