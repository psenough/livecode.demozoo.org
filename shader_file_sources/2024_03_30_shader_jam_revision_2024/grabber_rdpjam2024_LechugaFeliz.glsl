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
float t  = mod(fGlobalTime, 100.)*.03251;
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define pi acos(-1.)
#define tn(a) texture(texNoise, a).x
float ii = 0.;
float smin(float a, float b, float k){
  float h = max(0., k-abs(a-b))/k;
  return min(a,b)-h*h*k*.25;
}
float c(float tt){
  return mix(floor(tt), floor(tt+1.), smoothstep(0., 1., fract(tt)));
}
#define nn (texture(texFFTSmoothed, 0.01).x*10.)*.0125
float ac = 0., ac2 = 0.;
float m(vec3 p){
  vec3 p2,p3;
  p2 = p3 = p;
  //p3.z += t*100.;
  p3.xy *= rot(p3.z*.012+t*30.);
  
  p3.xy = abs(p3.xy)-5.;
  p3 = (fract(p3/20.-.5)-.5)*20.;
  float d3 = length(p3)-3.-sin(p.x+t)*sin(p.y+t)*cos(p.z+t);
  p.zy *= rot(t*2.);
  p.xz *= rot(p.y*.625);
  float d = 1.;
  float di = .635 - nn;
  //p.xy -= (texture(texFFTSmoothed, 0.01).x*10.)*.1;
  for(float i = 10.; i-- > 0.;){
    p.xy *= rot(c(t*.1332)+t);
    d = smin(length(p-vec3(sin(i+t)*1.75))-di, d, 1.);
  }
  //p.xz *= 
  p2.xz *= rot(.17625+t*40.);
  p2.xz *= rot(p.z*.0231);
  float d2 = length(abs(p2.xz)-.5-sin(p.x*.15+t*20.)*2.5-2.5)-.66;
  ac2 += 3./(1.+d2*d2*d2);
  d = smin(d, d2, 1.5);
  ac += .054125/(.15+d*d);
  ii -= d;
  
  d = smin(d, d3, 1.);
  return d;
}
vec3 nm(vec3 p){
  vec2 e = vec2(0.01, 0.);
  return normalize(m(p)-vec3(m(p-e.xyy),m(p-e.yxy),m(p-e.yyx)));
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 s = vec3(0.1+cos(t*20.)*4., 0.1-sin(t*20.)*2.,-10.);
  vec3 p = s;
  uv *= rot(t*10.);
  vec3 r=normalize(vec3(-uv, 1.75-length(uv)*1.25-fract(sin(t*10.345-length(uv-tn(uv)*.825)-2.))));
  vec3 co = vec3(0.01);
  //uv *= rot(c(t*200.)*.1);
  //uv.x *= tn(uv+t*t);
  
  t += fract(sin(dot(uv.yx, uv*244.43+t*20.))*133.432)*.00091347;
  for(float i = 0.; i++ < 100.;){
    float d = m(p);
    if(abs(d) < 0.0001) {
      if(ii < 0.){
        r = reflect(r, nm(p));
        p-=1.;
      }
      else break;
    }
    if(d > 100.) break;
    p+=d*r;
  }
  vec3 n = nm(p);
  vec3 l = normalize(vec3(-1, 2.,-3.));
  l.xy *= rot(t*120.);
  
  vec2 uv2 = fract(abs(uv*70.)-t*150.)*10.;
  //uv2 *= rot(p.x*.14);
  vec2 g = uv2 / (length(p-s)*r.z);
  float dd = min(g.x, g.y) * 1. - max(g.x, g.y);
  co += vec3(dd);
  co += clamp(vec3(dot(l,n)), 0., 1.);
  co += ac*vec3(.123,.04,.3)*pi/2.*.3972125;
  co += ac2*vec3(.2,.5,.0)*.235 ;
  co *= 1.25-length(p-s)/155.;
  co *= 1.-length(uv)*.98275;
  //co = sqrt(co)*.78;
  
	out_color = vec4(co, 1.);
}