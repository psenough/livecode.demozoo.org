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
float vmax(vec3 p){return max(max(p.x,p.y),p.z);}
float ha(float f){return fract(sin(f)*54783.5438);}
#define box(p,s) vmax(abs(p)-(s))
#define R(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define T(t,s) texture(t,(s)/textureSize(t,0))
#define ffti(f) T(texFFTIntegrated,f).r

float w(vec3 p){
  p.xy*=R(t*1.1);
  p.yz*=R(t*.7);
  return box(p, vec3(.7));
}
vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+vec3(.01,0.,0.)),
    w(p+vec3(.0,.01,0.)),
    w(p+vec3(.0,0.,.01))
  )-w(p));
}

float bg(vec2 uv){
  vec3 O=vec3(1.8*sin(t*.8),.7+.4*sin(t*.6),5.),D=normalize(vec3(uv,-1.)),p;
  O.x += sin(T(texFFTIntegrated,4.).r*.3);
  float l=0.;
  for (float i=0.;i<100.;++i){
    float d=w(p=O+D*l);l+=d;
    if(d<.001){
      return .2+.2*wn(p).y;
      //return max(0., wn(p).y);
    }
  }
  return 0.;
}

float cn(vec2 p){
  return
    texture(texNoise, p).r
    + texture(texNoise, p*2.+t*.01).r;
}

vec2 cno(vec2 p, float dd){
  vec2 d=vec2(0.,dd);
  return vec2(
    cn(p+d.yx)-cn(p-d.yx),
    cn(p+d.xy)-cn(p-d.xy)
  ) / (d.y*2.);
}

void main(void) {
  vec2 res=v2Resolution.xy;
  vec2 ts = gl_FragCoord.xy / v2Resolution.xy;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 C=vec3(0.);
  
  float v=bg(uv);
  
  vec2 fts=floor(ts*200.);
  v*=ha(fts.x*fts.y+floor(t*8.));//*.06;
  v*=.3;
  
  vec2 off = cno(ts/4., .01);
  vec2 ptsd = ts + vec2(0., -2.) / res + off*.0001;
  if (ptsd.y > -0.)
    v += texture(texPreviousFrame, ptsd).a;
  
  if (v<1.||ha(fts.x*fts.y+t) > .99)
    v*=.99;
  
  //v-=.001;
  
  C=vec3(
    smoothstep(.0, .6, v),
    smoothstep(.5, 1., v),
    smoothstep(.9, 1., v)
  );
  
  //C.rg = off;
  
	out_color = vec4(sqrt(C),v);
}