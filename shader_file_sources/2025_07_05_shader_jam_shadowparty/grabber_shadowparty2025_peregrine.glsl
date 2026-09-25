#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texBlueNoise;
uniform sampler2D texChecker;
uniform sampler2D texCookie;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
const float MAXDIST = 30.;
const float EPSILON = .001;
const float PI = acos(-1.);
const float BEAT = .5;

#define noise(uv) texture(texNoise, uv).x
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define pos(x) ((x) * .5 + .5)
#define sat(x) clamp(x, 0., 1.)
#define ffti(f) texture(texFFTIntegrated, f).x
#define min2(a, b) (a.x < b.x ? a : b)

vec3 rainbow(float t) {
  vec3 a = vec3(.5), b = a, c = vec3(1), d = vec3(0., .33, .67);
  return a + b * cos(2 * PI * (c * t + d));
}

float hash21(vec2 f) { // Fabrice Neyret's Integer Hash III
  uvec2 x = floatBitsToUint(f),
        q = 1103515245U * (x >> 1U ^ x.yx);
  return float(1103515245U * (q.x ^ q.y >> 3U)) / float(0xffffffffU);
}

float sdTriangle(vec3 p) {
  vec2 h = vec2(.45, .001);
  vec3 q = abs(p);
  return max(q.z - h.y, max(q.x * .866025 + p.y * .5, -p.y) - h.x * .5);
}


vec2 lissajous(float g_amp, vec2 amp, float g_f, vec2 f, float fft_f) {
  return vec2(
    g_amp * amp.x * sin(g_f * (f.x * time + .5 * ffti(fft_f))),
    g_amp * amp.y * sin(g_f * (f.y * time + .5 * ffti(fft_f)))
  );
}

vec2 focus1 = lissajous(4, vec2(6, 3), .05, vec2(11, 7), 0.);
vec2 focus2 = lissajous(4, vec2(6, 3), .01, vec2(13, 11), .1);
vec2 focus3 = lissajous(4, vec2(6, 3), .1, vec2(5, 7), .2);


float wave(vec2 uv, float radius, float f) {
  float l = length(uv);
  float t = radius * fract(ffti(f));
  float fo = exp(-.001 * l);
  return fo * (1 - sat(.33 * pow(abs(l - t), 1)));
}

float soundWaves(vec2 uv) {
  float d1 = wave(2 * uv - focus1, 90, .1);
  float d2 = wave(2 * uv - focus2, 90, .5);\
  float d3 = wave(2 * uv - focus3, 90, .0);
  return sat(d1 + d2 + d3);
}

vec2 sdScene(vec3 p) {
  vec2 di = vec2(MAXDIST, -1);
  p.z += mix(-1, -6, pos(sin(.5 * time + .5 * ffti(0) + sin(.3 * time))));
  p.xy *= rot(sin(.2 * ffti(.05) + sin(.3 * time)));
  vec2 r = vec2(1.);
  
#define lim(uv) clamp(uv, -100., 100.)
  ivec2 id = ivec2(floor((lim(p.xy + .5 * r)) / r));
  p.xy = mod(lim(p.xy + .5 * r), r) - .5 * r;
  
  float s = MAXDIST;
  for (int i = -1; i <= 1; i++)
    for (int j = -1; j <= 1; j++) {
      ivec2 cell = ivec2(i, j);
      vec2 sum = id + cell;
      float angle = soundWaves(id + cell);
      vec3 pp = p + vec3(cell, 0.);
      pp.xz *= rot(.25 * angle * 2 * PI);
      s = min(s, sdTriangle(pp));
    }
     
  return min2(di, vec2(s, hash21(id + mod(.00000025 * time, 30.) + 1.)));
}

vec3 normal(vec3 p, float d) {
  vec2 e = d * vec2(1, -1);
#define q(s) s * sdScene(s + p).x
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}

vec2 march(vec2 uv, vec3 ro, vec3 rd, int n) {
  float td = 0;
  vec3 p = ro;
  
  float dithering = mix(.8, 1.2, noise(uv + noise(vec2(cos(time), sin(time)))));
  for (int i = 0; i < n && td < MAXDIST; i++) {
    vec2 di = sdScene(p);
    di.x *= dithering;
    if (di.x < EPSILON)
      return vec2(td, di.y);
    p += rd * di.x;
    td += di.x;
  }
  
  return vec2(-1.);
}

vec3 shade(vec3 ro, vec3 rd, vec3 p, vec3 n, float mat_index) {
  vec3 lo1 = vec3(vec2(0.), ro.z),
       ld1 = normalize(lo1 - p);
  float diffuse = max(0, dot(ld1, n));
  float specular = pow(max(0, dot(normalize(ld1 - rd), n)), 1024);
  vec3 hue = (mat_index > .8) ? rainbow(sin(2. * p.x + time) + sin(2 * p.y + time)) : vec3(1);
  return hue * (diffuse + specular);
}

vec3 mirror(vec2 uv, vec3 ro, vec3 rd) {
  vec3 c = vec3(0);
  vec2 tdi = march(uv, ro, rd, 128);
  if (tdi.x > 0) {
    vec3 p = ro + tdi.x * rd,
         n = normal(p, EPSILON);
    c = shade(ro, rd, p, n, tdi.y);
    vec3 ro_refl = p * 2. * EPSILON * n;
    vec3 rd_refl = reflect(rd, n);
    vec2 tdi_refl = march(uv, ro_refl, rd_refl, 32);
    if (tdi_refl.x > 0.) {
      vec3 p_refl = ro_refl + rd_refl * tdi_refl.x;
      vec3 n_refl = normal(p_refl, EPSILON);
      c += shade(ro_refl, rd_refl, p_refl, n_refl, tdi_refl.y);
    } 
  }
  
  if (fract(.5 * time + .5 * ffti(0) + mix(.1, .2, pos(sin(.1 * time))) * length(uv)) > .8) {
    c = 1 - c;
  }
  
  return sat(c);
}
  
vec3 wireframe(vec2 uv, vec3 ro, vec3 rd) {
    vec3 c = vec3(0);
    float s = 0.;
    float td = 0;
    vec3 p = ro;
    bool hit = false, past = false;
    
    for (float i = 0.; i < 128.; i++) {
      vec2 di = sdScene(p);
      
      if(abs(di.x) < EPSILON) {
        float edge = .003 * td * clamp(800./v2Resolution.x, 1., 2.5);
        float edgeAmount = length(normal(p, .015) - normal(p, edge));
        s *= -1.;
        di.x = .001;
        past = true;
      }
      
      if (abs(di.x) < .05) hit = true;
      
      if (abs(di.x) > .1 && hit && !past) {
        c += (di.y > .8) ? rainbow(hash21(vec2(di.y, 1))) : vec3(1);
        break;
      }
      
      if (td > MAXDIST) break;
      td += abs(di.x);
      p  = ro + rd * td;
   }
     
  return sat(c);
}

mat3 lookAt(vec3 ro, vec3 rt) {
  vec3 f = normalize(rt - ro),
       r = cross(vec3(0, 1, 0), f),
       u = cross(f, r);
  return mat3(r, u, f);
}

void main(void) {
	vec2 uv = (2 * gl_FragCoord.xy - v2Resolution.xy) / min(v2Resolution.x, v2Resolution.y);
  vec3 c = vec3(0),
       ro = vec3(0, 0, -6),
       rt = vec3(0),
       rd = normalize(lookAt(ro, rt) * vec3(uv, 1));
  
  if (fract(.05 * time + .25 * ffti(0) - mix(.1, .8, fract(.05 * time)) * length(uv)) > .5)
    c = mirror(uv, ro, rd);
  else
    c = wireframe(uv, ro, rd);
  
  c = mix(c, texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy + .001 * uv).rgb, .8);
  
	out_color = vec4(c, 1);
}

















