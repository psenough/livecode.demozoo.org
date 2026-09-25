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
uniform sampler2D texSessions;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define hash(x) fract(sin(x) * 43758.5453123)
const float PI = acos(-1.);
const float PI2 = PI * 2.;
const float BPM = 140.;
float reTime;

float hash12(vec2 p) {
  return hash(dot(p, vec2(12.9898, 78.233)));
}

mat2 rotate2D(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, s, -s, c);
}

vec3 hsv(float h, float s, float v) {
  vec3 res = fract(h + vec3(0, 2, 1) / 3.);
  res = clamp(abs(res * 6. - 3.) - 1., 0., 1.);
  res = (res - 1.) * s + 1.;
  return res * v;
}

vec3 rayDir(vec2 uv, vec3 dir, float fov) {
  dir = normalize(dir);
  vec3 u = abs(dir.y) < 0.999 ? vec3(0, 1, 0) : vec3(0, 0, 1);
  vec3 side = normalize(cross(dir, u));
  vec3 up = cross(side, dir);
  return normalize(uv.x * side + uv.y * up + dir / tan(fov / 360. * PI));
}

float sdTorus(vec3 p, float R, float r) {
  return length(vec2(p.z, length(p.xy) - R)) - r;
}

vec3 opU(vec3 d1, vec3 d2) {
  return d1.x < d2.x ? d1 : d2;
}

float sdSuperChain(vec3 p, out vec3 ID) {
  ID.xz = floor(p.xz / 2.) * 2.;
  p.xz = mod(p.xz, 2.) - 1.;
  vec2 s = sign(p.xz);
  ID.y = s.x * s.y;
  p.xz = abs(p.xz) - 0.5;
  
  const float R = 0.85;
  const float a = 0.4;
  const float r = 0.07;
  
  vec4 t1 = vec4(p.xz - 0.5, p.xz + 0.5);
  vec4 t2 = t1 * t1 * a;
  
  float d1 = sdTorus(vec3(t1.xy, p.y - (t2.x - t2.y)), R, r);
  float d2 = sdTorus(vec3(t1.yz, p.y - (t2.y - t2.z)), R, r);
  float d3 = sdTorus(vec3(t1.zw, p.y - (t2.z - t2.w)), R, r);
  float d4 = sdTorus(vec3(t1.wx, p.y - (t2.w - t2.x)), R, r);
  
  vec3 res = vec3(d1, ID.xz + s);
  res = opU(res, vec3(d2, ID.xz + vec2(0, s.y)));
  res = opU(res, vec3(d3, ID.xz));
  res = opU(res, vec3(d4, ID.xz + vec2(s.x, 0)));
  ID.xz = res.yz;
  
  //float d = min(d1, min(d2, min(d3, d4)));
  return res.x;
}

const float N = 6.;
vec3 logPolar(vec3 p, out float mul) {
  float L = length(p.xz);
  p.xz = vec2(log(L), atan(p.z, p.x));
  float scale = N / PI / sqrt(2.);
  mul = L / scale;
  p *= scale;
  p.y /= L;
  return p;
}

float map(vec3 p, out vec3 ID) {
  float d;
  float mul;
  p = logPolar(p, mul);
  d = p.y;
  p.y -= 0.4;
  /*
  p.y -= 0.3;
  ID.xz = floor(p.xz);
  p.xz = mod(p.xz, 2.) - 1.;
  vec2 s = sign(p.xz);
  ID.y = s.x * s.y;
  p.xz = abs(p.xz) - 0.5;
  d = min(d, length(p) - 0.3);
  */
  p.xz -= mod(vec2(0.8, 0.3) * reTime, sqrt(2.) * 50.);
  p.xz *= rotate2D(PI / 4.);
  d = min(d, sdSuperChain(p, ID));
  
  ID.xz = mod(ID.xz, N);
  return d * mul;
}

vec3 calcNormal(vec3 p) {
  vec2 e = vec2(0.001 * length(p.xz), 0);
  vec3 ID;
  return normalize(vec3(map(p + e.xyy, ID) - map(p - e.xyy, ID),
                        map(p + e.yxy, ID) - map(p - e.yxy, ID),
                        map(p + e.yyx, ID) - map(p - e.yyx, ID)));
}

vec3 calcColor(vec3 p, vec3 ID) {
  if(p.y < 0.01) {
    return mix(vec3(0.05), vec3(0.9), ID.y * 0.5 + 0.5);
  }
  float h = hash12(ID.xz);
  return hsv(h, 0.8, 1.);
}

float fresnelSchlick(float f0, float cosTheta) {
  return f0 + (1. - f0) * pow(1. - cosTheta, 5.);
}

vec3 raymarch(inout vec3 ro, inout vec3 rd, inout bool hit, inout vec3 refAtt) {
  vec3 col = vec3(0);
  float t = 0.;
  hit = false;
  vec3 far = vec3(0.6, 0.7, 0.9) * 0.1;
  vec3 ID;
  
  for(int i = 0; i < 100; i++) {
    float d = map(ro + t * rd, ID);
    if(abs(d) < 0.001) {
      hit = true;
      break;
    }
    if(t > 1e3) {
      return far;
    }
    t += d * 0.75;
  }
  
  ro += t * rd;
  vec3 albedo = calcColor(ro, ID);
  vec3 n = calcNormal(ro);
  vec3 ld = normalize(vec3(2, 5, -1));
  float diff = max(dot(n, ld), 0.);
  float spec = pow(max(dot(reflect(ld, n), rd), 0.), 20.);
  float invFog = exp(-t * t * 0.001);
  float h = hash12(ID.xz * 2.2761);
  float lp = pow(sin(reTime * 2. + h * PI2) * 0.5 + 0.5, 1000.) * 300.;
  col += albedo * (mix(diff, spec, 0.95) * (5. + lp) + 0.01);
  col = mix(far, col, invFog);
  
  vec3 ref = reflect(rd, n);
  col *= refAtt;
  
  refAtt *= albedo * fresnelSchlick(0.8, dot(ref, n)) * invFog;
  
  ro += 0.01 * n;
  rd = ref;
  
  return col;
}

float stepNoise(float x, float n) {
  const float factor = 0.2;
  float i = floor(x);
  float f = x - i;
  float u = smoothstep(0.5 - factor, 0.5 + factor, f);
  float res = mix(floor(hash(i) * n), floor(hash(i + 1.) * n), u);
  res /= (n - 1.) * 0.5;
  return res - 1.;
}

float luma(vec3 col) {
  return dot(col, vec3(0.299, 0.587, 0.114));
}

float triWave(float x) {
  //x -= 0.5;
  //x *= 0.5;
  float res = abs(fract(x) - 0.5) - 0.25;
  return res;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * 0.5;
  vec3 col = vec3(0);
  
  float Time = time * BPM / 60. * 0.5;
  reTime = Time + triWave(Time * 0.5 + 0.5) * 0.9;
  //reTime = Time + triWave(Time * 1. + 0.5) * 0.9;
  
  vec3 ro = vec3(0, 4, 3);
  ro.y -= stepNoise(reTime, 2.) * 2.2;
  //ro.xz *= rotate2D(time * 0.2);
  vec3 ta = vec3(0);
  ta.x = stepNoise(reTime - 500., 3.);
  ta.z = stepNoise(reTime - 1000., 3.);
  vec3 dir = ta - ro;
  float fov = 60.;
  fov += stepNoise(reTime - 1500., 2.) * 20.;
  vec3 rd = rayDir(uv, dir, fov);
  
  bool hit = false;
  vec3 refAtt = vec3(1);
  for(int i = 0; i < 3; i++) {
    col += raymarch(ro, rd, hit, refAtt);
    if(!hit) break;
  }
  
  /*
  vec2 size = textureSize(texSessions, 0);
  vec2 pos = uv / size * min(size.x, size.y);
  pos += time * 0.3;
  float h = hash12(floor(pos));
  col += texture(texSessions, pos).rgb;
  col *= hsv(uv.y + h, 0.7, 1.);
  */
  
  col = pow(col, vec3(1. / 2.2));
  
  vec2 p = gl_FragCoord.xy / v2Resolution;
  col *= 0.5 + 0.5 * pow(16. * p.x * p.y * (1. - p.x) * (1. - p.y), 0.5);
  
  float lu = luma(col);
  vec2 dis = (p - 0.5) * 0.05;
  if(mod(Time - 0.5, 2.) < 1.) {
    col.r = texture(texPreviousFrame, p + dis).a;
    col.g = texture(texPreviousFrame, p).a;
    col.b = texture(texPreviousFrame, p - dis).a;
  }
  
	out_color = vec4(col, lu);
}