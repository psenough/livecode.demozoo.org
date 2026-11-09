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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define hash(x) fract(sin(x) * 43758.5453)
const float PI = acos(-1.);
const float PI2 = acos(-1.) * 2.;

const float BPM = 130.;
const float EPS = 0.001;
const float rSph = 0.3;
const float rCyl = 0.1;
const float cFFT = 10.;
const float maxHeight = cFFT + rSph * 2.;
const float lightSize = 0.5;
vec3 lightPos;

mat2 rotate2D(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c, s, -s, c);
}

float sphIntersect(vec3 ro, vec3 rd, vec3 ce, float ra) {
  vec3 oc = ro - ce;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - ra * ra;
  float h = b * b - c;
  if(h < 0.) return -1.;
  return -b - sqrt(h);
}

float cylIntersect(vec3 ro, vec3 rd, vec3 ca, float cr) {
  float rcaca = 1. / dot(ca, ca);
  float card = dot(ca, rd);
  float caro = dot(ca, ro);
  float a = 1. - card * card * rcaca;
  float b = dot(ro, rd) - caro * card * rcaca;
  float c = dot(ro, ro) - caro * caro * rcaca - cr * cr;
  float h = b * b - a * c;
  if(h < 0.) return -1.;
  float t = (-b - sqrt(h)) / a;
  if(caro + t * card < 0.) return -1.;
  return t;
}

float height(vec2 p) {
  p += 0.5;
  float L = length(p);
  float theta = (atan(p.y, p.x) + PI) / PI2;
  float fft = texture(texPreviousFrame, vec2(L * 0.002, theta)).a;
  return fft * cFFT + rSph;
}

float objIntersect(vec3 ro, vec3 rd, vec2 ID, float tCell) {
  float tObj = 1e5;
  
  float h = height(ID);
  float h1 = height(ID + vec2(1, 0));
  float h2 = height(ID + vec2(-1, 0));
  float h3 = height(ID + vec2(0, 1));
  float h4 = height(ID + vec2(0, -1));
  float maxH = max(max(max(max(h, h1), h2), h3), h4) + rSph;
  
  if(rd.y > 0. && ro.y > maxH) {
    return tObj;
  }
  if(rd.y < 0. && ro.y + rd.y * tCell > maxH) {
    return tObj;
  }
  
  ro.y -= h;
  float tSph = sphIntersect(ro, rd, vec3(0), rSph);
  tObj = tSph > 0. ? tSph : tObj;
  
  float res = cylIntersect(ro, rd, vec3(1, h1 - h, 0), rCyl);
  tObj = res > 0. && res < tObj ? res : tObj;
  res = cylIntersect(ro, rd, vec3(-1, h2 - h, 0), rCyl);
  tObj = res > 0. && res < tObj ? res : tObj;
  res = cylIntersect(ro, rd, vec3(0, h3 - h, 1), rCyl);
  tObj = res > 0. && res < tObj ? res : tObj;
  res = cylIntersect(ro, rd, vec3(0, h4 - h, -1), rCyl);
  tObj = res > 0. && res < tObj ? res : tObj;
  
  return tObj;
}

float castRay(vec3 ro, vec3 rd, const int itr) {
  float t = 0.;
  vec2 ri = 1. / rd.xz;
  vec2 rs = sign(rd.xz);
  float tLimit = 1e5;
  
  if(ro.y > maxHeight && rd.y > 0.) {
    return tLimit;
  }
  
  float temp = (maxHeight - ro.y) / rd.y;
  tLimit = temp > 0. && rd.y > 0. ? temp : tLimit;
  
  float tFloor = -ro.y / rd.y;
  tLimit = tFloor > 0. ? tFloor : tLimit;
  
  float tLight = sphIntersect(ro, rd, lightPos, lightSize);
  tLimit = tLight > 0. && tLight < tLimit ? tLight : tLimit;
  
  vec2 ID = floor(ro.xz);
  for(int i = 0; i < itr; i++) {
    if(t >= tLimit) {
      break;
    }
    vec3 rp = ro + t * rd;
    
    vec2 frp = rp.xz - ID - 0.5;
    vec2 v = (0.5 * rs - frp) * ri;
    vec2 vCell = vec2(step(v.x, v.y), step(v.y, v.x));
    float tCell = dot(v, vCell);
    float tObj = objIntersect(vec3(frp.x, rp.y, frp.y), rd, ID, tCell);
    
    if(tObj < tCell) {
      return min(t + tObj, tLimit);
    }
    
    t += tCell;
    ID += vCell * rs;
  }
  
  return tLimit;
}

vec3 cylNormal(vec3 p, vec3 ca, float cr) {
  return (p - ca * dot(p, ca) / dot(ca, ca)) / cr;
}

vec3 objNormal(vec3 p) {
  vec3 normal = vec3(0, 1, 0);
  
  if(p.y < EPS) {
    return normal;
  }
  
  vec3 pos = p - lightPos;
  if(dot(pos, pos) < (lightSize + EPS) * (lightSize + EPS)) {
    return pos / lightSize;
  }
  
  vec2 ID = floor(p.xz);
  float h = height(ID);
  p.xz = fract(p.xz) - 0.5;
  p.y -= h;
  
  if(dot(p, p) < (rSph + EPS) * (rSph + EPS)) {
    return p / rSph;
  }
  
  float minDis = 1e5;
  vec3 ca = vec3(1, height(ID + vec2(1, 0)) - h, 0);
  vec3 temp = cylNormal(p, ca, rCyl);
  float dis = abs(dot(temp, temp) - 1.);
  if(dis < minDis) {
    minDis = dis;
    normal = temp;
  }
  ca = vec3(-1, height(ID + vec2(-1, 0)) - h, 0);
  temp = cylNormal(p, ca, rCyl);
  dis = abs(dot(temp, temp) - 1.);
  if(dis < minDis) {
    minDis = dis;
    normal = temp;
  }
  ca = vec3(0, height(ID + vec2(0, 1)) - h, 1);
  temp = cylNormal(p, ca, rCyl);
  dis = abs(dot(temp, temp) - 1.);
  if(dis < minDis) {
    minDis = dis;
    normal = temp;
  }
  ca = vec3(0, height(ID + vec2(0, -1)) - h, -1);
  temp = cylNormal(p, ca, rCyl);
  dis = abs(dot(temp, temp) - 1.);
  if(dis < minDis) {
    minDis = dis;
    normal = temp;
  }
  
  return normal;
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 col = vec3(0);
  vec3 amb = vec3(0.01);
  
  float t = (maxHeight - ro.y) / rd.y;
  if(rd.y < 0. && t > 0.) {
    ro += t * rd;
  }
  
  t = castRay(ro, rd, 100);
  vec3 rp = ro + t * rd;
  if(rp.y > maxHeight - EPS) {
    return amb;
  }
  
  vec3 n = objNormal(rp);
  vec3 ld = lightPos - rp;
  float L = length(ld);
  if(L < lightSize + EPS) {
    return vec3(1);
  }
  ld /= L;
  
  float amp = pow(sin(fract(time * BPM / 60.) * PI2) * 0.5 + 0.5, 2.);
  float lp = (50. + amp * 450.) / (L * L);
  
  float diff = max(dot(n, ld), 0.);
  float spec = pow(max(dot(reflect(ld, n), rd), 0.), 20.);
  
  float sh = 1.;
  t = castRay(rp + n * EPS * 0.5, ld, 100);
  if(t < L - lightSize - EPS) {
    sh = 0.2;
  }
  
  float m = 0.8;
  col = amb + (diff * (1. - m) + spec * m) * lp * sh;
  
  return col;
}

float stepNoise(float x, float n) {
  n = max(n, 2.);
  float i = floor(x);
  float s = 0.2;
  float u = smoothstep(0.5 - s, 0.5 + s, fract(x));
  float res = mix(floor(hash(i) * n), floor(hash(i + 1.) * n), u);
  res = res / (n - 1.) - 0.5;
  return res;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * 0.5;
  vec3 col = vec3(0);
  
  lightPos.xz = sin(vec2(7, 9) * time * 0.2) * 5.;
  lightPos.y = 7. + sin(time * 0.5) * 3.;
  
  vec3 ro = vec3(0, 15, 15);
  
  float T = time * BPM / 60. / 2.;
  float na = stepNoise(T, 2.);
  float a = na + sign(na) * T * 0.2;
  
  ro.y += stepNoise(T + 500., 5.) * 20.;
  ro.z += stepNoise(T + 1000., 5.) * 10.;
  ro.xz *= rotate2D(a);
  
  vec3 ta = vec3(0, 5, 0);
  vec3 dir = normalize(ta - ro);
  vec3 side = normalize(cross(dir, vec3(0, 1, 0)));
  vec3 up = cross(side, dir);
  float fov = 50.;
  fov += stepNoise(T + 1500., 3.) * 20.;
  vec3 rd = normalize(uv.x * side + uv.y * up + dir / tan(fov / 360. * PI));
  
  col += render(ro, rd);
  col = clamp(col, 0., 1.);
  col = pow(col, vec3(1. / 2.2));
  col = mix(col, texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution).rgb, 0.7);
  
  float fft = texture(texFFTSmoothed, pow(gl_FragCoord.y / v2Resolution.y, 4.) * 0.1).r;
  float ave = 0.;
  float N = 300.;
  for(float i = 0.; i < N; i++) {
    ave += texture(texPreviousFrame, vec2(i + 0.5, gl_FragCoord.y) / v2Resolution).a;
  }
  if(ave > 0.) {
    ave /= N;
    fft /= ave;
  }
  
  //col += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution).a * 0.1;
  
	out_color = vec4(col, 1.);
  
  if(gl_FragCoord.x < 0.6) {
    out_color.a = fft;
  } else {
    out_color.a = texture(texPreviousFrame, (gl_FragCoord.xy - vec2(1, 0)) / v2Resolution).a;
  }
}