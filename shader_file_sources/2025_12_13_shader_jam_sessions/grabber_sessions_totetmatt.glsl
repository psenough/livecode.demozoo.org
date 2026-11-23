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
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


vec3 hash3d(vec3 p){
    uvec3 q = floatBitsToUint(p);
    q += ((q>>16u)^q.yzx)*111111111u;
   q += ((q>>16u)^q.yzx)*111111111u;
   q += ((q>>16u)^q.yzx)*111111111u;
  return vec3(q)/ float(-1U);
}

struct GS {vec3 hash,cell,size;};
struct Grid{GS sub;float d;};
Grid grid;
#define gsub grid.sub
void doSub(vec3 p){
     gsub.size =vec3(.5);
     for(int i=0;i<5;i++){
        gsub.cell = (floor(p/gsub.size)+.5)*gsub.size;
        gsub.cell.y =0;
        gsub.hash = hash3d(gsub.cell);
        if(i==4||gsub.hash.x < .5) break;
        gsub.size *=.5;
     }
  }

void doGrid( vec3 ro, vec3 rd ) {


  // get the info of the current grid cell
  // slightly pushing the ray position forward to see the next cell
  doSub( ro + rd * 1E-3 );

  // calculate the distance to the boundary
  // It's basically a backface only cube intersection
  // See the iq shader: https://www.shadertoy.com/view/ld23DV
  vec3 src = -( ro - gsub.cell ) / rd;
  vec3 dst = abs( 0.5 * gsub.size / rd );
  vec3 bv = src + dst;
  grid.d = min( min( bv.x, bv.z ), bv.z );
  
}

 vec3 stepNoise(float x,float n){
       float u = smoothstep(.5-n,.5+n,fract(x));
        return mix(hash3d(vec3(floor(x),-1U,1)),hash3d(vec3(floor(x+1),-1U,1)),u);
       
    }

vec3 getTexture(vec2 uv){
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions,uv*vec2(1,-1*ratio)-.5).rgb;
}
vec3 getTexture2(vec2 uv){
    vec2 size = textureSize(texShort,0);
    float ratio = size.x/size.y;
    return texture(texShort,uv*vec2(1,-1*ratio)-.5).rgb;
}
float bpm = fGlobalTime*148/60;
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0),p))+min(0.,max(p.x,max(p.y,p.z)));}
vec2 sdf(vec3 p){
  vec3 hp=p-gsub.cell;
  vec2 h;
  float fft= texture(texFFTSmoothed,gsub.hash.z).r;
  float d = length(gsub.cell.xz);
  float tbpm = floor(bpm) + smoothstep(0.,1.,fract(bpm));
  
 
  float ifft = texture(texFFTIntegrated,gsub.hash.y).r;
   hp.y -= (exp(-fract(ifft-d*.1))+dot(sin(gsub.cell),cos(gsub.cell.yzx+tbpm*.1))*.5);
 
  h.x = box(hp,vec3(.5*gsub.size.x,.5+sqrt(fft)*gsub.size.y,.5*gsub.size.z));
  h.y= 1.;
  return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
   vec3 col = vec3(0);
   //col = getTexture(uv);
  
  vec3 rnd = hash3d(floor(uv.xyy*100));
  //col = dFdx(col)*vec3(-1,1,1)+col;
  //col = col*exp(-5*fract(135*fGlobalTime/60+uv.y-rnd.x));
  
  vec3 ro=vec3(0.,4.,-7.),rt=vec3(0.);
  vec3 prnd = hash3d(vec3(uv,-1U));
  vec3 camrnd = stepNoise(bpm*.25,.2+prnd.x*.01);
  ro = erot(ro,vec3(0,1,0),camrnd.y*6.28);
  rt = (stepNoise(-bpm,.3)-.5)*4;
  vec3 z = normalize(rt-ro),x=vec3(z.z,0.,-z.x);
  vec3 rd = mat3(x,cross(z,x),z)*erot(normalize(vec3(uv,mix(1.5,.5,camrnd.z))),vec3(0,0,1),mix(-1,1,camrnd.x));
  
  vec3 rp=ro;
  vec3 light = vec3(1.,2.,-3.);
  vec2 d;
  float rl=0.;
  float glen = 0.;
  for(float i=0.;i++<128;){
       if(glen <=rl){
         
           doGrid(rp,rd);
           glen+=grid.d;
         }
      d = sdf(rp);
      
      if(d.x<.001) {
          break;
       }
       rl=min(rl+d.x,glen);
         rp=ro+rd*rl;
  }
  if(d.x<.001) {
    
     vec3 n = norm(rp,.001); 
      vec3 ld = normalize(light-rp);
      float dif = max(0.05,dot(ld,n));
     float spc= pow(max(0.,dot(reflect(ld,n),rd)),32);
      float fre = pow(1+dot(rd,n),4);
      col = mix(vec3(1.)*dif+spc,col,fre);   
      if(gsub.hash.y <.1 ) col *=getTexture(rp.xz*(1+gsub.hash.z));    
         else if(gsub.hash.x <.1 ) col *=getTexture2(rp.xz*(1+gsub.hash.z));   
   }
   // GOOD LUCK FOR COMMENTARY
   if(gsub.hash.z <.1) col = 1-col;
   col = mix(col,1-col,exp(-7*fract(bpm*.25+gsub.hash.y)));
	 
   if(length(gsub.hash)<1.)col = mix(vec3(.95,.2,.1).bgr*.1,vec3(.95,.2,.1),col);
    col = sqrt(col)+dFdx(col)*3*vec3(-1,1,1);
   col= mix(col,vec3(.5),1-exp(-.001*rl*rl*rl));
   
   vec3 crnd= hash3d(floor(vec3(uv.yy*100,-1u)));
   
   
   ivec2 gl = ivec2(gl_FragCoord.xy);
   ivec2 off = ivec2(crnd.yz);
   vec3 pcol = vec3(
      texelFetch(texPreviousFrame,gl+off,0).r,
   
      texelFetch(texPreviousFrame,gl-off,0).g,
   
      texelFetch(texPreviousFrame,gl-off,0).b
   );
   col = mix(col,pcol,1.2*exp(-3*fract(bpm+crnd.x)));
   
   col = mix(col+fwidth(col),sqrt(fwidth(col)),smoothstep(.4,.6,fract(uv.y*.25+bpm*.125)));
   //col = mix(col,1/col,exp(-7*fract(bpm*4+gsub.cell*.1)));
   
   out_color = vec4(col,1.);
}