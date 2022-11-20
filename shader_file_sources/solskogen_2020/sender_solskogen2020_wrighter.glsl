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


// POTATEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
// EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
//EEEEEEEEE


#define T fGlobalTime
#define pi acos(-1.)

#define pmod(p,j) mod(p,j) - 0.5*j
#define rot(j) mat2(cos(j),-sin(j),sin(j),cos(j))

vec3 glow = vec3(0);

float map(vec3 p){
  float d = 10e6;
  
  float dFl = abs(abs(p.y) - 0.9);
  
  p.xy *= rot(sin(p.z*0.4 + sin(p.x + p.z)*1.)*.8);
  
  
  vec2 disp = vec2(sin(p.z*0.4 + T),sin(p.z*0.7 + sin(p.x)*2. + T))*0.2;
  
  float dPa = length(p.xy - vec2(0.8,0) - disp);
  float dPb = length(p.xy + vec2(0.8,0) - disp);
  
  vec3 q = vec3(pmod(p.xz*1.1,2.), 1);
  
  float iters = 3. + sin(T*0.4 + p.z*0.2)*1;
  for(float i = 0.; i < 7.; i++){
    float dqq = dot(q.xy,q.xy);
    vec3 nq = abs(q)/dqq;
    nq.x -= 0.1;
    nq.xy *= rot(0.5);
    q = mix(q,nq,smoothstep(1.,0.,i - iters));
  }
  
  float dFr = length(q.x)/q.z;
  
  
  d = min(d,dFl);
  d = min(d,dPa);
  d = min(d,dPb);
  
  d -= dFr*0.8;
  
  d = abs(d) + 0.002;
  d *= 0.3;
  
  glow += 0.003/(0.001 + d*d*200.);
  glow.b += 0.03/(0.03 + dPa*dPa*1.);
  glow.gb += 0.03/(0.03 + dPb*dPb*1.);
  
  return d;
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col = vec3(0);

  vec3 ro = vec3(0);
  ro.z += T;
  
  vec3 rd = normalize(vec3(uv, 1));
  
  rd.xy *= rot(sin(T*0.5)*0.2);
  
  vec3 p = ro;
  
  float t = 0.;
  
  for(int i = 0; i < 90; i++){
    float d = map(p);
    p += rd*d;
    t += d;
  }
  
  
  col = col + 1.;

  col -= glow*0.01;
  
  col = pow(col,vec3(0.454545));
  out_color = vec4(col,1);
}