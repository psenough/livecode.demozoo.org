#version 420 core

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define AA 1
#define hash(x) fract(sin(x) * 43758.5453123)
#define saturate(x) clamp(x, 0., 1.)
#define linearstep(a, b, t) saturate( ( (t) - (a) ) / ( (b) - (a) ) )

#define SPHERE 0
#define PILLAR 1

const int maxDepth = 6;
const float PI = acos(-1.);
const float PI2 = PI * 2.;
const float LOG10 = log(10.);
const float lightSize = 0.5;
const float BPM = 140.;
float pathSeed = 0.;
vec3 lightPos = vec3(0);

float random() {
  return hash(pathSeed++);
}

float hash12(vec2 p) {
  return hash(dot(p, vec2(12.9898, 78.233)));
}

float hash13(vec3 p) {
    return hash(dot(p, vec3(127.1, 311.7, 74.7)));
}

mat2 rotate2D(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, s, -s, c);
}

float sphIntersect(vec3 ro, vec3 rd, vec3 ce, float ra) {
  vec3 oc = ro - ce;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - ra * ra;
  float h = b * b - c;
  if(h < 0.) {
    return -1.;
  }
  return -b - sqrt(h);
}

float fetchFFT(float x) {
  float xt = exp2(mix(-5., -1., x));
  //float xt = exp2(mix(-5., -0., x));
  float v = texture(texFFTSmoothed, xt).x;
  
  v = 20. * log(v) / LOG10;
  v += 24. * x;
  
  v = linearstep(-60., 0., v);
  return v;
}

vec3 rot3D(vec3 v, float a, vec3 ax) {
  ax = normalize(ax);
  return mix(dot(ax, v) * ax, v, cos(a)) - sin(a) * cross(ax, v);
}

vec3 rayDir(vec2 uv, vec3 dir, float fov) {
  dir = normalize(dir);
  vec3 u = abs(dir.y) < 0.999 ? vec3(0, 1, 0) : vec3(0, 0, 1);
  vec3 side = normalize(cross(dir, u));
  vec3 up = cross(side, dir);
  return normalize(uv.x * side + uv.y * up + dir / tan(fov / 360. * PI));
}

void dof(inout vec3 ro, inout vec3 rd, vec3 dir, float L, float factor) {
  float r = sqrt(hash(random()));
  float a = hash(random()) * PI2;
  vec3 v = vec3(r * vec2(cos(a), sin(a)) * factor, 0);
  vec3 diro = vec3(0, 0, -1);
  float d = dot(dir, diro);
  float va = acos(d);
  vec3 vax = abs(d) < 0.999 ? cross(dir, diro) : dir.yzx;
  v = rot3D(v, va, vax);
  ro += v;
  rd = normalize(rd * L - v);
}

vec3 jitter(vec3 v, float phi, float sinTheta, float cosTheta) {
  vec3 zAxis = normalize(v);
  vec3 xAxis = normalize(cross(zAxis.yzx, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);
  return (xAxis * cos(phi) + yAxis * sin(phi)) * sinTheta + zAxis * cosTheta;
}

float height(vec2 p) {
  p += 0.5;
  float L = length(p);
  float a = (atan(p.y, p.x) + PI) / PI2;
  float h = texture(texPreviousFrame, vec2(a, L * 0.002)).a;
  return h * 5.;
  //return hash12(p) * 5.;
}

float plaIntersect(vec3 ro, vec3 rd, vec3 ce, vec3 n) {
  return -dot(ro - ce, n) / dot(rd, n);
}

float castRay(vec3 ro, vec3 rd, out vec3 n, out int type) {
  float t = 0;
  vec2 ri = 1. / rd.xz;
  vec2 rs = sign(rd.xz);
  vec2 ID = floor(ro.xz);
  
  float tLight = sphIntersect(ro, rd, lightPos, lightSize);
  //vec3 nLight = normalize(ro + tLight * rd - lightPos);
  vec3 nLight = (ro + tLight * rd - lightPos) / lightSize;
  if(tLight < 0.) {
    tLight = 1e5;
  }
  
  type = PILLAR;
  for(int i = 0; i < 30; i++) {
    vec3 rp = ro + t * rd;
    vec2 frp = rp.xz - ID - 0.5;
    
    vec2 v = (0.5 * rs - frp) * ri;
    float s = step(v.x, v.y);
    vec2 vCell = vec2(s, 1. - s);
    float tCell = dot(v, vCell);
    
    float h = height(ID);
    const float maxHeight = 5. + 1.;
    if(rp.y > maxHeight && rd.y > 0.) {
      //break;
    }
    if(rp.y < h) {
      return t;
    }
    float tTop = plaIntersect(rp, rd, vec3(0, h, 0), vec3(0, 1, 0));
    if(tTop > 0. && tTop < tCell) {
      t += tTop;
      if(t < tLight) {
        n = vec3(0, 1, 0);
        return t;
      }
    }
    
    t += tCell;
    n.y = 0.;
    n.xz = -vCell * rs;
    ID -= n.xz;
    
    if(t > tLight) {
      n = nLight;
      type = SPHERE;
      return tLight;
    }
    
  }
  
  return -1.;
}

vec3 objColor(int type) {
  return type == SPHERE ? vec3(0) : vec3(0.9);
}

vec3 emission(int type) {
  return type == SPHERE ? vec3(20) : vec3(0);
}

vec3 pathTrace(vec3 ro, vec3 rd) {
  vec3 acc = vec3(0);
  vec3 mask = vec3(1);
  
  for(int i = 0; i < maxDepth; i++) {
    vec3 n;
    int type;
    float t = castRay(ro, rd, n, type);
    if(t < 0.) {
      break;
    }
    ro += t * rd;
    vec3 objC = objColor(type);
    vec3 objE = emission(type);
    
    ro += n * 0.005;
    vec3 e = vec3(0);
    vec3 l0 = lightPos - ro;
    float cosA_max = sqrt(1. - lightSize * lightSize / dot(l0, l0));
    float cosA = mix(cosA_max, 1., random());
    vec3 l = jitter(l0, random() * PI2, sqrt(1. - cosA * cosA), cosA);
    
    vec3 N;
    float tl = castRay(ro, l, N, type);
    if(type == SPHERE) {
      vec3 em = emission(type);
      float omega = PI2 * (1. - cosA_max);
      e += (em * max(dot(l, n), 0.) * omega) / PI;
    }
    
    acc += mask * (objE + objC * e);
    mask *= objC;
    
    float ur = random();
    rd = jitter(n, random() * PI2, sqrt(1. - ur), sqrt(ur));
  }
  
  return acc;
}

float stepNoise(float x, float n) {
  const float factor = 0.3;
  float i = floor(x);
  float f = x - i;
  float u = smoothstep(0.5 - factor, 0.5 + factor, f);
  float res = mix(floor(hash(i) * n), floor(hash(i + 1.) * n), u);
  res /= (n - 1.) * 0.5;
  return res - 1.;
}

void main(void)
{
  vec3 col = vec3(0);
  
  float Time = time * BPM / 60. * 0.5;
  
  lightPos = vec3(0, 3., 0);
  lightPos += sin(vec3(3, 4, 6) * time) * vec3(2, .5, 2);
  
  //col += uv.xyy;
  
  vec3 ro = vec3(0, 5, 5);
  ro.y += stepNoise(Time, 2.);
  ro.xz *= rotate2D(time * 0.2);
  vec3 ta = vec3(0.5, 1, 0.5);
  ta.x += stepNoise(Time - 500., 3.) * 1.;
  ta.z += stepNoise(Time - 1000., 3.) * 1.;
  vec3 dir = normalize(ta - ro);
  float fov = 60.;
  fov += stepNoise(Time - 1500., 2.) * 20.;
  float L = 5.;
  
  for(int i = 0; i < AA; i++) {
    for(int j = 0; j < AA; j++) {
      vec2 of = vec2(i, j) / float(AA) - 0.5;
      vec2 uv = ((gl_FragCoord.xy + of) * 2. - v2Resolution) / min(v2Resolution.x, v2Resolution.y);
      pathSeed += hash13(vec3(uv + of, fract(time * 0.1011)));
      
      vec3 rd = rayDir(uv, dir, fov);
      vec3 ros = ro;
      vec3 rds = rd;
      dof(ros, rds, dir, L, 0.1);
      
      col += pathTrace(ros, rds);
    }
  }
  col /= float(AA * AA);
  
  col = pow(col, vec3(1. / 2.2));
  
  /*
  vec3 n;
  int type;
  float t = castRay(ro, rd, n, type);
  if(t > 0)
  col += exp(-t * t * 0.05);
  */
  
  vec2 p = gl_FragCoord.xy / v2Resolution;
  col *= 0.5 + 0.5 * pow(16.0 * p.x * p.y * (1.0 - p.x) * (1.0 - p.y), 0.5);
  
  //col += texture(texPreviousFrame, p).a;
  
  float fft = fetchFFT(p.x);
  if(p.y * 5. < fft) col += 0.3;
  
  float tex = texture(texPreviousFrame, (gl_FragCoord.xy - vec2(0, 1)) / v2Resolution).a;
  float alpha = gl_FragCoord.y < 1. ? fft : tex;
  
  //col = mix(col, texture(texPreviousFrame, p).rgb, 0.6);
  //if(col.r > 1. || col.g > 1. || col.b > 1.) col = vec3(1, 0, 0);
  
	out_color = vec4(col, alpha);
}