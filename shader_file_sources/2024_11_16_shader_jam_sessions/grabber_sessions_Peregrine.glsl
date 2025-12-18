#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCookie;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t = fGlobalTime;

#define IOR 2. //crystal ball!
#define EPSILON 0.001
#define MAX_DIST 20.

#define fft(f) texture(texFFTSmoothed, f).x

// hello, konnichiwa people
// it's past 9 a.m. here in paris, france and i haven't slept enough
// let's see what i can do for your enjoyment!

float fbm(vec2 p, float H, int octaves) {
  float G = exp2(-H);
  float f = 1., a = 1., t = 0.;
  
  for(int i = 0; i < octaves; i++) {
    t += a * texture(texNoise, f * p).x;
    f *= 2.;
    a *= G;
  }
  
  return t;
}

float de(vec3 p, float hollow) {
  float d = MAX_DIST;
  float period = floor(mod(t * .1, 4.)) + 2.;
  float s = length(p) - 1. - 2. * fft(.01);
  s -= 2.6 * fbm(p.xy * period/200. + t * .001, .1, 4);
  float s2 = length(p) - 1. - 2. * fft(.7);
  s2 -= 2. * fbm(p.xy * 2.*period/1000. + t * .005, .3, 4);
  
  d = min(d, min(s, s2));
  return d * hollow;
}

struct Raymarching {
  bool hit;
  vec3 p, n;
  float i, td, id, hollow;
};

Raymarching march(vec3 ro, vec3 rd, float steps, float hollow) {
  Raymarching r;
  r.hit = false;
  r.p = ro;
  r.td = 0.;
  r.hollow = hollow;
  
  for(r.i = 0.; r.i < steps && r.td < MAX_DIST; r.i++) {
    r.p = ro + r.td * rd;
    float d = de(r.p, hollow);
    if(d < EPSILON) {
      r.hit = true;
      break;
    }
    r.td += d;
  }
  
  return r;
}

// one of my earliest bits of GLSL
vec2 lissajous(float a, float b, float speed) {
  return vec2(
    sin(a * t * speed),
    cos(b * t * speed)
  );
}

vec3 moire(vec2 p) {
  vec2 focus1 = lissajous(3., 2., .1),
       focus2 = lissajous(5., 4., .1);
  int ring_width = 4;
  float scale = 100.;
  
  int interference = int(scale * distance(focus1, p))
                   ^ int(scale * distance(focus2, p));
  interference /= ring_width;
  interference %= 2;
  return (interference == 0) ? vec3(0.) : vec3(.1);
 }

vec3 normal(vec3 p, float hollow) {
  vec2 e = EPSILON * vec2(1., -1.);
#define q(s) (s * de(p + s, hollow).x)
  return normalize(q(e.xyy) + q(e.yxy) + q(e.yyx) + q(e.xxx));
}  

float ambient_occlusion(vec3 p, vec3 n, float hollow) {
  float dist = 0.17,
        occlusion = 1.;
  for(int i = 0; i < 10; i++) {
    occlusion = min(occlusion, de(p + dist * n, hollow)/dist);
    dist *= .6;
  }
  
  return max(occlusion, 0.);
}

float soft_shadow(vec3 ro, vec3 rd, float softness, float hollow) {
  float s = 1.,
        t = 0.;
  for(int i = 0; i < 40; i++) {
    float dist = de(ro + rd * t, hollow);
    s = min(s, .5 + (.5 * dist)/(softness * t));
    if(s < 0.) break;
    t += dist + .0001;
  }
  
  s = max(s, 0.);
  return s * s * (3. - (2. * s));
}

float shade(Raymarching r, vec3 rd, vec3 lo, float hollow) {
  vec3 ld = normalize(lo - r.p),
       hv = normalize(ld - rd);
  float ambient = 0.0025,
        occlusion = ambient_occlusion(r.p, r.n, hollow),
        shadow = soft_shadow(r.p, ld, .15, hollow),
        diffuse = max(0., dot(ld, r.n)),
        specular = pow(max(0., dot(hv, r.n)), 128.),
        fresnel = 1. - abs(dot(rd, r.n));
  return ambient + diffuse * occlusion * shadow + fresnel + specular * shadow;
}
 
vec3 render(vec2 uv) {
  vec2 offset = .2 * vec2(fft(0.05), fft(.5));
  vec3 c = vec3(0.),
       ro = vec3(0., 0., -5.),
       rd = normalize(vec3(uv, 1.)),
       lo = vec3(cos(t), sin(t), -1.) * 2.;
  
  c.r = moire(uv + offset).r;
  c.g = moire(uv).g;
  c.b = moire(uv - offset).b;
  
  Raymarching r = march(ro, rd, 128., 1.);
  if (r.hit) {
    vec3 tint = vec3(.5, .15, .9);
    r.n = normal(r.p, 1.);
    c += tint * shade(r, rd, lo, 1.);
    vec3 ro_in = r.p - 2. * EPSILON * r.n,
         rd_in = refract(rd, r.n, 1./IOR);
    Raymarching r_in = march(ro_in, rd_in, 64., -1.);
    if (r_in.hit) {
      r_in.n = normal(r_in.p, -1.);
      c += tint * shade(r_in, rd_in, lo, -1.);
      vec3 ro_out = rd_in.p - 2. * EPSILON * r_in.n,
           rd_out = refract(rd_in, r_in.n, IOR);
      c.r += moire(uv + rd_out.xy + offset).r;
      c.g += moire(uv + rd_out.xy).g;
      c.b += moire(uv + rd_out.xy - offset).b;
    }
  }
  
  c *= exp(-5. * length(uv));
  return c;
}
 
void main(void) {
  vec2 uv = vec2(2. * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.yy;
	vec3 c = render(uv);
  c = pow(c, vec3(1./2.2));
	out_color = vec4(c, 1.);
}