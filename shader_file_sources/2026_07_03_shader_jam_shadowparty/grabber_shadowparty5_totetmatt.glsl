#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texCreative;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texHack;
uniform sampler2D texMsdf;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void set(vec2 p,vec3 c){
     for(int i=0;i<3;i++){imageAtomicAdd(computeTex[i],ivec2(p),int(2048*c[i]));}
  }
vec3 get(vec2 p){
     vec3 c=vec3(0);
     for(int i=0;i<3;i++){c[i]=imageLoad(computeTexBack[i],ivec2(p)).x;}
     return c/2048;
  }
mat3 mrd;vec3 ro;
vec2 toBuf(vec3 p){
    p= (p-ro)*mrd;
    p.xy/=p.z;
    vec2 rx= vec2(v2Resolution.x/v2Resolution.y,1.);
    return (p.xy+.5*rx)/rx*v2Resolution.xy;
}
vec3 hash3d(vec3 p){
    uvec3 q= floatBitsToUint(p);
    q+=((q>>16u)^q.yzx)*1111111111u;
    q+=((q>>151u)^q.zxy)*1111111111u;
    q+=((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
}
vec3 stepNoise(float t,float n){
     return mix(hash3d(vec3(floor(t),-1U,123456798)),hash3d(vec3(floor(t+1),-1U,123456798)), smoothstep(.5-n,.5+n,fract(t)));
  }
 float bpm = fGlobalTime*120/60;
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
   mat3 orth(vec3 z){
       z = normalize(z);
       vec3 up = normalize(vec3(z.z,0.,-z.x));
       return mat3(up,normalize(cross(z,up)),z);
   }
  vec3 cyclicNoise( vec3 p, float pump ) {
    vec4 sum = vec4( 0.0 );
    mat3 basis = orth( vec3( -1.0, 2.0, -3.0 ) );
    
    for ( int i = 0; i < 5; i ++ ) {
      p *= basis;
      p += sin( p.yzx );
      sum += vec4(
        cross( cos( p ), sin( p.zxy ) ),
        1.0
      );
      sum *= pump;
      p *= 2.0;
    }
    
    return sum.xyz / sum.w;
  }
  vec3 pal(float t){return .5+.5*cos(6.28*(1*t+vec3(.0,.3,.6)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0);
  

  /*float fft= texture(texFFTSmoothed,mix(.1,.3,((atan(uv.x,uv.y)/6.28)+.5)) ).r;
  float d =abs( length(uv)-.2-sqrt(fft)*2);
  d= .001/(.001+max(.0,d));
  col+=mix(vec3(.2,.4,.95)*.2,vec3(.95,.4,.2)*3,sqrt(d));
  */
  
  ro=vec3(2.5,1.,0);vec3 rt=vec3(0);
  ro=erot(ro,normalize(stepNoise(bpm*.5,.1)-.5),bpm*.125);
  vec3 z= normalize(rt-ro),x=vec3(z.z,0.,-z.x);
 mrd = mat3(x,cross(z,x),z);
  
  
  vec3 p =vec3(0);
  vec3 rnd = hash3d(vec3(gl_FragCoord.xy,-1))*2-1;
  
  p.xz= rnd.xz;
  p*=2.;
   if(p.x>0)p= floor(p*10)/10;
   p+=.01*(hash3d(p+gl_FragCoord.xyy)*2-1);
   //p*=1+exp(-3*fract(bpm));
   vec3 rrnd = stepNoise(-bpm,.4);
   p = mix(p/2,p*2,rrnd.x);
  p = cyclicNoise(p+texture(texFFTIntegrated,.3).r,3.)*4;
  
  float fft = texture(texFFTSmoothed,mix(.1,.3,((atan(p.x,p.z)/6.28)+.5)) ).r;
  fft = sqrt(fft)*smoothstep(0.,.4,length(p.xz));
  p.y += fft;

  vec3 cc= (pal(length(p.xz*.2)+bpm));
  set(toBuf(p),cc);
   for(float i=0.,im=50;i<im;i++){
     vec3 rp=p;
       
       rp += cyclicNoise(floor(rp)+i/im,1.)*exp(-3*fract(length(p*.1)+bpm));
      set(toBuf(rp),cc*.2);
    } 
  
    vec3 zrnd = hash3d(vec3(floor(uv.yx*20),floor(bpm*4)));
  col += get(gl_FragCoord.xy)*.1*exp(-0*fract(bpm+zrnd.x*.2));
  ivec2 gl= ivec2(gl_FragCoord.xy); ivec2 off= ivec2(5*(hash3d(vec3(floor(bpm*8),floor(uv*50))).xy-.5));
    vec3 pcol = vec3(texelFetch(texPreviousFrame,gl-off,0).r,
    texelFetch(texPreviousFrame,gl+off,0).g,
    texelFetch(texPreviousFrame,gl+off,0).b);

  col = mix(sqrt(col),pcol,.5);
   //col = mix(col,1./col,exp(-10*fract(bpm+col*.5)));
 
	out_color = vec4(col,1.);
}