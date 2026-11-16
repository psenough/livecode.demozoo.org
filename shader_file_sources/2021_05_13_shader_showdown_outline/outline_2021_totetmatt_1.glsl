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
uniform sampler2D texTexBee;
uniform sampler2D texTexOni;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
 mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
 
 float bi3 = texture(texFFTIntegrated,.2).r;
float mandel(vec2 uv,float l){
    vec2 z = uv;
    vec2 c = vec2(-.856,.401);
    float i=0;
    for(;i<=l;i++){
        z = vec2(z.x*z.x-z.y*z.y,2.*z.x*z.y)+ c;
        z*=rot(floor(bi3*20.));
        if(length(z) >=2.) break;
        
    }
    return i/l;
}
float box(vec3 p,vec3 b){

    vec3 q = abs(p)-b;
    return length(max(vec3(0),q))+min(0,max(q.x,max(q.y,q.z)));
 }

vec2 sdf(vec3 p){
    float _bit3 = texture(texFFTIntegrated,.33).r;
  float _bit6 = texture(texFFTIntegrated,.66).r;
    p.xz *=rot(fGlobalTime);
    vec3 pp= p;
      p.xy *=rot(floor(_bit3*50.)*6.66);
     p.zy *=rot(floor(_bit6*75.)*3.66);
     vec2 mandeluv = vec2(abs(atan(p.x,abs(p.z))),p.y);
    float q = mandel(mandeluv,10.);
    vec2 h;
    h.x = box(p,vec3(1.0-q*.1));
    h.x = max(h.x,-box(p,vec3(.9-q*.1)));
    h.y = 1.-q;
    h.x *=.9;
  
    vec2 t;
    t.x = -box(pp,vec3(10.));
  
     pp = abs(pp)-2.5;
     t.x  = min(box(pp,vec3(1.)),t.x);
    t.y = t.x == box(pp,vec3(1.)) ? 3.:2.;
  
      h = h.x < t.x ? h:t; 
    return h;
}
vec2 nv=vec2(-.001,.001);
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p){return normalize(q(nv.xyy)+q(nv.yxy)+q(nv.yyx)+q(nv.xxx));}
void main(void)
{
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	 vec2 puv = uv;
  uv -= 0.5;
 
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
      float _bit3 = texture(texFFTIntegrated,.33).r;
     _bit3 = cos(texture(texNoise,uv*.5).r+floor(_bit3*33)*6.66)*.5;
   
  vec3 ro = vec3(0.,0.,-5.),rd=normalize(vec3(uv,1.-_bit3 )),rp=ro;
  vec3 light= vec3(1.,2.,-3.);
  
  	vec3 col =vec3(.1);
  
  vec3 acc = vec3(0.);
  for(float i=0.;i<=69.;i++){
      vec2 d = sdf(rp);
     
      if(d.y <=.1) {
          acc += vec3(.1,7,.2)*exp(-abs(d.x))/59.;
          d.x = max(0.02,abs(d.x));
      }
    
    
      if(d.x<=0.01) {
          vec3 n= norm(rp);
        
        
         if(d.y>.1 && d.y <=1.){
             if(d.y >.5) {
          col = vec3(.2,.5,.7)*max(0.,dot(normalize(light-rp),n));
             } else {
                 col = vec3(9.,.5,.1)*max(0.,dot(normalize(light-rp),n));
               }
             break;
         } 
         if(d.y ==2.){
             float noize = texture(texNoise,rp.xz*10.).r*.01;
             col*=vec3(.1,.7,.5)*1.2;
             rd = reflect(rd,n+noize);
             rp+=rd*.01;
           }
                    if(d.y ==3.){
             float noize = texture(texNoise,rp.xz*10.).r*.01;
             col*=vec3(.1,.7,.5)*2.2;
             rd = reflect(rd,n+noize);
             rp+=rd*.01;
           }
        
      }
      rp+=rd*d.x;
  }
  col += acc;
  
  
  vec3 pcol = texture(texPreviousFrame,puv).rgb;
  
   col = mix(col,pcol,.5);
	out_color = vec4(col,1.);
}