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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float cr(vec3 p){
      p = abs(p);
       float d=0.,m;
      for(float i=0;i++<3.;){
              d += step(m=max(p.y,p.z),p.x)*m;
              p = p.yzx;
        }
        return max(max(p.x,max(p.y,p.z))-2.9,1.-d);
  
  }

vec2 sdf (vec3 p){
    vec2 h;
   vec3 tp=p;
   vec3 op = p;
  p.x = abs(p.x)-2.5;
  p.z +=texture(texFFTIntegrated,.3).r*15;
  p.z = asin(sin(p.z));
  //p = erot(p,normalize(vec3(1.,.2,.3)),fGlobalTime);
  h.x = cr(p);
  
  float sc=1.,d=0.;
  for(float i=0;i++<(3-0*sin(texture(texFFTIntegrated,.3+floor(tp.z)).r*10));){
         h.x = max(h.x,cr(p)*sc);
         sc /=3.;
         p = fract((p-1.)*.5)*6.-3;
    }
  
  h.y = 1.;
  
  vec2 t;
t.x = dot(tp,vec3(0.,1.,0.));
   t.y = 2.;

  h= t.x < h.x ? t:h;    
 
     op.y -=1.;
      op = abs(op)-.5;
      op.xy +=dot(cos(op+vec3(0.,0.,fGlobalTime*10)),sin(op.zxy))*.1;
   t.x  = length(op.xy)-.1;
  t.x = max(abs(op.z)-3,t.x);
    t.y = 3;;
      h = t.x < h.x ? t:h;
    return h;
  
  }
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p, float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.1,.2,.3)));}
// Technical pause
void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
   uv *=rot(fGlobalTime);
  //uv = vec2(log(length(uv)),atan(uv.x,uv.y));
  vec3 col = vec3(.1*texture(texFFT,floor(uv.y*10)/10).r*50);
	vec3 ro = vec3(.5+0*asin(cos(fGlobalTime))*.3,2.+asin(sin(fGlobalTime))*.2,-2.),rt=vec3(0.,1,0);
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,vec3(0.,-1.,0.)));
  vec3 y = normalize(cross(z,x));
  
  vec3 rd= mat3(x,y,z)*normalize(vec3(uv,1.-(.9)*sqrt(length(uv))));
  vec3 rp = ro;
  vec3 light = vec3(1,2.,-3.);
  for(float i=0;i<128;i++){
    
    vec2 d=  sdf(rp);
     
    if(d.y == 3){
      
        col +=vec3(1.)*exp(-abs(d.x))/(100-texture(texFFT,.3).r*5000);;
         d.x = max(.001,abs(d.x));
      }
    rp +=rd*d.x;
      
     if(d.x < .0001 ){
           vec3 n = norm(rp,.001);
           if(d.y==2.){
               rd = reflect(rd,n+dot(sin(rp),cos(rp.yzx))*.2);
               col+=vec3(.0,.1,.2);
               rp+=rd*.1;
                continue;
             }
             vec3 n2 = norm(rp,.01);
           float dif = max(0.,dot(normalize(light),n));
           col = dif * pal(.1+fGlobalTime+d.x*.01)+dif*pal(dif)*step(.01,length(n-n2));
           break;
       }
    }
  
  out_color = vec4(col,1.);
}