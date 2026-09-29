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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float diam2(vec2 p,float s){p=abs(p);return (p.x+p.y-s)*inversesqrt(3.);}

float tru(vec2 p){
        vec2 id = floor(p)+.5;
     vec2 gv = p-id;
      gv.x  *= fract(452.6*sin(dot(id,vec2(452.5,985.5)))) > .5 ? -1.:1. ;
    gv.xy-=.5 * (gv.x >-gv.y ? 1. :-1.);float q;
   return abs(q=diam2(gv.xy,.5))-.0*sqrt(texture(texFFTSmoothed,q).r);  
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 one(vec2 uv){vec3 col=vec3(0.);
  uv*=8.;
  float bpm = texture(texFFTIntegrated,.3).r+fGlobalTime*.2;
  bpm = floor(bpm)+smoothstep(.0,1.,fract(bpm));
  for(float i=0,im=8.;i<im;i++){
       float q = fract(i/im);
      vec2  luv =uv+q;
      col  += +exp(-5*fract(bpm*2+q))*sin(vec3(.1,.9,.1))*q*.02/tru((luv)*q+bpm);
    
      col  += +exp(-5*fract(bpm+q))*vec3(.9,.1,.1)*.256*.02/tru(uv+q+bpm);
  }
  return col;
  }
  
  
  // ITS NOT CHANGING A LOT BECASUE IM TRYUING TO FIGURE  OUT A BUG
  // AND WE DISCUSS WITH NUSAN :D 
vec4 two(vec2 uv){vec4 col=vec4(0.);
 
   vec3 ro=vec3(0,0,-5),rt=vec3(0.);
    vec3 z=normalize(rt-ro),x=normalize(cross(z,vec3(0.,-1.,0))),y=cross(z,x);
      
  vec3 rd= mat3(x,y,z)*normalize(vec3(uv,1.));
  vec3 p;
   for(float i=0,e=0,g=0;i++<99.;){
     
       p=ro+rd*g;
     vec3 pp=p;
        p.x-=2.;  p.z +=fGlobalTime*5;
     p = erot(p,vec3(0,0,1),fGlobalTime);
      p.xz +=fGlobalTime*5;
        p= asin(sin(p/5))*5;
       float h= length(p)-1.;
     
      for(float j=0.;j++<5.;){
            h = min(h,length(erot(p.xyz,normalize(sin(vec3(.5,1.,1)+fGlobalTime+j+p.z*.1)),j).xz)-.05);
        }
        g+=e=max(.001,.7*abs(h));
        
    

        col.a +=.025/exp(exp(-3*fract(fGlobalTime-pp.z*.05))*i*i*e);     
   }
       ivec2 gl= ivec2(gl_FragCoord.xy);
        ivec2 off = ivec2(1.+sqrt(texture(texFFT,sin(atan(uv.x,uv.y)*5)).r)*50);
           float pr = texelFetch(texPreviousFrame,gl+off,0).a;
        float pg = texelFetch(texPreviousFrame,gl-off,0).a;
        float pb = texelFetch(texPreviousFrame,gl-off,0).a;
  col.rgb = vec3(pr,pg,pb);
  return col;
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0.);
  //col +=sqrt(texture(texFFTSmoothed,floor(fGlobalTime+mod(floor(uv.y*16),16)+uv.x*16)/16).r*10);
  vec4 rr=vec4(0.);
  if((mod(fGlobalTime,6.)<3. ? uv.x < 0. : uv.y <0)){
    rr.rgb = one(uv);
  } else{
    rr = two(uv);
      
  }
	out_color = vec4(rr);
}