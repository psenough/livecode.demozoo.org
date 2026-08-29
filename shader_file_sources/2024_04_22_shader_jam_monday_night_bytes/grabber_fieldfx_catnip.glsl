#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define r2d(p,a) p=cos(a)*p + sin(a)*vec2(-p.y,p.x);

vec3 hash(vec3 p) {
  p = fract(p * vec3(443.537, 537.247, 247.428));
  p += dot(p, p.yxz + 19.19);
  return fract((p.xxy + p.yxx) * p.zyx);
} 


float cat(vec2 p) {
  p.x = abs(p.x);
  vec2 q=p;
  q.x = abs(q.x-.2);
  q.y += q.x - .2;
  float r = abs(q.y)<.05 && q.x<.15 ? 1. : 0.;
  p.x -= .6;
  p.y = abs(p.y) - .08;
  r += abs(p.y)<0.03 && abs(p.x)<.15 ? 1. : 0.;
  return r;
}

float boxDist(vec3 p, vec3 o, vec3 s, float r) {
  p = abs(p - o) - s / 2.;
  return length(max(p, 0.) + min(0., max(p.x, max(p.y, p.z)))) - r;
}

vec4 df(vec3 p) {
  float d = 1000.;
  //const vec3 cols[3] = {vec3(1,0,1), vec3(1,1,0), vec3(0,1,1) };
  p.z /= 3.;
  vec3 col;
  for (float i=0.; i<3.; i++) {
    float e = boxDist(p * vec3(1,1,0), vec3(sin(p.z + i * 3.142), cos(p.z + i * 3.142), 0.) * 1.5, vec3(.8), .1);
    if (e < d) {
      d = e;
      col = i==0. ? vec3(.7) : (i==1. ? vec3(.85) : vec3(1));
    }
    p.z *= -1.2;
  }
  
  d = min(
    d,
    -length(p.xy) + 2.
  );
  vec3 q = p;
  r2d(q.xy, q.z / 3.);
  if (d > 0.1) {
    col = step(0.98, fract(p + fract(q))) * 8.;
    col = vec3(max(col.x, max(col.y, col.z)));
  }
  return vec4(col, d);
}

vec3 norm(vec3 p) {
  vec2 e = vec2(1e-3, 0.);
  return normalize(vec3(
    df(p + e.xyy).w - df(p - e.xyy).w,
    df(p + e.yxy).w - df(p - e.yxy).w,
    df(p + e.yyx).w - df(p - e.yyx).w
  ));
}

vec3 rm(vec3 p, vec3 dir, float mDist) {
  vec3 col = vec3(0.);
  float td = 0.;
  for (int i=0; i< 10; i++) {
    vec4 d = df(p);
    td += d.w;
    if (d.w < 1e-3 || td > mDist) {
      col = d.xyz;
      vec3 n = norm(p);
      col *= 1.-max(0., dot(-n, dir));
      break;
    }
    p += d.w * dir;
  }
  return col;
}

const int samples = 16;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.yy;
  
  vec3 col = vec3(0.);
  
  for (int j=0;j<samples; j++) {
    vec3 k = hash(vec3(uv, fract(time + float(j) / float(samples)))) - .5;
    k.z = float(j) / float(samples);
    float t = time + k.z / 15.;
    vec2 c = vec2(gl_FragCoord.xy) + k.xy * 2.; //texture(texFFTSmoothed, 0.01).x * 20.;
    vec2 u = vec2(c * 2. - v2Resolution.xy) / v2Resolution.yy;
    vec3 p = vec3(0, 0, t * 10.),
    dir = normalize(vec3(u, .5));
    r2d(dir.xy, t / 4.);
    r2d(dir.xz, sin(t / 20.47) * 2.);
    r2d(dir.yz, sin(t / 17.24) * 2.);
  
    float d = 1. / length(dir.xy), d2 = d * 2;
    p += dir * d;
    
    int idx = int((k.z) * 3.);
    col[idx] += rm(p, dir, d / 2.).r * 3.;
    //col += hash(floor(p * 10.)) * .5 + .25;
  }

  vec3 catC = vec3(0);
  for (float i=0.;i<9.;i++) {
    vec2 o = vec2(sin(i / 10.+texture(texFFTIntegrated, 0.01).x * .4284), cos(i/10.+texture(texFFTIntegrated, 0.01).x * .325));
    o = pow(abs(o), vec2(7.)) * sign(o);
    catC[int(i)/3] += cat((uv + o / 4.) * .5) / 3.;
  }
	out_color = vec4(col / float(samples) + catC, 1.);
}
