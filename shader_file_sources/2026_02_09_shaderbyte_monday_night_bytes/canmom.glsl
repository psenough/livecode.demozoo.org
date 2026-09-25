#version 420 core

//hello!

//greets to all lets have a great jam :D
//it's octree time

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
const float POS_OFFSET = float(0xfffffu);

//pcg3d: https://github.com/markjarzynski/PCG3D
uvec3 hash(uvec3 v) {

    v = v * 1664525u + 1013904223u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    v ^= v >> 16u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    return v;
}

vec3 hash_float(uvec3 v) {
  return hash(v)*(1.0/U32_MAX);
}

const uint MAX_DEPTH = 3;

uint octree_depth(vec3 position) {
  vec3 test_point = position;
  uint depth = 0;
  
  for (; depth < MAX_DEPTH; ++depth) {
    if (hash_float(uvec3(test_point+POS_OFFSET)).r > 0.5) {
      test_point *= 2.0;
    } else {
      return depth;
    }
  }
}

vec3 boost_saturation(vec3 c, float amount) {
  float avg = (c.r + c.g + c.b)/3.0;
  vec3 delt = c - avg;
  return avg + delt * (amount + 1.0);
}

//we have an octree
//now to raymarch!!

bool cube_filled(vec3 position) {
  float scale = pow(2.0,float(octree_depth(position)));
  uvec3 v = uvec3(position * vec3(scale, scale, 1.0));
  vec3 hash = hash_float(v);
  return hash.r > 0.5;
}

vec3 raymarch(vec3 position, vec3 direction) {
  vec3 attenuation = vec3(1.0,1.0,0.7);
  for (int i = 0; i < 120; ++i) {
    float cell_size = pow(0.5,float(octree_depth(position)));
    vec3 position_in_cell = mod(position, cell_size);
    //ok let's do this exact
    
    vec3 steps = vec3(
      direction.x > 0.0 ? position_in_cell.x : cell_size - position_in_cell.x,
      direction.y > 0.0 ? position_in_cell.y : cell_size - position_in_cell.y,
      direction.z > 0.0 ? position_in_cell.z : cell_size - position_in_cell.z
    );
    steps /= abs(direction);
    float max_safe = max(min(steps.x, min(steps.y, steps.z)), pow(0.5,float(MAX_DEPTH)));
    
    vec3 hash = hash_float(uvec3(position/cell_size)+uvec3(2));
    bool central_tunnel = any(greaterThan(abs(position.xy), vec2(1.0)));
    if (central_tunnel && (hash.r > 0.8)) {
      return attenuation;
    } else {
      #if FALSE
      vec3 disp = direction * (max_safe*cell_size);
      #else
      vec3 disp = direction * pow(0.5, MAX_DEPTH);
      #endif
      position += disp;
      attenuation *= pow(vec3(0.98,0.98,0.99),5.0*vec3(length(disp)));
    }
  }
  return vec3(0.0);
}

void main(void)
{
  float time = texture(texFFTIntegrated, 0.1).r;
  vec3 start_position = vec3(0.1,0.1,time);
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 direction = normalize(vec3(uv, -1.0));

	out_color = vec4(vec3(raymarch(start_position+0.1*direction, direction)),1.0);
}