#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

int nB = 1;

float map(vec3 p, out int mat, out vec3 uvw) {
  vec3 cq = abs(p)-16.;
  float ib = max(cq.x,max(cq.y,cq.z));
  mat = 1;
  ib = - ib;
  
  float res = ib;
  
  float t = fGlobalTime*2;
  
  float cir = 1e7;
  
  for (int i=0; i<nB; ++i) {
    vec3 bbq = p - readVec3(ivec2(i,0));
    cir = min(cir,length(bbq)-1);
  }
  
  if (cir < res) {
    res = cir;
    mat = 2;
  }
  
  return res;
}

vec3 gn (vec3 p) {
  vec2 e= vec2(0.01,0);
  int i1;
  vec3 i2;
  return normalize(map(p,i1,i2) - vec3(map(p-e.xyy,i1,i2), map(p-e.yxy,i1,i2),map(p-e.yyx,i1,i2)));
}


void main(void)
{
  if (gl_FragCoord.x < nB && gl_FragCoord.y < 1) {
    ivec2 idx = ivec2(gl_FragCoord.x,0);
    ivec2 idxv = ivec2(gl_FragCoord.x,1);
    vec3 pt = readVec3(idx);
    vec3 vl = readVec3(idxv);
    vl.y += 0.01;
    pt += vl;
    if (pt.y> 16) {
      
      vl.y = -vl.y;
      vl.x += sin(fGlobalTime)*0.1;
      vl.z += sin(texture(texFFT,0.1).x)*0.1;
    }
    
    if (abs(pt.x)>16) {
      vl.x = - vl.x;
    }
    if (abs(pt.z)>16) {
      vl.z = - vl.z;
    }
    setVec3(idx,pt);
    setVec3(idxv,vl);
  }
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float rt=texture(texFFTIntegrated,0.05).x;
  vec3 ro = vec3(10*sin(rt),cos(rt*0.8)*3,-10*cos(rt));
  
  vec3 la = readVec3(ivec2(0,0));
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(f + r*uv.x + u*uv.y);
  
  float t=0,d;
  int mat;
  vec3 uvw;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t, mat, uvw);
    if (d<0.01) break;
    t += d;
    if (d>100) break;
  }

  vec3 col= vec3(0);
  
  vec3 p = ro+rd*t;
  vec3 lo = vec3(2,2*sin(fGlobalTime),8);
  vec3 ld = normalize(lo-p);
  float li = length(p-lo);
  
  if (d <0.01) {
    vec3 n = gn(p);
    col = vec3(1);
    if (mat == 2) {
      col = vec3(plas(uvw.xy*100,fGlobalTime));
    }
    col *= dot(ld,n);
  }
  out_color.rgb = col;
}