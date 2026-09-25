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

//#define time fGlobalTime
#define hash(x) fract(sin(x) * 1e4)

const float PI = acos(-1.);
const float PI2 = PI * 2.;
const float EPS = 0.0001;
const float FAR = 1e5;
const float numSamples = 8.;
const float numSph = 20.;
const float lightSize = 0.1;
const float minRa = 0.1;
const float BPM = 175.;
const vec3 boxSize = vec3(2, 1, 2);

float time;
float Time;
vec3 lightPos;

float hash12(vec2 p) {
  return hash(dot(p, vec2(14.6121, 11.7232)));
}

vec3 rotate3D(vec3 v, float a, vec3 ax) {
  ax = normalize(ax);
  return mix(dot(ax, v) * ax, v, cos(a)) - sin(a) * cross(ax, v);
}

float noise3D(vec3 p) {
  vec3 i = floor(p);
  vec3 f = fract(p);
  vec3 b = vec3(31, 47, 37);
  vec4 h = vec4(0, b.yz, b.y + b.z) + dot(i, b);
  f = f * f * (3. - 2. * f);
  h = mix(hash(h), hash(h + b.x), f.x);
  h.xy = mix(h.xz, h.yw, f.y);
  return mix(h.x, h.y, f.z);
}

float ease(float x, float s) {
  return floor(x) + smoothstep(0.5 - s, 0.5 + s, fract(x));
}

vec4 sphIntersect(vec3 ro, vec3 rd, vec3 ce, float ra) {
  float t = -1.;
  vec3 n = vec3(0, 1, 0);
  
  vec3 oc = ro - ce;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - ra * ra;
  float h = b * b - c;
  if(h < 0.) {
    return vec4(n, t);
  }
  
  t = -b - sqrt(h);
  n = (ro + t * rd - ce) / ra;
  return vec4(n, t);
}

float objNoise(vec3 p, float ID) {
  float h = noise3D((p + ID * 2.) * 2.) * 2.;
  return abs(h - 1.);
}

float bumpFunc(vec3 p, float ID, float thd) {
  float g = objNoise(p, ID) / thd;
  return sqrt(1. - g * g);
}

vec3 bumpMap(vec3 p, vec3 n, float ID, float thd) {
  const vec2 e = vec2(EPS, 0.);
  float factor = 0.02;
  float ref = bumpFunc(p, ID, thd);
  vec3 grad = (vec3(bumpFunc(p - e.xyy, ID, thd),
                    bumpFunc(p - e.yxy, ID, thd),
                    bumpFunc(p - e.yyx, ID, thd)) - ref) / e.x;
  grad -= n * dot(n, grad);
  return normalize(n + grad * factor);
}

vec4 concSphIntersect(vec3 ro, vec3 rd) {
  float t = -1.;
  vec3 n = vec3(0, 1, 0);
  
  float b = dot(ro, rd);
  float ro2 = dot(ro, ro);
  float rc = sqrt(ro2);
  float ho = b * b - ro2;
  
  for(float i = 0.; i < numSph * 2.; i++) {
    float k = numSph - i;
    float s = 1.;
    if(i >= numSph) {
      k = i - numSph + 1.;
      s = -1.;
    }
    
    float T = ease(Time * .5 - 0.5, .2) + time * .5;
    float Tr = T * 5.;
    float ra = (k + fract(Tr) - 1.) / numSph;
    ra = exp(ra * log(1. / minRa)) * minRa;
    
    float h = ho + ra * ra;
    if(h < 0.) {
      if(i < numSph) {
        i = numSph * 2. - i - 1.;
      }
      continue;
    }
    
    float ts = -b - s * sqrt(h);
    if(ts < 0.) {
      continue;
    }
    
    vec3 rp = ro + ts * rd;
    float lrp = length(rp);
    vec3 nrp = rp / lrp;
    
    float ID = mod(k - floor(Tr), 500.);
    float a = T * 0.3 + ID * 2.3;
    vec3 ax = normalize(hash(vec3(1, 2, 3) * ID) - .5);
    vec3 npos = rotate3D(nrp, a, ax);
    float g = objNoise(npos, ID);
    float thd = mix(0.1, 0., lrp);
    
    if(g < thd) {
      t = ts;
      n = bumpMap(npos, s * npos, ID, thd);
      n = rotate3D(n, -a, ax);
      break;
    }
  }
  
  return vec4(n, t);
}

vec4 boxIntersect(vec3 ro, vec3 rd) {
  vec3 srd = sign(rd);
  vec3 v = (srd * boxSize - ro) / rd;
  float t = min(v.x, min(v.y, v.z));
  vec3 n = -srd * step(v, v.yzx) * step(v, v.zxy);
  return vec4(n, t);
}

vec4 castRay(vec3 ro, vec3 rd) {
  float t = FAR;
  vec3 n = vec3(0, 1, 0);
  
  vec4 tmp = concSphIntersect(ro, rd);
  if(tmp.w > 0.) {
    t = tmp.w;
    n = tmp.xyz;
  }
  
  tmp = sphIntersect(ro, rd, lightPos, lightSize);
  if(tmp.w > 0. && tmp.w < t) {
    t = tmp.w;
    n = tmp.xyz;
  }
  
  tmp = boxIntersect(ro, rd);
  if(tmp.w < t) {
    t = tmp.w;
    n = tmp.xyz;
  }
  
  return vec4(n, t);
}

float fakeAO(vec3 p) {
  vec3 q = abs(abs(p) - boxSize);
  float d = max(q.x, max(q.y, q.z));
  d = q.x + q.y + q.z - d;
  float ao = mix(.1, .7, d);
  ao = min(ao, dot(p, p));
  ao = min(ao, length(p.xz) * 1. + .3);
  return clamp(ao, 0., 1.);
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 col = vec3(0);
  
  vec4 res = castRay(ro, rd);
  float t = res.w;
  vec3 n = res.xyz;
  
  vec3 rp = ro + t * rd;
  vec3 lv = lightPos - rp;
  float L = length(lv);
  if(L < lightSize + EPS) {
    col = vec3(1);
  }
  
  vec3 albedo = vec3(0.9);
  float amp = pow(sin(fract(Time) * PI2) * .5 + .5, 3.) * 3. + 0.05;
  float po = amp / (L * L);
  vec3 ld = lv / L;
  float diff = max(dot(n, ld), 0.);
  float spec = pow(max(dot(reflect(ld, n), rd), 0.), 30.);
  float sh = 1.;
  if(castRay(rp + n * EPS, ld).w < L - lightSize - EPS * 2.) {
    sh = 0.1;
  }
  float metal = dot(rp, rp) < 1. ? 0.7: 0.9;
  float ao = fakeAO(rp);
  col += albedo * mix(diff, spec, metal) * po * sh;
  col += albedo * ao * (amp * 0.01);
  
  return col;
}

float stepNoise(float x, float n) {
  float i = floor(x);
  float s = 0.2;
  float u = smoothstep(.5 - s, .5 + s, fract(x));
  float res = mix(floor(hash(i) * n), floor(hash(i + 1.) * n), u);
  res /= (n - 1.) * 0.5;
  return res - 1.;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * .5;
  vec3 col = vec3(0);
  
  //col = uv.xyy;
  //col += step(noise3D(vec3(uv * 3., fGlobalTime)), .5) * .5 + .5;
  
  for(float i = 0.; i < numSamples; i++) {
    time = fGlobalTime;
    vec2 seed = gl_FragCoord.xy + mod(time, 500.) * (i + 1.);
    time += hash12(seed) * .03;
    
    Time = time * BPM / 60.;
    lightPos = sin(normalize(vec3(3, 5, 9)) * time * 5.) * .5;
    
    vec3 ro = vec3(0, 0, 2);
    ro = rotate3D(ro, time * .3, vec3(0, 1, 0));
    ro.y += stepNoise(Time * .5, 3.) * .9;
    
    vec3 ta = vec3(0);
    ta.x += stepNoise(Time * .5 -  500., 3.) * .5;
    ta.y += stepNoise(Time * .5 - 1000., 3.) * .5;
    ta.z += stepNoise(Time * .5 - 1500., 3.) * .5;
    
    vec3 dir = normalize(ta - ro);
    vec3 side = normalize(cross(dir, vec3(0, 1, 0)));
    vec3 up = cross(side, dir);
    float fov = 60.;
    fov += stepNoise(Time * .5 - 2000., 2.) * 30.;
    vec3 rd = normalize(uv.x * side + uv.y * up + dir / tan(fov / 360. * PI));
    
    float L = length(ta - ro);
    vec3 fp = ro + L * rd;
    vec3 ros = ro;
    float r = sqrt(hash12(seed));
    float a = hash12(seed * 1.2) * PI2;
    
    vec3 v = vec3(r * vec2(cos(a), sin(a)) * L * 0.03, 0);
    vec3 diro = vec3(0, 0, -1);
    float va = dot(dir, diro);
    vec3 vax = cross(dir, diro);
    v = rotate3D(v, va, vax);
    
    //ros.xy += r * vec2(cos(a), sin(a)) * L * 0.03;
    ros += v;
    vec3 rds = normalize(fp - ros);
    
    col += render(ros, rds);
  }
  
  col /= numSamples;
  col = pow(col, vec3(1. / 2.2));
	out_color = vec4(col, 1.);
}