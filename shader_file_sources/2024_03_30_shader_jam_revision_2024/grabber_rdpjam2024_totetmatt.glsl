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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
 /** Result of the gridTraversal3 */
 struct Grid {
   /** Center of the cell */
   vec3 cell;
   
   /** Distance to the bound */
   float dist;
   
   /** Normal of the bound */
   vec3 normal;
 };
vec3 pcg3d(vec3 p){
     
    uvec3 q=floatBitsToUint(p)*1234567u*1234567890u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
    q^= q>>16u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1u);
  }
 Grid doGrid( vec3 ro, vec3 rd, vec3 size ) {
   Grid result;
 
   result.cell = floor( ( ro + rd * 1E-3 ) / size + 0.5 ) * size;
   result.cell.y=0.;
   vec3 src = -( ro - result.cell ) / rd;
   vec3 dst = abs( 0.5 * size / rd );
   vec3 bv = src + dst;
   result.dist = min( min( bv.x, bv.y ), bv.z );
   
   result.normal = step( bv, vec3( result.dist ) );
   
   return result;
 }
mat3 orth(vec3 p){
    vec3 z = normalize(p),x=vec3(z.z,0,-z.x);
    return mat3(x,cross(z,x),z);
    
}
vec3 path(vec3 p){
  vec3 o=vec3(0.);
   o.x +=tanh(sin(p.z*.1)*3)*2;
  return o;
  }
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box(vec3 p,vec3 b){p=abs(p)-b; return length(max(vec3(0.),p))+min(0.,max(p.x,max(p.y,p.z)));}
float box2(vec2 p,vec2 b){p=abs(p)-b; return length(max(vec2(0.),p))+min(0.,max(p.x,p.y));}
float diam2(vec2 p,float s){p=abs(p);return (p.x+p.y-s)*inversesqrt(3.); ;}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uuv=uv;
  
  float bpm = fGlobalTime*125/60;

   vec3 rnd = pcg3d(vec3(uv,fGlobalTime));
   vec3 frnd = pcg3d(vec3(floor(uv*10),fGlobalTime));
    uuv.x +=tanh(sin(bpm+rnd.z*.1+cos(bpm))*5)*.5;
  uuv*=1-texture(texFFTSmoothed,.3).r*50;
  vec3 col = vec3(0.);
    
    float ffti = texture(texFFTIntegrated,.3).r+rnd.x*.01;
  float bb = floor(bpm)+smoothstep(.1,.9,pow(fract(bpm+rnd.x*.1),2));
  uuv = erot(uuv.xyy,vec3(0,0,1),bb*(1-step(.3,length(uv))-.5)).xy;
  float rev = texture(texRevisionBW,clamp(uuv*vec2(1.,-1.),-.5,.5)-.5).r;
 
  float frw = bpm+ffti*10;
  vec3 ro=vec3(0.25,0.25,-5.+frw),rt=vec3(0.,0,0+frw);
  ro+=path(ro);
  rt+=path(rt);
  vec3 rd= orth(rt-ro)*normalize(vec3(uv,1.-exp(3*-fract(bpm+.5))));
  


    ffti = floor(ffti)+smoothstep(.0,1.,pow(fract(ffti),2.25));
  float i=0,e=0,g=0;
  vec3 p=ro;
  float len = 0.;
  Grid gr;
  for(;i++<99.;){ 
    
 p=ro+rd*g;
 
  ;
     p-=path(p);   
     p.y+=1.;
          p=erot(p,vec3(0.,0,1),tanh(cos(bpm*4+rnd.x*.1)*5)*3);
       vec3 hp=p;
        hp.x = abs(hp.x)-1.;
        hp.yz = fract(hp.yz)-.5;
     float h = diam2(hp.xy,.01);
     h = min(h,diam2(hp.xz,.05));
   
     
    vec3 gp= p;
    gp.y+=.5;
    vec3 id  = (floor(gp*4)+.5)/4;
    vec3 ir = pcg3d(id);
    id.x = clamp(id.x,-.5,.5);
    gp.xz= gp.xz-id.xz;
    float txt = texture(texFFTSmoothed,ir.y+ir.x).r;
     txt= sqrt(txt)*1.2;
    float t= box(gp,vec3(.12,.12+ txt,.12));
    h= min(t,h);
    
    
     g+=e=max(.001,h); 
     col+=vec3(1.2,.7,.2)*(.075-exp(-7*fract(bpm+ir.z)))/exp(i*i*e);
  }
  
  ivec2 gl= ivec2(gl_FragCoord.xy);
  ivec2 off = ivec2(4.+100*exp(-10*fract(bpm)));
  vec3 pcol = vec3(
     texelFetch(texPreviousFrame,gl+off,0).r,
  
     texelFetch(texPreviousFrame,gl-off,0).g,
  
     texelFetch(texPreviousFrame,gl-off,0).b
  );
  
  col = mix(col,pcol,.5);
  if(fract(bpm+frnd.x*.1)>.5) col = 1-col*+rev;
  col = erot(col,normalize(vec3(.2,.3,.4)),floor(bpm));
	out_color = vec4(sqrt(col),1);
}