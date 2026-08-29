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

#define rot2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x);
#define pi 3.142
#define eps 0.001
#define t fGlobalTime

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float smin(float a,float b, float k) {
  float c=clamp(.5+.5*(b-a)/k, 0., 1.);
  return mix(b,a,c) - k*c*(1-c);
}

float box(vec3 p, float s, float r) {
  p=abs(p)-s;
  return length(max(p, 0.)) + min(max(p.x,max(p.y,p.z)),0.)-r;
}

vec3 hsl2rgb(vec3 h) {
  vec3 r=clamp(abs(mod(h.x*6.+vec3(0,4,2), 6.) - 3.) - 1., 0., 1.);
  return h.z + h.y * (r-.5) * (1.-abs(2.*h.z - 1.));
}

vec2 df(vec3 p) {
  float a=p.z;
  //rot2d(p.xz,(a+t)/160.);
  //rot2d(p.yz,(a+t*1.15)/160.);
  vec3 q=p;
  vec2 e = vec2(10000,1);
  for (int i=0;i<8;i++) {
    float l=sin(texture(texFFTIntegrated, i/8.)*4.).x;
    l=pow(abs(l),5.)*sign(l)*.25+.5;
    rot2d(p.xy, 1.);
    rot2d(p.xz, 1.);
    e.x = smin(e.x,
    box(p+vec3(
     sin(t+i),
     sin((t*1.153+i)*1.2),
     sin((t*1.2535+i)*1.3)), l/2., .2), .1);
  }
  p=q;
  p.x+=sin(p.z/8.+t)/1.5;
  p.y+=sin(p.z/8.+t*1.24)*1.5;
  vec2 d=vec2(-length(p.xy)+3, 0);
  
  d=d.x<e.x?d:e;
  return d;
}

vec3 norm(vec3 p){
  vec2 e=vec2(eps,0);
  return normalize(vec3(
    df(p+e.xyy).x-df(p-e.xyy).x,
    df(p+e.yxy).x-df(p-e.yxy).x,
    df(p+e.yyx).x-df(p-e.yyx).x
  ));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 p=vec3(0,0,-4);
  vec3 dir=normalize(vec3(uv, 1));
  vec3 o=vec3(dir);
  
  vec2 d;
  vec3 bc=vec3(1);
  
  for (int i=0;i<100;i++) {
    d=df(p);
    if(d.x<eps) {
      if (d.y==0) {
        break;
      } else {
        vec3 n=norm(p);
        dir=reflect(dir,n);
        p+=n*eps*2;
        bc*=sin(p*2. + sin(p*4.73+2.54+t)+t)*.5+.5;
      }
    }
    p += dir*d.x;
  }
  if (d.y==0) {
    float z=p.z/4.+t*3.;
    float pulse = texture(texFFTSmoothed,0.01).x;
    o=hsl2rgb(vec3(
      z+t,1.,
      step(.5,fract(z*.25))*(pulse*10.)*.5+.5
    )) * step(.5,fract(z*.5)) * bc - max(0.,p.z/100.);
    //o=vec3(step(0.5,fract(p.z*.5+t)));
  } else { o=vec3(1); }
  
	out_color = vec4(o,1);
}