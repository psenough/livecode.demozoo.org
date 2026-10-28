#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texLcdz;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm=fGlobalTime*130/60*.1+sqrt(texture(texFFTIntegrated,.1).r)*16;
float rnd(vec2 uv){return fract(458.14*sin(dot(uv,vec2(953.5,8753.5)))); }
  
// Level 1
float txt(vec2 p,float t){
     ivec2 i = ivec2(abs(p)*128.);
      return texture(texFFT,p.x).x*5+(i.x&i.y)/128.;;
  }
vec3 lvl1(vec2 uv){
    vec2 ouv=uv;
  uv.x += sqrt(texture(texFFTSmoothed,uv.y*.5+tanh(.5*asin(sin(bpm+.25*asin(sin(uv.x)))))*.5).x);
   uv*= 1+fract(length(uv+uv.x)-.1-fGlobalTime*.4);;
  vec3 col= vec3(0.);
   bool type =mod(fGlobalTime*130/60*4,8)<4 ;
 #define spl texSessions//type? texSessions:texSessionsShort
  
      col.r= texture(spl,clamp(1.2*uv*vec2(.5,-1)+.5+texture(texFFTSmoothed,floor(bpm*10)*.1+txt(uv,1.)).r,0.,1.)).r;
     col.gb= texture(spl,clamp((1.21*uv*vec2(.5,-1)+.5)+texture(texFFTSmoothed,floor(bpm*10)*.1+txt(uv,2.)).r,0.,1.)).gb;
    float from = mix(-.5,.5,fract(.1+bpm*.1));
    float to = mix(-.5,.5,fract(.2+bpm*.1));
  if(fract(fGlobalTime*130/60) >.9+txt(uv,1.)*.1 && ouv.y >from &&ouv.y <to) col=1.-col;
  return col;
  }
// Level2
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 pal(float t){return .5+.5*cos(6.28*(1*t+vec3(.0,.3,.7)));}
vec2 sdf(vec3 p){
  vec2 h;
  float id = floor(p.y);
  p.x -=asin(sin(id*33+bpm));
  p.y = fract(p.y)-.5; 
   p = erot(p,normalize(vec3(0.,1.,0)),id);
  p = erot(p,normalize(vec3(0.,0.,1)),p.z+bpm);
float gy;
  p.xy = abs(p.xy)-.1-abs(gy=dot(sin(p+id),cos(p.zyx-id+bpm))*.1);
  h.x = .8*min(.25,length(p.xy)-.05-.1*tanh(10*texture(texFFTSmoothed,p.z*.1+bpm+fGlobalTime*.3).x));
  h.y = 1.+gy;
  return h;
}
#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  //bpm*=4.;
  bpm+=rnd(uv)*.05;
  bpm = floor(bpm)+pow(smoothstep(.0,1.,fract(bpm)),.25);
 vec3 col1  = lvl1(uv);
  vec3 col = vec3(0.);
   vec3 ro=vec3(-1.,bpm,5),rt=vec3(0.,bpm+6*tanh(sin(bpm*.25+cos(bpm*.5))*5),0.);
    ro=erot(ro,vec3(0.,1.,0),bpm*.1+.1*tanh(sin(bpm)*10+.1*dot(sin(uv*20),cos(uv.yx*100)))*3.14);
    vec3 z=normalize(rt-ro),x=(cross(z,vec3(0.,-1.,0.))),y=cross(z,x);
    vec3 rd = mat3(x,y,z)*normalize(vec3(uv,1.-10*texture(texFFTSmoothed,.3).x*sqrt(length(uv))));
    vec3 rp=ro;
    vec3 light = normalize(vec3(1.,2.,-3.));
    vec3 acc=vec3(0.);
    for(float i=0.;i++<128.;){
       vec2 d = sdf(rp);
        if(d.y >1) {acc+=pal(rp.z*.1+bpm+rp.y)*10*exp(10*-abs(d.x))/(100+-smoothstep(.0,1.,pow(fract(fGlobalTime*130/60),4.))*90+sin(rp.z*5+bpm*50)*20);
        d.x = max(.01,abs(d.x));
        }
        rp+=d.x*rd;
        if(d.x < .001){
          vec3 n = norm(rp,.001);
          float dif = max(0.,dot(light,n));
          float fre = pow(1+dot(rd,n),4.);
          col =mix(vec3(0.1)*dif,pal(rp.z*.1+bpm+rp.y)*10,fre);
          break;
        }
    }
	out_color = mix(vec4(sqrt(col1),1.),vec4(sqrt(col+acc*acc),1),sin(fGlobalTime+.1*dot(sin(uv*7),cos(9*uv.yx)))*.3+(sqrt(texture(texFFTSmoothed,.3)).x*10));
	//out_color = vec4(max(vec3(0),col+acc),1.);
}