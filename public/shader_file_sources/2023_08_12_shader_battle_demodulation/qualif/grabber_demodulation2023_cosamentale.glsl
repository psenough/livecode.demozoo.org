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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
mat2 rot(float t){ float c = cos(t); float s = sin(t); return mat2(c,-s,s,c);}

float no(vec3 p){ vec3 f=  floor(p); p = smoothstep(0.,1.,fract(p));
  vec3 e  = vec3(45.,98.,12.);
  vec4 v1 = dot(e,f)+vec4(0.,e.y,e.z,e.y+e.z);
  vec4 v2 =mix(fract(sin(v1)*7845.26),fract(sin(v1+e.x)*7845.26),p.x);
  vec2 v3 = mix(v2.xz,v2.yw,p.y);
  return mix(v3.x,v3.y,p.z);}
float v1 = texture(texFFTIntegrated,0.1).x*1.;
  float it(vec3 p){float r = 0.; float a = 0.5;for(int  i = 0 ; i <  5 ; i++){
    r += no(p/a)*a;a*=0.5;} return r;}
    float zc ;
float map(vec3 p){
  for(int  i =0 ; i <  5 ; i++){
    p -= 1.;
    p.xy*= rot(v1*2.);
      p.zy*= rot(v1*1.5);
    p = abs(p);
  }
  float n = (it(p)-0.5)+no(p*70.)*0.05;
  float d1 = length(p)-2.+n;
  float d2  = min(max(length(p.xz)-0.5,length(p)-3.),max(length(p.xz)-0.25,length(p)-4.));
  zc = d2;
  return min(d1,d2);}
  vec3 nor(vec3 p){ vec2 e  =vec2(0.01,0.); 
    return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));}
    float rd(float t){ return fract(sin(dot(floor(t),45.23))*7845.236);}
     float rd(vec2 t){ return fract(sin(dot(t,vec2(98.23,45.23)))*7845.236)-0.5;}
    float no(float t){ return mix(rd(t),rd(t+1.),smoothstep(0.,1.,fract(t)));}
    float ev(vec3 p){return clamp(no(normalize(p*vec3(1.,0.5,1.)).x*4.),0.,1.);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
uv = (uv-.5)*2.;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 p = vec3(0.,0.,-10.);
  vec3 r = normalize(vec3(uv+vec2(rd(uv),rd(uv+98.))*pow(length(uv.y),2.)*0.05,1.));
 float v2 = texture(texFFTIntegrated,0.2).x*1.;
  p.xz *= rot(v2);
  r.xz *= rot(v2);
  float dd;
  for(int  i = 0 ; i< 64 ; i++){
    float d = map(p);
    if(d<0.01){break;}
    p += r*d;
    dd += d;
  }
  float m = smoothstep(0.1,0.,zc);
  float r1 = smoothstep(15.,8.,dd);
  vec3 n = nor(p);
  float ao = clamp(map(p+n),0.,1.);
  float r2 = mix(ev(r), pow(ev(n),0.5)*0.5*ao,r1);
  vec3 r3 = mix(vec3(1.),3.*abs(1.-2.*fract(smoothstep(0.,0.5,ao)*-0.7+r2*0.1+m*0.5+0.5+vec3(0.,-1./3.,1./3.)))-1.,mix(0.5,0.,ao))*r2;
	out_color = vec4(r3,r2);
}