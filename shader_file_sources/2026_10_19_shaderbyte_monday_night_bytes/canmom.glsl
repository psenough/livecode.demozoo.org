#version 460 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// http://www.jcgt.org/published/0009/03/02/
vec3 hash(uvec3 v) {
  v = v * 1664525u + 1013904223u;

  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;

  v ^= v >> 16u;

  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;

  return vec3(v) * (1.0 / float(0xffffffffu));
}

uvec3 uhash(uvec3 v) {
  v = v * 1664525u + 1013904223u;

  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;

  v ^= v >> 16u;

  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;

  return v;
}

//borrowing noise with derivatives from Inigo Quilez
//https://www.shadertoy.com/view/4dffRH
//thanks Inigo we would be nowhere without you <3
vec4 noised(in vec3 x)
{
  // grid
  uvec3 i = uvec3(floor(x));

  vec3 f = fract(x);

  // quintic interpolant
  vec3 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
  vec3 du = 30.0 * f * f * (f * (f - 2.0) + 1.0);

  // gradients
  vec3 ga = hash(i + ivec3(0, 0, 0));
  vec3 gb = hash(i + ivec3(1, 0, 0));
  vec3 gc = hash(i + ivec3(0, 1, 0));
  vec3 gd = hash(i + ivec3(1, 1, 0));
  vec3 ge = hash(i + ivec3(0, 0, 1));
  vec3 gf = hash(i + ivec3(1, 0, 1));
  vec3 gg = hash(i + ivec3(0, 1, 1));
  vec3 gh = hash(i + ivec3(1, 1, 1));

  // projections
  float va = dot(ga, f - vec3(0.0, 0.0, 0.0));
  float vb = dot(gb, f - vec3(1.0, 0.0, 0.0));
  float vc = dot(gc, f - vec3(0.0, 1.0, 0.0));
  float vd = dot(gd, f - vec3(1.0, 1.0, 0.0));
  float ve = dot(ge, f - vec3(0.0, 0.0, 1.0));
  float vf = dot(gf, f - vec3(1.0, 0.0, 1.0));
  float vg = dot(gg, f - vec3(0.0, 1.0, 1.0));
  float vh = dot(gh, f - vec3(1.0, 1.0, 1.0));

  // interpolations
  float k0 = va - vb - vc + vd;
  vec3 g0 = ga - gb - gc + gd;
  float k1 = va - vc - ve + vg;
  vec3 g1 = ga - gc - ge + gg;
  float k2 = va - vb - ve + vf;
  vec3 g2 = ga - gb - ge + gf;
  float k3 = -va + vb + vc - vd + ve - vf - vg + vh;
  vec3 g3 = -ga + gb + gc - gd + ge - gf - gg + gh;
  float k4 = vb - va;
  vec3 g4 = gb - ga;
  float k5 = vc - va;
  vec3 g5 = gc - ga;
  float k6 = ve - va;
  vec3 g6 = ge - ga;

  return vec4(va + k4 * u.x + k5 * u.y + k6 * u.z + k0 * u.x * u.y + k1 * u.y * u.z + k2 * u.z * u.x + k3 * u.x * u.y * u.z, // value
    ga + g4 * u.x + g5 * u.y + g6 * u.z + g0 * u.x * u.y + g1 * u.y * u.z + g2 * u.z * u.x + g3 * u.x * u.y * u.z + // derivatives
      du * (vec3(k4, k5, k6) +
          vec3(k0, k1, k2) * u.yzx +
          vec3(k2, k0, k1) * u.zxy +
          k3 * u.yzx * u.zxy));
}

vec3 hue_shift(vec3 color, float hue) {
  const vec3 k = vec3(0.57735, 0.57735, 0.57735);
  float cosAngle = cos(hue);
  return vec3(color * cosAngle + cross(k, color) * sin(hue) + k * dot(k, color) * (1.0 - cosAngle));
}

const float PI = radians(180.0);

#define width uint(v2Resolution.x)
#define height uint(v2Resolution.y)
#define time fGlobalTime

vec3 hash_float(vec3 v) {
  uvec3 vu = uvec3(v);
  return hash(vu);
}

//hello fieldfx!!
//let's get the hang of motion vectors shall we

vec3 curl_noise(vec3 position, vec3 offset_y, vec3 offset_z, float scale) {
  vec4 gx = noised(position * scale);
  vec4 gy = noised(position * scale + offset_y);
  vec4 gz = noised(position * scale + offset_z);
  vec3 field = vec3(gx.x, gy.x, gz.x);
  vec3 curl = vec3(gz.yzw.y - gy.yzw.z, gx.yzw.z - gz.yzw.x, gy.yzw.x - gx.yzw.y);
  return curl;
}

const float QUANT = 65536.0;

void write(ivec2 UV, vec3 value) {
  imageAtomicAdd(computeTex[0], UV, uint(value.r * QUANT));
  imageAtomicAdd(computeTex[1], UV, uint(value.g * QUANT));
  imageAtomicAdd(computeTex[2], UV, uint(value.b * QUANT));
}

vec3 read(ivec2 UV) {
  return vec3(
    imageLoad(computeTexBack[0], UV).r / QUANT,
    imageLoad(computeTexBack[1], UV).r / QUANT,
    imageLoad(computeTexBack[2], UV).r / QUANT
  );
}

float saturate(float t) {
  return clamp(t, 0.0, 1.0);
}

vec3 draw_flower() {
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float acc_mask = 1.0;
  vec3 acc = vec3(0.0);
  vec3 backface_acc = vec3(0.0);

  for (float i = 1.0; i > 0.0; i -= 0.1) {
    uv += vec2(0.0, -0.03);
    float dist2 = dot(uv, uv);
    float r = 0.5 * i;
    float z2 = 10.0 * (r * r - dot(uv, uv));
    float z = sqrt(z2);
    vec2 xydir = normalize(uv);
    float mask = step(dist2, r * r);
    vec3 n = vec3(xydir * sqrt(dist2) * mask / r, z);
    vec3 lambert = vec3(0.0, 0.1, 0.1) * mask + vec3(1.0, 1.0, 0.8) * saturate(dot(n, normalize(vec3(1.0, 0.4, 0.4))));
    vec3 lambert_backface = vec3(0.0, 0.1, 0.1) * mask + vec3(1.0, 1.0, 0.8) * saturate(dot(n * vec3(1.0, 1.0, -1.0), normalize(vec3(1.0, 0.4, 0.4))));
    float longi = atan(n.z, n.x) / PI;
    float latitude = atan(n.y, sqrt(dot(n.xz, n.xz)));
    float speed_adjust = 0.4 / (i * i * i);
    float longitude = 1.0 - fract(longi + speed_adjust * texture(texFFTIntegrated, i).r);
    float zigzag = step(abs(fract(longitude * 4.0) - 0.5), latitude - 0.8 + 1.5 * i);
    longi = atan(-n.z, n.x) / PI;
    longitude = 1.0 - fract(longi + speed_adjust * texture(texFFTIntegrated, i).r);
    float zigzag_backface = step(abs(fract(longitude * 4.0) - 0.5), latitude - 0.8 + 1.5 * i);
    vec3 colour = mix(vec3(1.0, 0.2, 0.1), vec3(0.1, 0.2, 1.0), i);

    acc += 2.0 * (1.0 - zigzag) * lambert * acc_mask * colour + zigzag * (1.0 - zigzag_backface) * lambert * acc_mask * colour;

    acc_mask *= min(zigzag, zigzag_backface);
  }

  //it's a sphere, jim, but not raymarched! or raytraced! or rasterised!
  //it's an orthographic sphere!!

  return acc;
}

void main(void)
{
  float camera_time_x = texture(texFFTIntegrated, 0.1).r;
  float camera_time_y = texture(texFFTIntegrated, 0.2).r;

  float ctc = cos(camera_time_x);
  float cts = sin(camera_time_x);

  mat2 rot = mat2(ctc, cts, -cts, ctc);

  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.x);

  const float SCALE = 10.0;

  vec2 offset = vec2(camera_time_x, camera_time_y);

  vec3 motion_vec_broad = curl_noise(vec3(uv + offset, 0.4 * camera_time_x), vec3(10000.0, 0.0, 0.0), vec3(0.0, 10000.0, 0.0), 10.0);

  vec3 motion_vec_fine = curl_noise(vec3(uv, 0.1 * camera_time_y), vec3(10000.0, 0.0, 0.0), vec3(0.0, 10000.0, 0.0), 43.0);

  const float MOTION_VEC_SCALE_BROAD = 400.0 * (texture(texFFTSmoothed, 0.05).r) + 0.0;
  const float MOTION_VEC_SCALE_FINE = 350.0 * (texture(texFFTSmoothed, 0.4).r) + 0.05;

  float grid = step(0.1, fract(SCALE * uv.x)) * step(0.1, fract(SCALE * uv.y));

  ivec2 UV_read = ivec2(gl_FragCoord.xy);
  ivec2 UV_write = ivec2(gl_FragCoord.xy + MOTION_VEC_SCALE_BROAD * motion_vec_broad.xy + MOTION_VEC_SCALE_FINE * motion_vec_fine.xy);

  vec3 flo = draw_flower();

  write(UV_read, vec3(0.5 * flo));

  //propagate along motion vectors
  vec3 local_value = read(UV_read) / 10.2;
  write(UV_write, 2.0 * local_value);
  write(UV_write + ivec2(1, 0), local_value);
  write(UV_write + ivec2(-1, 0), local_value);
  write(UV_write + ivec2(0, 1), local_value);
  write(UV_write + ivec2(0, -1), local_value);
  write(UV_write + ivec2(1, 1), local_value);
  write(UV_write + ivec2(1, -1), local_value);
  write(UV_write + ivec2(-1, 1), local_value);
  write(UV_write + ivec2(-1, -1), local_value);

  vec4 prev = texture(texPreviousFrame, vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y));

  out_color = vec4(tanh(0.5 * local_value), 1.0) + 0.3 * prev;
}
