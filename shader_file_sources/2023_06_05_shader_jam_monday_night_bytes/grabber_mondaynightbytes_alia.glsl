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
#define time fGlobalTime

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float eps = 0.001;

vec3 bkg(vec3 d) {
  return mix(
    vec3(1,.9,.9),
    vec3(.2,.15,1),
    pow(abs(d.y), 1.2)
  );
}

vec2 df(vec3 p) {
  vec3 q=p;
  vec2 e=vec2(length(p-vec3(7,10,-5))-2, 1);
  
  p.x=0;
  p.y+=sin(q.x-texture(texFFTIntegrated,0.).x*2.+sin(q.x*.75+texture(texFFTIntegrated,.5).x*10.))/2.;
  p.y+=sin(q.x*1.5+texture(texFFTIntegrated,0.).x*1.5+sin(q.x*1.333-texture(texFFTIntegrated,.5).x*15.))/2.;
  vec2 d=vec2(
   (length(p)-(.5+texture(texFFTSmoothed, 0.0).x*1.)+sin(q.x+time+sin(q.x*.375+time*1.473))*.4)*.7, 0);
  d=d.x<e.x?d:e;
  p=q;
  q.y=0.;
  float stepping=sign(mod(q.x+time,6.)-3.);
  q.z+=2.*stepping;
  //p.y+=texture(texFFTIntegrated, 0.0).x*stepping;
  float timer=texture(texFFTIntegrated, 0.0).x*stepping;
  q.x=mod(q.x+time,3.)-1.5;
  q.x+=sin(p.y*2.-timer*4.)/2.;
  q.z+=cos(p.y*2.-timer*4.)/2.;
  e=vec2(
   //abs(length(q)-1.)
   (length(q)-.5)*.5,2.);
  d=d.x<e.x?d:e;
  
  return d;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(eps,0.);
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

  vec3 p=vec3(0,0,-5+(sin(uv.x*10482.55)+sin(uv.y*1385.537))*length(uv)*texture(texFFTSmoothed,0.05)*3.3);
  vec3 d=normalize(vec3(uv*2.,1));
  
  vec3 o=vec3(0);
  vec3 l=vec3(1);
  bool hit=false;
  float ior = 1./1.5;
  for (int i=0; i<70; i++) {
    vec2 dist=df(p);
    if (abs(dist.x)<eps) {
      vec3 n=norm(p);
      if (dist.y==0) {
        d=reflect(d,n);
        p+=n*dist.x*8.0;
        o+=vec3(1,0,0);
        l*=0.5;
      } else if(dist.y==1) {
        o+=1.;
        hit=true;
        break;
      } else if(dist.y==2) {
        d=reflect(d,n);
        p+=n*dist.x*8.0;
        o+=vec3(.1);
        l*=0.5;
      } else {
        o = n;
        break;
      }
    }
    
    p+=d*abs(dist.x)*.7;
  }
  
  if (!hit) { o+=bkg(d)*l; }
  
	//float f = texture( texFFT, d ).r * 100;
	out_color = vec4(o,1);
}