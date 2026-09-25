#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float n1,n2,ti = fGlobalTime,n3;

float mc(float z,float m1,float m2,float time){return clamp(cos(z*m1+ti*time)*m2,-.25,.25)*2.+.5;}

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

float sdf(vec3 p)
{
  vec3 p3 = p;
  
  p.z = mod(p.z+ti*3.,20.)-10.;
  
  vec3 p4 = p;
  
  float sp = length(max(abs(p)-1.,0.))-.1;
  
  p.xy *= R2D(ti/2.);
  
  p = abs(p)-3.;
  p.xy *=R2D(.3);
  p.yz *=R2D(.3);
  
  float cu = length(vec2(length(p4.xy)-8.,p4.z))-.1;
  
  p4.xy *= R2D(.785);
  
  float ck = min(length(p4.xz)-.2,length(p4.yz)-.2);
  
  float co = length(p.xy)-.2;
  
  p3 = mod(p3+vec3(ti,ti,ti*11),4.)-2.;
  
  float cy = length(p3)-.5;
  
  float cl = length(p.xz)-.2;
  
  float cz = dot(p,vec3(0.,1.,0.));
  
  sp = min(min(min(min(sp,ck),cl),cu),co);
  
  #define nn(s) .1/(s*s*40.+.1)
  n1 += nn(sp);
  n2 += nn(cy);
  n3 += nn(cz);
  
  return sp;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec2 uv2=uv;
  
  float tex = texture(texFFT,1.).r*100.;
  
  float bz = mc(ti,.4,.5,.01);
  
  vec3 ro = mix(vec3(sin(ti)*150.,50.,cos(ti)*150.),vec3(0.,10.,20.),bz);
  ro.xy = mix(ro.xy,ro.xy*R2D(ti/2.),bz);
  vec3 fr = normalize(vec3(0.)-ro);
  vec3 ri = normalize(cross(fr,vec3(0.,1.,0.)));
  vec3 up = normalize(cross(ri,fr));
  vec3 rd = normalize(ri*uv.x+up*uv.y+mix(fr*6.+(tex/1000.),fr,bz));
  
  float t = 0.;
  
  for(float i =0.;i++<64.;)
  {
    float d = sdf(ro+rd*t);
    if(d<.001||t>500.)break;
    t+=d;
    
  }
  
  vec3 p = ro+rd*t;
  p.z = mod(p.z+ti*3.,20.)-10.;
  
  float m = length(p)*.2;
  
	float f = texture( texFFT, m ).r * 100;

  float pat = ceil(-sin(uv2.y*4.5-3.141592/2.));
  
	out_color =vec4(vec3(0.,n3*.4+n2*.3+f*n1*.1,0.)*pat,0.)/pat;
}