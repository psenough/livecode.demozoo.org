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

vec3 sphereCenter = vec3(sin(t + .2) * 1.3, sin(t * 2.3) * 1.6, sin(t * .3));

mat2 rot(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c, -s, s, c);
}

vec3 g = normalize(vec3(1, 2, 3));

vec3 rot2(vec3 p) {
  return mix(dot(p, g) * g, p, cos(t)) + cross(p, g) * sin(t);
}

float hash21(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx + p3.yz) * p3.zy);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

  float a = hash21(i);
  float b = hash21(vec2(i.x + 1., i.y));
  float c = hash21(i + vec2(0, 1));
  float d = hash21(vec2(i.x + 1., i.y + 1.));

  vec2 u = f * f * (3. - 2. * f);

  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float sdCone(vec3 p, vec2 c) {
  // c is the sin/cos of the angle
  vec2 q = vec2(length(p.xz), -p.y);
  float d = length(q - c * max(dot(q, c), 0.0));
  return d * ((q.x * c.y - q.y * c.x < 0.0) ? -1.0 : 1.0);
}

vec2 minX(vec2 a, vec2 b) { return a.x < b.x ? a : b; }

vec2 grass(vec3 p) {
  p.xz -= t * .1;
  // p.x -= p.y * .3;
  float floor_ = p.y + 10.;
  p.y += 7.;
  vec2 s = vec2(.4);
  vec2 id = round(p.xz / s);
  vec2 r = p.xz - s * id;
  p.xz = vec2(((int(id.x) & 1) == 0) ? r.x : -r.x,
              ((int(id.y) & 1) == 0) ? r.y : -r.y);
  p.xz += vec2(0, sin((p.y + 4.) / 2.) * 0.15) * rot(id.x + id.y);
  float a = .04;
  float blade = sdCone(p, vec2(sin(a), cos(a)));

  return minX(vec2(floor_, 3), vec2(blade, 2));
}

vec2 sdf(vec3 p) {
  // p = rot2(p);

  return minX(vec2(length(p - sphereCenter) - 3., 1.), grass(p));
}

vec2 march(vec3 ro, vec3 rd) {
  vec3 c = vec3(0);
  vec2 r = vec2(0.);
  float m = 10000.;

  for (int i = 0; i < 256; i++) {
    // r = i * 0.02;
    vec3 p = ro + rd * r.x;
    vec2 z = sdf(p);
    r.x += z.x;
    r.y = z.y;

    if (r.x > 1000. || z.x < 0.0001)
      break;
    // c += 1e-2/z * vec3(0,1,1);
  }

  return r;
}

vec3 ld = normalize(vec3(1, 2, 3));

vec3 sky(vec3 rd) {
  vec3 start = vec3(174, 234, 252) / 255.;
  vec3 end = vec3(120, 221, 250) / 255.;
  return mix(end, start, rd.y);
}

void main(void) {
  vec2 uv = out_texcoord;
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(0, 0, 20);
  vec3 rd = normalize(vec3(uv.x, uv.y, -.5));
  rd.yz *= rot(-.5);

  vec2 rm = march(ro, rd);
  vec3 po = ro + rd * rm.x;
  vec3 no =
      normalize(ep.xyy * sdf(po + ep.xyy).x + ep.yyx * sdf(po + ep.yyx).x +
                ep.yxy * sdf(po + ep.yxy).x + ep.xxx * sdf(po + ep.xxx).x);

  vec3 bg = sky(rd);
  vec3 col = bg;
  // col += rm.rgb;

  if (rm.x < 100.) {
    vec3 alb = vec3(0);
    float dif = max(0., dot(ld, no));
    float spec = pow(max(dot(reflect(-ld, no), -rd), 0.), 30.);

    if (rm.y == 1.) {
      alb = vec3(.3);

      // float dif = dot(no,ld);
      // float spec = pow(max(dot(reflect(-ld, no), -rd),0.), 100.);
      vec2 pp = vec2(po.x + t, po.y + 2. * t) - sphereCenter.xy;

      vec2 g = hash22(floor(pp + .5 - .07));
      float f = g.x;
      f *=
          step(.2, abs(mod(pp.x + .5, 1.))) * step(.2, abs(mod(pp.y + .5, 1.)));

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

      alb += f * hue; // dif * alb + spec;

      col = alb * dif + spec;
    } else if (rm.y == 2.) {
      alb = mix(vec3(.3, .9, .3), vec3(0, 1, 0), smoothstep(-10., -6., po.y));
      alb *= mix(.6, 1., valueNoise(po.xz));
      col = alb * (dif * .5 + .5);
    } else if (rm.y == 3.) {
      alb = vec3(137, 100, 10) / 255. + .3;
      col = alb * dif + spec;
    } else {
      col = alb * dif + spec;
    }

    col = mix(bg, col, exp(-.00001 * rm.x * rm.x * rm.x));
  }

  vec4 t = vec4(col, 1);
  t = clamp(t, 0.0, 1.0);
  out_color = t;
}