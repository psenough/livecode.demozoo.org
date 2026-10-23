#version 420 core

#define saturate(x) clamp(x, 0.0, 1.0)
#define repeat(i, n) for (int i = 0; i < n; i ++)

const float PI = acos(-1.0);
const float TAU = 2.0 * PI;

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
uniform sampler2D texRevisionBW;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 cis(float t) {
  return vec2(cos(t), sin(t));
}

mat2 rotate2D(float t) {
  float c = cos(t);
  float s = sin(t);
  return mat2(c, s, -s, c);
}

uvec3 hash3u(uvec3 v) {
  v = v * 1145141919u + 1919810u;
  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;
  v ^= v >> 16u;
  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;
  return v;
}

vec3 hash3f(vec3 v) {
  uvec3 x = floatBitsToUint(v);
  return vec3(hash3u(x)) / float(-1u);
}

vec3 seed;
vec3 random3() {
  seed = hash3f(seed);
  return seed;
}

vec3 uniformSphere(vec2 xi) {
  float phi16 = 16.0 * TAU * xi.x;
  float sint = 1.0 - 2.0 * xi.y;
  float cost = sqrt(1.0 - sint * sint);
  return vec3(
    cost * cos(phi16),
    cost * sin(phi16),
    sint
  );
}

mat3 orthbas(vec3 z) {
  z = normalize(z);
  vec3 up = abs(z.y) > .99 ? vec3(0, 0, 1) : vec3(0, 1, 0);
  vec3 x = normalize(cross(up, z));
  return mat3(x, cross(z, x), z);
}

vec3 cyclic(vec3 p, float pers, float lacu) {
  mat3 b = orthbas(vec3(-4, 3, -2));
  vec4 sum = vec4(0.0);
  
  repeat(i, 5) {
    p *= b;
    p += sin(p.zxy);
    sum += vec4(
      cross(cos(p), sin(p.yzx)),
      1.0
    );
    sum /= pers;
    p *= lacu;
  }
  
  return sum.xyz / sum.w;
}

void cwrite(vec2 uv, vec3 col) {
  ivec2 coord = ivec2(uv * v2Resolution);
  ivec3 icol = ivec3(1000.0 * col);

  imageAtomicAdd(computeTex[0], coord, icol.x);
  imageAtomicAdd(computeTex[1], coord, icol.y);
  imageAtomicAdd(computeTex[2], coord, icol.z);
}

vec3 cread(vec2 uv) {
  ivec2 coord = ivec2(uv * v2Resolution);

  return vec3(
    imageLoad(computeTexBack[0], coord).x,
    imageLoad(computeTexBack[1], coord).x,
    imageLoad(computeTexBack[2], coord).x
  ) / 1000.0;
}

vec3 posCube(float prog) {
  float t = fGlobalTime - 0.2 * prog;
  
  // cube
  vec3 pos = 2.0 * random3() - 1.0;
  
  // rotate
  float rt = 4.0 * t;
  rt += cyclic(vec3(5.0, 7.0, rt), 0.5, 1.0).x;
  pos.zx *= rotate2D(rt);
  
  // noise
  vec3 np = pos;
  np += cyclic(vec3(2.0, 3.0, 2.0 * t), 0.5, 2.0);
  np.z -= 10.0 * t;
  pos += 0.1 * cyclic(np, 0.5, 2.0);

  pos.z -= 2.0;

  return pos;
}

vec3 posSphere(float prog) {
  float t = fGlobalTime - 0.2 * prog;
  
  // sphere
  vec3 xi = random3();
  vec3 pos = uniformSphere(xi.xy);
  
  // layers
  pos *= 0.5 * floor(1.0 + 3.0 * xi.z);
  
  // rotate
  float rt = 4.0 * t;
  rt += cyclic(vec3(5.0, 7.0, rt), 0.5, 1.0).x;
  pos.zx *= rotate2D(rt);
  
  // noise
  vec3 np = pos;
  np += cyclic(vec3(2.0, 3.0, 2.0 * t), 0.5, 2.0);
  np.z -= 10.0 * t;
  pos += 0.5 * cyclic(np, 0.5, 2.0);
  
  // color explosion
  pos *= mix(1.0, 1.5, prog);

  return pos;
}

vec3 posHolo(float prog) {
  float t = fGlobalTime - exp(-2.0 + 2.0 * sin(fGlobalTime)) * prog;
  
  // plane
  vec3 xi = random3();
  vec3 pos = 2.0 * xi - 1.0;
  pos.y = 0.0;
  
  // edges
  xi = random3();
  if (xi.x < 0.2) {
    pos.x = sign(pos.x);
  } else if (xi.x < 0.4) {
    pos.z = sign(pos.z);
  }
  
  // dots
  if (xi.y < 0.1) {
    pos.xz *= 6.0;
    pos.xz -= 0.5;
    pos.xz = round(pos.xz);
    pos.xz += 0.5;
    pos.xz /= 6.0;
    pos.y += mix(0.03, 0.06, xi.z);
  }
  
  // noise
  float noisescale = exp2(-2.0 + 2.0 * cyclic(vec3(7.0, 2.0, 2.0 * t), 0.5, 1.0).x);
  vec3 np = 2.0 * pos;
  np += cyclic(vec3(2.0, 3.0, 2.0 * t), 0.5, 2.0);
  np.z -= 10.0 * t;
  pos += vec3(0, 1, 0) * noisescale * cyclic(np, 0.5, 2.0);
  
  // arc
  xi = random3();
  if (xi.x < 0.1) {
    pos = vec3(0.0);
    pos.y = mix(0.0, 4.0, floor(100.0 * xi.z) / 100.0);
    pos.xz = 1.5 * cis(PI * xi.y + 4.0 * t * hash3f(pos.yyy).x);
  }
  
  // revision
  xi = random3();
  if (xi.z < 0.5) {
    vec3 poscand = random3() - 0.5;
    poscand.z = xi.x < 0.2 ? 0.5 * sign(poscand.z) : poscand.z;
    poscand.z *= 0.1;
    float tex = texture2D(texRevisionBW, poscand.xy + 0.5).x;
    
    if (tex > 0.5) {
      pos = poscand;
      pos.zx *= rotate2D(3.1 * t);
      pos.yz *= rotate2D(2.7 * t);
      pos.y += 0.6;
    }
  }
  
  // rotate
  float rt = 4.0 * t;
  rt += cyclic(vec3(5.0, 7.0, rt), 0.5, 1.0).x;
  pos.zx *= rotate2D(rt);
  
  // disperse
  xi = random3();
  float disperseamp = exp2(-8.0 + 3.0 * cyclic(vec3(17.0, 5.0, 5.0 * t), 0.5, 1.0).x);
  // pos += disperseamp * pow(xi.x, 0.33) * uniformSphere(xi.yz);
  
  // holo
  xi = random3();
  if (xi.x < 0.2) {
    pos = mix(pos, vec3(0, 2, 0), xi.y);
  }
  
  // color explosion
  // pos *= mix(1.0, 1.1, pow(prog, 1.0));
  pos *= mix(1.0, 1.5, pow(prog, 6.0));

  return pos;
}

vec3 colfuck(float t) {
  return 3.0 * vec3(0.5 - 0.5 * cos(TAU * saturate(1.5 * t - 0.25 * vec3(0.0, 1.0, 2.0))));
}

vec3 movefuck(float t, vec3 heck) {
  float tt = t;
  tt += cyclic(heck + 2.0 + t, 0.5, 1.0).x;

  return mix(
    hash3f(heck + floor(t)),
    hash3f(heck + floor(t + 1.0)),
    smoothstep(0.0, 0.1, fract(t))
  ) * 2.0 - 1.0;
}

void main() {
  float aspect = v2Resolution.x / v2Resolution.y;
  
  vec3 fuck = cyclic(vec3(fGlobalTime, 1.2, 3.8), 0.5, 2.0);
  
	vec2 uv = gl_FragCoord.xy / v2Resolution;
  seed = vec3(uv, fGlobalTime);

  repeat(i, 10) {
    float prog = float(i) / 10.0 + random3().x;
    float t = fGlobalTime - 0.1 * prog;
    
    vec3 pos = posHolo(prog);

    // camera
    vec3 co = vec3(0.0, 0.8, 2.0);
    vec3 ct = vec3(0.0, 0.2, 0.0);
    mat3 cb = orthbas(co - ct);
    pos -= co;
    pos *= cb;
    
    // camera animation
    pos.xy *= rotate2D(0.4 * movefuck(t, vec3(1.0, 2.0, -1.0)).x);
    pos += 0.2 * movefuck(t, vec3(6.0, 7.0, -1.0));

    if (pos.z < 0.0) {
      // projection
      pos /= -pos.z;
      pos *= 2.0;
      pos.x *= v2Resolution.y / v2Resolution.x;
      pos = 0.5 + 0.5 * pos;
      
      vec3 col = colfuck(prog);
      cwrite(pos.xy, 0.04 * col);
    }
  }

  if (fuck.x > 0.2) {
    uv -= 0.5;
    uv.x *= aspect;
    uv = abs(uv);
    uv *= rotate2D(fGlobalTime);
    uv.x /= aspect;
    uv += 0.5;
  }

  vec3 col = cread(uv);
  col = pow(col, vec3(0.4545));
  col = smoothstep(
    vec3(0.0, -0.1, -0.2),
    vec3(1.0, 1.0, 1.1),
    col
  );
	out_color = vec4(col, 1.0);
  
  if (fuck.y > 0.2) {
    uv -= 0.5;
    uv /= 1.1;
    uv += 0.5;
    out_color = mix(
      1.0 - texture2D(texPreviousFrame, uv),
      out_color,
      0.5
    );
  } else {
    out_color = mix(
      texture2D(texPreviousFrame, uv),
      out_color,
      0.2
    );
  }
}