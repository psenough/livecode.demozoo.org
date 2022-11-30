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

#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))
#define pi acos(-1.)
#define spd p.z += t*130.;
#define spd2 p1.z -= t*270.;
float t = mod(fGlobalTime, 100.);
float h21(vec2 uv){
  return fract(sin(dot(uv.yx, vec2(7.324,43.43)))*26.234);
}
float smin(float a, float b, float k){
  float h = max(0., k-abs(a-b))/k;
  return min(a,b)-h*h*k*.25; 
}
float d1(vec3 p){
  return length(p)-2.;
}
float d2(vec3 p){
  //for(float i = 0. ; i++ < 10.;) 0_0
  /*
  for(float i = 0.; i++ < 3.;){
    p.x = abs(p.x)-1.;
    p.xy *= rot(t);
  }
  */
  p.x += sin(t+p.x*.21);
  p.xy *= rot(sin(t*73.)*.015143);
  vec3 p0, p1, p2;
  p0 = p1 = p2 = p;
  p.xy *= rot(.523);
  p.z = abs(p.z)-2.65;
  p.yz *= rot(-t*50.);
  
  vec2 s = vec2(1.55, 1.)-texture(texNoise, p.xz*.34).x*.01;
  
  float d =length(vec2(length(p.yz)-s.x, p.x))-s.y;
  float d2 = length(p0-vec3(-2., 3., 0.))-2.;
  float d3 = length(p1-vec3(-3., 0., 0.))-1.;
  float d4 = length(p2- vec3(-2., -1., 0.))-1.;
  d = smin(d, d2, 1.);
  d = smin(d, d3, 1.);
  d = smin(d, d4, 1.);
  return d;
}
float d22(vec3 p){
  //for(float i = 0. ; i++ < 10.;) 0_0
  /*
  for(float i = 0.; i++ < 3.;){
    p.x = abs(p.x)-1.;
    p.xy *= rot(t);
  }
  */
  p.x += sin(t+p.x*.31);
  p.xy *= rot(sin(t*73.)*.015143);
  vec3 p0, p1, p2;
  p0 = p1 = p2 = p;
  p.xy *= rot(.523);
  p.z = abs(p.z)-2.65;
  p.yz *= rot(-t*50.);
  
  vec2 s = vec2(1.55, 1.)-texture(texNoise, p.xz*.34).x*.01;
 
  float d =length(vec2(length(p.yz)-s.x, p.x))-s.y;
  float d2 = length(p0-vec3(-2., 3., 0.))-2.;
  float d3 = length(p1-vec3(-3., 0., 0.))-1.;
  float d4 = length(p2- vec3(-2., -1., 0.))-1.;
  d = smin(d, d2, 1.);
  d = smin(d, d3, 1.);
  d = smin(d, d4, 1.);
  return d;
}

float d3(vec3 p){
  return p.y+2.35;
}
float ac4 = 0.;
float d4(vec3 p){
  spd;
  float ss = 20.;
  p.z = (fract(p.z/ss-.5)-.5)*ss;
  p.x = abs(p.x)-40.;
  float d= length(p-vec3(0., -2., 0.))-2.;
  ac4 = 3./(1.+d*d);
  return 1.;
}
float bb(vec3 p, vec3 s){
  p = abs(p)-s;
  return length(max(vec3(0.), p))-1.;
}
float d5(vec3 p){
  spd;
  float ss= 140.;
  p.z = (fract(p.z/ss-.5)-.5)*ss;
  
  p.x = abs(p.x)-20.;
  vec3 p1 = p;
  
  float d = bb(p, vec3(1., min(20., p.y), 0.));
  //p.x += sin(p.x*4.+t);
 //p1.xy *= rot(pi/.55134);
  d = min(bb(p1-vec3(0.+p1.x, 20., 0.), vec3(1.)), d);  
  return d;
}
float ac3 = 0., ac5 = 0.;
vec2 m(vec3 p){
  //p.x += cos(p.z+t)*4.525;
  //
  p.x += sin(p.z*.7434+t);
  
  float d = 1.;
  float id = 0.;
  float d1 = d1(p);
  float d2 = d2(p);
  vec3 p1 = p;
  spd2;
  float ss = 500.;
  float gid = (floor(p1.z/ss-.5));
  p1.z = (fract(p1.z/ss-.5)-0.5)*ss;
  p1.xz *= rot(sin(-t-gid*gid)*.2151);
  float d22 = d22(p1+vec3(10., 0., 0.));
  float d3 = d3(p);
  float d4 = d4(p);
  float d5 = d5(p);
  ac3 += 1./(1+d3*d3);
  //d = d1;
  d = min(d, d2);
  id = d < d2 ? 0. : 1.;
  d = min(d, d3);
  id = d < d3 ? id : 2.;
  d = min(d, d4);
  id = d < d5 ? id : 3.;
  d = min(d, d5);
  
  // final..
  id = d < d22 ? id : 4.;
  ac5 += 1./(1.+d22*d22);
  d = min(d, d22);
  return vec2(d, id);
}

vec3 nm(vec3 p){
  vec2 e = vec2(0.01, 0.);
  return normalize(m(p).x - vec3(m(p-e.xyy).x, m(p-e.yxy).x, m(p-e.yyx).x));
}

void main(void){
  vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
  uv -= vec2(0.5);
  uv.x /= v2Resolution.y / v2Resolution.x;
  t += h21(uv*.141)*.001;
  vec3 co = vec3(0.31);
  vec3 s = vec3(-3.01, 5.01, -18.-texture(texFFTSmoothed, uv.y+t).x*120.);
  
  vec3 p = s;
  p.x += sin(t+p.x)*10.;
  vec3 cz = normalize(vec3(0.)-s);
  vec3 cx = normalize(cross(cz,vec3(0., -1., 0.)));
  vec3 cy = normalize(cross(cz,cx));
  vec3 r= mat3(cx,cy,cz)*normalize(vec3(uv, 1.-length(uv*.334)*3.125));
  for(float i = 0.; i++ < 200.;){
    vec2 e = m(p);
    float d = e.x;
    float id = e.y;
    if(d < 0.1){
    if(id == 1 || id == 3 || id == 4){
      co *= vec3(0.345, 0.123, 1.);
        r = reflect(r, nm(p))*.89;
        p -= .1;
      }
      else 
      break;
    }
    p+=d*r;
  }
  vec3 l = normalize(vec3(-1., -2., -3.));
  vec3 n = nm(p);
  float dif = clamp(dot(l,n), 0., 1.);
  co += vec3(dif)*.84;
  //co += ac3*.024 - step(0.175, fract(p.z*.35+t*13.))*vec3(.54,.65,.145)*.51261 + texture(texFFTSmoothed,0.01).x*2.;
  co += ac4 * vec3(0.546, 0.24, 0.134) * 3.;
  co += ac5 * vec3(1., 0.24, 0.24)*.0111;
  co *= 1.-length(p-s)/300.;
  co += length(p-s)*.00915*vec3(.7534,.335,.156)/.93344324;
  co = pow(co, vec3(2.34));
  out_color = vec4(co, 1.);
}