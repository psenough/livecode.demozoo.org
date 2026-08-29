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

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.25).r;

const float PI = 3.14159265;

const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 64;

float M = 0.0;
vec3 glow = vec3(0.0);

struct Material{
  vec3 l;
  float li;
  vec3 s;
  float si;
};

Material red(){
  
  Material m;
  m.l = vec3(1.0, 0.0, 0.0);
  m.li = 0.5;
  m.s = vec3(1.2, 0.2, 0.2);
  m.si = 0.5;
  
  return m;
}

Material orange(){
  
  Material m;
  m.l = vec3(1.0, 0.5, 0.0);
  m.li = 0.5;
  m.s = vec3(1.2, 0.7, 0.2);
  m.si = 0.5;
  
  return m;
}

Material yellow(){
  
  Material m;
  m.l = vec3(1.0, 0.8, 0.0);
  m.li = 0.5;
  m.s = vec3(1.2, 1.0, 0.2);
  m.si = 0.5;
  
  return m;
}

Material green(){
  
  Material m;
  m.l = vec3(0.0, 1.0, 0.0);
  m.li = 0.5;
  m.s = vec3(0.2, 1.2, 0.2);
  m.si = 0.5;
  
  return m;
}

Material blue(){
  
  Material m;
  m.l = vec3(0.0, 0.0, 1.0);
  m.li = 0.5;
  m.s = vec3(0.2, 0.2, 1.2);
  m.si = 0.5;
  
  return m;
}

Material purple(){
  
  Material m;
  m.l = vec3(0.8, 0.0, 0.6);
  m.li = 0.5;
  m.s = vec3(1.0, 0.2, 0.8);
  m.si = 0.5;
  
  return m;
}

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

//https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float cappedCylinder(vec3 p, float h, float r){
  vec2 d = abs(vec2(length(p.xz), p.y))-vec2(h, r);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
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
  float offset = 12.0;
  
  //rot(pp.xz, time);
  rot(pp.yz, PI*0.5);
  float isoSydan = heart(pp, 0.8)-noise(p+time+fft)*0.5;
  isoSydan += sin(time+fft)*0.1;
  pp = p;
  
  float id = floor((pp.z + offset*0.5) / offset);
  pp.z = mod(pp.z+offset*0.5, offset)-offset*0.5;
  
  if(mod(id, 2.0) == 0){
    rot(pp.xy, time+fft);
  }
  else{
    rot(pp.xy, -time-fft);
  }
  
  M = pModPolar(pp.xy, offset);
  pp.x -= offset;
  
  rot(pp.yz, PI*0.5);
  float sydan = heart(pp, 0.6)-noise(p)*0.2;
  
  //pp = p;
  
  for(int i = 0; i < 2; ++i){
    pp = abs(pp)-vec3(4.);
    rot(pp.xz, time);
    rot(pp.xy, fft);
    rot(pp.yx, fft + time);
  }
  
  //float b = box(pp, vec3(1.0, 1.0, FAR*2.0));
  float b = heart(pp-vec3(1.0, .0, -1.0), 0.5);
  
  vec3 g = vec3(0.8, 0.1, 0.1) * 0.01 / (abs(sydan) + 0.03);
  g += vec3(0.8, 0.1, 0.1) * 0.01 / (abs(isoSydan) + 0.05);
  g += vec3(0.8, 0.1, 0.9) * 0.05 / (abs(b) + 0.01);
  g *= 0.33;
  glow += g;
  
  if(isoSydan < sydan){
    M = -1.;
  }
  
  
  return min(sydan, isoSydan);
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


vec3 normals(vec3 p, float epsilon){
  vec3 e = vec3(epsilon, 0.0, 0.0);
  
  return normalize(vec3(
    scene(p+e.xyy) - scene(p-e.xyy),
    scene(p+e.yxy) - scene(p-e.yxy),
    scene(p+e.yyx) - scene(p-e.yyx)
  ));
}


//From Flopine <3 <3 <3
//https://www.shadertoy.com/view/sdfyWl
float ao(float e, vec3 p, vec3 n){
  return scene(p+e*n)/e;
}

vec3 shade(vec3 p, vec3 rd, vec3 ld){
  
  vec3 n = normals(p, E);
  float lamb = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(rd, ld), n), 0.0);
  float spec = pow(a, 20.0);
  
  vec3 coll = vec3(0.8, 0.4, 0.5)*0.25;
  vec3 cols = vec3(0.8, 0.0, 0.0);
  
  float aoc = ao(0.1, p, n) + ao(0.2, p, n) + ao(0.5, p, n);
  
  Material m = red();
  if(M == -1.0){
     m = orange();
  }
  else if(abs(M) > 0.0 && abs(M) <= 1.0){
    m = orange();
  }
  else if(abs(M) > 1.0 && abs(M) <= 2.0){
    m = yellow();
  }
  else if(abs(M) > 2.0 && abs(M) <= 3.0){
    m = green();
  }
  else if(abs(M) > 3.0 && abs(M) <= 4.0){
    m = blue();
  }
  else if(abs(M) > 4.0 && abs(M) <= 5.0){
    m = purple();
  }
  
  return (m.li * m.l * lamb + m.si * m.s * spec);//*aoc;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = uv - 0.5;
	q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0.0, 0.0, 18.0);
  vec3 rt = vec3(0.0, 0.0, -FAR);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x, y, z) * vec3(q, 1.0/radians(60.0)));
  
  float t = march(ro, rd);
  vec3 p = ro + rd * t;
  
  vec3 ld = -z;
  
  vec3 col = vec3(0.1, 0.0, 0.1);
  
  if(t < FAR){
    col = shade(p, rd, ld);
  }
  col +=glow*0.25;
  
  col = smoothstep(-0.1, 0.9, col);
  
  vec4 pcol = vec4(0.0);
  vec2 puv = vec2(2.0/v2Resolution.x, 2.0/v2Resolution.y);
  vec4 kertoimet = vec4(0.1531, 0.12245, 0.0918, 0.051);
  pcol = texture2D(texPreviousFrame, uv) * 0.1633;
  pcol += texture2D(texPreviousFrame, uv) * 0.1633;
  for(int i = 0; i < 4; ++i){
    pcol += texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i];
  }
  col += pcol.rgb;
  col *= 0.38;
  col = mix(col, texture2D(texPreviousFrame, uv).rgb, 0.1);
  
  col *= smoothstep(0.8, 0.1*0.799, distance(uv, vec2(0.5))*(0.6 + 0.1));

	out_color = vec4(col, 1.0);
}