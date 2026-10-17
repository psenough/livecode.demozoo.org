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
float box2(vec2 p,vec2 b){
    vec2 q = abs(p)-b;
     return length(max(vec2(0.),q))+min(0.,max(q.x,q.y));
  }
 
vec2 sdf(vec3 p){
  p.y -=.2;
    p.xy *=rot(-.785*.5);
  float bump = texture(texFFTSmoothed,.3).r*100;
  vec2 h;
  vec3 hp = p;
  hp.y -=1.;
  hp.x +=1.;
  h.x =  max(abs(hp.z)-.1-bump,box2(hp.xy,vec2(.5)));
  h.y = 1.;
  
  vec2 t;
  vec3 tp = p;
  tp.x +=1.;
  tp.y +=1.;
  t.x =  max(abs(tp.z)-.1-bump,box2(tp.xy,vec2(.5,1.)));
  t.y = 1.;
  
  h = t.x < h.x ? t:h;
  
  tp = p;
  tp.y+=.3;
  tp.x +=.1;
  t.x = max(abs(tp.z)-.1-bump,length(tp.xy)-1.75);
  t.x = max(-tp.x+.1,t.x);
  
  float tt  = max(abs(tp.z)-.2-bump,length(tp.xy)-1.);
  tt = max(-tp.x,tt);
  t.x= max(-tt,t.x);
  t.y = 2.;
  
    h = t.x < h.x ? t:h;
  return h;
  }
#define q(s) s*sdf(p+s).x
  vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
float diam2(vec2 p,float s){
    p = abs(p);
    return (p.x+p.y-s)*inversesqrt(3.);
}
vec3 txt(vec2 uv){
  uv*=4.;
  uv = vec2(log(length(uv)),atan(uv.y,uv.x))*3.1415;
  uv.x -=texture(texFFTIntegrated,.3).r;
  vec2 id = floor(uv);
  uv = fract(uv)-.5;
     vec3 col = vec3(.8,.2,.2);
  if(mod(id.x,2.)==0.){
       uv*=4.;
       uv.y +=fGlobalTime;
       uv = fract(uv)-.5;
    col = vec3(.2,.8,.2);
    }
  float d = diam2(uv,.2);
  d=  mix(d,abs(d)-.01,asin(sin(texture(texFFTIntegrated,.1+min(1.,fract(length(id)))).r*50))*.5+.5); // NOT SQUIDGAME 
  d=  smoothstep(1.7*fwidth(d),0.,d);
 
  return .5*col*d;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 col = txt(uv);
  
  vec3 ro = vec3(sin(fGlobalTime),0.,-5.);
  vec3 rt = vec3(0.);
  vec3 rp = ro;
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z,vec3(0.,-1.,0.)));
  vec3 y = normalize(cross(z,x));

  vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.));
  vec3 light = vec3(1.,2.,-3.);
  vec3 acc = vec3(0.);
  float time = mod(fGlobalTime,10);
for(float i=0;i<=128.;i++){
    vec2 d = sdf(rp);
     
     
     if(time < 5 && length(rp-vec3(.25,.1,.0)) >.6 ) acc += (d.y ==1. ? vec3(.2,.9,.2):vec3(.9,.2,.2))*exp(-abs(d.x))/(50.-min(40,texture(texFFT,.3).r*1000));
     if(time < 5 &&  fract(fGlobalTime+ length(rp)*.5)<0.5){  d.x = max(.001,abs(d.x));}
    
    if(d.x <.0001){
        vec3 n = norm(rp,.001);
        vec3 nn = norm(rp,.01);
        float diff = max(0.,dot(normalize(light-rp),n));
        float spc = max(0.,dot(normalize(light-ro),reflect(-normalize(light),n)));
      spc  = pow(spc,32);
        if(d.y == 1.){
             col = vec3(.2,.9,.2)*diff;
        }  else {
             col = vec3(.9,.2,.2)*diff;
          
          }
         col = time < 5 ?col : mix(col, col*step(.2,length(nn-n)),floor(asin(sin(rp.y+fGlobalTime)*.5)*10)*.5+.5);
         col +=spc*vec3(1.);
      break;
      }
      rp +=rd*d.x;
  
  }  
  col +=acc;
	out_color = vec4(col,1.);
}