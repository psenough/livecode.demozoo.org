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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = fGlobalTime*120./60.;
mat3 orth(vec3 p){
    vec3 z = normalize(p);
    vec3 x = vec3(z.z,0.,-z.x);
    return mat3(x,cross(z,x),z);
}
struct Grid {
    float d;
    vec3 id;
};
Grid dogrid(vec3 ro,vec3 rd,float size){

    Grid g;
    g.id = floor((ro+rd*.001)/size+.5)*size;
    vec3 src = -(ro-g.id)/rd;
    src+= abs(.5*size/rd);
    g.d  = min(src.x,min(src.y,src.z));
    return g;
}
vec3 cy(vec3 p,float pump){
  
    vec4 s = vec4(0.);
    mat3 o = orth(vec3(-1.,2.,-3.));
    for(float i=0.;i++<5.;){
         p*=o;
         p+=sin(p.xyz);
         s+=vec4(cross(sin(p),cos(p.yzx)),1.);
         s*=pump;
         p*=2.;
      }
      return s.xyz/s.w;
  }
vec3 pcg3d(vec3 p){
    uvec3 q=floatBitsToUint(p)*1234567u+123456789u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
    q^=q>>16;
        q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
        return vec3(q)/(float(-1u));
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
   
     float zz = step(.40,abs(uv.y));
  
    vec3 col = vec3(0);
  vec3 rrnd = pcg3d(vec3(uv,bpm));
    
  //  float d= length(uv)-.1-sqrt(texture(texFFTSmoothed,3.).r);
  //  d = smoothstep(fwidth(d),0.,abs(d)-texture(texFFTSmoothed,atan(uv.x,uv.y)/6.28).r);
   // col+=d;
  
        vec3 c = cy(vec3(bpm),4.)*.5;
   vec3 ro=vec3(-bpm,0.,5.),rt=vec3(-bpm,vec2(0));
  float rbpm = bpm*.25;
   rbpm = floor(rbpm)+smoothstep(.8-rrnd.x*.1,.9+rrnd.x*.01,fract(rbpm));
   vec3 rd = orth(rt-ro)*erot(normalize(vec3(uv,1.-zz*.9)),normalize(vec3(0.5,1.,-.25)),rbpm);;
   
  float i=0.,e=0.,g=0.;
  vec3 p=ro; 
    float len = 0.;
    Grid gr;
  for(;i++<99;){
        if(len<=g){
            gr=dogrid(p,rd,1.);
            len+=gr.d;
        }
         p +=cross(sin(p+bpm),cos(p.yzx))*.2;
        
           vec3 op=p;
        
      
   
        p-=gr.id;
        
        vec3 rnd = pcg3d(gr.id);
        float zz = 100.;
        vec3 pp=p;
        pp=erot(pp,normalize(vec3(1.)),bpm+rrnd.x*.1);
        for(int ax=0;ax<3;ax++){
        vec2 q = vec2(length(pp.xy)-.2,pp.z);
         zz = min(zz,length(q)-.01);
          pp.xyz=pp.yzx;
          }
  p=abs(p)-.0125;p=abs(p)-.0225;
       float h = min(min(length(p.yz),length(p.xz)),length(p.xy))-.005;
        
         h= min(h,zz);
        
        e=max(0.001,rnd.y >.5 ? h:abs(h));
        g=min(g+e,len);   
        p = ro+rd*g;
       col+=mix(vec3(1.,.5,.1),vec3(.1,.5,1.),exp(-3*fract(bpm+.5+rnd.z)))*(.5*exp(-5*fract(bpm+rrnd.x*.1+op.z*.1+rnd.x*.2+rnd.y*.5)))/exp(i*i*e);
   }
  
	out_color = vec4(col,1.);
}