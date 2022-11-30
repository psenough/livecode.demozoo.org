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
uniform sampler2D texTex5;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
float box(vec3 p,vec3 b){
    vec3 q = abs(p)-b;
    
    return length(max(vec3(0.),q))+min(0.,max(q.x,max(q.y,q.z)));
}
float diam(vec3 p,float s){
   p = abs(p);
   return (p.x+p.y+p.z-s)*0.57735027;
}
//http://glslsandbox.com/e#48230.4
float hash21(vec2 p) {
    p = fract(p * vec2(233.34, 851.74));
    p += dot(p, p + 23.45);
    return fract(p.x * p.y);
}
//http://mercury.sexy/hg_sdf/
vec2 pMod2(inout vec2 p, vec2 size) {
	vec2 c = floor((p + size*0.5)/size);
	p = mod(p + size*0.5,size) - size*0.5;
	return c;
}

vec2 iid ;

vec2 sdf(vec3 p){
  vec3 pppp=p;
  vec3 ppp = p;
  
p.z +=mod(fGlobalTime+texture(texFFTIntegrated,.3).r*100. ,10000);
  vec2 h;
  p.xy*=rot(p.z*.01);
  p.y = -abs(p.y);
  p.x +=fGlobalTime*10;
  p.y +=5.;
  vec3 pp = p;
  vec2 id = pMod2(pp.xz,vec2(3.));
  iid = id;
  float tt = texture(texFFT,.05+(abs(id.y)/10.+abs(id.x)/3.)*.5).r;
  tt = sqrt(tt);
  float dd = hash21(id);
  h.x = box(pp,vec3(1.,1.+sqrt(dd)*2.,1.));
  h.y = 1.-tt;
  
  vec2 t;
  t.x = dot(p,vec3(0.,1.,0.));
  t.y = 2.;
  h = t.x < h.x ? t:h;
  
  t.x = diam(pp+vec3(.0,-2.,.0),.5+dd*1);
  t.y = 2.;
  h = t.x < h.x ? t:h;
  
    float scale = 2.-texture(texFFT,.33).r*100;
   pppp*=scale;
   pppp.xz *=rot(fGlobalTime);
     pppp.xy *=rot(fGlobalTime);
   t.x = (1./scale)*mix(box(pppp,vec3(.5)) ,diam(pppp,1.) ,1.5);
   t.y = 3.;
   h = t.x < h.x ? t:h;
  
  return h;
 }
#define q(s) s*sdf(p+s).x
 vec2 nv=vec2(-.01,.01);
 vec3 norm(vec3 p){return normalize(q(nv.xyy)+q(nv.yxy)+q(nv.yyx)+q(nv.xxx));}
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.0,.3,.7)));}

bool inside=false;
float IOR =1.45;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv*=1.+fract(fGlobalTime+texture(texNoise,uv*.1).r*2);
  vec3 ro=vec3(0.,0.,-5.);

  vec3 rt = vec3(sin(fGlobalTime)*2,0.,(cos(fGlobalTime)*.5+.5)*2.);
  vec3 z = normalize(rt-ro);
  vec3 x = cross(z,vec3(0.,-1.,0.));
  vec3 y = cross(z,x);
  vec3 rd=normalize(mat3(x,y,z)*vec3(uv,1.));
   
  //vec3 rd=normalize(vec3(uv,1.));
  //rd = 
  vec3 rp=ro;
  vec3 light= vec3(1.,2.,-3.);	

	vec3 col = vec3(.0);
  float i=0;;
  vec3 acc = vec3(0.);
  for(i=0;i<=100.;i++){
      vec2 d = sdf(rp);
      rp += rd*d.x;
    
    if(d.y <= .87){
           
           acc += pal(d.y*10.5)*exp(-abs(d.x))/100.;
       d.x = max(.01,abs(d.x));
    }
      if(d.x <=0.001){
          vec3 n = norm(rp);
          if(d.y <= 1.){
       
            col = vec3(.001)*max(0.,dot(light-rp,n));
            
          break;
          } else if(d.y ==2.){
              rd = reflect(rd,n+texture(texNoise,texture(texFFT,.3).r*100+rp.xz*.1).r);
              rp+=rd*.01;
          }else if (d.y==4.)
          {
            
              col = vec3(1.)*max(0.,dot(normalize(light-rp),n));
            
          } else if (d.y == 3.){
             col +=vec3(.1,.2,.1)/3.;
              if(!inside){
               
                rd = refract(rd,n,1./IOR);
                rp-=0.005*n;
                inside = true;
            } else {
                n = -n;
                vec3 _rd = refract(rd,n,IOR);
                if(dot(_rd,_rd)==0.){
                    rd = reflect(rd,n);
                    rp+=0.002*n;
                    
                } else {
                 
                    rd = _rd;
                    rp -= 0.005*n;
                    inside=false;
                  
                }
            }
          }
      }
  }
  col +=sqrt(acc);
  col*=1.1;
	out_color = vec4(col,1.);
}














// PLEASE VISIT https://livecode.demozoo.org/index.html
// And don't forget to archive on your next demoparty !!










