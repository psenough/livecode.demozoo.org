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
// =^^=

#define t fGlobalTime
#define r2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x);
#define pi 3.142
#define eps 0.01
#define min2(a,b) a.x<b.x?a:b

vec3 hash(vec3 p) {
  p=fract(p*vec3(224.5648789,350.367,474.3657));
  p+=dot(p,p+19.19);
  return fract((p.xxy+p.yxx)*p.zyx);
}

float boxdist(vec3 p, vec3 o, vec3 s, float r) {
  p -= o;
  p=abs(p)-s;
  return length(max(p, 0.)) + min(0., max(p.x,max(p.y,p.z)));
}

vec2 df(vec3 p) {
  vec3 q=p;
  vec2 d=vec2(abs(p.y),0);
  vec3 cell = hash(floor(p.xzz));
  p.xz=fract(p.xz*2.)/2.-.25;
  p.y-=.1;
  cell.x=texture(texFFTSmoothed,0.1).x*20.;
  vec2 e=vec2(boxdist(p, vec3(0), vec3(.05,cell.x/8.+.2,.05),.1),1);
  d=min2(d,e);
  //e=vec2((length(p+vec3(.2,-abs(sin(t*4.)/8.),0))-..5)/2.,1);
  //d=min2(d,e);
  return d;
}

vec3 norm(vec3 p) {
  vec2 e=vec2(eps,0);
  return normalize(vec3(
    df(p+e.xyy).x-df(p-e.xyy).x,
    df(p+e.yxy).x-df(p-e.yxy).x,
    df(p+e.yyx).x-df(p-e.yyx).x
  ));
}

vec3 ld = normalize(vec3(1,1,0));

float light(vec3 n) {
  n=abs(n);
  return min(1,(1-max(
    dot(n,vec3(1,0,0)),
    max(
      dot(n,vec3(0,1,0)),
      dot(n,vec3(0,0,1))
     )))*3.);
}

vec3 rm(vec3 p, vec3 dir) {
  for (int i=0;i<50;i++) {
    vec2 d=df(p);
    if (d.x<eps) {
      if (d.y==0) {
        //p.x = atan(p.xz).y;
        return vec3(0,1,0)*texture(texFFTSmoothed,p.x).x*100.;
        //hash(floor(p*80.)).x;
        p.xz=abs(fract(p.xz*4.)-.5);
        return vec3(1-smoothstep(0.,0.03,min(p.x,p.z)));
      }
      vec3 n=norm(p);
      
      float l=max(0.,dot(n,ld));
      return vec3(l);
    }
    p+=dir*d.x;
    
  }
  return vec3(0);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv -=.2;


  vec3 p=vec3(uv,0);
  vec3 d=vec3(0,0,1);
  r2d(p.yz,pi/6);
  r2d(d.yz,pi/6);
  r2d(p.xz,pi/6+t/4);
  r2d(d.xz,pi/6+t/4);
  p.y+=1;
  p.z+=t/2;
  vec3 o=rm(p,d);
  
	out_color = vec4(o,1);
}