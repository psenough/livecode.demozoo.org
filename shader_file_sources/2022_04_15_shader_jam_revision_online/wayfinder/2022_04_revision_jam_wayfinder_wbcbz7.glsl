#version 410 core

/*

TEST TEST TEST

IDW DA NYA
AMIIIIIGAAAAA
BK RULEZ FOREVER

FUCK THE WAR

GREETZ TO DIVERGREETZ TO DIVERGREETZ TO DIVERGREETZ TO DIVERGREETZ TO DIVERGREETZ TO DIVER
GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER GREETZ TO DIVER

greets to everyone and much kudos to UA bois: TS-Labs, VBI, noob, robus, ivanpirog, keen and the others
fuck the war, fuck the politics!

funked up rings from bottom right, kinda 2002ish -_-

--wbcbz7 18.04.2022 @ revision satellites 2022
*/

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texDfox;
uniform sampler2D texDojoe;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

#define PI 3.14159

float hash(vec2 uv) {return fract(sin(dot(vec2(54001.52, 520042.2), uv))* 2003.5); }

float tt = mod(fGlobalTime + 0.01*hash(gl_FragCoord.xy/v2Resolution), 180.0);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define REP(N, T) T N(T p, T r) { return T(mod(p+.5*r, r)-.5*r); }

REP(rep ,float)
REP(rep2 ,vec2)
REP(rep3 ,vec3)

float box(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(max(q.x, q.y), q.z), 0.0);
}

mat2 rot2(float a) {return mat2(cos(a), -sin(a), sin(a), cos(a));}

vec3 cart2cyl(vec3 a) {return vec3(length(a.xy), atan(a.y, a.x), a.z);}

float map(vec3 p) {
  p = rep3(p, vec3(400.0, 2000, 20));
  p.xz *= rot2(0.06*tt);
  p = cart2cyl(p);
  p.xz *= rot2(0.01*tt);
  float t = 0.;

  t = box(rep3(p + vec3(5.5, 0.1+1*sin(tt*0.3), 0.0), vec3(25.0+30*sin(tt*0.4), PI/4, 12.)), vec3(0.1, 0.1, 4.0));
  t = min(t, box(rep3(p + vec3(5.1, 5+1*sin(tt*0.3), 0.0), vec3(21.0+30*sin(tt*0.1), PI/2, 26.)), vec3(0.2, 0.1, 4.0)));
  t = max(t, -box(rep3(p + vec3(1.1, 5+1*sin(tt*0.3), 0.0), vec3(11.0+30*sin(tt*0.1), PI/6, 26.)), vec3(0.2, 0.1, 16.0)));
  
  
  return t;
}

vec2 tr(vec3 o, vec3 d) {
  float t = 0;
  float acc = 0;
  
  vec3 p = o;
  
  for (int i = 0 ; i < 128; i++) {
    p = o + d*t;
    float ct = max(abs(map(p)), 0.001);
    acc += exp(-2.0 * ct) * ((mod(p.z + tt*1.4, 11) < 10) ? 2 : 1);
    t += ct;
  }
  
  return vec2(t, acc);
}

vec3 getCam(vec2 uv, float a, float sp) {
  float f = 1.0 / (a * 2.0 * PI);
  float r = length(uv);
  float phi = atan(uv.y, uv.x), theta = atan(r/(sp*f))*sp;
  
  return vec3 (
    sin(theta)*cos(phi),
    sin(theta)*sin(phi),
    -cos(theta)
  );
}

mat3 la(vec3 o, vec3 e, vec3 up) {
  vec3 w = normalize(e - o);
  vec3 u = normalize(cross(w, up));
  vec3 v = normalize(cross(u, w));
  
  return mat3(u,v,w);
}

vec3 colorme(float t) {
  vec3 u = vec3(0.3, 0.2, 1.0);
  vec3 a = vec3(0.9, 0.9, 0.2);
  
  vec3 b = vec3(1);
  vec3 y = vec3(1,0,0);
  
  return clamp(smoothstep(u, a, vec3(.5*sin(t*0.4)+.5)), vec3(0.), vec3(1));
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  uv.x += 0.1*fract(sin(fGlobalTime*4.6)*67.5*(round(uv.y*32)/32)) * texture(texFFT, 0.02).r;
  uv.y += 0.1*fract(sin(fGlobalTime*4.6)*47.5*(round(uv.y*32)/32)) * texture(texFFT, 0.01).r;
  
  float adj = tt*50.0;
  
  vec3 o = 6*vec3(sin(tt*0.2), cos(tt*1.24), 0.0) + vec3(0,0, 6 + adj + 3*sin(tt*1.2));
  vec3 e = 1*vec3(sin(tt*1.24), cos(tt*0.3), 0.0) + vec3(0,0, + adj);
  
  o += 0.5*hash(uv)*sin(tt*1.4);
  
  vec3 r = getCam(uv,0.3*sin(tt*0.3)*cos(tt*0.5) + 1.0, 0.2*sin(tt*0.3)*cos(tt*0.5) + 1.0)*la(o, e, vec3(0,0,1));
  //vec3 r = getCam(uv, 0.5, 1.0)*la(o, e, vec3(0,0,1));
  //vec3 r = normalize(vec3(uv, -1.5))*la(o, e, vec3(0,0,1));
  
  vec2 t = tr(o, r);
  vec3 p = o+t.y*r;
  
  
  vec3 color = vec3((60 / (t.x*t.x)) * t.y);
  
  if (mod(fGlobalTime, 2) < 1.5) out_color = vec4(pow(color/(1+color), vec3(0.45)), 1.0);
  else
  out_color = vec4(pow(colorme(t.x*0.1+tt*0.3) * color/(1+color), vec3(0.45)), 1.0);
}