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

#define time fGlobalTime
#define pi 3.142
#define eps 0.01

#define r2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x)

float boxDist(vec3 p, vec3 o, vec3 s, float r) {
  p -= o;
  p=abs(p)-s;
  return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.) - r;
}

vec3 hash(vec3 p) {
  p=fract(p*vec3(424.276, 413.426, 523.24));
  p += dot(p, p.yzx+19.19);
  return fract((p.xxy+p.yxx)*p.zyx);
}

vec2 df(vec3 p) {
  vec3 q=p;
  q=abs(mod(p, 2.)-1.);
  vec3 c=floor(p/2.);
  r2d(q.xy,c.x+time);//*texture(texFFTIntegrated, c.x));
  r2d(q.xz,c.x+time);
  
  float d=boxDist(q, vec3(0), vec3(.5), 0.),
  e=length(q)-.3;
  //d=e;
  d=int(c.x+c.y+c.z)%4 > 0 ? d: e;
  //d=min(d,e);
  return vec2(d, d==e?1.:0.);
}

vec3 norm(vec3 p) {
  vec2 e=vec2(eps, 0.);
  return normalize(vec3(
    df(p+e.xyy).x - df(p-e.xyy).x,
    df(p+e.yxy).x - df(p-e.yxy).x,
    df(p+e.yyx).x - df(p-e.yyx).x
  ));
}
void main(void)
{
  vec2 uvb=gl_FragCoord.xy / v2Resolution;
  uvb.y=abs(uvb.y*2.-1.);

	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv *= 2.;
  uv = abs(uv);
  vec3 o=vec3(0);
  
  for(int c=0; c<3; c++) {
    bool ins=false;
    vec3 d=normalize(vec3(uv,1));
    vec3 p=vec3(0,0,+time);
    
    for(int i=0;i<100;i++) {
      vec2 dist=df(p);
      if(abs(dist.x)<eps) {
        if (dist.y==1.) {
//          float d=texture(texFFTSmoothed, abs(p.x)/20.).x - abs(p.y)/10.;
  //        d=texture(texFFTSmoothed, abs(uvb.x-.5)).x - uvb.y/3.;
    //      o[c]+= smoothstep(0., 1., fract(abs(d)*10.)*10.);
      //    o[c]*= smoothstep(0., .1, fract(abs(uvb.x*8.-4.)+abs(uvb.y*6.)-time));
          o[c] += hash(floor(p/2.))[c] * .5 + .5;
          break;
          
        } else {
          vec3 n=norm(p) * (ins?-1.:1.);
          float ior = 1.5 + float(c + hash(p).x)/10.;
        
          vec3 td=refract(d,n,ins?1./ior : ior);
          if(any(isnan(td))) {
            d=reflect(d,n);
            p += n*abs(dist.x)*2.;
          } else {
            d = td;
            p -= n*abs(dist.x)*8.;
            ins = !ins;
          }
        }
      }
    
      p+=abs(dist.x)*d*.9;
    }
  }
	out_color = vec4(o,1.);
}