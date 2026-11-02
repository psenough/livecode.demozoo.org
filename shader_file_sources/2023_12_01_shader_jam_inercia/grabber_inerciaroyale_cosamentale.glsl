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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float rs = 1.;
//float t1 = texture(texFFTSmoothed,0.2).x*10.;
//float t2 = texture(texFFTIntegrated,0.2).x*10.;
float rd(float t){ return fract(sin(dot(floor(t),45.236))*7854.236);}
float no(float t){ return mix(rd(t), rd(t+1.),smoothstep(0.,1.,fract(t)));}
float hs(vec2 t){ return fract(sin(dot(t,vec2(45.236,98.26)))*7854.236)-0.5;}
float time= fGlobalTime;
float t1 = rd(rd(fGlobalTime));
float t2 = fGlobalTime+no(time)+no(time*3.+98.9)*0.4;
float n1 = no(t2*2.)+no(t2*4.)*0.5;
float n2 =  no(t2*1.8);
mat2 rot(float t){float s  = sin(t); float c = cos(t); return mat2(c,-s,s,c);}

float map(vec3 p){ 
  vec3 pn = p;
  p += 1.;
  for(float i = 0 ; i < 7 ; i++){
   p-= 0.5+n1;
    p.xz *= rot(t2);
    p.xy *= rot(t2*0.9);
    p = abs(p);
  }
  float d1 = max(length(p.xz)-1.5-t1*10.,length(pn)-18.);
  float d2 = length(p)-2.-t1*10.;
  return mix(d1,d2,smoothstep(0.3,0.7,n2));}
  vec3 nor (vec3 p){ vec2 e = vec2(0.01,0.); return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
  float gl(vec2 uv){vec2 s = 6.28/v2Resolution;float r= 0.;
    for(int  i = 0 ; i < 25 ; i++){
      float p = 6.28*(1./25.)*i;
      r += texture(texPreviousFrame,uv+vec2(cos(p),sin(p))*s).a;
    }return r /=25.;}
    float b (vec2 p, vec2 b){vec2 q =abs(p)-b;
     return length(max(q,vec2(0.)))+min(0.,max(q.x,q.y));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv.x  = uv.x+hs(uv)*no(t2*4.3+98.4)*0.05*pow(length((uv.y-0.5)*2.),2.);
  vec2 uc  = uv;
	uv -= 0.5;
  uv *= 2.;
 
  vec2 fac = vec2(v2Resolution.y / v2Resolution.x, 1);
	uv /= fac;
   uv.x = mix(uv.x,abs(uv.x),step(0.8,rd(no(t2*5.2+98.236))));
  float ca = mix(10.,80.,no(t2*3.8+985.));
  vec2 ul = fract(uv*ca);
  vec2 ul2 = fract(uv*rot(3.14*0.25)*ca);
  uv = floor(uv*ca)/ca;
  vec3 p = vec3(0.,0.,-20.);
  vec3 r = normalize(vec3(uv,1.));
  float dd;
  for(int  i = 0 ; i < 15 ; i++){
    float d=  map(p);
    if(d<0.01){break;}
   
    p += r*d;
    dd += d;
  }
  float d1 = pow(t1*300.,2.)*0.5;
  float r1 = floor(smoothstep(20.,0.,dd)*16.)/16.;
  float m = step(dd,20.);
   vec3 n = nor(p);
  float ml= clamp(mix(n.x,n.y,step(0.5,rd(t2*5.)))*mix(-1.,1.,step(0.5,(t2*2.5+985.))),0.,1.);
  float n3 = no(t2*3.5+453.)*0.5;
  float ia = mix(0.5+n3,0.5-n3,ml);
  float l1 = step(ia,ul.x);
  float l2 = step(ia,ul.y);
  float l3 = step(ia,ul2.x);
  float l4 = step(ia,ul2.y);
  float l5 = mix(mix(l3,l4,step(n.x,0.)), mix(l4,l3,step(n.x,0.)),step(0.,n.y));
  float l6 = mix(l1,l5,step(0.35,abs(n.x)));
  float l7 = mix(l2,l5,step(0.35,abs(n.y)));
  float l8 = step(abs(n.z),0.9);
  float lf= mix(step(0.1,ml),mix(l6,l7,step(0.35,abs(n.x))),mix(l8,1.-l8,step(0.75,rd(t2*4.6*6.3))));
  
  float li = sin(gl(uc)*no(t2*4.65+69.25)*8.)-0.5+(r1)*5.; 
  vec2 un =300.*fac.yx; 
  float li2 = texture(texPreviousFrame,floor(uc*un)/(un)).a;
  vec3 c2 =( 3.*abs(1.-2.*fract(li2*5.+r1*5.+t2*5.+vec3(0.,-1./3.,1./3.)))-1.)*li2;
  vec3 c1 =( 3.*abs(1.-2.*fract(r1*5.+t2*5.+vec3(0.,-1./3.,1./3.)))-1.)*mix(lf,1.,step(0.95,rd(t2*7.+8.87)));
  vec3 r2 = mix(step(0.4+no(t2*5.)*0.5,texture(texPreviousFrame,uc+(floor(uv*4.)/4.)*-0.005).xyz),c1,m);
  vec3 r3 = mix(r2,1.-r2,step(0.95,rd(t2*6.+89.58)));
  vec3 r4 = mix(r2,c2,step(0.5,rd(t2*3.8+914.55)));
  uv += n.xy*0.01;
  uv.x +=1.4;
  uv.y += sin(uv.x*4.+time*5.)*0.1;
  float i1 = b(uv,vec2(0.05,0.2));
   uv.x -=0.25;
   i1 = min(i1,b(uv,vec2(0.05,0.2)));
   i1 = min(i1,b((uv-vec2(0.1,0.))*rot(-0.5),vec2(0.05,0.2)));
     uv.x -=0.25;
   i1 = min(i1,b(uv,vec2(0.05,0.2)));
    uv.x -=0.25;
   i1 = min(i1,b(uv,vec2(0.05,0.2)));
     uv.x -=0.15;
   i1 = min(i1,b(uv+vec2(0.,0.15),vec2(0.1,0.05)));
   i1 = min(i1,b(uv-vec2(0.,0.15),vec2(0.1,0.05)));
   i1 = min(i1,b(uv,vec2(0.1,0.05)));
      uv.x -=0.25;
       i1 = min(i1,b(uv,vec2(0.05,0.2)));
     uv.x -=0.15;
   i1 = min(i1,b(uv-vec2(0.,0.15),vec2(0.1,0.05)));
   i1 = min(i1,b(uv,vec2(0.1,0.05)));   
     i1 = min(i1,b((uv+vec2(-0.05,0.1))*rot(-0.5),vec2(0.05,0.11)));
       uv.x -=0.05;
          uv.x -=0.25;
   i1 = min(i1,b(uv,vec2(0.05,0.2)));
     uv.x -=0.15;
   i1 = min(i1,b(uv+vec2(0.,0.15),vec2(0.1,0.05)));
   i1 = min(i1,b(uv-vec2(0.,0.15),vec2(0.1,0.05)));
   i1 = min(i1,b(uv,vec2(0.1,0.05)));
           uv.x -=0.25;
   i1 = min(i1,b(uv,vec2(0.05,0.2)));
     uv.x -=0.15;
   i1 = min(i1,b(uv+vec2(0.,0.15),vec2(0.1,0.05)));
   i1 = min(i1,b(uv-vec2(0.,0.15),vec2(0.1,0.05)));
  // i1 = min(i1,b(uv,vec2(0.1,0.05)));
  uv.x -=0.3;
   i1 = min(i1,b(uv,vec2(0.05,0.2)));
     uv.x -=0.25;
       i1 = min(i1,b(uv,vec2(0.05,0.2)));
     uv.x -=0.15;
   i1 = min(i1,b(uv-vec2(0.,0.15),vec2(0.1,0.05)));
   i1 = min(i1,b(uv,vec2(0.1,0.05)));   
   uv.x -=0.1;
     i1 = min(i1,b(uv,vec2(0.05,0.2)));
  float il = max(step(0.,i1),step(0.5,no(t2*6.25+95.65)));
  vec3 r5 = mix(1.-r4,r4,il);
	out_color = vec4(r5,li);
}