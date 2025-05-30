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
float bpm = 110/60*fGlobalTime;
struct Grid {
   /** Center of the cell */
   vec3 cell;
   
   /** Distance to the bound */
   float dist;
   
   /** Normal of the bound */
   vec3 normal;
 };
 Grid g;
 Grid doGrid( vec3 ro, vec3 rd, vec3 size ) {
   Grid result;
 
   result.cell = floor( ( ro + rd * 1E-3 ) / size + 0.5 ) * size;
   
   vec3 src = -( ro - result.cell ) / rd;
   vec3 dst = abs( 0.5 * size / rd );
   vec3 bv = src + dst;
   result.dist = min( min( bv.x, bv.y ), bv.z );
   
   result.normal = step( bv, vec3( result.dist ) );
   
   return result;
 } 
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
mat3 orth(vec3 p){
    vec3 z=normalize(p),x=vec3(z.z,0.,-z.x);
  
    return mat3(x,cross(z,x),z);
  }
float box3(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0.),p))+min(0.,max(p.x,max(p.y,p.z)));}
vec3 pcg3d(vec3 p){
    uvec3 q=floatBitsToUint(p)*1234567u+1234567890u;
    q.x+=q.y*q.z; q.y+=q.x*q.z; q.z+=q.y*q.x;
   q^=q>>16u;
      q.x+=q.y*q.z; q.y+=q.x*q.z; q.z+=q.y*q.x;
  return vec3(q)/float(-1u);
}

vec3 cy(vec3 p,float pump){
    vec4 s = vec4(0.);
    mat3 o = orth(vec3(-1,2,-3));
    for(float i=0;i++<5.;){
      
         p*=o;
         p+=sin(p.yzx);
         s+=vec4(cross(cos(p),sin(p.zxy)),1.);
         s*=pump;
         p*=2.;
      }
      return s.xyz/s.w;
}
vec2 sdf(vec3 p){
  vec3 hp=p;
  vec2 h;
  vec3 rnd = pcg3d(g.cell);
  h.x = box3(p,vec3(3.20));
  vec3 hhp=hp-g.cell;
  hhp.y = abs(hhp.y);
  float d = sqrt(texture(texFFTSmoothed,length(rnd)).r)*5;
  h.x = max(h.x,box3( (hhp)-vec3(0.,d,0),vec3(.25,.1+d,.25)));
  
  h.y =1.+rnd.x+rnd.y+rnd.z;
  vec3 tp=p;
  tp=abs(tp)-1.5;
  tp= erot(tp,normalize(vec3(1.,1.,1)),-.785);
  vec2 t;
  t.x = abs(box3(tp,vec3(10)))-.1;
  t.y = 0.;
  
  
   h=t.x < h.x ?t:h;
  
  return h;
  }
#define q(s) s*sdf(p+s).x
  vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.1,.3,.7)));}
 vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
      vec3 rnd = pcg3d(vec3(uv,fGlobalTime));
  
  uv.y *= 1-.9*step(.9,abs(fract(uv.y+bpm+rnd.x*.1)));

  vec3 col =vec3(0.);

  
  vec3 ro=vec3(0.,3.,-7.),rt=vec3(0.,1.,0);

  float tt =texture(texFFTIntegrated,.3).r+bpm+rnd.x*.1;
  tt= floor(tt)+smoothstep(.1,.9,fract(tt));
ro=erot(ro,normalize(vec3(1.,1.,0)),bpm*.1+floor(tt)+tanh(sin(tt)*4));
  
  vec3 rd= orth(rt-ro)*normalize(vec3(uv,+tanh(sin(bpm*.5)*5.5)*.1+.5+exp(3.*-fract(-bpm*.5))));
  vec3 light = vec3(1.,5.,-5.);
  light=erot(light,vec3(0.,1.,0),bpm*.1);
  vec3 rp=ro;;
  vec2 d;
  float rl=0.,i=0;
  float len=0.;
  for(i=0,rl=0;i++<90;){
      if(len<=rl){
          g=doGrid(rp,rd,vec3(.5,10.,.5));
          len+=g.dist;
        }
      d= sdf(rp);
      rl=min(rl+d.x,len);
      rp=ro+rd*rl;
      if(d.x< .001) break;
  }
  if(d.y==0.){
    vec3 n = norm(rp,.001);
     rd= reflect(rd,normalize(n+cy(floor(rp*10.)+bpm,1.)*.2));
    ro=rp+n*.1;
    len=0;
    for(i=0,rl=0;i++<70;){
         if(len<=rl){
          g=doGrid(rp,rd,vec3(.5,10.,.5));
          len+=g.dist;
        }
      d= sdf(rp);
      rl=min(rl+d.x,len);
   
      rp=ro+rd*rl;
    
  }
    }
    
       ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off = ivec2(erot(vec2(.3,.9).xyy,vec3(0.,0.,1),bpm).xy*(5+exp(1*fract(bpm+.5))));
  vec3 pcol= vec3(
  texelFetch(texPreviousFrame,gl+off,0).r,
  texelFetch(texPreviousFrame,gl-off,0).g,
  texelFetch(texPreviousFrame,gl-off,0).b
  );
  if(d.x <.001){
   
       // float txt = texture(texFFTIntegrated,length(rnd)).r;
       // float zzz =   sqrt(texture(texFFTSmoothed,length(rnd)+txt).r);
        vec3 n = norm(rp,.001);
        vec3 ld = normalize(light-rp);
        float dif = max(0.,dot(ld,n));
       float spc = max(0.,pow(dot(reflect(ld,n),rd),32));
        float sss  = clamp(sdf(rp+ld*.4).x/.4,0.,1.);
       float fre = pow(1+dot(rd,n),4-2*exp(-3.*fract(bpm*.5+.5)));
    float bbpm =bpm;
      
    if(d.y >=1.){
       for(int i=0;i<3;i++){
         bbpm +=rnd.x*.05;
         bbpm =floor(bbpm)+smoothstep(.0,1.,fract(bbpm));
        col[i] = 2*exp(-3*fract(d.y*5+bbpm))*(dif+sss*.5)+spc;
         
         }
        col = mix(vec3(.1),sqrt(col),(1-fre));
      
    } else {
      col = vec3(.5+step(.9,fract(bpm*4)))*dif;
       col = mix(pcol,col,.5-3*exp(-3+fract(bpm)));
      }
  }
 
 
	out_color = vec4(col,1.);
}