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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float ti = fGlobalTime;
float n1,n2,n3,pi = 3.141592,f;

mat2 r2d(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

float mc(float z,float m1, float m2, float time){return clamp(cos(z*m1+time*ti)*m2,-.25,.25)/2.+.5;}

float sdf(vec3 p)
{
  
  vec3 p2 = p;
  
  float ti2 = floor(mod(ti,5.))+5.;
  float tex = texture(texFFTSmoothed,1.).x*50;

  for(float i = 0.;i++<ti2;)
  {
    p2 = abs(p2)-cos(ti/5+3.141592)/2.-2.;
    p2.xy *= r2d(1283);
    p2.zy *= r2d(2.123);
    p2.xz *= r2d(12.12);
    
    
    float so = length(p2)-.5*tex;
    
    f = so;
  }
  
  float sp = length(p2.xy)-.2*tex;
  
  float co = p2.y;

  p2.xy *= r2d(ti/8.);
  p2.xz *= r2d(ti/8.);
  p2.zy *= r2d(ti/8.);
  
  float cu = length(max(abs(mod(p2,50.)-25)-.5*tex,0.));
  
  p2 = p;
  
  p2 = mod(p2, 50)-25;
  
  float su = length(p2)-5.;
  
  f = min(min(f,cu),sp);
  
  #define nn(s) .1/(s*s*40+.1)
  n1 += nn(f);
  n2 += nn(min(co,su));
  n3 += nn(cu);
  
  return f;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv2 = uv;
  
  float bz = mc(ti,.005,100.,7.);
  
  //uv2 = mix(uv2*r2d(ti/4.),uv2*r2d(-ti),bz);
  
  vec3 ro = mix(vec3(0.,0.,-50.),vec3(0.,0.,-300.),bz);
  ro.xz *= r2d(ti/8.);
  ro.yz *= r2d(ti/8.);
  ro.xy *= r2d(ti/8.);
  
  vec3 fr = normalize(vec3(5.)-ro);
  vec3 ri = normalize(cross(fr,vec3(0,1,0)));
  vec3 up = normalize(cross(ri,fr));
  vec3 rd = normalize(ri*uv2.x+up*uv2.y+mix(fr*.5,fr*3.,bz));
  
  float t = 0.;
  
  for(float i = 0.;i++<128.;)
  {
    float d = sdf(ro+rd*t);
    if(d<.001||t>500.)break;
    t+=d;
  }
  
	float f = texture( texFFTSmoothed, length(ro+rd*t) ).r * 100;
  
  float pat = ceil(sin(uv.y*4.5+3.141592/2.));
  
  vec3 vcol = vec3(0.2,1.,.8);
  vec3 bcol = vec3(1.,.2,0.);
  
  vec3 col = mix(bcol,vcol,bz);
	out_color = mix(vec4(n1*.02*col+n2*.5*col+n3*.2*col,1.)/pat,texture(texPreviousFrame,(gl_FragCoord.xy / v2Resolution.xy)),.4);
}