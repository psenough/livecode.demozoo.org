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

#define T fGlobalTime

#define pi acos(-1.)
#define xor(a,b,e) min( max(a, -b), max(-a + e, b))

#define rot(j) mat2(cos(j),-sin(j),sin(j),cos(j))

#define pal(a,b,c,d,e) ((a) + (b)*sin((c)*(d) + (e)))

#define kick(T,k) floor(T) + pow(fract(T),k)

#define dmin(a,b) a.x < b.x ? a : b

#define pmod(p,md) mod(p - 0.5*md, md) - 0.5*md

vec3 glow = vec3(0);

float sdBox(vec3 p, vec3 s){
  p = abs(p) - s;
  return max(p.x,max(p.y,p.z));
}

vec2 map(vec3 p){
  vec2 d = vec2(10e5);

  float id = 0.;
  
  p.y = pmod(p.y, 9.);
  
  float dc = length(p) - 0.2;
  
  d.x = min(d.x,dc);
  
  
  p.x += pow(abs(sin(p.x + T)),20.)*0.5;
  
  for(int i = 0; i < 6; i++){
    p = abs(p) - vec3(0.2, .8 + sin(kick(T*0.5,5.))*0.5,   float(mod(i,2) - 1.)*0.2)+ sin(T)*0.1;
  
    p.xz *= rot(0.25*pi);
    
    
    float od = xor(d.x,sdBox(p,vec3(0.25)), -0.5);
  
    //od = xor(d.x,length(p.yx), -0.2);
  
    
    //d.x = xor(d.x,length(p.yz) - 0.4,4.2);
    if(od < d.x){
      d.x = od;
      id++;
    }
  }
  
  d.x = abs(d.x*0.6) + 0.004;
  
  
  glow += 0.2/(0.005 + d.x*d.x*40.)*pal(0.5,0.5,vec3(5 + kick(T*0.2,4.),1,2), 1., id + T*0.2);
  
  vec4 q = vec4(p,1);
  
  
  for(int i = 0; i < 2; i++){
    p = abs(p) - 0.;
    
    p.xz *= rot(0.5*pi);
  
  
    float od = xor(d.x,length(p.xz) - 0.01,0.42);
    od = xor(od,length(p.xy) - 0.01,0.12);
    
    if (od < d.x){
      d.y = 4.;
      d.x = od;
      
    d.x = xor(d.x,length(p) - .06,-1.52);
  
    }
 
  }
  
  //d = dmin(d,vec2(length(p.xy) - 0.01,4.));
  
  //d = dmin(d,vec2(length(p.zy) - 0.01,4.));
  
  
  p -= 0.5;
  d = dmin(d,vec2(length(p) - 0.51,4.));
  
  
  q /= dot(q.xyz,q.xyz);
  
  for(int i = 0; i < 5; i++){
    float dpp = dot(q.xyz,q.xyz);
    //q.xyz = abs(q.xyz) - vec3(0.1,0.5,0.6);
     q.xyz = pmod(q.xyz, 1.5);  
   
    //q.xz *= rot(0.25*pi
    q /= dpp;

  
  }
  
  
  float db = length(q.xy)*q.w;
  //db = abs(db*0.6) + 0.002;
  
  //d = dmin(d,vec2(db,4.));
  
  //glow -= 0.1/(0.005 + db*db*40.)*pal(0.5,0.5,vec3(1,2,3), 1., 1);
  
  
  return d;
}

vec3 getnormal(vec3 p){
  vec2 t = vec2(0.001,0.);
  return normalize(p - vec3(
    map(p-t.xyy).x,
    map(p-t.yxy).x,
    map(p-t.yyx).x
  ));
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col = vec3(0.9,0.7 + length(uv)*sin(kick(T,2.))*.2,0.2);
  
  // cam
  vec3 ro = vec3(0);
  ro.x = sin(cos(T));
  ro.y = cos(T*0.4 + sin(T));
  ro.z = sin(cos(T*0.5));
  ro = normalize(ro)*1.9;
  
  ro.y += T;
  
  vec3 lookAt = vec3(0,0 + ro.y + 2.,0);
  vec3 dir = normalize(lookAt - ro);
  vec3 right = normalize(cross(vec3(0,1,0), dir));
  vec3 up = normalize(cross(dir,right));
  vec3 rd = normalize(dir + right*uv.x + up*uv.y);
  

  
  vec3 p = ro;
  float t = 0.;
  vec2 d;
  
  
  for(int i = 0;i < 130; i++){
    d = map(p);
  
    if(d.x < 0.001){
      if (d.y == 4){
        vec3 n = getnormal(p);
        //col += 0.1;
        
      }
    
    }
  
    p += rd*d.x;
  
  }
  
  col -= glow*0.001;
  
  col = pow(col,vec3(0.454545));
  
  out_color = vec4(col,1);
}