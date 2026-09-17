#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
// Human PARTY ! Human PARTY ! Human PARTY ! Human PARTY ! 
// Party PARTY ! 
// 
// KORE DA ! 
//
// Party PARTY ! 
// KORE DA !  
//
// Party PARTY ! 
// KORE DA !
//
// Party PARTY ! 
// KORE DA !
//
// Party PARTY ! 
// KORE DA !
vec3 trnd ;
 struct GridTraversal3Result {
   /** Center of the cell */
   vec3 cell;
   
   /** Distance to the bound */
   float dist;
   
   /** Normal of the bound */
   vec3 normal;
 };
 vec3  prnd;
 GridTraversal3Result gridTraversal3( vec3 ro, vec3 rd, vec3 size ) {
   GridTraversal3Result result;
 
   result.cell = floor( ( ro + rd * 1E-3 ) / size + 0.5 ) * size;
  
   vec3 src = -( ro - result.cell ) / rd;
   vec3 dst = abs( 0.5 * size / rd );
   vec3 bv = src + dst;
   result.dist = min( min( bv.x, bv.y ), bv.z );
   
   result.normal = step( bv, vec3( result.dist ) );
   
   return result;
 } 
 GridTraversal3Result grid;
float bpm = fGlobalTime*140/60;
vec3 pcg3d(vec3 p){
    uvec3 q= floatBitsToUint(p)*1234567890u+123459689u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  q^=q>>16u;
   q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1U);
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box3(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0.),p))+min(0,max(p.x,max(p.y,p.z)));}
mat3 orth(vec3 p){
    vec3 z = normalize(p);
    vec3 x = vec3(z.z,0.,-z.x);
    return mat3(x,cross(z,x),z);
}
vec2 sdf(vec3 p){
   p -= grid.cell;
    vec3 hp=p;
    vec2 h;
  float zz= -exp(-3*fract(bpm));
  vec3 rrnd = pcg3d(grid.cell);
   //p = erot(p,normalize((trnd-.5)*2.),zz*6.28);
    h.x = dot(sin(grid.cell*.5),cos(grid.cell.yzx*.1)) <0.9?1.: box3(p,vec3(.1)+(rrnd)*.2);
    
    h.y= 1.+length(rrnd);
    return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
 vec4 getTexture(sampler2D sampler, vec2 uv){

  
                vec2 size = textureSize(sampler,0);
                float ratio = size.x/size.y;
                return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
 }
vec3  intro(vec2 uv){
       float x = sqrt(texture(texFFTIntegrated,.3).r)*50;
   x=floor(x)+smoothstep(0.,1.,fract(x));
  float wave = exp(-5*fract(bpm*.125-length(uv)-sqrt(texture(texFFTSmoothed,atan(uv.x,uv.y)/6.28).r)*2));
        uv*=(1+.5*atan(sin(x+length(uv)*.5+wave)));
  float tt= texture(texFFTSmoothed,uv.y+texture(texNoise,uv+bpm*.1).r*.5).r;
  vec3 t = pow(getTexture(texInerciaLogo2024,uv+tt).rgb,vec3(.5-.3*exp(-3*wave)));
      return t+tt;
  }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
 trnd = pcg3d(vec3(floor(bpm)));
  vec3 col = vec3(0.);
  
  //col = intro(uv);
   prnd = pcg3d(vec3(uv,fGlobalTime));
  vec3 ro=vec3(0.5,0.5,-5.),rt=vec3(0.);
  ro.y +=bpm*4;
 
  rt =ro+vec3(1.);
  vec3 rd= orth(rt-ro)*normalize(vec3(uv,1.));
  
  float tbpm = bpm;
  rd= erot(rd,normalize(sin(vec3(0.1,1.,0.1)+bpm*.1)),atan(sin(tbpm*.5+prnd.x*.005)*5));
  vec3 rp=ro;
  vec3 light = vec3(1.,2.+bpm*.1,-3.);
  vec2 d ;
  float gridlen;
  float rl=0.;
  vec3 acc= vec3(0.);
  for(float i=0.;i++<128;){
      d = sdf(rp);
    if ( gridlen <= rl ) {
      grid = gridTraversal3( rp, rd ,vec3(1.));
      gridlen += grid.dist;
    }
    float wabe = exp(-3*fract(bpm+d.y*.9));
    acc+=mix(vec3(1.,.5,.2),vec3(.1,.5,.9),wabe)*exp(-10*abs(d.x))/(150-wabe*149);
    d.x =max(0.001,abs(d.x));
      if(d.x<.001){
          break;
      }
       rl = min( rl + d.x, gridlen );
      rp=ro+rd*rl;
  }
  if(d.x<.001){
      vec3 n = norm(rp,.001);
      vec3 ld = normalize(light-rp);
      
      float dif = max(0.,dot(ld,n));
      float spc = pow(max(dot(reflect(ld,n),rd),0.),32.);
       float fre = pow(1+dot(rd,n),4.);
      col =vec3(.1)*dif+spc*.5;
      col = mix(vec3(.01,.1,.2),col,1-fre);
  }   
  col = fwidth(acc).rbg;
  vec3 txt =getTexture(texInerciaLogo2024,uv*(1-exp(-3*fract(bpm)))).rgb;
  
  ivec2 gl = ivec2(gl_FragCoord.xy);
  ivec2 off= ivec2(5.,-5.);
  vec3 pcol = vec3(texelFetch(texPreviousFrame,gl-off,0).r,
  texelFetch(texPreviousFrame,gl+off,0).g,
  texelFetch(texPreviousFrame,gl+off,0).b);
  col = sqrt(col)+acc+fwidth(length(txt)*10);
  col= mix(col,pcol,-exp(-2*fract(bpm+length(txt)*10)));
	out_color = vec4(col,1.);
}