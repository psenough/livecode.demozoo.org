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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float t=fGlobalTime;
#define T(t,s) texture(t,(s+.5)/textureSize(t,0))
#define no(f) T(texNoise,f).r
vec3 e=vec3(0.,1.,.01);
float hash(float f){return fract(sin(f)*48539.5437);}
float hash(vec2 f){return hash(dot(f, vec2(19.5435,59.4382)));}
#define rep(p,s) (mod(p,s)-(s)*.5)
float no2(vec2 f){vec2 F=floor(f);f-=F;
  return mix(
    mix(hash(F+e.xx),hash(F+e.yx),f.x),
    mix(hash(F+e.xy),hash(F+e.yy),f.x),f.y);
}

float he(vec2 p) {
  return -no(p) * .13 * p.y;
}

float w(vec3 p) {
  float d=p.y;
  d -= he(p.xz);
  
  d -= no(p.xz*100.)*.1;
  //d = min(d, length(p)-1.);
  
  if (p.z < -30. && no(p.xz) > .31)
  {
    d -= no2(p.xz*3.) * 1.4;
    d*=.5;
  }
  
  //d -= 
  
  p.x = rep(p.x, 25.);
  p.z += 0.;
  d = min(d, length(p.xz)-.1);
  
  return d;
}

vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+e.zxx),w(p+e.xzx),w(p+e.xxz)) - w(p));
}

float tr(vec3 O,vec3 D,float l,float L){
  for(float i=0.;i<400.;++i){
    float d=w(O+D*l);l+=d;
    if(d<.001*l||l>L)break;
  }
  return l;
}

vec3 sd=normalize(vec3(-.4,.2,-1.));
vec3 sc=vec3(1.,.7,.5);
vec3 skc(vec3 d) {
  return mix(
    vec3(1.),
    vec3(0.,.34,.72),
    .4+.6*smoothstep(0.,.2,d.y));
}

vec3 sce(vec2 uv){
  vec3 O=vec3(30.*t,1.,5.),D=normalize(vec3(uv,-2.));
  float L=500.,l=tr(O,D,0.,L);
  vec3 c=skc(D);
  if (l<L){ 
    vec3 p=O+D*l,n=wn(p);
    vec3 mc=vec3(.99,.87, 0.);
    float sh=step(20., tr(p+n*.1, sd, 0., 20.));
    vec3 pc = sc*mc*max(0., dot(n,sd))*sh;
    pc += mc * max(0., n.y) * skc(vec3(0.,1.,0.)) * .02;
    c = mix(pc, c, smoothstep(.2, 1., l/L));
  }
  
  c += sc*pow(max(0., dot(D,sd)), 80.);
  
  return c;
}

void main(void) {
  vec2 pix = gl_FragCoord.xy;
  pix.x += hash(pix.x*.3+t)-.5;
  pix.y += hash(pix.x*.1+t*.7)-.5;
  
	vec2 uv = pix / v2Resolution;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  t -= hash(t*.02+.7*uv.x*t+1.2*uv.y)*fFrameTime;
  
  vec3 c=sce(uv);

	out_color = vec4(sqrt(c), 0.);
}