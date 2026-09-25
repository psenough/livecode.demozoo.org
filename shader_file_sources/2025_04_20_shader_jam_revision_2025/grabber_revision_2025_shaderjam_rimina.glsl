#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.1).r;

const float PI = 3.14159265;

const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 64;

vec3 glow = vec3(0.0);

float M = 0;

// 3D noise function (IQ)
float noise(vec3 p){
  vec3 ip = floor(p);
  p -= ip;
  vec3 s = vec3(7.0,157.0,113.0);
  vec4 h = vec4(0.0, s.yz, s.y+s.z)+dot(ip, s);
  p = p*p*(3.0-2.0*p);
  h = mix(fract(sin(h)*43758.5), fract(sin(h+s.x)*43758.5), p.x);
  h.xy = mix(h.xz, h.yw, p.y);
  return mix(h.x, h.y, p.z);
}

float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

//https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float cappedCylinder(vec3 p, float h, float r){
  vec2 d = abs(vec2(length(p.xz), p.y))-vec2(h, r);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

//USING HG SDF LIBRARY!
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.0*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.0;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.0;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.0)) c = abs(c);
	return c;
}


float heart(vec3 p, float height){
  vec3 pp = p;
  
  pp.x = abs(pp.x)-1.4;
  rot(pp.xz, -PI*0.22);
  
  float kaari = cappedCylinder(pp, 1.61, height);
  pp -= vec3(-2., 0.0, 0.6);
  
  float kulma = box(pp, vec3(2.0, height, 1.01));
  
  return min(kaari, kulma);  
}


float scene(vec3 p){
  vec3 pp = p;
  float offset = 14.0;
  
  rot(pp.xy, time*0.25 + fft);
  //rot(pp.xz, time*0.25 + fft);
  
  M = abs(pModPolar(pp.xy, offset));
  pp.x -= offset;
  
  rot(pp.yz, PI*0.5);
  rot(pp.xz, fft*10.0);
  //rot(pp.xy, time*0.5);
  
  float sydan = heart(pp, 0.5);//-noise(pp+time+fft)*0.5;
  
  glow += vec3(0.4) * 0.01 / (abs(sydan) + 0.1);
  
  pp = p;
  
  for(int i = 0; i < 7; ++i){
    pp = abs(pp) - vec3(0.5, 0.1, 1.0);
    rot(pp.xz, time*0.5);
    rot(pp.yz, fft*2.0);
    rot(pp.xy, time);
    
  }
  
  float b = box(pp, vec3(0.1, 0.2, 0.1))-noise(pp+time+fft)*0.5;
  vec3 g = vec3(0.1, 0.1, 0.2) * 0.1 / (abs(b) + 0.01);
  
  float hb = heart(pp, 0.1)-noise(pp+time+fft)*0.25;
  g += vec3(0.2, 0.1, 0.1) * 0.1 / (abs(hb) + 0.01);
  
  g *= 0.5;
  
  glow += g;
  
  b = max(abs(b), 0.9);
  hb = max(abs(hb), 0.9);
  
  if(b < sydan) M = -1;
  
  return min(sydan, min(b, hb));
  
}

float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    p = ro + rd * t;
    
    if(d < E || t > FAR){
      break;
    }
  }
  
  return t;
}

vec3 normals(vec3 p){
  vec3 e = vec3(E, 0.0, 0.0);
  
  return normalize(vec3(
    scene(p+e.xyy) - scene(p-e.xyy),
    scene(p+e.yxy) - scene(p-e.yxy),
    scene(p+e.yyx) - scene(p-e.yyx)
  ));
}

vec4 shade(vec3 p, vec3 n, vec3 rd, vec3 ld){
  
  float lamb = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(rd, ld), n), 0.0);
  float spec = pow(a, 20.0);

  vec4 coll = vec4(0.8, 0.2, 0.8, 1.0)*0.25;
  vec4 cols = vec4(0.8, 0.5, 0.8, 1.0);
  
  if(M < 0){
    return coll.gbra*lamb + cols.bgra*cols;
  }
  
  if(mod(M, 2.0) == 0){
    coll = coll.grba;
    cols = cols.grba;
  }
  
  return coll*lamb + cols*spec;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 q = uv - 0.5;
	q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0.0, 0.0, 33.0);
  //vec3 ro = vec3(0.0, 0.0, 10.0);
  vec3 rt = vec3(0.0, 0.0, -FAR);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x, y, z) * vec3(q, 1.0/radians(60.0)));
  
  
	vec4 col = vec4(0, 0, 0, 1);
  float t = march(ro, rd);
  vec3 p = ro + rd * t;
  int id = 1;
  vec3 n = normals(p);
  vec3 ld = -rd;
  
  if(t < FAR){
    col = shade(p, n, rd, ld);
  }
  col += vec4(glow, 1.0)*0.5;
  
  if(q.x < 0.5 && q.x > -0.5){
    col += texture(texLynn, vec2(q.x/*+0.5 + sin(fft)*/, -q.y+0.5))*-0.5;//*(0.5*(sin(time*0.5 + fft))+0.25);
  }
  
  vec4 prev = texture(texPreviousFrame, uv);
  col = mix(col, prev, 0.5);
  
  //col = 1.5 - col;
  
  col = smoothstep(-0.2, 0.9, col);
  
	out_color = col;
}