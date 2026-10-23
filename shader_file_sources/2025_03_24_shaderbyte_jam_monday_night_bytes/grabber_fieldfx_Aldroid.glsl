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

void setVec3(ivec2 index, vec3 val) {  
  ivec3 quant_val = ivec3((val+100) * 1000);
  
  imageStore(computeTex[0], index, ivec4(quant_val.x)); 
  imageStore(computeTex[1], index, ivec4(quant_val.y)); 
  imageStore(computeTex[2], index, ivec4(quant_val.z)); 
}

vec3 readVec3(ivec2 index){
  return 0.001*(vec3(
    imageLoad(computeTexBack[0],index).x,
    imageLoad(computeTexBack[1],index).x,
    imageLoad(computeTexBack[2],index).x
  ))-100;
}

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.283185*(c*t+d) );
}

vec2 n2(vec2 uv) {
  vec3 p = vec3(234.32*uv.x,345.243*uv.y,324.23*(uv.x+uv.y));
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+43);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float smin(float a, float b, float k) {
  float h = max(0., k-abs(a-b));
  return min(a,b)-h*h*0.25/k;
}

float nst;
float nid = -1;

float ballz = 100;
float map(vec3 p) {
  float res = 1e7;
  for (int i=0;i<ballz; ++i) {
    vec3 br = readVec3(ivec2(i,0));
    float r = length(p-br)-.13;
    
    if (r < res) {
      nid = i;
    }
    
    res = smin(r,res,0.32);
  }
  nst=min(nst,res);
  return res;
}

vec3 field(vec3 loc,int id) {
  return vec3(-abs(loc.x),-1,-abs(loc.z))*0.1;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.1,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.xxy)));
}

void main(void)
{
  if (gl_FragCoord.x < ballz && gl_FragCoord.y < 1) {
    ivec2 index = ivec2(gl_FragCoord.x,0);
    ivec2 indexv = ivec2(gl_FragCoord.x,1);
    vec3 pt = readVec3(index);
    vec3 vel = readVec3(indexv);
    vel = (vel + field(pt,index.x))/2;
    
    float untz =texture(texFFT,0.01).x;
    pt -= vel/(10-untz);
    if (pt.y <-40 || pt.y > 13 ) {
      vec2 nz = n2(vec2(gl_FragCoord.x,fGlobalTime))*3-1.5;
      pt = vec3(nz.x,10+nz.y,nz.y);
    }
    setVec3(index,pt);
    setVec3(indexv,vel);
  }
  
  nst=1e7;
	vec2 ruv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv = ruv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float ucl=floor(ruv.x*10);
  uv.y += sin(texture(texFFTSmoothed,ucl*2.232).x)*30;

  float mvt = texture(texFFTIntegrated,0.2).x/15;
  
  vec3 ro=vec3(3+sin(mvt)*5,11,-5*cos(mvt));//, rd=normalize(vec3(uv,1));
  
  vec3 la=vec3(3,11,5);
  
  vec3 f=normalize(la-ro);
  vec3 r=cross(f,vec3(0,-1,0));
  vec3 u=cross(f,r);
  
  vec3 rd = normalize(f+r*uv.x+u*uv.y);
  
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) {
      break;
    }
    t += d;
    if (t>100) break;
  }
  
  vec3 col = vec3(.05);
  
  vec3 mcal = palette(length(rd.xy)*4/t, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20) );
  
  col = mcal*exp(-nst*nst*nst*10)*1;
  
  float pt1=texture(texFFTIntegrated,0.1).x;
  vec3 ld = normalize(vec3((sin(pt1),0.5,cos(pt1*0.1))));
  
  if (d<0.01) {
    col = clamp(dot(rd,gn(ro+rd*t)),0.5,1.)*mcal;
  }
  
  col = pow(col,vec3(0.45454));
  
  float untz =texture(texFFT,0.01).x;
  vec2 duv = rd.xy/2-.5;
  vec3 cl = texture(texPreviousFrame,duv*1.0+untz*0.1).zyx*(1,0.5,0.5);
  
  col += cl*(0.7+untz);
  col += n2(rd.xy).x*0.1;
  col = 1-col;
  //col = mix(col,vec3(0),pow(length(uv),4));
  
  
  out_color.rgb=col;
}