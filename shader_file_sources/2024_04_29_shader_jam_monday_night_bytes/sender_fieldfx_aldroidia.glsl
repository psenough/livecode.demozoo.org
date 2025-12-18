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
uniform sampler2D texSessionsShort;
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

vec2 min2(vec2 a,vec2 b) {
  return a.x<b.x ? a : b;
}

vec2 cbsh(vec3 p) {
  p *= 0.5+10*texture(texFFTSmoothed,0.1).x;
  float cb=length(p)-2;
  if (mod(texture(texFFTIntegrated,0.5).x,2)>1.) {
    vec3 q=abs(p)-1.5;
    q.xz *= rot(sin(fGlobalTime));
    cb = max(q.x,max(q.y,q.z));
  }
  return vec2(cb,1);
}

vec2 bwl(vec3 p) {
  p.x = abs(p.x);
  p.xz *= rot(1.2+sin(fGlobalTime));
   return vec2(-p.z+10,3);
}

vec2 map(vec3 p) {
  return min2(
    cbsh(p),
    min2(
      vec2(p.y+2,2),
      bwl(p)
    )
  );
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}

void main(void)
{
	vec2 suv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = suv-0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  if (length(uv) > 0.7) {
    uv = floor(uv*20)/20;
  }
  float axr = sin(fGlobalTime*0.45)*2;
  uv *= rot(axr);
  uv.x=abs(uv.x);
  uv *= rot(-sin(fGlobalTime*0.1));
  uv *= rot(-axr);

  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv+vec2(sin(fGlobalTime)*0.5,0),1));
  float t=0;
  vec2 d;
  
  float gcl=0;
  
  for (int i=0;i<200;++i) {
    d=map(ro+rd*t);
    if (d.x<0.01) {
      if (d.y==3) {
        vec3 n = gn(ro+rd*t);
        ro = ro + rd *t;
        rd = reflect(rd,n);
        t += 0.1;
        gcl=0.11;
      } else {
        break;
      }
    }
    t += d.x;
  }
  float incld = 1-uv.y;
  vec3 col=vec3(mod(floor(incld*incld*50/(1-texture(texFFT,uv.y).x)*2),2))*(-0.1+uv.y)*vec3(1,1.,0)*2;
  
  if (d.x<0.01) {
    vec3 p=ro+rd*t;
    vec3 texcol = vec3(0);
    if (d.y == 1) texcol = vec3(texture(texFFTSmoothed,0.1).x*500)*floor(mod((uv.y+uv.x)*10+fGlobalTime,2));
    else if (d.y == 2) {
      vec2 luv = p.xz;
      luv += vec2(sin(fGlobalTime*0.2)*10,atan(sin(fGlobalTime))*5);
      luv *= rot(sin(fGlobalTime));
      texcol = vec3(mod(floor(luv.x*1)+floor(luv.y*1),2));
    }
    col=texcol*dot(gn(ro+rd*t),-rd);
    col.xz+=texture(texPreviousFrame,suv+texture(texFFTSmoothed,0.05).x*4/t).yy*1.2;
    
  }
  
  col -= length(uv)/4;
  
  out_color = vec4(col+gcl,1);
}