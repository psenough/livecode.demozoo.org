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


float tt; 

mat2 Rot2(float angle) { return mat2(cos(angle), sin(angle), -sin(angle), cos(angle)); }


float Box(vec3 P, vec3 d)
{
  vec3 q=abs(P)-d;
  return length(max(q,0));
}

float Map(vec3 P)
{
    vec4 low = texture(texFFT, 0);
    vec4 mid = texture(texFFT, 0.05);
    vec4 high = texture(texFFT, 0.08);
  
    vec3 CP = P;
    float s = CP.z*0.1+tt*2;
  
    for(int i=0; i<5; i++)
    {
      CP = abs(CP) - vec3(1,1,1);
      CP.zy *= Rot2(s)+low.r*0.5;
      CP.xy *= Rot2(s*0.1);
      CP.yx *= Rot2(s*0.2+high.r);
    }
       
    float t= Box(CP, vec3(1)+low.r);
    
    return t*0.5;
}
  
float CastRay(vec3 O, vec3 dir)
{
    float t=0;
    for(int i=0; i<64; i++)
    {
      vec3 P=O+t*dir;
      float d=Map(P);
      t+=d;
      if(d<0.01) return t;
      if(t>100) break;
    }

    return -1;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  tt=fGlobalTime;
  
  vec3 Target = vec3(0,0,0);
  vec3 Eye = vec3(20*cos(tt*0.5),20*cos(tt*0.5),20*sin(tt*0.5));
  
  vec3 ww = normalize(Target-Eye);  
  vec3 uu = cross(ww,vec3(0,1,0));
  vec3 vv = cross(uu,ww);
  vec3 dir = normalize(uv.x*uu+uv.y*vv+0.5*ww);
  
  float t=CastRay(Eye,dir);
  vec3 color=vec3(0);
  if(t>0)
  {
      vec3 P=Eye+t*dir;
      vec2 e=vec2(0.01,0);
      vec3 N=normalize(vec3(Map(P+e.xyy)-Map(P+e.xyy),Map(P+e.yxy)-Map(P-e.yxy),Map(P+e.yyx)-Map(P-e.yyx)));
      
      vec3 LightDir1 = vec3(-0.5,0.5,-0.5);
      vec3 LightDir2 = vec3(0.5,0.5,0.5);
      vec3 LightDir3 = vec3(0.01,1,0.01);
    
      vec3 dif1=max(dot(LightDir1,N),0)*vec3(2.4,0,0);
      vec3 dif2=max(dot(LightDir2,N),0)*vec3(0.0,2.5,0);
      vec3 dif3=max(dot(LightDir3,N),0)*vec3(0,0,0.01);
  
      vec3 V = normalize(Eye-P);
      vec3 H1 = normalize(LightDir1+V);
      vec3 H2 = normalize(LightDir2+V);
      vec3 H3 = normalize(LightDir3+V);
    
      vec3 spec1=pow(dot(N,H1),32)*vec3(0.4,0,0);
      vec3 spec2=pow(dot(N,H2),64)*vec3(0.,0.5,0);
      vec3 spec3=pow(dot(N,H3),32)*vec3(0.,0,0.0);
    
      float F0=0.9;
      float fresnel1 = F0+(1-F0)*pow(dot(V,H1),5);
      float fresnel2 = F0+(1-F0)*pow(dot(V,H2),5);
      float fresnel3 = F0+(1-F0)*pow(dot(V,H3),5);
    
      color += fresnel1*spec1 + (1-fresnel1)*dif1;
      color += fresnel2*spec2 + (1-fresnel1)*dif2;
      color += fresnel3*spec3 + (1-fresnel1)*dif3;
     
      color = pow(color, vec3(0.45));
  }
  else
  {
    ivec2 iUV = ivec2(abs(uv)*128);
    float s = mix(float((iUV.x)^(iUV.y) & 255)/255, float((iUV.x)&(iUV.y) & 255)/255, abs(sin(tt)));
    
    vec4 c1 = texture(texFFT, s);
    vec4 c2 = texture(texFFT, s*8);
    
    color = vec3(c1.r,c2.r,0);
  }
  
	out_color = vec4(color,1);
}