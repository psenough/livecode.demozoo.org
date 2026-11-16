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
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
const float pi = acos(-1);
#define r2(a) mat2(cos(a),-sin(a),sin(a), cos(a))
vec4 s = fGlobalTime*(128/60.)/vec4(1,4,8,16);
vec4 t = fract(s);
float sd_b(vec3 p, vec3 e) {
  p = abs(p) -e ;
  return length(max(p,0)) + min(max(max(p.x,p.y),p.z),0);
}
#define time fGlobalTime
float map(vec3 p) {
  float d;
  {
    vec3 q = p;
    q.xy = abs(q.xy);
    q.xy -= .5;
    q.x += asin(sin(p.z+time)) * .5;
    q.y += asin(cos(p.z+time)) * .5;
    d = sd_b(q, vec3(0.2,0.2,1111))-.1;
  }
  {
    vec3 q = p;
    q.z -= round(q.z);
q.xz *= r2(time+q.z);
    d = min(d, sd_b(q, vec3(0.1))-0.1);
  }
  return d;
}
vec3 nor(vec3 p) {
  vec3 e = vec3(1e-4,0,0);
  return normalize(vec3(
  map(p+e.xyy)-map(p-e.xyy),
  map(p+e.yxy)-map(p-e.yxy),
  map(p+e.yyx)-map(p-e.yyx)
  ));
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy  - .5 * v2Resolution.xy ) / v2Resolution.y;
  vec3 col = vec3(1);
  vec3 ro = vec3(1+cos(fGlobalTime),2+sin(fGlobalTime),4);
  
  if (t.w >.5)
    ro = vec3(0,4,sin(time));
  vec3 cf = normalize(-ro),
  cu = normalize(cross(cf, vec3(1,0,0))),
  cl = normalize(cross(cf,cu)),
  rd = mat3(cl,cu,cf)*normalize(vec3(uv, 0.5));
  float i,r,d,N=123,h=0;
  for (i=r=0.; i<N; i++) {
    d =  1e9;
    { vec3 p = ro+rd*r;
      d=map(p);
      if (d<1e-3 && h<10.) {
        vec3 n = nor(p);
        col *= 1-pow(1-dot(-rd,n),2);
        rd=reflect(rd,n);
        r=1e-3;
        ro=p;
        h++;
        continue;
      }
      {
        vec3 p = ro+rd*r;
        float th = mix(0.1,0.4,texture(texFFTSmoothed, 0.01).r*10);
        p.z -= round(p.z);
        
        p.xy = abs(p.xy);
        p.xy -= 2;
        p.xy *= r2(.25*pi);
        float n = int(mix(1,4,t.x));
        p.xy -= clamp(round(p.xy),0,n);
        d=min(d, sd_b(p, vec3(0.1+th,.05,.05)));
      }
        
    }
    if (d>0) r+=d*.5;
    if (d<1e-4||r>1e5) break;
  }
  if (i<N)
  col *= clamp(1/(r*.1),0,1);
  else col *= 0;
  if (t.y>.5 && t.w < .25) {
    col *= step(0.5, fract(t.x*8));
  }else
  if (texture(texFFTSmoothed,0.005).r > 0.2)
    col = 1 - col;
  
    
	out_color = vec4(col, 1);
}