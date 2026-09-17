#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaBW;
uniform sampler2D texInercia;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const vec2 sz = vec2(1.,1.73),hs = sz*.5; 

vec2 hexgrid(inout vec2 p){
  vec2 pa= mod(p,sz)-hs,pb=mod(p-hs,sz)-hs,pc=dot(pa,pa) < dot(pb,pb) ? pa : pb;
  vec2 n = (p-pc+hs)/sz;
  //   ^--- This is used to have the "id" of the hexcell
  p = pc;
  return round(n*2.)*.5;
  // Returning the cell id, but p is 'inout' and beeing modified /!\ to 
  // makes p having local cell coordinate
  
  }
  vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
  vec3 pal(float t){return .5+.5*cos(6.28*(-1*t+vec3(.0,.3,.7)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
   vec2 uuv=uv;
   if(abs(uv.y)>.35) uv/=2.;
  vec3 col=vec3(0.);

  vec3 ro=vec3(1.,1.,-5.),rt=vec3(0);
     float time = fGlobalTime;
  float rnd = fract(77.9*sin(45.5*dot(uv,vec2(3453.353,103.35))))*.1;
   float bpm = tanh(sin(fGlobalTime+rnd)*5.)*2;
  ro=erot(ro,vec3(0.,1.,0.),bpm);
  ro.z +=fGlobalTime*4+smoothstep(-1.,1.,cos(fGlobalTime));
  ro.y +=2+5*sin(floor(bpm*1.5));
  rt.z +=fGlobalTime*4+smoothstep(-1.,1.,sin(fGlobalTime));
  vec3 z = normalize(rt-ro),x=normalize(cross(z,vec3(0.,-1.,0.))),y=cross(z,x);
  
  vec3 rd=mat3(x,y,z)*normalize(vec3(uv,1.-.8*sqrt(length(uv))));
  vec3 p;
  float i=0,e=0,g=0;
  for(;i++<40.;){
    
       p=ro+rd*g;
       vec3 pp=p;
        vec2 id = hexgrid(pp.xz);
      float gy=dot(sin(p*.5),cos(p.zyx*.3))*.5;
    float gy2 = dot(sin(fGlobalTime*130/60+id),cos(id.yx*id));
       float h=dot(p,vec3(0.,1.,0.))+.1-gy;
       float dx = sqrt(texture(texFFTSmoothed,dot(sin(id*.4),cos(id.yx*.2))).r)*.5;
       h=min(h,max((abs(p.y)-0.14-min(1.,dx*30)),max(dot(abs(pp.xz),sz*.5),pp.x)-.45));
       g+=e=max(.001,h);
       col+=vec3(gy2>0. ? 1.-exp(-3*fract(fGlobalTime*130/60*.5+.5)):exp(-3*fract(fGlobalTime*130/60*.5))*.5)*.0425/exp(.5*i*i*e);
    }
      
     float tt =dot(floor(sin(uv.yx*80))/70,floor(cos(uv*10))/100);
  float txt = fract(fGlobalTime);sqrt(texture(texFFTSmoothed,floor((tt+fGlobalTime)*100.)*.01).r)*1;
  
 
 
   if(abs(uuv.y)>.35) col =pow(col,clamp(pal((uuv.y <0 ? -.5: 0.)+fGlobalTime+i*.1),vec3(.1),vec3(.9)));  
    
	out_color = vec4(col,1);
}