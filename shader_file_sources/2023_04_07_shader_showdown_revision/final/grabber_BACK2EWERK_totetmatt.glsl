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
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
// With 5 T >> TOTETMATT << here, I'm still not a robot
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = texture(texFFTIntegrated,.3).r+fGlobalTime*.5;
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float rnd(vec2 p){
    return fract(865.5*sin(dot(p,vec2(542.25,752.23))));
  }
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(0.,.3,.5)));}
vec2 sdf(vec3 p){
    vec2 h;
  vec3 hp=p;
  float tt=texture(texRevision,clamp((hp.xz*(.1-texture(texFFTSmoothed,.3).r*1))+.5,0.,1.)).r;
    h.x = dot(hp,vec3(0.,1.,0))-tt*.1+texture(texNoise,hp.xz*.1).x*.1;
    h.y = 1.+tt;
     
     vec2 t;
     vec3 tp=p;
     t.x = 100;
     for(float i=0,im=8;i++<im;){
       float sc= fract(i/im-bpm*5);
       vec3 off = vec3(0.,sin(p.z*.5),sc*5);
        vec3 op = p-off;
        t.x = min(t.x,length(op)-.5);
     }
     t.y = 2.;
     h=t.x < h.x  ?t:h;
    return h;
  
}

#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
   
  bpm = floor(bpm) + pow(fract(bpm),5);
vec2 qq = vec2(log(length(uv)),atan(uv.x,uv.y))/3.5;
vec3 col = vec3(0.);
  col = pal(qq.x+bpm)*sqrt(texture(texFFTSmoothed,floor(qq.x*10)/10+floor(qq.y*10)/10).rrr)*texture(texRevision,clamp(uv+.5,0.,1.)).r;
  
   vec3 ro=vec3(2.,1.,-5),rt=vec3(0.);
     ro .x +=tanh(sin(bpm*1+fGlobalTime)*5)*5;
   ro .y +=2+tanh(cos(bpm*1+fGlobalTime)*5);
    ro =erot(ro,vec3(0,1,0),bpm);
   vec3 z=normalize(rt-ro),x=normalize(cross(z,vec3(0.,-1.,0))),y=cross(z,x);
   vec3 rd=mat3(x,y,z)*normalize(vec3(uv,1.-(.8+cos(bpm+rnd(uv)*.1)*.5)*sqrt(length(uv))));
  
   
    vec3 rp=ro;
    float dd=0.;
     vec3 light = normalize(vec3(1.,2.,-3.));
  vec3 acc= vec3(0.);
      for(float i=0.;i++<128 && dd < 50;){
        
           vec2 d =sdf(rp);
           if(d.y==2){
                acc+=vec3(.0,.4,.1)*exp(-abs(d.x))/(50-min(45,texture(texFFTSmoothed,.3).r*5000));
             }
           rp+=rd*d.x;
           dd+=d.x;
        
           if(d.x < .001){
             
                 vec3 n = norm(rp,.001);
             vec3 n2 = norm(rp,.005);
                 float dif = max(0.,dot(light,n));
             
                 float spc = pow(max(0.,dot(rd,reflect(light,n))),32);
             float fr = pow(dot(rd,n),.4);
                
                 if(d.y ==2){
                          col = vec3(0.,1.,.1)*dif+spc;
                   } else {
                      col = vec3(.1,.1,.2)*dif+smoothstep(.001,.2,length(n-n2))*20*pal(spc+bpm);
                   }
                 break;
             }
        }  
	out_color = vec4(sqrt(col+acc),1.);
}