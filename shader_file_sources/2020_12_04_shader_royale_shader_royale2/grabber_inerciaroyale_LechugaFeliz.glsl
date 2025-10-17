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

#define time fGlobalTime

float esp(vec3 p, float s){
  return length(p)-s;
}

float box(vec3 p, vec3 s){
  vec3 q = abs(p)-s;
  return max(q.x, max(q.y, q.z));
}



vec2 rp(vec2 p, vec2 s){
  return (fract(p/s-.5)-.5)/s;
}

float rp(float p, float s){
  return (fract(p/s-.5)-.5)/s;
}

vec3 smin(vec3 a, vec3 b, vec3 k){
  vec3 h = max(abs(a-b)-k, 0.)/k;
  
  return min(a,b) - pow(h,vec3(3.)) *k*(1.0/4.0);
}

mat2 rot(float a){
  float aco = cos(a);
  float asi = sin(a);
  return mat2(aco, asi, -asi, aco);
}

float map2(vec3 p){
  return -box(p, vec3(40.));
}

float at =1.;
float map(vec3 p){
//  
  float t1 = time*.1;
  
  for(int i = 0; i < 8;++i){
     
    p.xz *= rot(t1*i*.2);
    p.yz *= rot(t1*.3*i);
    p -= vec3(0.1, .1, .1);
    
    p = abs(p)-.5-vec3(.2, 0.5, .2)*i*.5+sin(time)*.5-.5;

    p.xy *= rot(time*.13);
    
    //p = smin(p, -p, vec3(1.));
  }
  //float d1 = esp(p, .3);
  
  float d2 = box(p, vec3(1.));
  at += .1/(.1+d2*d2);
  
  return min(d2, map2(p));
  
}

vec3 nm(vec3 p){
  vec2 offs=vec2(0.01, 0.);
  return normalize(map(p)-vec3(map(p-offs.xyy),map(p-offs.yxy), map(p-offs.yyx)));
}

void cam(inout vec3 p){
  p.xz *= rot(time+cos(time*.6)*.25-.5);
  p.yz *=rot(time*.6+sin(time*.56)*.25-.5);
  p.xy *= rot(time*.25);
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  //px
  /*
  float det = 1.-sin(time)*texture(texFFTSmoothed, 0.01).x *2000;
  uv = floor(uv/det)*det;
  */
  
  
  float timing = floor(mod(time, 4.));
  if(timing > 2.){
    float det = texture(texFFTSmoothed, 0.01).x* 60.;
    uv = floor(uv/det)*det;
  }
  
  vec3 s = vec3(0., 0., -25.);
  float fov =.7-sin(time*.5)*.25-.25;
  vec3 r = normalize(vec3(-uv, fov));
  vec3 col = vec3(0.);
  
  cam(s);
  cam(r);
  
  
  vec3 p = s;
  float i = 0.;
  float pred = 1.;
  // NO LE PUEDO BAJAR EL BRILLO CTM XDDDD
  for(;i < 100.;i++){
    float d = map(p);
    if(d<0.0001){
      float fog = 1.-i/200.;
      vec3 n = nm(p);
      vec3 l = normalize(vec3(-1.));
      float toc = floor(mod(time, 10.));
      float pi = acos(-1.);
      if(toc < 3 && toc > 1)
        col += .6-max(dot(l,n),0.)*fog*vec3(.45, 0.3456, 0.4)*pi*sin(time*5.)*.4;
      if(toc > 3){
        col += .5-max(dot(l,n),0.)*vec3(.456, .456, .2)*pi*sin(time)*5.*.2;
      }
      
      col += .5-max(dot(l,n),0.)*vec3(.4, .3, .3)*pi*sin(time)*5.*.26;
      col += .1/(100.+i)*vec3(0.4, 0.3,0.65)*sin(time)*.94-.1;
      col *= .6;
      col += 1.-length(p)/65.;
      col += at*.005*vec3(1., .5,.2);
      pred *= 0.9;
      r = reflect(n, l);
      d = 0.01;
      if(pred < 0.001) break;
    }
    if(d>100.)break;
    p+=d*r;
  }
  
  out_color = vec4(col, 1.);
}