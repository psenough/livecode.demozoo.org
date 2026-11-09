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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define INF (1./0.)
#define time fGlobalTime
#define rep(p,s) (mod(p,s)-s/2.)
#define rep2(p,s) (abs(rep(p,2.*s))-s/2.)
#define PI 3.14159265

float hash(float x) {return fract(sin(x)*3458.2551);}
float hash(vec3 x) {return hash(dot(x, vec3(34.67546,65.34135,23.4567457)));}

float ffti(float t) {return texture(texFFTIntegrated, t).x;}
float ffts(float t) {return texture(texFFTSmoothed, t).x;}
vec4 back(vec2 uv) {return texture(texPreviousFrame, uv);}

vec2 polar(vec2 p, float n) {
  p = vec2(length(p), atan(p.y,p.x));
  p.y = rep2(p.y, 2.*PI/n);
  return p.x*vec2(cos(p.y),sin(p.y));
}

mat2 mr(float t) {float c=cos(t),s=sin(t); return mat2(c,s,-s,c);}

float box(vec3 p, vec3 s) {
  p = abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

vec3 ct(vec3 p) {
  if(p.x<p.y)p.xy=p.yx;
  if(p.y<p.z)p.yz=p.zy;
  if(p.x<p.y)p.xy=p.yx;
  return p;
}

float maxx(vec3 p) {return max(p.x, max(p.y,p.z));}

vec3 glow=vec3(0.);

float map(vec3 p, float t) {
  p.z += .6*t + .6*ffti(.1);
  vec3 op=p;
  float m=INF;
  
  p.xy=polar(p.xy, 7.);
  float bound = p.x-.2;
  
  vec3 s = vec3(1.2);
  for(float i=0.;i<3.;++i) {
    p.x += (.1*time + .3*op.z) * exp2(-i);
    p = rep2(p, s);
    
    s *= .65;
    s.xy *= mr(.17);
    s = s.zxy;
    if(i==1.) p.xy *= mr(PI/4.);
    
    p = ct(abs(p));
    float boxs=maxx(s)/(i==0.?10.:100.);
    float m1=box(p, vec3(boxs, boxs, INF).zxy);
    float gpow=pow(sin(length(10.*op.xy)+op.z+5.*t)*.5+.5, 4.);
    vec3 gcol=vec3(1.4,1.,1.);
    gcol.xz *= mr(.4*op.z);
    gcol=abs(gcol);
    glow += gpow * .001*gcol / (m1+mix(.03,.05, hash(p+time)));
    m = min(m, m1);
  }
  m= max(m,-bound);
  
  return m;
}

vec3 norm(vec3 p) {
  vec2 E=vec2(.001,.0);
  return normalize(vec3(
    map(p+E.xyy,time),map(p+E.yxy,time),map(p+E.yyx,time)
  )-map(p,time));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 c=vec3(0.);  
  vec3 O=vec3(0.,0.,-1.), D = vec3(uv,1.);
  D.z = (1.+.6*length(D.xy));
  D = normalize(D);
  D.xz *=mr(.15*sin(.2*time));
  D.yz *=mr(.15*sin(.22*time));
  float d = 0.;
  bool hit = false;
  for(float i=0.;i<64.;++i) {
    vec3 p=O+D*d;
    float m=map(p,time + .1*hash(vec3(uv, time)));
    d += m;
    if(m<.001*d) {
      hit = true;
      break;
    }
  }
  c += min(vec3(5.),glow)* exp(-d*.1);
  
  uv = gl_FragCoord.xy / v2Resolution.xy;
  if(hit) {
    vec3 p=O+D*d;
    vec3 n=norm(p);
    float e=.03;
    vec2 off=n.xy*.4;
    vec3 prev=vec3(
      back(uv+off*(1+e)).r,
      back(uv+off).g,
      back(uv+off*(1-e)).b
    );
    c += prev.rgb * mix(.5,1.,min(1.,8.*ffts(.12)));
  } else {
    c = mix(c, back(uv).rgb, .8);
  }

	out_color = vec4(c, 1.);
}