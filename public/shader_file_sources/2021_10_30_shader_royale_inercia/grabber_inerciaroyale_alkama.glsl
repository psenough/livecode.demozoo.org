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

float pi = acos(-1);
float tt = mod(fGlobalTime, 20*pi)*130/120;
float ft=fract(tt);
float it=floor(tt);
float t = it+ft*ft*ft;

vec3 rep(vec3 p, float r) { return mod(p,r)-r*.5; }
mat2 rot(float a) { float c=cos(a),s=sin(a); return mat2(c,s,-s,c); }
float sphere(vec3 p, float r) { return length(p)-r; }
float torus(vec3 p, float r, float s) { vec2 b=vec2(length(p.xy)-r, p.z); return length(b)-s; }
vec2 moda(vec2 p, float r) {
  r = 2*pi/r;
  float a=mod(atan(p.y,p.x), r) - r*.5;
  return length(p) * vec2(cos(a),sin(a));
}

float g=0;
float scene(vec3 p) {
  p.xz*=rot(t*.1);
  p.yz*=rot(t*.1);
  
  p.xz = moda(abs(p.xz), 5.);
  p.yz = moda(abs(p.yz), 9.+3*cos(t));
  vec3 p2 = p;
  p2.xz += .1*sin(10*p2.yz + t);
  float tr = torus(p2, 1.4*p.x, .15+.1*sin(t));
  
  //p.xz = moda(abs(p.xz), 5.);
  //p.yz = moda(abs(p.yz), 5.);
  float gtr = torus(p, 2., .15);
  g+=.1/(.001+pow(abs(gtr),2.)*3.);
  
  p.xy = moda(abs(p.xy), 5.);
  p.yz = moda(abs(p.yz), 5.);
  gtr = torus(p, 2., .15);
  g+=.1/(.001+pow(abs(gtr),2.)*3.);
  
  float bx=sphere(rep(p, 0.05), 0.0025);
  
  float d=  max(tr,bx)-(.02+.01*sin(t));
  return max(d,-sphere(p+vec3(.0,.8,-2.),1));
}

vec3 norm(vec3 p) {
  vec2 e=vec2(.001,0);
  return normalize(scene(p)-vec3(scene(p-e.xyy),scene(p-e.yxy),scene(p-e.yyx)));
}

float sss(vec3 p, vec3 l, float d) { return smoothstep(0,1,scene(p+l*d)/d); }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv /= 1. - length(uv)*(1+sin(t));
  if(mod(t,8)>6.) {
    uv.x=abs(uv.x);
  }
  if(mod(t,10)>8.) {
    uv.y=abs(uv.y);
  }
  vec3 o=vec3(0,.8,-2.);
  vec3 tg=vec3(0);
  tg+=.75*vec3(sin(t),cos(t),sin(t));
  
  vec3 f=normalize(tg-o);
  vec3 s=normalize(cross(f,vec3(.5+.5*sin(t),1,0)));
  vec3 u=normalize(cross(s,f));
  vec3 dir=normalize(f*(.75+.2*sin(t))+uv.x*s+uv.y*u);
  
	vec3 col=vec3(0);
  vec3 lp=vec3(4);
  
  float d=0.0;
  vec3 p=o;
  int i=0;
  for(i=0; i<200; i++) {
    float h=scene(p)*.3;
    if(abs(h)<0.0001*d) {
      vec3 n=norm(p);
      vec3 ld=normalize(lp-p);
      float diff=max(0.,(dot(n,ld)));
      float fres=pow(max(0., 1-dot(n,-dir)), 2.);
      col += pow(diff, 2.) * fres * acos(-dir);
      
      float a=0.;
      float steps=5.;
      for(float j; j<steps; j++) {
        float ddd = j*.1/steps;
        a += sss(p,ld,ddd);
      }
      a *= 1./steps;
      col += a;
      
      break;
    }
    if(d>100.) {
      break;
    }
    d+=h;
    p=o+dir*d;
  }
  col -= i/800.;
  col += g*.0005*min(vec3(1),.8*acos(dir));
  
	out_color.rgb = col;
}