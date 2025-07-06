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

#define hash(x) fract(sin(x) * 5e3)

const float PI = acos(-1.);
const float PI2 = acos(-1.) * 2.;
const float BPM = 135.;
const float EPS = 0.0001;
float T = time * BPM / 60.;
const float lightSize = 0.2;
vec3 lightPos;

float hash12(vec2 p) {
  return fract(sin(dot(p, vec2(23, 11))) * 4e3);
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

float castRay(vec3 ro, vec3 rd, out vec3 normal) {
  float t = 1e5;
  
  float a = 1.0 - rd.z * rd.z;
  float b = dot(ro.xy, rd.xy);
  float co = dot(ro.xy, ro.xy);
  float rc = sqrt(co);
  
  const int N = 10;
  const float delta = 1. / float(N);
  for(int i = 0; i < N * 2; i++) {
    float n = float(N - i);
    float s = 1.;
    if(i >= N) {
      n = float(i - N + 1);
      s = -1.;
    }
    float ra = n * delta;
    
    if(b > ra) {
      break;
    }
    
    if(i == 0 && rc < ra) {
      int nc = int(rc / delta);
      if(b < 0) {
        i = N - nc - 1;
      } else {
        i = N + nc - 1;
      }
      continue;
    }
        
    float c = co - ra * ra;
    float h = b * b - a * c;
    if(h < 0.) {
      if(i < N) {
        i = N * 2 - i - 1;
      }
      continue;
    }
    
    float tc = (-b - s * sqrt(h)) / a;
    if(tc < 1e-5) {
      continue;
    }
    
    vec3 rp = ro + tc * rd;
    float theta = atan(rp.y, rp.x) + time * sin(n) * .5;
    theta = mod(theta, PI2);
    
    rp.z -= time * .5;
    rp.z = fract(rp.z / 500.) * 500.;
    vec2 p = vec2(theta, rp.z * 2.) / PI2 * 6.;
    for(int j = 0; j < 5; j++) {
      if(hash12(floor(p)) < 0.5) {
        break;
      }
      p *= 2.;
    }
    
    if(hash12(floor(p) + n * 500. * PI) < 0.1) {
      t = tc;
      normal = normalize(vec3(s * rp.xy, 0));
      break;
    }
    
  }
  
  float ts = sphIntersect(ro, rd, lightPos, lightSize);
  if(ts > 0. && ts < t) {
    t = ts;
    normal = normalize(ro + t * rd - lightPos);
  }
  
  vec2 srd = sign(rd.xy);
  vec2 v = (srd * vec2(4, 1.6) - ro.xy) / rd.xy;
  float tw = min(v.x, v.y);
  if(tw < t) {
    t = tw;
    normal = v.x < v.y ? vec3(-srd.x, 0, 0) : vec3(0, -srd.y, 0);
  }
  
  return t;
}

float fs(float f0, float cosTheta) {
  return f0 + (1. - f0) * pow(1. - cosTheta, 5.);
}

vec3 reflCol(inout vec3 ro, inout vec3 rd, inout vec3 refAtt) {
  vec3 col = vec3(0);
  
  vec3 normal;
  float t = castRay(ro, rd, normal);
  vec3 rp = ro + t * rd;
  
  vec3 lv = lightPos - rp;
  float L = length(lv);
  float amp = pow(sin(fract(T) * PI2) * .5 + .5, 2.);
  if(L < lightSize + EPS) {
    col = vec3(10);
  }
  
  vec3 ld = lv / L;
  
  vec3 albedo = vec3(.9);
  float po = (.02 + amp) * 30. / dot(lv, lv);
  float diff= max(dot(normal, ld), 0.);
  float spec = pow(max(dot(reflect(ld, normal), rd), 0.), 20.);
  float sh= 1.;
  vec3 normal0 = normal;
  if(castRay(rp + normal * EPS * 0.5, ld, normal) < L - lightSize - EPS) {
    sh = 0.5;
  }
  float m = 0.8;
  col += albedo * (diff * (1. - m) + spec * m) * po * sh;
  vec3 ref = reflect(rd, normal0);
  
  //float invFog = exp(-t * t * .00);
  //col *= invFog;
  
  //refAtt *= albedo * fs(0.8, dot(ref, normal0)) * invFog;
  refAtt *= albedo * fs(0.8, dot(ref, normal0));
  
  ro = rp + normal0 * EPS;
  rd = ref;
  
  return col * refAtt;
}

float stepNoise(float x, float n) {
  float i = floor(x);
  float s = .2;
  float u = smoothstep(.5 - s, .5 + s, fract(x));
  float res = mix(floor(hash(i) * n), floor(hash(i + 1.) * n), u);
  res /= (n - 1.) * .5;
  return res - 1.;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * 0.5;
  vec3 col = vec3(0);
  
  vec3 ro = vec3(0, 0, 0);
  ro.x += stepNoise(T * .5, 5.) * 1.5;
  ro.y += stepNoise(T * .5 - 500., 5.) * 1.5;
  
  float a = stepNoise(T * .5 - 1000., 2.) * .5 + .5;
  a = .1 + a * .8;
  vec3 ta = vec3(0, 0, ro.z - tan(a * PI * .5));
  
  vec3 dir = normalize(ta - ro);
  vec3 side = normalize(cross(dir, vec3(0, 1, 0)));
  vec3 up = cross(side, dir);
  
  float fov = 60.;
  fov += stepNoise(T * .5 - 1500., 2.) * 20.;
  vec3 rd = normalize(uv.x * side + uv.y * up + dir / tan(fov / 360. * PI));
  
  lightPos.xy = sin(vec2(8, 9) * time * 0.2) * .8;
  lightPos.z = ro.z - 2. + sin(time);
  
  
  /*
  vec2 p = uv * 5.;
  for(int i = 0; i < 5; i++) {
    if(hash12(floor(p) + floor(time) * PI) < 0.5) {
      break;
    }
    p *= 2.;
  }
  
  if(hash12(floor(p) * 1.3 + floor(time) * 1.6343) < 0.5) {
    col += .5;
  }*/
  
  vec3 refAtt = vec3(1);
  for(int i = 0; i < 4; i++) {
    col += reflCol(ro, rd, refAtt);
  }
  
  col = pow(col, vec3(1. / 2.2));
  //col = mix(col, texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).rgb, 0.6);
  
	out_color = vec4(col, 1.);
}