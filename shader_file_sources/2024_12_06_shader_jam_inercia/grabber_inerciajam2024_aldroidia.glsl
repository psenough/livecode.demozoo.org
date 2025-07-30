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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

vec2 n2(vec2 uv) {
  vec3 p = vec3(uv.x*234.234,uv.y*433.23,(uv.x+uv.y)*231.34);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float nv(vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f*f*(3-2*f);
  float a = n2(p+vec2(0,0)).x;
  float b = n2(p+vec2(1,0)).x;
  float c = n2(p+vec2(0,1)).x;
  float d = n2(p+vec2(1,1)).x;
  return a + (b-a)*u.x + (c-a)*u.y + (a - b - c + d) *u.x*u.y;
}

float fbm(vec2 uv) {
  float res = 0;
  float a = 0.5;
  
  for (int i=0;i<4;++i) {
    res += nv(uv);
    uv *= 2;
    a *= 0.4;
  }
  return res;
}

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

float PI = atan(1)*4;

float map(vec3 p, out float mat) {
  //p *= 1+-texture(texFFT,0.1).x*0.1;
  
  float res = 1e7;
  
  vec3 q = p;
  q.y += PI/2;
  
  float grd = dot(sin(q),cos(q.zxy))+p.y+fbm(p.xy)*0.1;
  res = grd;
  mat = 0;
  
  q=p;
  q.xy *= rot(sin(fGlobalTime)*0.1);
  q.y += sin(fGlobalTime)*0.05;
  q=abs(q-vec3(0,0,fGlobalTime+1))-.11;
  q.xy *= rot(5.1);
  //q.yz *= rot(0..);
  
  float cb = max(q.x,max(q.y,q.z));
  
  if (cb < res) {
    res=cb;
    mat =1 ;
  }
  
  return res;
  //return length(p)-1;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.1,0);
  float ig;
  return normalize(map(p,ig)- vec3(map(p-e.xyy,ig),map(p-e.yxy,ig),map(p-e.yyx,ig)));
}

float shad(vec3 p, vec3 ld) {
  float res,d,t=0.1;
  float ig;
  res = 1e7;
  for (int i=0;i<120;++i) {
    d = map(p+ld*t,ig);
    if (d<0.01) return 0;
    res = min(res, 8*d/t);
    t += d;
  }
  return res;
}

void main(void)
{
	vec2 muv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	muv = muv - 0.5;
	vec2 uv = muv/ vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 ro=vec3((4+2*sin(fGlobalTime*0.5))*0.1,.2,fGlobalTime);
  
  vec3 la = vec3(0,0,fGlobalTime+2);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  
  vec3 rd=normalize(f + r*uv.x - u *uv.y);
  float t=0,d;
  float mat;
  
  float metal = 0;
  for (int i=0;i<120; ++i) {
    d = map(ro+rd*t,mat);
    if (d<0.01) {
      if (mat == 1) {
        ro = ro+rd*t;
        rd = reflect(gn(ro),rd);
        metal += 1;
        t = 0.1;
      } else {
        break;
      }
    }
    t += d;
  }
  
  vec3 bgcol=mix(vec3(0.5,0.6,0.95),vec3(0.94),1-fbm(rd.xy*10));
  bgcol = mix(vec3(0.9),bgcol,smoothstep(0.,0.5,uv.y));
  vec3 col = bgcol;
  
  vec3 ld = normalize(vec3(1,1,-1));
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    
    col = plas(p.xz/4,fGlobalTime/5);
    col = mix(vec3(0.4,0.2,0.1)*0.1,col,smoothstep(-1.5,-0.4,p.y));
    col = mix(col,vec3(0.9),smoothstep(0.5,1.4,p.y));
    
    col *= dot(n,ld);
    vec3 md = normalize(ld-rd);
    col += pow(clamp(dot(md,n),0,1),14)*0.3;
    col *= 0.5+shad(p,ld);
  }
  
  col += metal *vec3(0,0,0.2);
  
  
  col = mix(bgcol,col,exp(-t*t*t*0.0007));
  
  col = pow(col,vec3(0.45454));
  
  out_color=vec4(col,1);
}