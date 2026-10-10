#version 420 core

uniform float fGlobalTime;
uniform vec2 v2Resolution;
layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color;

#define time fGlobalTime
#define PI acos(-1)
#define TAU (2 * PI)
#define saturate(x) clamp(x, 0.0, 1.0)
#define phase(x) (floor(x) + .5 + .5 * cos(TAU * .5 * exp(-5. * fract(x))))

float beat, beatTau, beatPhase;
int nBeat, scene;

const uint C_HASH = 20242024u;

float hash12(vec2 p)
{
    uvec2 x = floatBitsToUint(p);
    x = C_HASH * ((x >> 8u) ^ x.yx);
    x = C_HASH * ((x >> 8u) ^ x.yx);
    x = C_HASH * ((x >> 8u) ^ x.yx);
    return float(x.x) / float(0xffffffffu);
}

vec4 hash42(vec2 p)
{
    uvec4 x = floatBitsToUint(vec4(p, 1.0, 2.0));
    x = C_HASH * ((x >> 8u) ^ x.yzwx);
    x = C_HASH * ((x >> 8u) ^ x.yzwx);
    x = C_HASH * ((x >> 8u) ^ x.yzwx);
    return vec4(x) / float(0xffffffffu);
}

// AEP logo: 10 polygons, 64 vertices.
const float logoVertices[128] = float[128](
  -.53, .38, -.33, .12, -.33, -.29,
  -.26, -.37, .53, -.37, .47, -.3,
  .47, -.22, -.05, -.22, -.19, -.04,
  -.19, .22, .47, .22, .32, .38,
  -.72, .38, -1.15, -.07, -.9, -.07,
  -.71, .15, -.39, -.25, -.39, .1,
  -.6, .38, 1.16, .38, .94, .38,
  1.22, .07, 1.08, -.07, .82, -.07,
  .73, -.15, .73, -.22, 1.16, -.22,
  1.46, .07, .88, .16, .53, .16,
  .53, -.3, .62, -.4, .69, -.4,
  .69, -.01, .85, -.01, .97, .08,
  .47, -.07, .36, .09, -.13, .09,
  -.13, -.03, -.1, -.07, -.98, -.26,
  -.64, -.26, -.54, -.37, -.36, -.37,
  -.47, -.24, -.57, -.1, -.84, -.1,
  .37, .38, .53, .22, .86, .22,
  .71, .38, -1.06, -.1, -1.18, -.1,
  -1.46, -.38, -1.33, -.38, -.92, -.1,
  -1.01, -.1, -1.28, -.38, -1.18, -.38,
  .76, .38, .91, .22, 1.02, .22,
  .87, .38
);

const int logoOffsets[11] = int[11](0, 12, 19, 28, 36, 41, 48, 52, 56, 60, 64);
// xy: lower corner, zw: upper corner of each polygon.
const vec4 logoBounds[10] = vec4[10](
  vec4(-.53, -.37, .53, .38), vec4(-1.15, -.25, -.39, .38),
  vec4(.73, -.22, 1.46, .38), vec4(.53, -.4, .97, .16),
  vec4(-.13, -.07, .47, .09), vec4(-.98, -.37, -.36, -.1),
  vec4(.37, .22, .86, .38), vec4(-1.46, -.38, -1.06, -.1),
  vec4(-1.28, -.38, -.92, -.1), vec4(.76, .22, 1.02, .38)
);

vec2 logoVertex(int index) {
  index *= 2;
  return vec2(logoVertices[index], logoVertices[index + 1]);
}

vec2 logoOffset(int first) {
  if (nBeat % 8 >= 4) return vec2(0.0);
  float currentBeat = floor(beat);
  vec2 offsetA = (hash42(vec2(currentBeat, float(first))).xy * 2.0 - 1.0) * 0.5;
  vec2 offsetB = (hash42(vec2(currentBeat + 1.0, float(first))).xy * 2.0 - 1.0) * 0.5;
  if (mod(currentBeat, 4.0) == 0.0) offsetA = vec2(0.0);
  if (mod(currentBeat + 1.0, 4.0) == 0.0) offsetB = vec2(0.0);
  return mix(offsetA, offsetB, phase(fract(beat)));
}

float polygon(vec2 p, int first, int count) {
  vec2 firstVertex = logoVertex(first);
  float d = dot(p - firstVertex, p - firstVertex);
  float s = 1.0;

  for (int i = first, j = first + count - 1; i < first + count; j = i, ++i) {
    vec2 vertexI = logoVertex(i);
    vec2 vertexJ = logoVertex(j);
    vec2 e = vertexJ - vertexI;
    vec2 w = p - vertexI;
    vec2 b = w - e * saturate(dot(w, e) / dot(e, e));
    d = min(d, dot(b, b));

    bvec3 c = bvec3(p.y >= vertexI.y, p.y<vertexJ.y, e.x * w.y> e.y * w.x);
    if (all(c) || all(not(c))) {
      s = -s;
    }
  }

  return s * sqrt(d);
}

vec3 pal(float h) {
  vec3 col = vec3(.5) + .5 * cos(TAU * (vec3(0.0, .33, .67) + h));
  return mix(col, vec3(1.0), .1 * floor(h));
}

float logoDistanceExact(vec2 p) {
  float d = 1e3;
  vec2 margin = nBeat % 8 < 4 ? vec2(0.5) : vec2(0.0);
  for (int i = 0; i < 10; ++i) {
    // The animated offset stays within 0.5 on each axis.
    vec2 coarse = max(max(logoBounds[i].xy - margin - p,
                          p - logoBounds[i].zw - margin), 0.0);
    if (d >= 0.0 && dot(coarse, coarse) >= d * d) continue;
    vec2 q = p - logoOffset(logoOffsets[i]);
    vec2 outside = max(max(logoBounds[i].xy - q, q - logoBounds[i].zw), 0.0);
    if (d >= 0.0 && dot(outside, outside) >= d * d) continue;
    d = min(d, polygon(q, logoOffsets[i], logoOffsets[i + 1] - logoOffsets[i]));
  }
  return d;
}

// Cache the unshifted logo on a fixed [-2, 2] square. Bonzomatic exposes
// computeTexBack as the previous frame's computeTex image.
const float logoCacheExtent = 2.0;

uint logoCacheTag(ivec2 size) {
  return 0x4c000000u ^ (uint(size.x) << 12u) ^ uint(size.y);
}

void writeLogoCache() {
  ivec2 pixel = ivec2(gl_FragCoord.xy);
  ivec2 size = ivec2(v2Resolution);
  if (any(greaterThanEqual(pixel, size))) return;
  uint tag = 0u;
  if (nBeat % 8 >= 4) {
    vec2 p = ((vec2(pixel) + 0.5) / vec2(size) * 2.0 - 1.0) * logoCacheExtent;
    imageStore(computeTex[0], pixel, uvec4(floatBitsToUint(logoDistanceExact(p))));
    tag = logoCacheTag(size);
  }
  imageStore(computeTex[1], pixel, uvec4(tag));
}

float logoDistance(vec2 p) {
  if (nBeat % 8 >= 4) {
    ivec2 size = ivec2(v2Resolution);
    vec2 pixel = (p / logoCacheExtent * 0.5 + 0.5) * vec2(size);
    ivec2 texel = ivec2(floor(pixel));
    if (all(greaterThanEqual(texel, ivec2(0))) && all(lessThan(texel, size)) &&
        imageLoad(computeTexBack[1], texel).x == logoCacheTag(size)) {
      vec2 samplePoint = ((vec2(texel) + 0.5) / vec2(size) * 2.0 - 1.0) * logoCacheExtent;
      float sampleDistance = uintBitsToFloat(imageLoad(computeTexBack[0], texel).x);
      // A signed distance field is 1-Lipschitz: this is a safe lower bound.
      float lowerBound = sampleDistance - length(p - samplePoint);
      if (lowerBound > 0.02) return lowerBound;
    }
  }
  return logoDistanceExact(p);
}

// Extrude the same 2D logo used by the foreground layer.
float logoExtrusion(vec3 p) {
  vec2 w = vec2(logoDistance(p.xy), abs(p.z) - .12);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}

void rot(inout vec2 p, float a) { p *= mat2(cos(a), sin(a), -sin(a), cos(a)); }

void U(inout vec4 hit, float distance, float material, float intensity, float hue) {
  if (distance < hit.x) {
    hit = vec4(distance, material, intensity, hue);
  }
}

vec4 map(vec3 p) {
  vec3 pos = p;
  if (scene >= 1)
  {
    float a = 4;
    p = mod(p, a) - 0.5 * a;
  }

  if (scene >= 2)
  {
    vec3 offset = vec3(0.3, 0.3, 0.0);
    p -= offset;

    for (int i = 0; i < 3; i++) {
        p = abs(p + offset) - offset;
        rot(p.xy, TAU * 0.8);
        rot(p.zy, TAU * 0.3);
        rot(p.xz, TAU * 0.3 * beatPhase);
    }
  }

  rot(p.xz, beatTau / 4);
  vec4 m = vec4(logoExtrusion(p), 1, 1, 10);
  U(m, logoExtrusion(p - vec3(0.1, 0, 0)), 0, 1, 0.4);
  U(m, logoExtrusion(p - vec3(0, 0.1, 0)), 0, clamp(sin(beatTau + TAU * pos.z / 16.0), 0, 1), (scene >= 3) ? fract(pos.z * 0.02) : 0.0);
  return m;
}

vec3 normal(vec3 p) {
  vec2 e = vec2(0.01, 0);
  return normalize(vec3(
    map(p + e.xyy).x - map(p - e.xyy).x,
    map(p + e.yxy).x - map(p - e.yxy).x,
    map(p + e.yyx).x - map(p - e.yyx).x
  ));
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 color = vec3(0.0);
  float rayLength = 0.0;

  for (int i = 0; i < 30; i++) {
    vec3 p = ro + rd * rayLength;
    vec4 hit = map(p);

    if (hit.y == 1.0) {
      rayLength += hit.x;
      if (hit.x < 0.001) {
        vec3 light = normalize(vec3(1.0, 1.0, -1.0));
        vec3 n = normal(p);
        float diffuse = clamp(dot(n, light), 0.0, 1.0);
        float specular = pow(clamp(dot(n, normalize(light - rd)), 0.0, 1.0), 10.0);
        color += 0.1 * diffuse + specular;
        break;
      }
    } else {
      rayLength += 0.5 * abs(hit.x) + 0.01;
      color += clamp(0.001 * pal(hit.w) * hit.z / abs(hit.x), 0.0, 1.0);
    }
  }

  return color * exp(-0.1 * rayLength);
}

void main() {
  vec2 p = (2.0 * gl_FragCoord.xy - v2Resolution.xy) / v2Resolution.y;


  vec2 uv = gl_FragCoord.xy / v2Resolution;
  uv -= 0.5;
  uv.x *= v2Resolution.x / v2Resolution.y;

  beat = time * 150 / 60;
  beatTau = beat * TAU;
  beatPhase = phase(beat / 2);
  nBeat = int(beat);
  scene = (nBeat / 4) % 4;

  float bpm = 132;
  beat = time * bpm / 60;
  beatTau = beat * TAU;
  beatPhase = phase(beat);

  // p.x += (0.5 + 0.5 * hash42(vec2(floor(p.y * 20), 0.0)).x * 0.1 * saturate(cos(beatTau))) * 3.;


  writeLogoCache();

  vec3 ro = vec3(0, 0, -2);
  if (scene >= 1 ) ro = vec3(0, 0, beat);
  vec3 rd = vec3(uv, 0.5 + step(24, nBeat % 32) * cos(beatTau / 8));
  rd = normalize(rd);
  vec3 col = render(ro, rd);
  vec3 inv = saturate(vec3(1) - col);

  float foreground = smoothstep(fwidth(p.x), 0.0, logoDistance(p));
  col = mix(col, inv, foreground);
  if (nBeat % 2 == 1) col = vec3(1) - col;
  out_color = vec4(col, 1.0);
}
