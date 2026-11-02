#version 460 core

//hey everyone who's excited for EMF!!
//time to go and figure out some cool compute nonsense
//going to try and figure out flopine's shader from revision

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

const float PI = radians(180.0);

const float PERIOD = 0.75;
const float CAMPERIOD = 15.0;

//pcg3d: https://github.com/markjarzynski/PCG3D
uvec3 hash(uvec3 v) {
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

const float U32_MAX = float(0xffffffffu);
const float POS_OFFSET = float(0xfeu);

const uint QUADTREE_DEPTH = 4;

vec3 hash_float(vec3 v) {
    uvec3 vu = uvec3(v);
    return hash(vu) * (1.0 / U32_MAX);
}

vec3 quadtree_hash(vec2 position, out float size) {
    size = 4.0;
    vec2 corner;
    vec3 cell_hash;
    for (int i = 0; i < QUADTREE_DEPTH; i++) {
        corner = floor(position / (size * 2.0 * PERIOD));
        cell_hash = hash_float(vec3(corner, 0.0));
        if (cell_hash.r > 0.5) {
            size /= 2.0;
        } else {
            return cell_hash;
        }
    }
    corner = floor(position / (size * 2.0 * PERIOD));
    cell_hash = hash_float(vec3(corner, 0.0));
    return cell_hash;
}

const uint MAX_DEPTH = 3;

vec3 read (ivec2 UV) {
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
  imageStore(computeTex[0], UV+ivec2(0,200), uvec4(value.y * 1000.0));
  imageStore(computeTex[1], UV, uvec4(value.z * 1000.0));
}

void trail_write(ivec2 UV, float trail) {
  imageAtomicMax(computeTex[2], UV, uint(trail * 1000.0));
}

const float TRAIL_FACTOR = 0.8;
const float BLUR_FACTOR = 0.95;
const float FADE = 0.02;

#define width uint(v2Resolution.x)
#define height uint(v2Resolution.y)
#define time fGlobalTime

const float SPEED = 2.0;
const float SAMPLE_OFFSET = 5.0;
const float ANGLE_SPACING = 17.0 * PI/180;
const float TURN_SPEED = 0.2 * PI;

void diffuse(ivec2 UV) {
  float prev = trail_read(UV);
  
  float mean = 0.0;
  
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      ivec2 UVclamp = ivec2(clamp(UV.x + i, 0, width-1), clamp(UV.y+j, 0, height-1));
      mean += imageLoad(computeTexBack[2],UV+ivec2(i,j)).x / 1000.0;
    }
  }
  mean /= 9.0;

  float diffused = mix(prev,mean,BLUR_FACTOR);
  
  if (fGlobalTime < 0.1) {
    trail_write(UV, 0.0);
  } else {
    trail_write(UV, diffused-FADE);
  }
}


//from https://www.shadertoy.com/view/sXS3Dw
vec3 c1(float t) {
    return vec3(0.20,0.11,0.09)
        +t*(vec3(2.41,3.97,1.95)
        +t*(vec3(-20.77,-44.43,16.57)
        +t*(vec3(153.33,183.16,-125.96)
        +t*(vec3(-401.40,-311.48,297.60)
        +t*(vec3(418.13,231.50,-293.64)
        +t*(vec3(-151.76,-62.60,103.55)
    ))))));
}


float sense(vec3 data, float angle_offset) {
  float next_angle = data.z + angle_offset;
  vec2 dir = vec2(cos(next_angle), sin(next_angle));
  vec2 sample_pos = data.xy + dir * SAMPLE_OFFSET;
  
  float sum = 0.0;
  for (int i=-1; i <=1; i++) {
    for (int j=-1; j<=1; j++) {
      ivec2 sample_UV = ivec2(clamp(sample_pos.x +i, 0, width-1), clamp(sample_pos.y+j,0,height-1));
      sum += trail_read(sample_UV);
    }
  }
  return sum;
}

void sim(ivec2 UV) {
  uint id = UV.y * width + UV.x;
  if (UV.y > 100) return;
  
  vec3 h = hash_float(vec3(float(UV.x), float(UV.y), time));
  
  if (time < 0.1)
  {
    write(UV, vec3(width/2, height/2, h.y*2.0*PI));
  } else {
    vec3 data = read(UV);
    vec2 dir = vec2(cos(data.z), sin(data.z));
    //next_pos
    vec2 np = data.xy + dir * SPEED;
    
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
    
    if (np.x <= 0. || np.x > width) {
      np.x = clamp(np.x, 0, width-1);
      data.z = h.z * 2.0 * PI;
    }
    
    if (np.y <= 0.0 || np.y > height) {
      np.y = clamp(np.y, 0, height-1);
      data.z = h.z * 2.0 * PI;
    }
    
    trail_write(ivec2(np), TRAIL_FACTOR);
    
    write(UV, vec3(np, data.z));
  }
}

void stasis(ivec2 UV) {
  vec3 data = read(UV);
  trail_write(ivec2(data.xy),TRAIL_FACTOR);
  write(UV, data);
}

void main() {
  //vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  //uv -= 0.5;
  //uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  ivec2 UV = ivec2(gl_FragCoord.xy);
  
  //stasis(UV);
  sim(UV);
  diffuse(UV);
  //should_be_noop(UV);
  //diffuse_inline(UV);
  
  out_color = vec4(vec3(trail_read(UV)), 1.0);
  //out_color = vec4(hash_float(vec3(float(UV.x), float(UV.y), time)), 1.0);
}
