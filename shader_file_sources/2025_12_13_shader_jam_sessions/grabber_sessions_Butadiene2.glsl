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
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

#define time fGlobalTime

float noise(vec3 p){
  p*= 3.;
  vec3 s = vec3(7,157,113);
  vec3 ip = floor(p);
  vec4 h = vec4(0,s.yz,s.y+s.z)+dot(ip,s);
  p -= ip;
  p = smoothstep(0,1,p);
  h = mix(fract(sin(mod(h,3.141592*2.)*43756.98742)),fract(sin(mod(h+s.x,3.141592*2.)*43756.98742)),p.x);
  h.xy = mix(h.xz,h.yw,p.y);
  return mix(h.x,h.y,p.z);
  }

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2 rot(float r){
  
  return mat2(cos(r),sin(r),-sin(r),cos(r));
  }
vec4 dist(vec3 p, float itex){
  float f = 0.;
  
  if(sin(time*60./148.*3.141592*0.5)>0.2){
  for(int i = 0;i<2;i++){
      p = abs(p)-0.5;
      p.xz *= rot(0.1);
    }
  }
  
  vec3 ssp = p;
  vec3 sssp = p;
  
  ssp.z += time;
  ssp.xy *= rot(ssp.z+time);
  float k = 1.8;
  ssp.xy = mod(ssp.xy,k)-0.5*k;
  float dii = length(ssp.xy)-0.2;
  
  vec3 sp = p;
  float scale = 0.5;
  for(int i = 0;i<3;i++){
    sp -= vec3(0,0.1*time,0.);
    f += scale*noise(sp+vec3(0.,10.*f,0.));
    scale *= 0.5;
    sp *= 2.0;
    }
  vec3 col = vec3(0.0);
  float dist = -dii+f;
    float ssn = pow(abs(sin(p.z*3.+2.*itex)),4.);
    col = mix(vec3(0.8,0.8*ssn,0.8*ssn),vec3(0.2),dist);
    p = sssp;
    float kn = 1.0;
    p = mod(p,kn)-0.5*kn;
    float d = length(p)-0.3;
    if(d<dist){
        col = mix(vec3(0.8,0.4,0.2)*2.,vec3(0.2),dist);      
      }
      
      col = clamp(col,vec3(0.),vec3(1));
      if(sin(60./148.*time*6.28*2.)>0.)col = col.gbr;
      col *= 1.4+0.3*pow(abs(sin(60./148.*time*6.28*8.)),4.);
  return vec4(col,dist);
  
  }


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv.y += 0.01*floor(sin(uv.y*5000.)*10.)/10.;
  vec2 uv_tex = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 p = uv;
  float itex = texture(texFFTIntegrated,0.).r;

  p*= rot(itex*0.1);
  
  vec3 tar = vec3(0.);
  if(sin(60./148.*time*6.28*1.)>0.)tar -= vec3(0,3,0);
  vec3 cpos = vec3(0,0,1);
  vec3 cdir = normalize(tar-cpos);
  vec3 side = cross(cdir, vec3(0,1,0));
  vec3 up = cross(side,cdir);
  
  vec3 rd = normalize(side*p.x+up*p.y+cdir*0.2);
  float t =0.;
  
  vec4 col = vec4(0.);
  for(int i = 0;i<66;i++){
    vec4 rsd = dist(cpos+rd*t,itex);
    if(rsd.w>0.){
      rsd.w = min(rsd.w,1.);
      rsd.xyz *= rsd.w;
      col += (1.-col.w)*rsd;
       if(col.w>1.)break;
      }
    t +=0.05;
    
    }
    
    col += exp(-2.0*t);
    
    float is = texture(texFFTSmoothed,0.5).r;
    float ik = is+0.1;
    
    float bcolr = texture(texPreviousFrame,(uv_tex-0.5)*(1.+ik)+0.5).r;
    float bcolg = texture(texPreviousFrame,(uv_tex-0.5)*1.+0.5).g;
    float bcolb = texture(texPreviousFrame,(uv_tex-0.5)*(1.-ik)+0.5).b;
    
    col.xyz = mix(col.xyz,vec3(bcolr,bcolg,bcolb),0.6);

	out_color = vec4(col.xyz,0.);
}