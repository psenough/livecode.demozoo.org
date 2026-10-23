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
#define iTime fGlobalTime

#define one_bpm 0.3429
#define beat(a) tick(iTime / (one_bpm*a))
#define cumbeat(a, b) b*iTime+tick(iTime/(one_bpm*a))
float tick(float t) {
  t = fract(t);
  return t;
}


vec3 ro = vec3(0, 3., -8);
vec3 spho = vec3(0. , 3., -5.);
vec3 light = normalize(vec3(2, 1.9, -2));
//hello! o/

mat2 rot(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a));}
float smin(float a, float b, float k) {
  float h = max(k - abs(a-b), 0.0) / k;
  return min(a,b) - h*+h*k*(1.0/4.0);
}

float sph(vec3 p, float r){
  return length(p) - r;
}



float map(vec3 p) {
  p.z -= 2;
  if(beat(4*12) < 0.5)
    p.xz *= rot(0.5);
  if(beat(8) < 0.5)
    p.yz *= rot(0.8);
  if(beat(12) < 0.5){
    p.x = abs(p.x);
    
    p.xz *= rot(-0.8);
  }
    
  
  p.z -= 1.5;
  vec3 ip= p;  
  float f = 0;
  
  p.y -= 3;
  
  
  for(int i = 0; i < 3; i++){
    f += sph(p,5);
    p.x = abs(p.x);
    p.xz *= rot(0.2*float(i)*ip.y);
    p.z = cos(p.x + sin(p.z*2));
    p.xz *= rot(-cumbeat(4, 2));
    p.xz *= rot(0.3- p.y);
    f = smin(f, sph(p, 1.2), 6+sin(p.z));
  }
  
  p.x-= sin(iTime+p.z);
  
  float s = f;
  
  float sph1 = sph(ip - vec3(0, -1, 2*sin(beat(4)*0.1)), 2.5);
  s = max(s, -sph1);
  
  s = max(s, sph(ip+spho , 8.0+sin(p.x))) ;
  s += texture(texNoise, p.xz*0.07).r;
  
  return s/15.;
}

vec3 norm(vec3 p) {
     float h = 0.0001;
   vec2 k = vec2(1, -1);
  return normalize(
  k.xyy * map(p + k.xyy*h) + 
  k.yyx * map(p + k.yyx*h) +
  k.yxy * map(p + k.yxy*h) +
  k.xxx * map(p + k.xxx*h));
}

vec3 sky(vec3 rd){
  rd.yz *= rot(0.6);
  float r = length(rd);
  float phi = acos(rd.z/r);
  float theta = atan(rd.y, rd.z);
  
  vec3 sp = vec3(r, phi, theta);
  
  vec3 color = vec3(0);
  
  sp.z *= sin(0.5+4*cos(theta));
  sp.xz *= rot(sp.z);
  sp.xz = abs(sp.xz);
  sp.xz -= 0.8;
  sp += cumbeat(8, 0.5)*0.1;
  vec2 uv = sp.yx;
  
  
  color += texture(texNoise, uv*0.8).r;
  color += pow(color, vec3(1.64));
  
  vec3 l = vec3(0.2, 0.1, 0.2);
  vec3 h = vec3(0.1, 0.8, 0.9);
  return mix(l, h, color);
}

vec3 march(vec3 ro, vec3 rd) {
  float t = 0.01;
  int steps = int(mix(128, 256, abs(sin(0.01*iTime))));
  vec3 color = vec3(0);
  for(int i = 0; i < steps; i++) {
    float a = map(ro+rd*t);
    if(a < 0.001) {color = vec3(1);break;}
    if(t > 100.) break;
    t+=a;
  }
  if(color.r > 0.1){
    vec3 p = ro+rd*t;
    vec3 n = norm(p);  
    vec3 color = vec3(0.5, 0.02, 0.3);
    
    
    
    vec3 r = reflect(rd, n);
    vec3 sk = sky(r);
    float dt = dot(light, n);
    vec3 ndotl = max(vec3(0.5*sk-dt*0.4) , sk+dt);
    color*= ndotl;
    vec3 h = (light+rd) / length(light+rd);
    color += max(0.1, dot(n,h)) * sky(h);
    
    return color;
  }
  else return sky(rd);

}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv1 = uv;
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec2 uv2 = uv;
  
  uv2.x += cumbeat(12,.5);
  uv2.y += iTime*0.2;
  uv2 = fract(uv2*4);
  
  float flip = 1;
  if(uv2.x < 0.5 && beat(24) < 0.5){
    ro += 0.2; 
  }
  
  flip = beat(24);
  vec3 rd = normalize(vec3(uv, 1));
  rd.zy *= rot(0.2);
  
  
  
  vec3 color = march(ro, rd);
  color *= 1.75;
  color = mix(color, texture(texPreviousFrame, uv1*1.0).rgb , abs(sin(beat(4))));
  color = pow(color, vec3(1.2));
  
	out_color = vec4(flip > 0.5 ? color : 1-color, 1);
  
}