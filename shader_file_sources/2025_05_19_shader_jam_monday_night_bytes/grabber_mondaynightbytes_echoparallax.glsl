#version 420 core

// hi!
// hopefully if this works right, my theme will be "Rendering Worlds with (???) Triangles"
// woooo!!
// let's go!

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

// 0: FFT, 1: visibility buffer, 2 : frame count
layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float g_kick;

// We're in the prepared part at the moment so this should go faster
// than usual

float spectrum(float u) {
  float v = (50. / 22050.) * pow(240., u);
  float loudness = clamp(0.01, v, (1-v)/3.);
  return 25. * texture(texFFT, v).r * loudness;
}

// and now for the interesting part!
// I'm going to drop in some code I wrote a few hours ago because it
// was hard to write and there's no way I could do this live

struct Triangle {
  vec3 v[3]; // In pixel screen coordinates, .z = depth (0-inf)
};

void swap(inout vec3 a, inout vec3 b) {
  vec3 temp = b;
  b = a;
  a = temp;
}

const uint BLOCK_SIZE = 16;
const uint WORK = 2; // Each pixel does at most WORK^2 writes

void raster(Triangle tri, uint id, ivec2 localThread)
{
  // imageAtomicMax(computeTex[1], ivec2(200, 200) + localThread, 0xFFFFFFFFu);
  // All triangles must have tri.z > 0 because I don't want to implement clipping
  // Reorder vertices so that v0 has min y, v2 has max y
  if(tri.v[0].y > tri.v[1].y) swap(tri.v[0], tri.v[1]);
  if(tri.v[1].y > tri.v[2].y) swap(tri.v[1], tri.v[2]);
  if(tri.v[0].y > tri.v[1].y) swap(tri.v[0], tri.v[1]);
  // Conceptually:
  // for(y = minY, y <= maxY; y++) {
  //   compute minX, maxX by solving plane equations
  //   for(x = minX, x <= maxX; x++) {
  //     compute barycentric coordinates
  //     compute depth; depth < 0 ? reject
  //     depth -> 1/(1+depth)
  //     imageAtomicMax
  //   }
  // }
  int minY = int(round(tri.v[0].y)); // below 0.5 could include the pixel, above 0.5 definitely doesn't
  int maxY = int(round(tri.v[2].y)); // Exclusive
  int sizeY = maxY - minY;
  for(int iterY = 0; iterY < WORK; iterY++)
  {
    int yI = localThread.y + iterY * int(BLOCK_SIZE);
    // If we have enough threads, arrange them linearly; otherwise,
    // spread them out
    if(sizeY <= int(BLOCK_SIZE * WORK)) {
      yI = minY + yI;
      if(yI >= maxY) break;
    } else {
      yI = int(mix(float(minY), float(maxY), float(yI) / float(BLOCK_SIZE * WORK)));
    }
    float y = float(yI) + 0.5;
    // Edge equations
    // (v0 + (v1-v0)t).y == y
    // -> t = (y - v0.y) / (v1.y - v0.y);
    // -> x = v0.x + (v1.x - v0.x) * t
    vec2 edges[3];
    edges[0] = (tri.v[1] - tri.v[0]).xy;
    edges[1] = (tri.v[2] - tri.v[1]).xy;
    edges[2] = (tri.v[0] - tri.v[2]).xy;
    float winding = cross(vec3(edges[0],0.), vec3(edges[2], 0.)).z;
    float minXF = -1e6, maxXF = 1e6;
    for(int i = 0; i < 3; i++){
      vec2 e = edges[i];
      if(e.y == 0.0) continue; // Skip horizontal edges
      vec2 v = tri.v[i].xy;
      float x = v.x + e.x * (y - v.y) / e.y;
      // For our default winding, if our edge is going down, we're on the right side
      if(e.y * winding < 0.) maxXF = min(maxXF, x);
      else                   minXF = max(minXF, x);
    }
    // To half-pixel centers
    int minX = int(round(minXF));
    int maxX = int(round(maxXF)); // Exclusive
    int sizeX = maxX - minX;
    
    for(int iterX = 0; iterX < WORK ; iterX++) {
      int xI = localThread.x + iterX * int(BLOCK_SIZE);
      // If we have enough threads, arrange them linearly; otherwise,
      // spread them out
      if(sizeX <= int(BLOCK_SIZE * WORK )) {
        xI = minX + xI;
        if(xI >= maxX) break;
      } else {
        xI = int(mix(float(minX), float(maxX), float(xI) / float(BLOCK_SIZE * WORK)));
      }
      float x = float(xI) + .5;
      // Barycentric coordinates
      // v0 * (1 - u - v) + v1 * u + v2 * v = (x,y)
      // (v1 - v0) * u + (v2 - v0) * v == (x,y) - v0
      // column 0 is edges[0]
      // column 1 is -edges[2]
      vec2 d = vec2(x, y) - tri.v[0].xy;
      vec2 bary = vec2(dot(vec2(edges[2].y, -edges[2].x), d), dot(vec2(edges[0].y, -edges[0].x), d)) / winding;
      float depth = tri.v[0].z * (1 - bary.x - bary.y) + tri.v[1].z * bary.x + tri.v[2].z * bary.y;
      
      float depth01 = 1. / (1 + depth);
      // Encode to a 32-bit int
      uint encoded = uint(0xFFFF * depth01) << 16 | id;
      imageAtomicMax(computeTex[1], ivec2(xI, yI), encoded);
    }
  }
}

// but what comes next will be!

// Random number generation using pcg32i_random_t, using inc = 1. Our random state is a uint.
uint stepRNG(uint rngState)
{
  return rngState * 747796405 + 1;
}

// Steps the RNG and returns a floating-point value between 0 and 1 inclusive.
float rnd(inout uint rngState)
{
  // Condensed version of pcg_output_rxs_m_xs_32_32, with simple conversion to floating-point [0,1].
  rngState  = stepRNG(rngState);
  uint word = ((rngState >> ((rngState >> 28) + 4)) ^ rngState) * 277803737;
  word      = (word >> 22) ^ word;
  return float(word) / 4294967295.0f;
}

// thank you blackle
vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}

// https://github.com/hughsk/glsl-hsv2rgb/blob/master/index.glsl
vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float gram(uint back, uint bin) {
  return imageLoad(computeTexBack[0], ivec2(back, bin)).r / 1e6;
}

void main(void)
{
  g_kick = texture(texFFTSmoothed, (4.f + 0.5f)/1024.f).r;
  
  ivec2 thread = ivec2(gl_FragCoord.xy);
  ivec2 block2 = thread / ivec2(BLOCK_SIZE);
  int block = block2.x + block2.y * int(v2Resolution.x / BLOCK_SIZE);
  ivec2 localThread = thread - ivec2(BLOCK_SIZE) * block2;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  // Update FFT in compute texture
  {
    float sgram2 = float(imageLoad(computeTexBack[0], thread + ivec2(-1,0))) / 1e6;
    if(thread.x == 0) sgram2 = texture(texFFT, uv.y).r;
    imageStore(computeTex[0], thread, uvec4(sgram2 * 1e6));
  }
  // And frame counter
  uint frame = imageLoad(computeTexBack[2], ivec2(0,0)).r;
  if(thread == ivec2(0,0)) {
    imageStore(computeTex[2], ivec2(0,0), ivec4(frame + 1));
  }
  
  // Rasterization part
  vec3 eye = vec3(5., 5., -5.);
  eye = erot(eye, vec3(0,1,0), 0.3 * texture(texFFTIntegrated, (4.5)/1024).r);
  
  vec3 look = vec3(0., 0., 0.);
  vec3 fwd = normalize(look - eye);
  vec3 up = vec3(0., 1., 0);
  vec3 right = normalize(cross(up, fwd));
  up = cross(fwd, right);
  
  // Scene
  Triangle tri;
  uint id = 0;
  {
    const uint PER_ROW = 32;
    uint col = block % PER_ROW;
    uint row = block / PER_ROW;
    float s00 = gram(row, col + 0);
    float s10 = gram(row + 1, col + 0);
    tri.v[0] = vec3(float(col + 0) / float(PER_ROW), s00 + float(row) / 32., float(row)/10.);
    tri.v[1] = vec3(float(col + 1) / float(PER_ROW), s10 + float(row) / 32., float(row)/10.);
    tri.v[2] = tri.v[0] - vec3(0., 0.07, 0.0);
    
    for(int i = 0; i < 3; i++){
      vec3 v = tri.v[i];
      
      v = vec3(-.5) + v;
      
      float rot = -0.01 * row * sin(0.15 * fGlobalTime);
      mat2 m = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
      v.xy = m * v.xy;
      v.yz = m * v.yz;
      
      v.x *= 2;
      v.xy /= (v.z + 1.0);
      
      v.xy += vec2(.5);
      v.xy *= v2Resolution.xy;
      
      
      
      tri.v[i] = v;
    }
    
    id = row + 1;
  }
  
  {
    for(int i = 0; i < 3; i++) {
      vec3 v = tri.v[i];
      
      // View
      /*
      v -= eye;
      v = vec3(dot(v, right), dot(v, up), dot(v, fwd));
      
      v.xy = 0.2 * v2Resolution.y * v.xy + 0.5 * v2Resolution.xy;
      */
      
      tri.v[i] = v;
    }
    
    raster(tri, id, localThread);
  }
  
  // Pixel shader part
  // ehh let's do some chromatic aberration here
  // or not!
#if 0
  vec3 sgram = vec3(0.);
  for(int i = 0; i < 3; i++){
    sgram[i] = float(imageLoad(computeTex[0], thread + ivec2(i + 20 * abs(sin(uv.y)), 0) ).r) / 1e6;
  }
#else
  vec3 sgram = vec3(imageLoad(computeTex[0], thread).r / 1e6);
#endif
  vec3 col = 100. * vec3(sgram) * uv.y;
  
  uint encoded = imageLoad(computeTexBack[1], thread).r;
  float depth = float(encoded >> 16) / 0xFFFF;
  id = (encoded & 0xFFFF);
  if(id > 0){ // anything?
    col = hsv2rgb(vec3(float(id - 0.99 * frame) / 10.0, 0.5, 1.0));
  }
  
  if(uv.y < 0.2 * spectrum(uv.x)) {
    col = vec3(1., 0., .5);
  }

	out_color = vec4(col, 1.);
}