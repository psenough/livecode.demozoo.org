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

float t = fGlobalTime;
vec2 ep = vec2(.00035, -.00035);

mat2 rot(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c, -s, s, c);
}

vec3 g = normalize(vec3(1, 2, 3));

vec3 rot2(vec3 p) {
  return mix(dot(p, g) * g, p, cos(t)) + cross(p, g) * sin(t);
}

vec2 hash22(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx + p3.yz) * p3.zy);
}

float sdCone(vec3 p, vec2 c) {
  // c is the sin/cos of the angle
  vec2 q = vec2(length(p.xz), -p.y);
  float d = length(q - c * max(dot(q, c), 0.0));
  return d * ((q.x * c.y - q.y * c.x < 0.0) ? -1.0 : 1.0);
}

float sdf(vec3 p) {
  // p = rot2(p);

  float a = .5;

  float ballcone =
      min(length(p) - 6., -sdCone(vec3(0, -10, 0) - p, vec2(sin(a), cos(a))));

  p.xz *= rot(t);
  float balls =
      min(min(length(p - vec3(5, 5, 3)) - 1., length(p - vec3(-5, 5, 3)) - 1.),
          length(p - vec3(0, 5, -5)) - 1.);
  return min(ballcone, balls);
}

vec4 march(vec3 ro, vec3 rd) {
  vec3 c = vec3(0);
  float r = 0.;
  float m = 10000.;

  for (int i = 0; i < 256; i++) {
    // r = i * 0.02;
    vec3 p = ro + rd * r;
    float z = sdf(p);
    r += z;

    if (r > 1000. || z < 0.0001)
      break;
    // c += 1e-2/z * vec3(0,1,1);
  }

  return vec4(c, r);
}

vec3 ld = normalize(vec3(1, 2, 3));

vec3 sky(vec3 rd) { return vec3(0); }

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

  vec3 col = sky(rd);
  col += rm.rgb;

  if (rm.w < 100.) {
    vec3 alb = vec3(.5, .8, .9);

    // float dif = dot(no,ld);
    // float spec = pow(max(dot(reflect(-ld, no), -rd),0.), 100.);
    vec2 pp = vec2(po.x + t, po.z + 2. * t);

    vec2 g = hash22(floor(pp + .5 - .07));
    float f = g.x;
    f *= step(.2, abs(mod(pp.x + .5, 1.))) * step(.2, abs(mod(pp.y + .5, 1.)));

    vec3 hue1a = vec3(0xf7, 0x91, 0x08);
    vec3 hue2a = vec3(0xf4, 0x4c, 0x0b);

    vec3 hue1b = vec3(0x36, 0x10, 0xef);
    vec3 hue2b = vec3(0x1a, 0xe5, 0x91);

    float shift = sin(length(pp) / 10.) * .5 + .5;
    vec3 hue1 = mix(hue1a, hue1b, shift);
    vec3 hue2 = mix(hue2a, hue2b, shift);

    vec3 hue = mix(hue1, hue2, g.y) / 255.;

    pp *= acos(-1.); // (acos(-1) = pi)
    pp += .5;
    f *= smoothstep(.94, 1., sin(pp.x * 2.)) +
         smoothstep(.94, 1., sin(pp.y * 2.));

    col = f * hue; // dif * alb + spec;
  }

  vec4 t = vec4(col, 1);
  t = clamp(t, 0.0, 1.0);
  out_color = t;
}