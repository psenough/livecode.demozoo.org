#version 460 core

//from the final Algoravioli
//a frankenstein of two previous shaders so the code is messy as fuck :p

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

//hey let's make swizzle
//soon to be seen in the skies over cologne!

float sdTriangle(in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2)
{
  vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
  vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
  vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0);
  vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0);
  vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0);
  float s = sign(e0.x * e2.y - e0.y * e2.x);
  vec2 d = min(min(vec2(dot(pq0, pq0), s * (v0.x * e0.y - v0.y * e0.x)),
        vec2(dot(pq1, pq1), s * (v1.x * e1.y - v1.y * e1.x))),
      vec2(dot(pq2, pq2), s * (v2.x * e2.y - v2.y * e2.x)));
  return -sqrt(d.x) * sign(d.y);
}

float edge(in vec2 p, in vec2 p0, in vec2 p1) {
  return (p.x - p0.x) * (p1.y - p0.y) - (p.y - p0.y) * (p1.x - p0.x);
}

struct Triangle {
  vec2[3] positions;
  vec3[3] colours;
  float[3] back_left_weight;
  float[3] back_right_weight;
  float[3] front_left_weight;
  float[3] front_right_weight;
  float[3] head_weight;
  float[3] tail_weight;
};

const int TRI_COUNT = 11;

const Triangle tris[TRI_COUNT] = Triangle[](
    //tail
    Triangle(
      vec2[3](
        vec2(-2.785, 1.043),
        vec2(-4.092, 0.780),
        vec2(-4.381, 0.022)
      ),
      vec3[3](
        vec3(0.510, 0.265, 0.768),
        vec3(0.408, 0.160, 0.757),
        vec3(0.437, 0.039, 0.757)
      ),
      float[3](0.488, 0.0, 0.0),
      float[3](0.488, 0.0, 0.0),
      float[3](0.012, 0.0, 0.0),
      float[3](0.012, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 1.0, 1.0)
    ),
    //back leg back left
    Triangle(
      vec2[3](
        vec2(-2.715, 1.124),
        vec2(-1.613, 1.852),
        vec2(-1.996, 0.026)
      ),
      vec3[3](
        vec3(0.255, 0.132, 0.384),
        vec3(0.255, 0.132, 0.384),
        vec3(0.198, 0.033, 0.108)
      ),
      float[3](0.488, 0.488, 0.977),
      float[3](0.488, 0.488, 0.0),
      float[3](0.012, 0.012, 0.23),
      float[3](0.012, 0.012, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0)
    ),
    //back leg front left
    Triangle(
      vec2[3](
        vec2(-1.898, 0.280),
        vec2(-1.575, 1.863),
        vec2(-0.838, 1.459)
      ),
      vec3[3](
        vec3(0.315, 0.145, 0.208),
        vec3(0.187, 0.155, 0.453),
        vec3(0.255, 0.132, 0.384)
      ),
      float[3](0.910, 0.487, 0.165),
      float[3](0.067, 0.487, 0.165),
      float[3](0.022, 0.013, 0.335),
      float[3](0.002, 0.013, 0.335),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0)
    ),

    //front leg left
    Triangle(
      vec2[3](
        vec2(-1.267, 0.906),
        vec2(-0.002, 0.003),
        vec2(-0.819, 1.409)
      ),
      vec3[3](
        vec3(0.172, 0.092, 0.255),
        vec3(0.185, 0.031, 0.100),
        vec3(0.086, 0.075, 0.379)
      ),
      float[3](0.531, 0.002, 0.170),
      float[3](0.142, 0.000, 0.170),
      float[3](0.189, 0.998, 0.330),
      float[3](0.138, 0.000, 0.330),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0)
    ),
    //back leg back right
    Triangle(
      vec2[3](
        vec2(-2.715, 1.124),
        vec2(-1.613, 1.852),
        vec2(-1.996, 0.026)
      ),
      vec3[3](
        vec3(0.510, 0.265, 0.768),
        vec3(0.510, 0.265, 0.768),
        vec3(0.396, 0.067, 0.214)
      ),
      float[3](0.488, 0.488, 0.0),
      float[3](0.488, 0.488, 0.977),
      float[3](0.012, 0.012, 0.0),
      float[3](0.012, 0.012, 0.23),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0)
    ),

    //back leg front right
    Triangle(
      vec2[3](
        vec2(-1.898, 0.280),
        vec2(-1.575, 1.863),
        vec2(-0.838, 1.459)
      ),
      vec3[3](
        vec3(0.629, 0.290, 0.415),
        vec3(0.373, 0.310, 0.906),
        vec3(0.510, 0.265, 0.768)
      ),
      float[3](0.070, 0.487, 0.165),
      float[3](0.906, 0.487, 0.165),
      float[3](0.002, 0.013, 0.335),
      float[3](0.022, 0.013, 0.335),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0)
    ),

    //front leg right
    Triangle(
      vec2[3](
        vec2(-1.267, 0.906),
        vec2(-0.002, 0.003),
        vec2(-0.819, 1.409)
      ),
      vec3[3](
        vec3(0.510, 0.265, 0.768),
        vec3(0.396, 0.067, 0.214),
        vec3(0.510, 0.265, 0.768)
      ),
      float[3](0.142, 0.000, 0.170),
      float[3](0.531, 0.002, 0.170),
      float[3](0.138, 0.000, 0.330),
      float[3](0.189, 0.998, 0.330),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0)
    ),
    //neck 1
    Triangle(
      vec2[3](
        vec2(-0.319, 0.663),
        vec2(-0.781, 1.425),
        vec2(0.393, 1.306)
      ),
      vec3[3](
        vec3(0.396, 0.067, 0.214),
        vec3(0.272, 0.439, 0.633),
        vec3(0.566, 0.149, 0.476)
      ),
      float[3](0.076, 0.174, 0.0),
      float[3](0.076, 0.174, 0.0),
      float[3](0.145, 0.326, 0.0),
      float[3](0.705, 0.326, 0.0),
      float[3](0.0, 0.0, 1.0),
      float[3](0.0, 0.0, 0.0)
    ),
    //neck 2
    Triangle(
      vec2[3](
        vec2(-0.781, 1.425),
        vec2(0.393, 1.306),
        vec2(0.465, 1.631)
      ),
      vec3[3](
        vec3(0.272, 0.439, 0.633),
        vec3(0.566, 0.149, 0.476),
        vec3(0.567, 0.223, 0.584)
      ),
      float[3](0.174, 0.0, 0.0),
      float[3](0.174, 0.0, 0.0),
      float[3](0.326, 0.0, 0.0),
      float[3](0.326, 0.0, 0.0),
      float[3](0.0, 1.0, 1.0),
      float[3](0.0, 0.0, 0.0)
    ),
    //head
    Triangle(
      vec2[3](
        vec2(0.502, 1.915),
        vec2(1.574, 1.343),
        vec2(0.323, 1.148)
      ),
      vec3[3](
        vec3(0.209, 0.636, 0.323),
        vec3(0.009, 0.723, 1.000),
        vec3(0.137, 0.636, 0.445)
      ),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](1.0, 1.0, 1.0),
      float[3](0.0, 0.0, 0.0)
    ),
    //ear
    Triangle(
      vec2[3](
        vec2(0.160, 1.868),
        vec2(0.447, 1.924),
        vec2(0.387, 1.661)
      ),
      vec3[3](
        vec3(0.209, 0.636, 0.323),
        vec3(0.009, 0.723, 1.000),
        vec3(0.137, 0.636, 0.445)
      ),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](0.0, 0.0, 0.0),
      float[3](1.0, 1.0, 1.0),
      float[3](0.0, 0.0, 0.0)
    )
  );

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

vec3 read(ivec2 UV) {
  float px = imageLoad(computeTexBack[0], UV).x / 1000.;
  float py = imageLoad(computeTexBack[0], UV + ivec2(0, 200)).x / 1000.0;
  float angle = imageLoad(computeTexBack[1], UV).x / 1000.0;

  return vec3(px, py, angle);
}

float trail_read(ivec2 UV) {
  return imageLoad(computeTexBack[2], UV).x / 1000.0;
}

void write(ivec2 UV, vec3 value) {
  imageStore(computeTex[0], UV, uvec4(value.x * 1000.0));
  imageStore(computeTex[0], UV + ivec2(0, 200), uvec4(value.y * 1000.0));
  imageStore(computeTex[1], UV, uvec4(value.z * 1000.0));
}

void trail_write(ivec2 UV, float trail) {
  imageAtomicMax(computeTex[2], UV, uint(trail * 1000.0));
}

const float TRAIL_FACTOR = 0.8;
const float BLUR_FACTOR = 0.99;
const float FADE = 0.01;

#define width uint(v2Resolution.x)
#define height uint(v2Resolution.y)
#define time fGlobalTime

const float SPEED = 1.5;
const float SAMPLE_OFFSET = 5.0;
const float ANGLE_SPACING = 17.0 * PI / 180;
const float TURN_SPEED = 0.075 * PI;
const float RESET_PERIOD = 6.0;

void diffuse(ivec2 UV) {
  float prev = trail_read(UV);

  float mean = 0.0;

  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      ivec2 UVclamp = ivec2(clamp(UV.x + i, 0, width - 1), clamp(UV.y + j, 0, height - 1));
      mean += imageLoad(computeTexBack[2], UV + ivec2(i, j)).x / 1000.0;
    }
  }
  mean /= 9.0;

  float diffused = mix(prev, mean, BLUR_FACTOR);

  if (mod(fGlobalTime, RESET_PERIOD) < 0.1) {
    trail_write(UV, 0.0);
  } else {
    trail_write(UV, diffused - FADE);
  }
}

//from https://www.shadertoy.com/view/sXS3Dw
vec3 c1(float t) {
  return vec3(0.20, 0.11, 0.09)
    + t * (vec3(2.41, 3.97, 1.95)
        + t * (vec3(-20.77, -44.43, 16.57)
            + t * (vec3(153.33, 183.16, -125.96)
                + t * (vec3(-401.40, -311.48, 297.60)
                    + t * (vec3(418.13, 231.50, -293.64)
                        + t * (vec3(-151.76, -62.60, 103.55)
                          ))))));
}

float sense(vec3 data, float angle_offset) {
  float next_angle = data.z + angle_offset;
  vec2 dir = vec2(cos(next_angle), sin(next_angle));
  vec2 sample_pos = data.xy + dir * SAMPLE_OFFSET;

  float sum = 0.0;
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      ivec2 sample_UV = ivec2(clamp(sample_pos.x + i, 0, width - 1), clamp(sample_pos.y + j, 0, height - 1));
      sum += trail_read(sample_UV);
    }
  }
  return sum;
}

const float U32_MAX = float(0xffffffffu);

vec3 hash_float(vec3 v) {
  uvec3 vu = uvec3(v);
  return hash(vu);
}

void sim(ivec2 UV, float speed_adjust) {
  uint id = UV.y * width + UV.x;
  if (UV.y > 20) return;

  vec3 h = hash_float(vec3(float(UV.x), float(UV.y), 100.0 * time));

  if (mod(fGlobalTime, RESET_PERIOD) < 0.1)
  {
    write(UV, vec3(width / 2, height / 2, h.x * 2.0 * PI));
  } else {
    vec3 data = read(UV);
    vec2 dir = vec2(cos(data.z), sin(data.z));
    //next_pos
    vec2 np = data.xy + dir * SPEED * speed_adjust * (20.0 * texture(texFFT, 0.1).x + 0.5);

    float sample_forward = sense(data, 0);
    float sample_left = sense(data, -ANGLE_SPACING);
    float sample_right = sense(data, ANGLE_SPACING);

    if (sample_forward > sample_left && sample_forward > sample_right) {
      data.z += 0.;
    } else if (sample_forward < sample_left && sample_forward < sample_right) {
      data.z += (h.z - 0.5) * TURN_SPEED;
    } else if (sample_left > sample_right) {
      data.z -= h.z * TURN_SPEED;
    } else {
      data.z += h.z * TURN_SPEED;
    }

    if (np.x <= 0. || np.x > width || np.y <= 0.0 || np.y > height) {
      np.x = h.z * width;
      np.y = h.x * height;
      data.z = h.y * 2.0 * PI;
    }
    if (mod(fGlobalTime, RESET_PERIOD) > RESET_PERIOD - 2.0) {
      float fadeout = 0.5 * (2.0 - mod(fGlobalTime, RESET_PERIOD) - (RESET_PERIOD - 2.0));
      trail_write(ivec2(np), TRAIL_FACTOR * fadeout);
    } else {
      trail_write(ivec2(np), TRAIL_FACTOR);
    }

    write(UV, vec3(np, data.z));
  }
}

void stasis(ivec2 UV) {
  vec3 data = read(UV);
  trail_write(ivec2(data.xy), TRAIL_FACTOR);
  write(UV, data);
}

float distance_travelled(float x_pos) {
  return 0.2 * sin(x_pos);
}

//hello fieldfx!!
//tonight we will be introducing the innovation of 'jamming in latex'
//not LaTeX

//let's start with just one swizzle

void main(void)
{
  float camera_time_x = texture(texFFTIntegrated, 0.1).r;
  float camera_time_y = texture(texFFTIntegrated, 0.2).r;

  float ctc = cos(camera_time_x);
  float cts = sin(camera_time_x);

  mat2 rot = mat2(ctc * 0.5, cts, -cts, ctc);

  //vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);

  ivec2 UV = ivec2(gl_FragCoord.xy);

  float loop_time = mod(fGlobalTime, RESET_PERIOD);
  float blast_scale = loop_time / RESET_PERIOD;
  if (loop_time > RESET_PERIOD - 2.0) {
    blast_scale = 0.5 * (2.0 - (loop_time - (RESET_PERIOD - 2.0)));
  }

  sim(UV, 1.0 + 3.0 * blast_scale);
  diffuse(UV);

  vec2 cuv = rot * (gl_FragCoord.xy / v2Resolution - 0.5) / vec2(v2Resolution.y / v2Resolution.x, 1.) * 2.0 + 0.4 * vec2(3.0 * cos(camera_time_x), 2.0 * sin(camera_time_y)); //

  //vec2 ruv = vec2(atan(cuv.y, cuv.x)/(2*PI), length(cuv));

  vec2 uv = vec2(1.0, 2.5) * gl_FragCoord.xy / v2Resolution.x + vec2(0.0, -0.25);

  float scale_osc = (1.0 + 0.5 * sin(texture(texFFTIntegrated, 0.2).r));

  //float physarum = trail_read(ivec2(vec2(0.5,0.8)*cuv * v2Resolution));
  float physarum = trail_read(ivec2(rot * (vec2(UV) - 0.5 * v2Resolution) * (1.0 - blast_scale) + 0.5 * v2Resolution + 0.15 * vec2(v2Resolution.x) * vec2(cts, ctc)));

  float walk_time = texture(texFFTIntegrated, 0.2).r;

  vec3 noise_1 = noised(vec3(20.0 * cuv + vec2(100.0), fGlobalTime)).yzw;
  vec3 noise_2 = noised(vec3(20.0 * cuv, fGlobalTime)).yzw;
  vec3 noise_curl = cross(noise_1, noise_2);

  float angle = -3.0 * texture(texFFTIntegrated, 0.9).r;
  float c = cos(angle);
  float s = sin(angle);

  vec2 scale = vec2(0.1, 0.3) * (0.5 + 0.5 * scale_osc);
  //vec2 scale = vec2(0.1);
  //vec2 scale = vec2(0.1,0.3)*1.5;

  //uv = mat2(c, s, -s, c) * uv;

  //uv += vec2(c,s)*texture(texFFTIntegrated, 0.8).r * 0.0001 /scale_osc;

  //uv = fract(uv*scale*10.0);

  uv += 0.8 * blast_scale * (noise_curl.yz * texture(texFFTSmoothed, 0.2).r + noise_curl.xy * texture(texFFTSmoothed, 0.1).r);

  vec3 colour = vec3(0.0);

  vec2 offset = vec2(0.65, 0.0);

  float back_leg_time = 10.0 * walk_time;
  float front_leg_time = 10.0 * walk_time - 0.5 * PI;

  float ground_height = distance_travelled(walk_time - uv.x);

  float tail_offset = texture(texFFTSmoothed, 0.1).r * 4.0;
  float back_left_offset = max(texture(texFFTSmoothed, 0.3).r * 5.0 * cos(back_leg_time), 0.0);
  float back_right_offset = max(-texture(texFFTSmoothed, 0.3).r * 5.0 * cos(back_leg_time), 0.0);
  float front_left_offset = max(texture(texFFTSmoothed, 0.5).r * 20.0 * cos(front_leg_time), 0.0);
  float front_right_offset = max(-texture(texFFTSmoothed, 0.5).r * 10.0 * cos(front_leg_time), 0.0);
  float head_offset = texture(texFFTSmoothed, 0.7).r * 10.0;

  float front_fb = 0.07 * sin(front_leg_time);
  float back_fb = 0.07 * sin(back_leg_time);

  float front_left_height = distance_travelled(walk_time - 0.5 - 0.2 - front_fb);
  float front_right_height = distance_travelled(walk_time - 0.5 - 0.2 + front_fb);
  float back_left_height = distance_travelled(walk_time - 0.5 + 0.2 - back_fb);
  float back_right_height = distance_travelled(walk_time - 0.5 + 0.2 + back_fb);

  bool hit = false;

  for (int i = 0; i < TRI_COUNT; i++) {
    vec2[3] pos = vec2[3](
        tris[i].positions[0] * scale + offset,
        tris[i].positions[1] * scale + offset,
        tris[i].positions[2] * scale + offset
      );

    for (int j = 0; j < 3; j++) {
      pos[j] += tris[i].back_left_weight[j] * vec2(back_fb, back_left_offset + back_left_height)
          + tris[i].front_left_weight[j] * vec2(front_fb, front_left_offset + front_left_height)
          + tris[i].back_right_weight[j] * vec2(-back_fb, back_right_offset + back_right_height)
          + tris[i].front_right_weight[j] * vec2(-front_fb, front_right_offset + front_right_height)
          + tris[i].head_weight[j] * vec2(0.0, head_offset + front_right_height)
          + tris[i].tail_weight[j] * vec2(0.0, tail_offset + back_right_height);
    }

    float[3] e = float[3](
        edge(uv, pos[1], pos[2]) / edge(pos[0], pos[1], pos[2]),
        edge(uv, pos[2], pos[0]) / edge(pos[1], pos[2], pos[0]),
        edge(uv, pos[0], pos[1]) / edge(pos[2], pos[0], pos[1])
      );

    if (e[0] > 0 && e[1] > 0 && e[2] > 0) {
      //calculate barycentric coordinates
      colour = e[0] * tris[i].colours[0]
          + e[1] * tris[i].colours[1]
          + e[2] * tris[i].colours[2];
      hit = true;
    }
  }

  colour = hue_shift(colour, texture(texFFTIntegrated, 0.05).r);

  vec2 tunnel = 0.5 - 0.2 * vec2(s, c);

  float ground = 0.5 * step(uv.y, ground_height);

  if (ground > 0.0) {
    hit = true;
  }

  float fade_glow = (1.0 - 0.8 * blast_scale);

  out_color = vec4(fade_glow * colour, 1.0) + texture(texPreviousFrame, (1.0 - 0.08 * blast_scale) * (gl_FragCoord.xy / v2Resolution - tunnel) + tunnel) * vec4(0.7, 0.82, 0.8, 1.0) + vec4(hue_shift(vec3(0.1, 0.5, 0.2), 5.0 * texture(texFFTIntegrated, 0.1).r), 1.0) * ground * fade_glow;

  if (!hit) {
    //out_color += vec4(c1(physarum),1.0);
    out_color += vec4(hue_shift(c1(0.5 * physarum), texture(texFFTIntegrated, 0.1).r + 5.0 * physarum) - vec3(0.2), 0.0);
  }

  //out_color =  vec4(c1(physarum),1.0);
  out_color *= 0.8;
  //out_color = vec4(uv,0.0, 1.0);
}
