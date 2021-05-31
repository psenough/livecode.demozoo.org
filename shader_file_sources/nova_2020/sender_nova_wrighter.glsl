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

#define T fGlobalTime*2.

#define pi acos(-1.)

#define pal(a,b,c,d,e) (a + b*sin(c*d + e))

#define rot(j) mat2(cos(j),-sin(j),sin(j),cos(j))

#define pmod(p,j) mod(p - 0.5*j,j)  - 0.5*j

float sdBox(vec3 p, vec3 s){
  p = abs(p) - s;
  return max(p.x,max(p.y,p.z));
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv*=1.5;

  vec3 col = vec3(0,0.2,0.5);
  
  float tt = T*0.1;
  
  uv += vec2(cos(tt*0.7 + cos(tt/2.)), sin(tt*0.9) + sin(tt*0.6))/1.;
  

  
  vec3 p = vec3(uv,1);
  
  
   p /= dot(p,p);
  
  p.x += tt*0.003;
  p.y += tt*0.003;
  p.xz *= rot(0.25*pi - sin(T/2.)/20. + tt*0.1);
  
  p.xy *= rot(0.25*pi + sin(T/2.)/20.);


  
  //p.xz = vec2(atan(p.y,p.x)*pi*2./7.,log(length(p.xy) ));

  p = pmod(p,0.3);
  
  
  //
  col = mix(col,vec3(0.1,0.1,0.5),smoothstep(0.001,0.,abs(length(p-0.1)-0.1)-0.02));
  
  
  // 
  float db = sdBox(p - 0.01,vec3(0.1));
  db = abs(db) - 0.01;
  
  col = mix(col,vec3(0.0,0.8,0.5)*1.,smoothstep(0.001,0.,db));
  
  // 
  db = sdBox(p,vec3(0.1));
  col = mix(col,vec3(0.1,0.4,0.1)*4.,smoothstep(0.001,0.,db));
  
  //
  db = length(p)- 0.1;
  
  db = abs(db)-0.01;
  col = mix(col,vec3(0.9,0.4,0.5)*0.1,smoothstep(0.001,0.,db));
  
  // circ
  db = length(p + 0.05)-0.05;
  db = abs(db) - 0.01;

  
  col = mix(col,vec3(0.9,0.4,0.1)*4.,smoothstep(0.001,0.,db));
  
  
  
  
  
  col = pow(col,vec3(0.454545));
  out_color = vec4(col,0);
}