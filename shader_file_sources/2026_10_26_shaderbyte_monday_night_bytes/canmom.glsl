#version 460 core

//hiii gang! happy halloween!

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

const float U32_MAX = float(0xffffffffu);
const float POS_OFFSET = float(0xfeu);


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

const uint MAX_DEPTH = 4;

float sdCutHollowSphere( vec3 p, float r, float h, float t )
{
  float w = sqrt(r*r-h*h);
  vec2 q = vec2( length(p.xz), p.y );
  return ((h*q.x<w*q.y) ? length(q-vec2(w,h)) : 
                          abs(length(q)-r) ) - t;
}

float smin( float a, float b, float k )
{
    k *= 1.0;
    float r = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdCappedCylinder( vec3 p, float r, float h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float opSmoothUnion( float a, float b, float k )
{
  k *= 4.0;
  float h = max(k-abs(a-b),0.0);
  return min(a, b) - h*h*0.25/k;
}

float opSmoothSubtraction( float a, float b, float k )
{
  k *= 4.0;
  float h = max(k-abs(-a-b),0.0);
  return max(-a, b) + h*h*0.25/k;
}

mat3 rot(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3 (c, s, 0,
       -s, c, 0,
        0, 0, 1);
}

float f( in vec3 p, float offset) {
  offset *= 6.0;
  mat3 r_l = rot(0.3);
  mat3 r_lo = rot(0.4);
  mat3 r_r = rot(-0.3);
  mat3 r_ro = rot(-0.4);
  float box_l_outer = sdRoundBox(r_lo*(p-vec3(0.3,-0.1+offset,-0.4)), vec3(0.3, 0.18, 0.1), 0.08);
  float box_r_outer = sdRoundBox(r_ro*(p-vec3(-0.3,-0.1+offset,-0.4)), vec3(0.3, 0.18, 0.1), 0.08);
  
  float box_l_inner = sdRoundBox(r_l*(p-vec3(0.28,-0.1+offset,-0.5)), vec3(0.2, 0.11, 0.2), 0.08);
  float box_r_inner = sdRoundBox(r_r*(p-vec3(-0.28,-0.1+offset,-0.5)), vec3(0.2, 0.1, 0.2), 0.08);
  float cranium = sdCutHollowSphere((p-vec3(0.0,offset,0.0)) * vec3(1.0, -1.0, 1.0), 0.5, 0.2, 0.08);
  
  float upper_jaw = sdCappedCylinder(p - vec3(0.0, -0.4+offset, -0.3),0.25, 0.1)-0.04;
  float nostril_hole = sdTorus(p - vec3(0.0, -0.3+offset, -0.5), vec2(0.05,0.05));
  
  float jaw_height = -0.6- offset;
  
  float teeth = sdCappedCylinder(p-vec3(0.0, jaw_height, -0.28), 0.25, 0.1)-0.02;
  
  float jaw_left = sdRoundBox(r_lo*(p-vec3(0.3, -0.4-offset, -0.2)), vec3(0.04, 0.3, 0.1), 0.03);
  float jaw_right = sdRoundBox(r_ro*(p-vec3(-0.3, -0.4-offset, -0.2)), vec3(0.04, 0.3, 0.1), 0.03);
  
  float teeth_back = sdRoundBox(p-vec3(0.0,-0.4+offset,-0.15), vec3(0.3, 0.5, 0.2), 0.05);
  return
    min(opSmoothSubtraction(
      min(opSmoothUnion(opSmoothUnion(box_l_inner, box_r_inner,0.02), teeth_back, 0.02),nostril_hole),
      opSmoothUnion(
        opSmoothUnion(cranium,upper_jaw,0.02),
        opSmoothUnion(box_l_outer, box_r_outer,0.02),
      0.02),
     0.02),opSmoothUnion(teeth,opSmoothUnion(jaw_left, jaw_right, 0.02),0.02));
}

const uint RAYMARCH_DEPTH = 150;
const float FOV = sin(40.0 * 3.1415926359 / 180.0);
const float THRESHOLD = 0.001;
const vec3 LIGHT = vec3(1.0, 0.4, -1.0);


vec3 calcNormal( in vec3 p, float offset ) // for function f(p)
{
    const float eps = 0.0001; // or some other value
    const vec2 h = vec2(eps,0);
    return normalize( vec3(f(p+h.xyy, offset) - f(p-h.xyy,offset),
                           f(p+h.yxy,offset) - f(p-h.yxy,offset),
                           f(p+h.yyx,offset) - f(p-h.yyx,offset) ) );
}

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

vec3 draw()
{
  vec3 o = vec3(0.0);
  
  float angle = -radians(90.0)+sin(2.0*texture(texFFTIntegrated, 0.1).r);
  float c = cos(angle);
  float s = sin(angle);
  
  vec3 origin = vec3(5.0 * c, -0.1, 5.0 * s);
  vec3 c_x = vec3(-s, 0.0, c);
  vec3 c_y = vec3(0, 1, 0);
  vec3 c_z = vec3(-c, 0, -s);
  
  vec2 uv = (gl_FragCoord.xy - 0.5 * v2Resolution.xy)/v2Resolution.x;
  
  vec3 v = normalize(uv.x * FOV * c_x + uv.y * FOV * c_y + c_z);
  
  vec3 p = origin;
  
  bool hit = false;
  
  float offset = texture(texFFTSmoothed, 0.2).r;
  
  float d;
  
  for(int i = 0; i < RAYMARCH_DEPTH; i++) {
    d = f(p, offset);
    if (d < THRESHOLD) { hit = true; break; }
    p += d * v;
  }
 
  
  vec3 n = calcNormal(p, offset);
  
  bool lit = true;
  
  p += 4.0*THRESHOLD * n;
  
  d = f(p, offset);
  
  for (int i = 0; i < RAYMARCH_DEPTH; i++) {
    p += d * LIGHT;
    float d = f(p,offset);
    if (d < THRESHOLD) { lit = false; break;}
  }
  
  if (hit) {
    o = vec3(float(lit) * max(dot(n, normalize(LIGHT)),0.0))+vec3(0.03,0.03,0.04);
  } else {
    o = vec3(0.08,0.05,0.1),1.0;
  }
  
  return o;
}

void main(void)
{
  float camera_time_x = texture(texFFTIntegrated, 0.1).r;
  float camera_time_y = texture(texFFTIntegrated, 0.2).r;

  float ctc = cos(camera_time_x);
  float cts = sin(camera_time_x);

  mat2 rot = mat2(ctc, cts, -cts, ctc);

  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.x);

  float scale = 5.0;
  
  vec2 cuv = uv - vec2(0.5, 0.5 * v2Resolution.y / v2Resolution.x);
  float vignette = dot(cuv, cuv);

  vec2 offset = vec2(camera_time_x, camera_time_y);

  vec3 motion_vec_broad = curl_noise(vec3(uv + offset, 0.4 * camera_time_x), vec3(10000.0, 0.0, 0.0), vec3(0.0, 10000.0, 0.0), 10.0);

  vec3 motion_vec_fine = curl_noise(vec3(uv, 0.1 * camera_time_y), vec3(10000.0, 0.0, 0.0), vec3(0.0, 10000.0, 0.0), 33.0);
  
  float speed = 4.0*texture(texFFTSmoothed,0.55).r + 5.0*vignette + 0.1;

  const float MOTION_VEC_SCALE_BROAD = speed * 400.0 * (texture(texFFTSmoothed, 0.1).r) + 0.0;
  const float MOTION_VEC_SCALE_FINE = speed * 1050.0 * (texture(texFFTSmoothed, 0.4).r) + 0.05;

  float grid = step(0.1, fract(scale * uv.x)) * step(0.1, fract(scale * uv.y));

  ivec2 UV_read = ivec2(gl_FragCoord.xy);
  ivec2 UV_write = ivec2(gl_FragCoord.xy + MOTION_VEC_SCALE_BROAD * motion_vec_broad.xy + MOTION_VEC_SCALE_FINE * motion_vec_fine.xy);

  vec3 flo = draw();

  write(UV_read, vec3(0.8* flo));

  //propagate along motion vectors
  vec3 local_value = read(UV_read) / 10.0;
  write(UV_write, local_value);
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