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


#define time mod(fGlobalTime, 25.)
#define m -texture(texFFTSmoothed, 0.01).x *10.
#define t1 time*20.
#define rot(a) mat2(cos(a), sin(a) ,-sin(a), cos(a))
#define pi acos(-1.)

float rand(vec2 uv){
  return fract(sin(dot(uv*.23244*uv.yx*.15756, vec2(234534.4234234)))*2345653.23423423);
}
const float rep = 75.;

float acumNeu = 1.;
//const float rep5 = 60.;
float base (inout vec3 p, inout float id){
  vec3 p1 = p;
  p1.xy *= rot(radians(pi)+time*.1);
  p1.y += t1*1.;
  
  vec2 g = floor(p1.xy/rep-.5);
  id = rand(g+4.324);
  p1.x += sin(p1.y * 0.144+t1*.05) * 2.-.5;
  p1.z += sin(p1.y*0.96554+t1*.06)*.5-.5;
  p1 = (fract(p1/rep-.5)-.5)*rep;
  p1.x = abs(p1.x)-8.;
  p = p1;
  float neu = length(p1.xz)-.6 ;
  
  acumNeu += 5./(.1+neu*neu);
  return neu;
}

float smin(float a, float b, float k){
  float h = max(k-abs(a-b), 0.)/k;
  return min(a, b)-pow(h, 3.)*k*(1.0/6.0);
}

float boom(vec3 p){
  vec3 p1 = p;
  float id;
  float d = base(p1, id);
  
  float e = length(p1)-1.5-id m m m * sin(p1.x+t1)*sin(p1.y+t1-id)*sin(p1.z+t1)*2.5-.5;
  
  return smin(d, e, 10.);
}

float acum1 = .0;
const float rep3 = 50.;
const float MAX_DIST = 200.;
float neurons(vec3 p){
  float d = boom(p);
  vec3 p1 = p;
  
  p1.z += t1;
  p1 = (fract(p1/rep3-.5)-.5)*rep3;
  
  float r = 0.;
  for(int i = 0; i < 2; i++) r += mod(.5+time*20., .2);
  float b = length(p1)-r m m m m m;
  
  acum1 += 10./(.2+b*b);
  return d;
  //return min(d, b);
}

float sb(vec3 p, vec3 s){
  vec3 q = abs(p)-s m m m;
  return max(max(q.y, q.z), q.x);
}
const float rep2 = 20.;



bool coli = false;
float laststands(vec3 p){
  float d = neurons(p);
  vec3 p1 = p;
  
  vec2 g = floor(p1.xz/rep2-.5);
  float id = rand(g+4.324);
  p1 = (fract(p1/rep2-.5)-.5)*rep2;
  

  p1.x = abs(p1.x)-.2 m m m m m m m m m m m m m; // MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
  p1.xy -= time*.1;
  p1.xz *= rot(time);
  p1.yz *= rot(time);
  p1.x += sin(time)*5.5-.5;
  float b = sb(p1, vec3(.5, .5, 1.)+(id*2.))*.68+sin(time+id*2.)*.5-.5;
  coli = b < 50.;
  
  p1.y -= 50.5;
  d = min(max(d, p1.y-5.2), b);
  
  return d;
}


bool coli2 = false;
float map(vec3 p){
  float d = laststands(p);
  // not idea how to contine... mmmmm m mm mm m m m
  
  vec3 p1 = p;
  float dd = p1.z*.234234;
  p1.x += sin(time+dd);
  p1.z += sin(time+dd);
  float rrr = 50.-sin(time+p1.x*2.)*sin(time+p1.y)*cos(p1.z+time)*.25-.0001 m m m m m m m m;
  float cil = length(p1.xy)-rrr ;
  //coli2 = cil < .5;
  return max(d, cil);
}
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);


  vec3 s = vec3(0.0001, -2.0001, -6.), r = normalize(vec3(-uv, 1.));
  s.yz *= rot(time);
  s.xy *= rot(cos(time+s.x*10./pi))*3.;
  s.z -= t1;
  //
  
  vec3 p = s, col = vec3(0.);
  float i = 0.;
  const float MAX = 100.;
  const vec2 off = vec2(0.0145645, 0.);
  vec3 n;    
  for(; i < MAX; i++){
    float d = map(p);
    if(abs(d) < 0.001){
      
      n = normalize(d-vec3(map(p-off.xyy), map(p-off.yxy) , map(p-off.yyx)));
      if(coli || coli2){
        r = reflect(n,r);
        d+=10.5;
        //d*=.1;
      }
      else break;
    }
    if(d > MAX) break;
    p+=d*r;
  }
  
  n = normalize(map(p)-vec3(map(p-off.xyy), map(p-off.yxy) , map(p-off.yyx)));
  vec3 l = normalize(vec3(-1.));
  
  //col += 1.-i/MAX;
  col += clamp(dot(n, l), 0., 1.)*vec3(.1)*.01;
  col += acum1*vec3(0.24, .2, .4)*.777;
  col += acumNeu*vec3(1., 0., 0.)*.04;
  col *= 1.-max(length(p-s)/MAX_DIST, 0.)*vec3(0., .0003, 0.)*.005;
  col = smoothstep(0., 1.,col);
  //col += rand(uv);
  out_color = vec4(col, 1.);
}