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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texTex;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 pcg3d(vec3 p){
    uvec3 q=  floatBitsToUint(p)*1234567890u+1346798520u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
    q^=q>>16u;
      q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1U);
}

float bpm = fGlobalTime *160/60;
mat3 orth(vec3 p){
     vec3 z = normalize(p);
    vec3 x = vec3(z.z,0.,-z.x);
    return mat3(x,cross(z,x),z);
 }
 vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 rnd = pcg3d(vec3(uv,bpm));

  
  
  vec3 ro=vec3(0.,0.,-5.),rt=vec3(0);
  ro=erot(ro,normalize(vec3(0.3,1.,.0)),atan(sin(bpm*.25)*80)+bpm*.125);
  /*ro.z += bpm*2;
  ro.x += sin(bpm*.125+cos(bpm*.25));
   ro.y += cos(bpm*.25+cos(bpm*.32));
  rt.z+=bpm*2;*/
  vec3 rd = orth(rt-ro)*erot(normalize(vec3(uv,1.)),vec3(0.,0.,1.),atan(sin(bpm*.0)*50)*.25);
  
  float i=0.,e=0.,g=0.;
    vec3 p;
  vec3 op;
    vec3 col =vec3(0.);
  for(;i++<99.;){
     p = ro+rd*g;
    op=p;
     bool tempo = mod(bpm,8.)<4;
     vec3 fp = fract(erot(p*(tempo? 2:1),normalize(vec3(0.,1.,1)),floor(bpm+rnd.x*.25+op.z*5)))-.5;
     float h = min(length(fp.xy),length(fp.zy));
   if(tempo){
      h= max(length(op)-2.+sqrt(texture(texFFTSmoothed,.3).r)*5+dot(sin(op),cos(op.yzx*5))*.2,h);
     h/=2.;
       h= min(abs(length(op)-2.+sqrt(texture(texFFTSmoothed,.3).r)*5+dot(sin(op),cos(op.yzx*5))*.2)+.015,h);
   }
   
     float bump = 0.;
    float sc = 1.;
    vec3 zp= p;
      for(float j=0;j++<4.;){
               bump+=clamp(abs(dot(sin(zp*sc),cos(zp.yzx*sc)))/sc,0,1);
        sc*=1.4;;
        zp+=sin(zp+zp)*.5;
        
      }
      bump/=sc;
      vec3 pp=p;
       pp.y =1.5-abs(pp.y);
     float t = dot(pp,vec3(0.,1.,0.))+bump;
    t*=.8;
     h=min(t,max(-t*1.1,h));
     g+=e=max(.001,abs(h));
    
      vec3 id = vec3(floor(p*20)/20);
  vec3 idrrnd = pcg3d(vec3(id.xxx+1654));
  float lol=textureLod(texTex,(p.xz*vec2(1.,-1.)-.5)*mix(.1,5.,idrrnd.x)+vec2(0.,texture(texFFTIntegrated,idrrnd.z)-bpm*.2),0.).a;
      if(t==h){
          col+=sqrt(idrrnd).xzz*vec3(.2+5*(t==h?lol*2*sqrt(texture(texFFTSmoothed,idrrnd.z).r):0))*.0525/exp(i*i*e*.2);
      } else {
          col+= (.6+.4*sin(vec3(.2,.5,.9)+op.z*.1+bpm))*.0525/exp(i*i*e-3*fract(-bpm+length(op*.5+dot(sin(op),cos(op.yzx)))));
        }
        //col *= exp(-.1*fract(op.z*.1+bpm));
   
    
    }

	out_color = vec4(col,1.);
}