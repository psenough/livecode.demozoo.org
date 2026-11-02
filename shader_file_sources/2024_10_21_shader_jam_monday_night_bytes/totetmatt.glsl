#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texDR;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = fGlobalTime*175/60;
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 pcg3d(vec3 p){
    uvec3 q = floatBitsToUint(p)*1234567890u+12345678u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  q^=q>>16u;
    q.x+=q.y*q.z;q.y+=q.x*q.z;q.z+=q.y*q.x;
  return vec3(q)/float(-1U);
}
float cd( in vec3 p ) {
       p = abs(p);
       float d=0.,m;
       for(int i=0;i++<3.;){
               d+=step(m=max(p.y,p.z),p.x)*m;
               p = p.yzx;
         }
         return max(max(p.x,max(p.y,p.z))-3,1.-d);
 }
 // menger sponge fractal
 float fractal( in vec3 p ) {
     float s = 1.,d=0.;
     for (int i=0;i<6;i++){
         d = max(d, cd(p)*s);
         p = fract((p-1.)*.5)*6.-3.;
         s /= 3.0;
     }
     return d;
 }
vec3 sc1(vec2 uv){
   uv*=(5+4*atan(sin(bpm)));
   uv = fract(uv)-.5;
  float d = abs(uv.y)-.1-sqrt(texture(texFFTSmoothed,uv.x).r);
  d= .01/(.001+abs(d));
     vec3 col =vec3(1.)*d; 
    return  mix(col,1-col,exp(-4.*fract(bpm*2)));
}
vec3 sc2(vec2 uv){
  vec3 col = vec3(0.);
  vec3 ro=vec3(0.,1.,-5.),rt=vec3(0.);
  ro.z +=bpm;
  rt.z +=bpm;
  vec3 z = normalize(rt-ro),x=vec3(z.z,0.,z.x),y=cross(z,x);
  vec3 rd= mat3(x,y,z)*erot(normalize(vec3(uv,1.)),vec3(0.,0.,1.),atan(sin(bpm*.125))*.5);
  for(float i=0.,e=0.,g=0.;i++<50;){
      vec3 p= ro+rd*g;
     float d = 0.;
    vec4 pp=vec4(p,1.0);
    for(float j=0.;j++<8;){
        
       d += clamp(cos(pp.z)+sin(pp.x+pp.z*.1)+dot(sin(pp.xyz*.4),cos(p.yzx*2.)),-.1,.1)/pp.w;
        pp*=1.1;
      }
      d/=pp.w;
      float h = dot(p,vec3(0.,1.,0.))+d;
      g+=e=max(.001,(h));
      col +=step(.1+sqrt(texture(texFFTSmoothed,p.z*.1).r),fract(pp.x))*vec3(1.)*(.01+.5*exp(10*-fract(p.z*.1+bpm*.25+.1*pcg3d(floor(pp.xyz*10)))))/exp(i*i*e);
  }
  return 1-col;
  
}
vec3 sc3(vec2 uv){
   vec3 col = vec3(0.);
  vec3 ro=vec3(0.,0.,-5.),rt=vec3(0.);

    ro=erot(ro,normalize(pcg3d(vec3(floor(bpm)))),.1);  
  ro.z -=bpm;
    rt= erot(ro+vec3(.0,.0,1.13),normalize(vec3(.1,.2,.3)),fGlobalTime);
   
  vec3 z = normalize(rt-ro),x=vec3(z.z,0.,z.x),y=cross(z,x);
  vec3 rd= mat3(x,y,z)*normalize(vec3(uv,1.));
  for(float i=0.,e=0.,g=0.;i++<50;){
      vec3 p= ro+rd*g;

       p= fract(p)-.5;
      float h = min(min(length(p.yz),min(length(p.xy),length(p.xz))),length(p)-.1);
      g+=e=max(.001,abs(h));
      col +=exp(-3.1*fract(bpm*.125+g*.5+vec3(.1,.2,.3)))*.5/exp(i*i*e);
  }
  return col;
     
  }
  
 vec3 sc4(vec2 uv){
   vec3 col = vec3(0.);
  vec3 ro=vec3(0.,0.,-15.),rt=vec3(0.);
  ro= erot(ro,normalize(vec3(0.,1.,1.)),bpm);
 
  
   
  vec3 z = normalize(rt-ro),x=vec3(z.z,0.,z.x),y=cross(z,x);
  vec3 rd= mat3(x,y,z)*normalize(vec3(uv,1.));
  for(float i=0.,e=0.,g=0.;i++<50;){
      vec3 p= ro+rd*g;

     
      float h = fractal(p);
      g+=e=max(.001,abs(h));
      col +=vec3(1.,.5,.2)*(.05*exp(-3*fract(bpm+floor(length(floor(p*10)))*.1)))/exp(i*i*e);
  }
  return col;
     
  }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 ouv = uv;
  vec3 col = vec3(0.);
  
  float fbpm = floor(bpm*2.);
  float sq = mod(fbpm,4.);
  vec3 subscreenRnd =  pcg3d(vec3(fbpm));
  float screenRatio = v2Resolution.y/v2Resolution.x;
vec2 subscreenSize = vec2(1.,screenRatio);
    uv -=(max(vec2(.05),subscreenRnd.xy)-.5)*1.;
uv /=max(.1,subscreenRnd.z);
   uv = erot(uv.xyy,vec3(0.,0.,1.),tanh(sin(floor(fbpm*3.3)))).xy;
  if(sq <1.) col = sc2(uv);
  else if(sq<2.) col += sc3(uv);
   else if(sq<3.) col += sc1(uv);
   else if(sq<4.) col += sc4(uv);

  col +=step(.95,abs(uv.x))+step(.45,abs(uv.y));
  ivec2 gl = ivec2( gl_FragCoord.xy);
  vec3 pcol = texelFetch(texPreviousFrame,gl,0).rgb;
  ouv.y+=.001*sin(ouv.x*2030);
  ouv.x+=sign(sin(uv.y*5))*tan(bpm*.1);
   ouv/=(1.00-.1*exp(-3*fract(bpm))+0*sin(subscreenRnd.x+ouv.y*1000)*.1);
  pcol = texture(texPreviousFrame,(ouv*vec2(v2Resolution.y / v2Resolution.x, 1))+.5).gbr;
  col = mix(pcol*.7,col,.9*step(abs(uv.y),subscreenSize.y)*step(abs(uv.x),subscreenSize.x));
  col = mix(col,.05/col,exp(-10.*fract(bpm+.5)));
	out_color = vec4(col,1.);
}