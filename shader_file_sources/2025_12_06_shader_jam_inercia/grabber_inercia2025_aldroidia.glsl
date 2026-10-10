#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 n2(vec2 uv) {
  vec3 p = vec3(432.23*uv.x,243.432*uv.y,246.23*(uv.x+uv.y));
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vn(vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f *f *(3-2*f);
  
  float a= n2(p + vec2(0,0)).x;
  float b= n2(p + vec2(1,0)).x;
  float c= n2(p + vec2(0,1)).x;
  float d= n2(p + vec2(1,1)).x;
  
  return a +(b -a) * u.x + (c-a) *u.y + (a - b - c + d) *u.x*u.y;
}

float fbm(vec2 uv, int octs) {
  float res=0;
  float a = 0.5;
  
  for (int i=0;i<octs;++i) {
    res += a*vn(uv);
    uv *= 2;
    a *= 0.4;
  }
  return res;
}

float bpos;

// pasted from iq :)
float sdTriPrism( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

int drawPass;

float glo;

vec4 map(vec3 p) {
  float d= p.y +1 + cos(p.x) - fbm(p.xz,2+drawPass*2);
  vec2 uv = p.xz;
  float mat=0;
  
  float lk = p.y+1;
  if (lk <d) {
    d = lk;
    mat = 1;
  }
  float tpos = bpos - clamp(texture(texFFTSmoothed,0.1).x*100,0,8);
  float tr = sdTriPrism(p-vec3(0,0,tpos+10),vec2(1,0.1));
  tr = max(tr,-sdTriPrism(p-vec3(0,0,tpos+9.9),vec2(0.7,1)));
  
  glo += 1/(50+(d*0.01)*48);
  
  if (tr<d) {
    d = tr;
    mat = 2;
  }
  
  return vec4(d,uv,mat);
}

float sky(vec2 uv) {
  float sk = fbm(uv*100,3);
  float rsk = smoothstep(0.6,.65,sk);
  
  return rsk*fbm(uv*91,2);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p).x - vec3 (map(p-e.xyy).x,map(p-e.yxy).x, map(p-e.yyx).x));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  //uv *= 1 - 20*texture(texFFT,0.1).x;
  glo = 0;
  float wt = 2+texture(texFFTIntegrated,0.1).x*5;
  bpos = wt;
  vec3 ro=vec3(0,0,wt),rd=normalize(vec3(uv,1));
  vec4 d;
  float t=0;
  drawPass = 0;
  
  float flect = 0;
  float rft = 0;
  for(int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if(d.x<0.01) {
      if (d.w != 1) break;
      ro = ro+rd*t;
      rd = reflect(rd,gn(ro)+vec3(0,0,0.1*cos(.1*ro.z+fGlobalTime)));
      
      rft = t;
      t = 0.1;
      flect = 1;
    }
    t += d.x;
    if (t > 100) break;
  }
  
  drawPass = 1;
  vec3 bgcol = vec3(sky(uv));
  bgcol = mix(vec3(0),bgcol,smoothstep(0.,0.6,uv.y));
  vec3 col=bgcol;
  
  vec3 mcol = vec3(0.3,.1,.5);
  vec3 fcol = mix(vec3(.1)+mcol*0.1,bgcol,smoothstep(-.1,0.01,uv.y));
  fcol += pow(glo,4)*vec3(1,1,0)*0.9*texture(texFFT,0.1).x;
  
  vec3 ld = normalize(vec3(3,2,1));
  
  float al = .1;
  
  if (d.x<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    
    if (d.w == 0) {
      vec3 gcol = vec3(0.3,.1,0)*0.4;
      gcol=mix(vec3(0.1,0.3,0.04)*0.4,gcol,smoothstep(-1.,-0.4,p.y));
      gcol=mix(gcol,vec3(0.1,0.5,0.04)*0.4,smoothstep(-1.,-0.4,p.y));
      gcol=mix(gcol,vec3(1,1,1)*0.4,smoothstep(.1,1.5,p.y));
      
      col = (al+dot(ld,n))*mcol*gcol;
    } else if (d.w ==2) {
      col = vec3(1,1,0);
    }
  }
  
  col += flect*vec3(0,0.1,0.3)*mcol*0.1;
  
  if (rft > 0) t = rft;
  col = mix(fcol,col,exp(-t*t*t*0.0001));
  col *= 0.8 + 0.2*n2(uv).x;
  col *= smoothstep(1.1,0.4,length(uv));
  col = pow(col,vec3(0.45));
  
  out_color.rgb=col;
}