#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime;  // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is
                          // higher / treble freq
uniform sampler1D
    texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

in vec2 out_texcoord;
layout(location = 0)
    out vec4 out_color; // out_color must be written in order to see anything

vec2 ep = vec2(.00035, -.00035);

mat2 rot(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c, -s, s, c);
}

vec4 plas(vec2 v, float time) {
  float c = 0.5 + sin(v.x * 10.0) + cos(sin(time + v.y) * 10.0);
  return vec4(sin(c * 0.2 + cos(time)), c * 0.15,
              cos(c * 0.1 + time / .4) * .25, 1.0);
}

float sdf(vec3 p) {

  // p.xy *= rot(fGlobalTime);

  p.xz *= rot(p.y / (sin(fGlobalTime) * 2. + 3.));
  // p.xz *= rot(p.y / 2.);
  // p.xy += sin((p.z + fGlobalTime) * 20.) / 20.;
  p.zy += sin((p.x + fGlobalTime) * 10.) / 20.;

  return length(p) - 7.;
}

vec4 march(vec3 ro, vec3 rd) {
  vec3 c = vec3(0);
  float r = 0.;
  for (int i = 0; i < 256; i++) {
    r = i * 0.04;
    vec3 p = ro + rd * r;
    float z = sdf(p);
    // r += z;

    if (r > 1000. || z < 0.0001)
      break;

    z = pow(z, 4.);

    c += min(0.8, exp(-z / 10.)) *
         (sin(vec3(2, 4, 6) + mod(fGlobalTime, 10.)) * .5 + .5);
  }
  // c = vec3(smoothstep(0.6,0.8, c.x / 100.));
  c /= 100.;
  c = min(c, vec3(1));
  c = pow(c, vec3(.5));

  return vec4(c, r);
}

void main(void) {
  vec2 uv = out_texcoord;
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(0, 10, 0);
  vec3 rd = normalize(vec3(uv.x, -.25, uv.y));
  // rd.yz *= rot(-.3);

  vec4 rm = march(ro, rd);
  vec3 po = ro + rd * rm.a;
  vec3 no = normalize(ep.xyy * sdf(po + ep.xyy) + ep.yyx * sdf(po + ep.yyx) +
                      ep.yxy * sdf(po + ep.yxy) + ep.xxx * sdf(po + ep.xxx));

  vec3 zubi = uv.xyx + fGlobalTime;
  zubi += sin(zubi + fGlobalTime + sin(zubi.yzx));
  vec3 col = rm.rgb;

  if (rm.a < 10.) {

    vec3 alb = sin(vec3(1, 2, 3) + po.x / 2.) + rm.rgb / 10.;

    float dif = dot(no, normalize(vec3(1)));
    col = dif * alb;
  }

  vec4 t = vec4(col, 1);
  t = clamp(t, 0.0, 1.0);
  out_color = t;
}