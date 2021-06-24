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


#define time mod(fGlobalTime, 100.)
#define scene mod(time, 10)

#define low +texture(texFFTSmoothed, 0.01).x * 100.
#define high +texture(texFFTSmoothed, .99).x * 20.
#define ec(p, r) length(p)-r 

float sb(vec3 p, vec3 s){
  vec3 q = abs(p)-s;
  return min(max(q.x, max(q.z, q.y)), length(max(q, 0.)));
}

mat2 rot(float a){
  float aco = cos(a);
  float asi = sin(a);
  return mat2(aco, asi, -asi, aco);
}

float smin(float a, float b, float k){
  float h = max(k-abs(a-b), 0.)/k;
  return min(a,b)-pow(h, 3.)*k*(1.5/4.0);
}

void kk(inout vec3 p){
  float t = time*.45+(scene >= 0 && scene <= 5 ? low low: 1.);
  for(int i = 0; i < 10; i++){
    p.xz *= rot(t*(1+i*.1));
    p.yz *= rot(t*(.1+i*.25));
    p.xy *= rot(t*((1.+i)*.55));
    //p.x = abs(p.x)-1.5-(i*.1);
    //p.z = abs(p.z)-2.-(i*.46);
    p.x = smin(p.x, (4+i*.24)-p.x, 1.6);
    p.z = smin(p.z , (1.5+i*.1)-p.z, 1.6);

  }
}

float map(vec3 p){
  float d;

  // :')
  float rp = 20. -sin(time+p.y*.25)*.5+.5;
  float pl = p.y +rp;
  vec3 p1 = p;
  kk(p1);
  float r1 = 1. high  high high high  high high high  high high;
  //float r2b = 2;
  
  //vec3 p2 = p;
  //float bg = ec(p1, r1);
  float e1 = ec(p1, r1);
  
  vec3 r2 = vec3(2.4, 5., 4.);
  float c1 = sb(p1-vec3(1., 0., 1.), r2);
  {
    d = min(e1, c1);
    //d = e1;
    d = min(pl, d);
  }  
  
  return d;
}

vec3 nm(vec3 p){
  vec2 e = vec2(0.01, 0.0);
  return normalize( map(p)-vec3(map(p-e.xyy), map(p-e.yxy), map(p-e.yyx)) );
}


void cam(inout vec3 c){
  //c.xy *= rot(time*2. low low);
}
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float fov = 1.;
  vec3 s = vec3(0., 0., -80);
  vec3 t = vec3(0., 0., 0.);
  // :0 OMG! VAMOS CTM!!!!!!!!
  vec3 cz = normalize(t-s);
  vec3 cx = normalize(cross(cz, vec3(0., -1., 0.)));
  vec3 cy = normalize(cross(cz, cx));
  
  //vec3 r = normalize(vec3(uv, fov));
  
  vec3 r = normalize(cx*uv.x + cy*uv.y + cz*fov);
  
  
  //cam(s);
  //cam(t);
  cam(r);
  vec3 p = s;
  float at;
  float md = 0.000001;
  for(int i = 0; i < 105.; i++){
    float d = map(p);
    if(d < md) d = md;
    p+=d*r;
    at += .1/(.5+d);
  }
  
  float fog = 1-max(length(p-s)/90., 0.);
  vec3 l = vec3(0., 0., -2);
  vec3 n = nm(p);
  vec3 dif = vec3(clamp(dot(l, n), 0. ,1.));
  
  vec3 col = dif;
  
  col *= at*vec3(.2, .8, .65)*.4;
  col += mix(vec3(fog), vec3(1., 0.5, 0.5), .1);
  col *= fog;
  col = smoothstep(0., 1., col);
  out_color = vec4(col, 1.);
}