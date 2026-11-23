#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

// hello aldroid here!

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

vec2 n2(vec2 uv) {
  vec3 p = vec3(234.23*uv.x,342.32*uv.y,243.54*(uv.x+uv.y));
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float nv(vec2 uv) {
  
  vec2 p= floor(uv);
  vec2 f = fract(uv);
  vec2 u = f*f*(3-2*f);
  
  float a=n2(p+vec2(0,0)).x;
  float b=n2(p+vec2(1,0)).x;
  float c=n2(p+vec2(0,1)).x;
  float d=n2(p+vec2(1,1)).x;
  
  return a + (b-a)*u.x + (c-a)*u.y + (a - b - c+d)*u.x*u.y;

}

float fbm(vec2 uv) {
  float res=0;
  float a = 0.5;
  for (int i=0;i<4;++i) {
    res += a* nv(uv);
    uv *= 2;
    a *= 0.4;
  }
  return res;
}

int maxSnoo = 50;

float smin(float a, float b, float k) {
  float h = max(k-abs(a-b),0.0);
  return min(a,b)-h*h*0.25/k;
}

float map(vec3 p) {
  p = mod(p+20,40)-20;
  
  float res = 1e7;
  for (int i=0;i<maxSnoo;++i) {
    res = smin(res,length(p-readVec3(ivec2(i,0)))-(.8+texture(texFFTSmoothed,i*10/maxSnoo).x*22),0.9);
  }
  vec3 q = p;
  q.y = mod(q.y,1)-.5;
  res = max(-abs(q.y)+0.3,res);
  return res;
}

vec3 field(vec3 p, float i) {
  vec3 res=vec3(0,1+i/maxSnoo,0);
  res.y *= 0.1+abs(sin(p.y));
  res.z += sin(texture(texFFT,0.1).x)*100;
  res.xz *= 1+cos(p.y);
  return res;
} 

vec3 gn(vec3 p) {
  vec2 e = vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
  if (gl_FragCoord.x < maxSnoo && gl_FragCoord.y < 1) {
    ivec2 index = ivec2(gl_FragCoord.x,0);
    ivec2 indexv = ivec2(gl_FragCoord.x,1);
    vec3 pt = readVec3(index);
    vec3 vel = readVec3(indexv);
    vel = (vel + field(pt,index.x))/2;
    pt -= vel/10;
    if (pt.y <-10 || pt.y > 100) {
      vec2 nz = n2(vec2(gl_FragCoord.x,fGlobalTime))*3-1.5;
      pt = vec3(nz.x,10+nz.y,nz.y);
    }
    setVec3(index,pt);
    setVec3(indexv,vel);
  }
  
  
  
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float ram = sin(texture(texFFTIntegrated,0.1).x);
  vec3 ro=vec3(cos(ram)*10,sin(fGlobalTime),sin(ram)*10);
  vec3 la=readVec3(ivec2(0,0));
  
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,-1,0));
  vec3 u = cross(f,r);
  
  vec3 rd = normalize(f+r*uv.x+u*uv.y);
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01)break;
    t += d;
    if (t>100) break;
  }
  
  vec3 ld = normalize(vec3(1,1,1));
  
  vec3 bgcol= mix(vec3(1),vec3(0.6,0.7,1),fbm(rd.xy*10))*vec3(0.2,0.3,0.9);
  vec3 col = bgcol;
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    col = vec3(0.99,0.89,0.8)*dot(n,ld);
    col += pow(max(dot(reflect(-ld,n),-rd),0),10);
  }
  
  col = mix(bgcol,col,exp(-t*t*t*0.00001));
  
  col*=clamp(1-length(uv),0,1);
  
  col = pow(col,vec3(0.4545));
  
  
  out_color.rgb=col;
}