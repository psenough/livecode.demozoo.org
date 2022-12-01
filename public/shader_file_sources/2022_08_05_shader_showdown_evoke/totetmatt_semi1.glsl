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
// I WANT THE SOURCE !!!!!!
// come to https://livecode.demozoo.org 
in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
const vec2 sz = vec2(1.,1.73),hs = sz*.5;
vec2 hexgrid(inout vec2 p){
  vec2 pa= mod(p,sz)-hs,pb=mod(p-hs,sz)-hs,pc=dot(pa,pa) < dot(pb,pb) ? pa : pb;
  vec2 n = (p-pc+hs)/sz;
  p = pc;
  return round(n*2.)*.5;
  
  }
float box(vec3 p,vec3 b){
    vec3 q = abs(p)-b;
    return length(max(vec3(0.),q))+min(0.,max(q.x,max(q.y,q.z)));
  }
vec3 pal(float t){return .5+.5*cos(6.28*(1.*t+vec3(.0,.3,.6)));}
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
void main(void)
{
	vec2 uv = out_texcoord;
	
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uuv = uv;
  vec3 col = vec3(.1+texture(texFFT,abs(uv.x)).r*10);
	float tt =texture(texFFTIntegrated,.3).r*.25; 
     uv += vec2(asin(sin(sz.y*tt)),asin(cos(sz.x*tt)));  
  uv*=2;
  
  vec2 n = hexgrid(uv);
  if(dot(cos(n),sin(n.yx)) < .0) uv*=2.;
  vec2 p1=uv*3.,p2=p1+vec2(1.,inversesqrt(3.));
  
  vec2 n1 = hexgrid(p1);
  vec2 n2 = hexgrid(p2);
  
  float l = 1.;
  if(n1.x < n2.x+.5) l *= .75;
  
  if(n1.y < n2.y) l *= .75;
   float gy = dot(sin(n1*4),cos(n2*8));
  float zzccmxtp=  (gy + fGlobalTime+n2.y*.4+n2.y*.3+n2.x*.2+n1.x*1.1);
  float txt = texture(texFFTSmoothed,zzccmxtp).r;
  
  float d1 = max(dot(p1=abs(p1),sz*.5),p1.x)-.48;
  
  float d2 = max(dot(p2=abs(p2),sz*.5),p2.x)-.48;
  float d = max(d1,d2);
  d = smoothstep(0.,fwidth(d),d);
  
  col = (gy < .0 ? d: 1.)*(txt*10 > .1 ? pal(zzccmxtp*3): vec3(.5))*l*vec3(1.)*txt*100;
  
  uv = uuv;
  vec3 p,dd= normalize(vec3(uv,1.));
  for(float i=0.,g=0.,e=0.;i++<99.;){
    
       p = dd*g;
       p.z -=5.-texture(texFFTSmoothed,.3).r*500;
       p.x += asin(sin(fGlobalTime));
    
       p.y += asin(cos(fGlobalTime));
    
       p.xy *=rot(fGlobalTime);
    
       float h = box(p,vec3(1.));
        g+=e=h;
        // CUBIGGGAAAAAAAA
        vec3 cc = mod(floor(p.x*5+floor(mod(p.y*5,2)))*5 ,2.) < 1. ? vec3(1.,0.,0.) : vec3(1.);
        col += cc*.055/exp(e*e*i);
    }
  out_color = vec4(sqrt(col),1.);
}