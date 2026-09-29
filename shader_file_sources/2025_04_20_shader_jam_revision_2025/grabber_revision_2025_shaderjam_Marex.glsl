#version 410 core

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
uniform sampler2D texAcorn1;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const vec2 ep =vec2(.00035,-.00035);
const float far = 20000.;

vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

  vec2 map_wrong( vec2 p, float n )
{
    float b = 6.283185/n;
    float a = atan(p.y,p.x);
    float i = round(a/b);

    float c = b*i;
    p *= R2D(-c);
    
    return p; 
}
  
vec2 map(vec3 p){
  
  vec3 rp = p;
  
  float avance = rp.z - fGlobalTime*1.;
  
  float id = floor(avance/1.);  
  rp.z = mod(avance,2)-1.;
  
  rp = erot(rp,normalize(vec3(0,0,1)),fGlobalTime/4.+id);

  rp.xy = map_wrong(rp.xy,20);
  
  rp.x-=4;

  vec2 sp = vec2(length(rp)-sin(rp.z*10.+fGlobalTime)*.1-.4,0.);
  
  vec2 final = sp;
  
  return final;
  }


  
  vec2 rC(vec3 rO,vec3 rD){
    vec2 d, res=vec2(0.);
    for(float i = 0.; i<128.; i++){
      d = map(rO+rD*res.x);
      if(d.x<.0001||res.x>far) break;
      res.x += d.x; res.y = d.y;
      }
     return res;
    }
  
    float frac(vec2 c){
      
      float n = 0.;
      vec2 z = c;
      
      for(float i = 0.; i<128.; i++){
        
        z = vec2(z.x*z.x-z.y*z.y,2.1*z.x*z.y)+vec2(-.8+sin(fGlobalTime/1.5)*.005,.176+sin(fGlobalTime)/20.);
        
        if(dot(z,z)>(100.+100.))break;
        n+=1.;
        
        if(z.x*z.x-z.y*z.y > 9999.){
          
          return i/200.;
          
          }
        
        }
      
      return n-log(log(length(z))+log(100.))*log(1.);
      }
    
void main(void)
{
  
    vec2 uv=(gl_FragCoord.xy/v2Resolution-0.5)/vec2(v2Resolution.y/v2Resolution.x,1.);       
    vec2 R2D = uv*R2D(fGlobalTime);
  
  float BPM = fract(fGlobalTime*177./60.);
  
  float FOV = 2.+BPM;
  
  float modu = mod(fGlobalTime,4);
  
  if(modu >= 2.){
    
    FOV = 15.+BPM;
    
    }
    
    vec2 p = (gl_FragCoord.xy -.5 * vec2(v2Resolution.x,v2Resolution.y))/1000.+sin(fGlobalTime)/4.;
    
    float frac = frac(p+R2D)/100.;
    
    vec3 ro=vec3(0.,0.,1.),cw=normalize(vec3(0.)-ro),cu=normalize(cross(cw,vec3(0,1,0))),
         cv=normalize(cross(cu,cw)),rd=mat3(cu,cv,cw)*normalize(vec3(uv,FOV)),
         ld=normalize(vec3(.1)),co,fo;
         co=fo=vec3(.0)+length(uv)*.1;
    vec2 t=rC(ro,rd);
    if(t.x<far){
        vec3 po=ro+rd*t.x;
        vec3 no=normalize(ep.xyy*map(po+ep.xyy).x+ep.yyx*map(po+ep.yyx).x+
                               ep.yxy*map(po+ep.yxy).x+ep.xxx*map(po+ep.xxx).x);
        vec3 color = cos(fGlobalTime+uv.xyx+vec3(0.,2.,4.));
        vec3 al=vec3(color);
        if(t.y<1.) al=vec3(0.);
        float dif=max(0.,dot(no,ld)),
              fre=pow(1.+dot(no,rd),4.),
              spe=pow(max(dot(reflect(-ld,no),-rd),0.),30.),
              ao=clamp(map(po+no*.1).x/.1,0.,1.);
        co=mix(spe+al*(ao+.2)*(dif*.5),fo,fre);
    }
    vec3 color = .5+.5*cos(fGlobalTime+uv.xyx+vec3(0.,2.,4.));

    float line = fract(sin(20.*fGlobalTime-R2D.y*200.));
    
    vec3 FOG = vec3(.1)*length(uv)/1000000000.;
    
    float modu2 = mod(fGlobalTime,8);
    
    vec3 final = co/line/color;
    
    if(modu2 >= 4.){
      
      final = (frac+color/2.+FOG)*.5;
      
      }
    
	out_color =vec4(pow(max(final,0.),vec3(.4545)),1.);
    }