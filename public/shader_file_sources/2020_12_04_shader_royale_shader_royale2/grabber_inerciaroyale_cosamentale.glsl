#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float time = fGlobalTime;
mat2 rot(float t){ float c = cos(t); float s = sin(t); return mat2(c,-s,s,c);}
float hs(vec2 t){return fract(sin(dot((t),vec2(874.,45.)))*7845.236+time);}
float rd(float t){return fract(sin(dot(floor(t),45.))*7845.236);}
float no (float t){ return mix(rd(t),rd(t+1.),smoothstep(0.,1.,fract(t)));}
float it(float t){float r =0.; float a = 0.5; for (int i = 0 ; i < 3 ;i++){
  r += no(t/a)*a; a*=0.5;} return r;}
  vec3 rer (vec3 p, float r){float at = atan(p.z,p.x);
    float t = 6.28/r;
    float a = mod(at,t)-0.5*t;
    vec2 v = vec2(cos(a),sin(a))*length(p.xz);
    return vec3 (v.x,p.y,v.y);}
    float cap (vec3 p , vec3 a, vec3 b){ vec3 pa = p-a; vec3 ba = b-a;
      float h = clamp(dot(pa,ba)/dot(ba,ba),0.,1.);
      return length ( pa-ba*h);}
float no(vec3 p) { vec3 f = floor(p); p = smoothstep(0.,1.,fract(p));
vec3 se = vec3 (7.,65.,154.);
vec4 v1 = dot(f,se)+vec4(0.,se.y,se.z,se.y+se.z);
vec4 v2 = mix(fract(sin(v1)*4587.236), fract(sin(v1+se.x)*4587.236) ,p.x);
  vec2 v3 = mix(v2.xz,v2.yw,p.y);
  return mix(v3.x,v3.y,p.z);}
  float fmb (vec3 p){ return smoothstep(0.,1.,no(p+no(p)*8.));}
float map(vec3 p,float v4) { vec3 b = p;
  for (int i = 0 ; i < 11; i++){
    b = vec3(1.8)*abs(b/dot(b,b))-vec3(0.7,0.3,0.6);
  }
 float v1 = length(b)-0.5+v4*0.1;
  float v2 = length(p)-6.;
  return max(v1,-v2);
  }
      
  float zl (vec3 p,float m1){ p = rer(p,4.);
    return smoothstep(3.+pow(length(p.y),1.1)*0.7,0.,length(p.xz))*5.5+smoothstep(3.+m1*10.,0.,length(p))*15.+smoothstep(0.7,0.1,length(p.zy))*10.;}
  
  
    float zo (vec3 p, float v5 , float m1){
      vec3 p2 = p;
      p.y += sin(p.x+p.z+time*3.);
      p.xz *= rot(time*-4.+p.y*0.7*sign(p.y));
      float tt = no(p*3.);
      p.y = abs(p.y);
      p = rer (p,4.);
      return smoothstep(0.,tt*0.9,cap(p+vec3(tt*-2.,0.,0.),vec3(0.,1.5,0.),vec3 (0.,8.,0.)))*smoothstep(0.1+m1*5.,0.7+m1*5.,length(p2));}
    /*  vec3 n (float p) {vec2 e =vec2(0.01,0.);
        return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));} */
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
   float m1 = smoothstep(0.3,0.7,sin(time*0.3)*0.5+0.5);
    float v4 = it(time*1.5);
 float v1 = pow(it(time*4.),1.)*1.;
  float v2 = v4*6.28*mix(1.,0.3,m1);
    float v3 = it(time*1.1)*1.3*mix(1.,0.3,m1);

  float v5 = it(time);
    float m2 = sin (time*5.)*0.5+0.5;
  
vec3 e = vec3(0.,0.,-5.5);
  vec3 e2 = vec3(0.,0.,mix(-200.,-85.5,m1));
  vec3 r = normalize(vec3(uv,0.5+v4*0.5));
  e.xz *= rot(v2);
  r.xz *= rot(v2);
  e.yz *= rot(v3);
  r.yz *= rot(v3);
   e2.xz *= rot(v2);
  
  e2.yz *= rot(v3);
  

  vec3 r2 = r;
 
  int n1 = int(mix(20.,0.,m1));
  float fstp = 10./n1;
  vec3 fr = fstp*r;
  float prog = fstp+mix(0.8,1.,hs(uv));
  vec3 lp = e+r*prog;
  float val; float opa = 1.;
  for( int i = 0 ; i < n1 ; i++){
    if(prog > 10.){break;}
    if(opa<0.01){break;}
    vec3 lp2 = lp;
    lp2.xz *= rot(lp.y*0.5+time*0.1);
    opa *= zo(lp,v5,m1)*mix(0.95,1.01,fmb(lp2*3.));
    val += zl(lp,m1)*opa;
    lp += fr;
    prog += fstp;
  }
  float c1 = val*0.015*v1;
  c1 += opa*0.15;
  
  vec3 p = e2;
  float dd =0.;
  int n2 = int(mix(0.,64.,m1));
  for(int i = 0 ; i <n2 ; i++){
    float d = map(p,v4);
    if(dd > 80.){break;}
    if(d<0.01){break;}
    p += r*d;
    dd +=d;
  }
  float s1 = smoothstep(20.,80.,dd);
  float r1 =mix(c1,s1,m1);
  vec3 c2 = mix(vec3(1.),3.*abs(1.-2.*fract(r1*0.7+0.3+v4*0.1+length(uv)*0.2+vec3(0.,-1./3.,1./3.)))-1.,0.2)*r1;
  vec3 c3 = smoothstep(vec3(-0.1,-0.1,-0.05),vec3(1.,1.,1.),c2);
  vec3 c4 = mix(c3,1.-c3,smoothstep(0.7,0.8,it(time*8.)));
  out_color = vec4(c4,0.);
}