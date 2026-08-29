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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float tt,fft;

mat2 Rot2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}

float Box(vec3 P, vec3 d)
{
  vec3 q=abs(P)-d;
  return length(max(q,0));
}

float Map(vec3 P)
{
  float s=5;
  
  vec3 RP=P;
  vec3 id = round(RP/s);
  vec2  o = sign(RP.xz-s*id.xz); // neighbor offset direction
  
  float t=1e20;
  
  vec3 RRP=RP;
  for( int j=0; j<2; j++ )
  for( int i=0; i<2; i++ )
  {
    vec2 rid = id.xz + vec2(i,j)*o;
    RRP.xz = RP.xz-rid*s;
    
    t = min(t, Box(RRP-vec3(0,-5+2.5*sin(tt*4.5+rid.x)*sin(rid.x*17+rid.y*53),0), vec3(2.2)));
  }
  
  vec3 FP=P-vec3(0,8,0);
  float fs=FP.z*0.2+tt*4+0.5;
  for(int i=0;i<5;i++)
  {
    FP=abs(FP)-vec3(1,0,1);
    FP.xy*=Rot2(fs*0.01);
    FP.xz*=Rot2(fs*0.02);
    FP.yx*=Rot2(fs*0.09);
  }
  
    t=min(t,Box(FP,vec3(1)));
    
  return t;
}

  
float CastRay(vec3 Eye, vec3 dir)
{
  float t=0;
  for(int i=0;i<128;i++)
  {
    vec3 P=Eye+t*dir;
    float d=Map(P);
    t+=d;
    if(d<0.001) return t;
    if(t>100) break;    
    } 
return 0;    
  }
  
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  tt = mod(fGlobalTime,10000);
  
 fft=texture(texFFT,uv.x).r;  
  
  vec3 Target=vec3(0,9-4*sin(tt*0.5),0);
  vec3 Eye=vec3(15*cos(tt*0.3)+3*abs(sin(tt)),9-4*sin(tt),15*sin(tt*0.5)+3*abs(sin(tt)));
  vec3 ww = normalize(Target-Eye);
  vec3 uu = cross(ww,vec3(0,1,0));
  vec3 vv = cross(uu,ww)+(0.1*sin(tt));
  vec3 dir = normalize(uv.x*uu+uv.y*vv+(0.5+0.3*sin(tt))*ww);
  
  float t = CastRay(Eye,dir);
  vec3 P=Eye+t*dir;
  vec2 e=vec2(0.01,0);
  vec3 N=normalize(vec3(Map(P+e.xyy)-Map(P-e.xyy),Map(P+e.yxy)-Map(P-e.yxy),Map(P+e.yyx)-Map(P-e.yyx)));
	
  vec3 color=vec3(0);
  if(t>0)
  {
    vec3 V=normalize(Eye-P);
    
    float F0=0.17;
    vec3 Light1=vec3(0.5,0.5,0.5);
    vec3 dif1=max(dot(Light1,N),0)*vec3(1.2*sin(tt),0.18,0.19);
    vec3 H1=normalize(V+Light1);
    vec3 spec1=pow(dot(N,H1),64)*vec3(1.2,0.18,0.19+0.3*abs(sin(tt)));
    float fresnel1=F0+(1-F0)*pow(dot(V,H1),5);
    
    vec3 Light2=vec3(-0.5,0.2,-0.5);
    vec3 dif2=max(dot(Light2,N),0)*vec3(0.2,0.18,0.8);
    vec3 H2=normalize(V+Light2);
    vec3 spec2=pow(dot(N,H2),32)*vec3(0.2,0.18,0.8);
    
    color =dif1*(1-fresnel1)+spec1*fresnel1+dif2+spec2;
  }
  else
    {
      color= vec3(1-1.2*cos(tt*0.1+3.2), sin(tt),sin(tt*0.3)*0.18+0.19);
    }
    
	out_color = vec4(pow(color,vec3(0.45)),1);
}