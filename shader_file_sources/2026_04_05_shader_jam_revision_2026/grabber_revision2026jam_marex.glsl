#version 420 core

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float ti = fGlobalTime;
float n1,n2;

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

float mc(float z,float m1,float m2,float time){return clamp(cos(z*m1*ti*time)*m2,-.25,.25)*2.+.5;}

float sdf(vec3 p)
{
  float f = texture( texFFTSmoothed, 1. ).r * 100;
  
  vec3 p2 = p;
  
  p.xz *=R2D(ti/2);
  p.xy *=R2D(ti/2);
  p.yz *=R2D(ti/2);
  
  p = abs(p)-2.;
  
  float sp = length(max(abs(abs(p)-1.4)-.5*f,0.));
    
  p = p2;
  
  p.xz *=R2D(ti);
  p.yz *=R2D(ti);
  p.xy *=R2D(ti);

  
  p = p2;
  
  p.xy *= R2D(ti);
  
  for(float i = 0.;i++<6.;)
  {
    p = abs(p)-1.;
    float ck = length(p.xz)-1.;
    
  }
  
  float ci = length(vec2(length(p.xz)-3.*f,p.y))-.3;
  
  p.xy *=R2D(ti);
  p.yz *=R2D(ti);
  p.xz *=R2D(ti);

  float ci2 = length(vec2(length(p.xy)-4.*f,p.z))-.3;
  
  p.xy *=R2D(ti);
  p.xz *=R2D(ti);
  p.yz *=R2D(ti);

  float ci3 = length(vec2(length(p.zy)-6.,p.x))-.3;
  
  p = p2;
  
  float ch = min(min(length(p.xz)-.3*f,length(p.xy)-.3*f),length(p.zy)-.3*f);
  
  ci = min(min(ci,ci3),ci2);
  
  sp = min(min(sp,ch),ci);
  
  #define nn(s) .1/(s*s*40.+.1)
  n1 += nn(sp);
  
  return sp;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 uv2=uv;
  
  float bz = mc(ti,.4,.5,.001);
  
  vec3 col = vec3(0.);
  vec3 ro = mix(vec3(20.,0.,20.),vec3(20,sin(ti*2.+.2)*5.,20.),bz);
  ro.zy = mix(ro.xz*R2D(ti*3.),vec2(1.),bz);
  ro.xz *= R2D(ti/2.);
  uv *= R2D(ti/2.);
  vec3 fr = normalize(vec3(0.)-ro);
  vec3 ri = normalize(cross(fr,vec3(0.,1.,0.)));
  vec3 up = normalize(cross(ri,fr));
  
  vec3 rd = normalize(ri*uv.x+up*uv.y+fr*.6);
  
  float t = 0.;
  
  for(float i = 0.;i++<64.;)
  {
    float d= sdf(ro+rd*t);
    if(d<.001||t>200.)break;
    t+=d;
  }
  vec3 p = ro+rd*t;
  
  float m = length(p)*.1;
  
	float f = texture( texFFT, m ).r * 100;

  col += vec3(1.,.5,0.)*t*.01;
  
  float pat = ceil(-sin(uv2.y*4.5-(3.141592/2.)));
  
	out_color =mix(vec4(col*2.*n1*.1*f+col*.5,0.)/pat,texture(texPreviousFrame,(gl_FragCoord.xy / v2Resolution.xy)),.5);
}