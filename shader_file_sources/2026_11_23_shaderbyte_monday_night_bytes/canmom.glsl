#version 430 core

//we got fbm curl noise advection
//now let's add some kinda Cool Raymarched Shape eh

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
uniform sampler2D texSessions;
uniform sampler2D texShort;

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

vec2 noisefield(vec2 fc) {
  float nx = noised(vec3(fc, 0.0)).r;
  float ny = noised(vec3(fc + vec2(1100.0, 1000.00), 0.0)).r;
  return vec2(nx, ny);
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

const mat3 COLOUR_MIX = mat3(0.6, 0.25, 0.2,
    0.15, 0.9, 0.3,
    0.15, 0.2, 0.75);

vec3 hue_shift(vec3 color, float hue) {
  const vec3 k = vec3(0.57735, 0.57735, 0.57735);
  float cosAngle = cos(hue);
  return vec3(color * cosAngle + cross(k, color) * sin(hue) + k * dot(k, color) * (1.0 - cosAngle));
}

void advect(ivec2 UV, vec2 velocity, float weight) {
  vec3 local_value = weight * COLOUR_MIX * read(UV) / 1.5;
  ivec2 UV_write = UV + ivec2(velocity);
  vec2 inter = fract(velocity);
  write(UV_write, local_value * (1.0 - inter.x) * (1.0 - inter.y));
  write(UV_write + ivec2(1, 0), local_value * inter.x * (1.0 - inter.y));
  write(UV_write + ivec2(0, 1), local_value * (1.0 - inter.x) * inter.y);
  write(UV_write + ivec2(1, 1), local_value * inter.x * inter.y);
}

void blur(ivec2 UV, float weight) {
  vec3 value = weight * read(UV) / 9.0;
  write(UV, value);
  write(UV + ivec2(1, 0), value);
  write(UV + ivec2(0, 1), value);
  write(UV + ivec2(-1, 0), value);
  write(UV + ivec2(0, -1), value);
  write(UV + ivec2(1, 1), value);
  write(UV + ivec2(-1, 1), value);
  write(UV + ivec2(1, -1), value);
  write(UV + ivec2(-1, -1), value);
}

//gyroid after https://www.shadertoy.com/view/4lyGzR
vec2 path(in float z) {
  float s = sin(z * 0.11);
  float c = sin(z * 0.14);
  return vec2(c*4. - s * 1.5, c * 1.7 + s * 1.5);
}

//let's learn how to make a gyroid
float map(vec3 p) {
  p.xy -= path(p.z);
  
  float d = dot(cos(p*1.5707963), sin(p.yzx*1.5707963)) + 1.;
  float bio = d + .25 +  texture(texFFTSmoothed,0.4).r;
  return bio;
}

vec3 getNormal(in vec3 p) {
	const vec2 e = vec2(0.002, 0);
	return normalize(vec3(map(p + e.xyy) - map(p - e.xyy), map(p + e.yxy) - map(p - e.yxy),	map(p + e.yyx) - map(p - e.yyx)));
}

void main(void) {
  vec2 uv = gl_FragCoord.xy / v2Resolution.x;
  uv = 2.0 * uv - vec2(1.0, v2Resolution.y / v2Resolution.x);
  const float PI = radians(180.0);
  const float TAU = 2 * PI;
  float theta = atan(uv.y, uv.x) / PI + 2.0;
  const float NOISE_SCALE_0 = 0.003;
  const float NOISE_SCALE_1 = 0.012;
  const float NOISE_SCALE_2 = 0.031;
  const float WEIGHT_0 = 8.0;
  const float WEIGHT_1 = 3.0;
  const float WEIGHT_2 = 1.2;
  const float TOTAL_WEIGHT = WEIGHT_0 + WEIGHT_1 + WEIGHT_2;
  

  float r = length(uv);
  ivec2 UV = ivec2(gl_FragCoord.xy);
  float time = texture(texFFTIntegrated, 0.2).r;
  float spiral = mod(0.5 * theta - 2.0 * r + time, 1.0);
  float fft = 100.0 * texture(texFFT, spiral).r * spiral;

  
  
    
  vec3 ro=vec3(path(5.0*time),5.0*time);
  vec3 rd=normalize(vec3(uv, 1.0));
  
  float t=0.0, h;
  const int MAX_ITER = 72;
  for (int i; i < MAX_ITER; i++) {
    h = map(ro + rd * t);
    if(abs(h)<0.002*(t*.125 + 1.)) break;
    //ok so what's up with this step??
    //it seems to remapping the sdf distance somehow...
    //but why does that work?
    t += step(h, 1.)*h*.2 + h*.5;
  }
  
  vec3 normal = getNormal(ro+rd*t);
  float fresnel = dot(-normal, rd);
  
  float write_val = (1.0-tanh(0.1*t));
  
  float hue = TAU * write_val + 400.0 * texture(texFFTSmoothed, 0.3).r;
  vec3 write_colour = hue_shift(vec3(0.5, 0.0, 0.4), hue);
  
  vec4 n0 = noised(vec3(gl_FragCoord.xy * NOISE_SCALE_0/t, 5.0*texture(texFFTIntegrated, 0.1).r));
  vec4 n1 = noised(vec3(gl_FragCoord.xy * NOISE_SCALE_1 + vec2(10.0), 5.0*texture(texFFTIntegrated, 0.2).r));
  vec4 n2 = noised(vec3(gl_FragCoord.xy * NOISE_SCALE_2 + vec2(100.0), 5.0*texture(texFFTIntegrated, 0.3).r));

  //vec2 n = noisefield(gl_FragCoord.xy * (0.05 + 0.02*sin(texture(texFFTIntegrated,0.1).r))) + 2.0*noisefield(gl_FragCoord.xy * 0.1 + vec2(texture(texFFTIntegrated,0.2).r));
  vec2 n = (WEIGHT_0 * n0.zy + WEIGHT_1 * n1.zy + WEIGHT_2 * n2.zy) * vec2(1.0, -1.0)/TOTAL_WEIGHT;
  

  write(UV, 0.7 * vec3(write_colour * 0.3*write_val));
  float BLUR_WEIGHT = 0.6;
  advect(UV, 30.0*n*fresnel, 1.0 - BLUR_WEIGHT);
  blur(UV, BLUR_WEIGHT);

  
  out_color = vec4(fresnel);
  

  //out_color = vec4(vec3(fft),1.0);
  //out_color = vec4(vec3(n.x, n.y, 0.0),0.0);
  //out_color = vec4(adjusted_uv, 0.0, 1.0);
  //out_color = vec4(length(n),0.0,0.0,0.0);
  //out_color = vec4(n.x, n.y, 0.0, 1.0);
  out_color = vec4(vec3(read(UV)), 0.0);
  //out_color=vec4(0.5*n+0.5,0.0,0.0);
  //out_color = vec4(write_colour,1.0);
}
