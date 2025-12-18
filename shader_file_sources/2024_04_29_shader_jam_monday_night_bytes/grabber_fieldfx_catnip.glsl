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

#define r2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y, p.x);
#define time fGlobalTime * 2.

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

float iPlane(vec3 p, vec3 d){
    return p.y / -d.y;
}

float smin(float a, float b, float k) {
  float h = clamp(.5 + .5 * (b-a) / k, 0., 1.);
  return mix(b, a, h) - k * h * (1. - h);
}

float ldist(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p-a, ba = b-a;
  float h = clamp(dot(pa,ba) / dot(ba,ba), 0., 1.);
  return length(pa - ba*h) - r;
}
float df(vec3 p) {
  p.y -= 3.;
  float sx = sign(p.x);
  p.x = abs(p.x);
  
  vec3 a = vec3(0, -abs(sin(time))*.5, 1),
  b = vec3(0,-1.5,0);
  r2d(b.yz, sin(time));
  float d = smin(
    length(p + a) - 1.,
    length(p - vec3(0, -abs(sin(time-.3))*.5, 1)) - 1.,
    1.5) * .7;
  a.x += 1.;
  b = a+b;
  d = smin(
    d,
    ldist(p, a, b, .2),
    .5
  );
  a = b;
  b = vec3(0, -1.5, 0);
  r2d(b.yz, sin(time+.5));

  b = a+b;
  d = smin(
    d,
    ldist(p, a, b, .2),
    .3
  );
  // back
  a = vec3(0, abs(sin(time-.3))*.5, -1),
  b = vec3(0,-1.5,0);
  r2d(b.yz, sin(time + 1.5));
  a.x += 1.;
  b = a+b;
  d = smin(
    d,
    ldist(p, a, b, .2),
    .5
  );
  a = b;
  b = vec3(0, -1.5, 0);
  r2d(b.yz, sin(time+.5));

  b = a+b;
  d = smin(
    d,
    ldist(p, a, b, .2),
    .5
  );
  a = vec3(0, abs(sin(time-.3))*.5, -2);
  b = vec3(0, -1, -.5);
  r2d(b.yz, sin(time)*.25);
  b += a;
  
  d = smin(
    d, 
    ldist(p, a, b, 0.1),
    0.5);
    
    
  a = vec3(0, abs(sin(time))*.5, 2);
  b = vec3(0, .4, .5);
  r2d(b.yz, sin(time)*.25);
  
  b += a;
  
  d = smin(
    d, 
    ldist(p, a, b, 0.4),
    0.5);
  a=b;
  b=vec3(0, 0, .5);
  b += a;
  d = smin(
    d, 
    ldist(p, a, b, 0.2),
    0.3);
  a.x += .3;
  a.y += .3;
  b = a + vec3(.1, .3, 0);
  
  d = smin(
    d, 
    ldist(p, a, b, 0.1),
    0.1);
    
  return d;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(1e-3, 0);
  return normalize(vec3(
    df(p+e.xyy)-df(p-e.xyy),
    df(p+e.yxy)-df(p-e.yxy),
    df(p+e.yyx)-df(p-e.yyx)
  ));
}

vec3 rm(inout vec3 p, inout vec3 dir, float mDist) {
  float tdist = 0.;
    
  for (int i=0; i<70; i++) {
    float d = df(p);
    if (d<1e-3) {
      vec3 n = norm(p);
      dir = reflect(dir, n);
      p += n * 3e-3;
      //return vec3(n);
    }
    p += dir * d;
    tdist += d;
    if (tdist > mDist){
      p -= dir * (tdist - mDist);
      break;
    }
  }
  return vec3(0.);
}

void main(void) {
	vec2 uv = vec2(gl_FragCoord.xy * 2. - v2Resolution.xy) /v2Resolution.y;
  
  vec3 p = vec3(0,4,-4),
  d = normalize(vec3(uv, 1.));
  r2d(d.yz,.5);
  r2d(p.xz, time/8.);
  r2d(d.xz, time/8.);
  
  vec4 catC = vec4(0);
  
  float pd = iPlane(p, d);
  
  catC.xyz += rm(p, d, pd <= 0. ? 8. : pd);
  if (p.y < 1e-2) {
    p.z += time;
    p = floor(p * .2);
    catC += step(0.5, mod(p.x + p.z, 2.));
  } else {
    catC.rgb += mix(vec3(.5,.5,1), vec3(1), d.y);
  }
  /*
  for (float i=0.;i<9.;i++) {
    vec2 o = vec2(sin(i / 10.+texture(texFFTIntegrated, 0.01).x * .4284), cos(i/10.+texture(texFFTIntegrated, 0.01).x * .325));
    o = pow(abs(o), vec2(7.)) * sign(o);
    vec2 u = uv;
    r2d(u, sin(i / 10.+texture(texFFTIntegrated, 0.01).x * .4284) * .3);
    catC[int(i)/3] += cat((u + o / 4.) * .5) / 3.;
  }*/
	out_color = catC;
}