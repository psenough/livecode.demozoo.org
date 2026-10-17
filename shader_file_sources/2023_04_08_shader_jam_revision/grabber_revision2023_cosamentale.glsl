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
float time = fGlobalTime;
float rd(float t){return fract(sin(dot(floor(t),45.236))*7845.26);}
float no(float t){return mix(rd(t),rd(+1.),smoothstep(0.,1.,fract(t)));}
float e;
/*vec3 b(vec3 p, vec3 a , vec3 b){vec3 q = abs(p)-b;
  return mix(*/
float rd(){return fract(sin(e++)*7845.236);}
vec3 vr(){float a = (rd()-0.5)*2.;
  float b = rd()*6.28;
  float c = sqrt(1.-a*a);
  return vec3(cos(b)*c,sin(b)*c,a)*sqrt(rd());}
  float zl;
float map(vec3 p){
  for(int  i = 0 ;i  < 2; i++){
  if(p.x>p.y)p.yx = p.xy;
   if(p.x>p.z)p.xz = p.zx;
   p = abs(p);
  }
  float d1 = length(p.xz-vec2(0.5,0.5))-2.;
float d2 = length(p.xy+vec2(sin(time),cos(time)))-2.;
  zl = d2;
float d3 = p.y+3.;
return min(d3,min(d1,d2));
}  
float rm(vec3 p, vec3 r){
  float dd = 0.;
  for(int  i = 0 ; i < 64 ; i++){
    float d = map(p);
    if(dd >40.){break;}
    if(d<0.01){break;}
    p += r*d;
    dd +=d;
  }
  return dd;
}
vec3 nor (vec3 p){vec2 e  =vec2(0.01,0.); return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;
  uv *= 2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 p = vec3(0.,0.,-7.);
  vec3 r  = normalize(vec3(uv,1.));
  e = uv.x *  v2Resolution.y+uv.y;
  e += time;
  float d1 = rm(p,r);
  float r1 = 0.;
  for(int  i = 0 ; i < 3 ; i++){
 
    float d = rm(p,r);
       if(d>40.){break;}
    if(zl>0.1){
      vec3 pp = p+r*d;
      vec3 n = nor(pp);
      r  = n+vr();
      p = pp+0.1*r;
    }else{r1 = 1.;}
  }
  float t1 = mix(texture(texPreviousFrame,uc).x,r1,0.5);
  float t2 = pow(t1,0.2);
	out_color = vec4(vec3(t1),t1);
}