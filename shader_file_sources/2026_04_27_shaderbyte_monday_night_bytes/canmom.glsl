#version 430 core

//hello fieldfx! long time no see!

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

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    v ^= v >> 16u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    return v;
}

const float U32_MAX = float(0xffffffffu);
const float POS_OFFSET = float(0xfeu);
vec3 hash_float(vec3 v) {
  uvec3 vu = uvec3(v +POS_OFFSET);
  return hash(vu)*(1.0/U32_MAX);
}

bool flower_test(inout vec3 abs_pos, vec3 cell_centre, float size, vec3 ray_dir, inout vec4 colour) {
  float hit_flower = 0.0;
  vec3 ray_pos = abs_pos;
  for (int i = 0; i < 30; i++) {
    ray_pos = (abs_pos - cell_centre)/(size);
    float layer = floor(length(ray_pos)*10.0);
    float longitude = atan(ray_pos.y, ray_pos.x)+3.0*texture(texFFTIntegrated,layer/10.0).r;
    float latitude = atan(ray_pos.z, length(ray_pos.xy))/PI+0.5;
    if (latitude < (0.8-0.15*layer)+0.4*abs(fract((2.0+layer)*longitude/PI)-0.5)) {
      hit_flower = layer/10.0;
      break;
    }
    abs_pos += 0.005 * ray_dir*size;
    if (length(ray_pos) > 0.5) {break;}
  }
    
  if (hit_flower>0.0) {
    colour = vec4(mix(vec3(0.8,0.1,0.4)*0.6,vec3(1.0,0.3,1.0),hit_flower+1.5*ray_pos.z), 1.0);
    return true;
  } else {
    return false;
  }
}

const uint QUADTREE_DEPTH = 4;

vec3 quadtree_hash(vec2 position, out float size) {
  size = 1.0;
  vec2 corner;
  vec3 cell_hash;
  for (int i = 0; i < QUADTREE_DEPTH; i++) {
    corner = floor(position/(size*2.0*PERIOD));
    cell_hash = hash_float(vec3(corner,0.0));
    if (cell_hash.r > 0.5) {
      size /= 2.0;
    } else {
      return cell_hash;
    }
  }
  corner = floor(position/(size*2.0*PERIOD));
  cell_hash = hash_float(vec3(corner,0.0));
  return cell_hash;
  
}
  
void main(void) {
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float fft_time = 0.3*texture(texFFTIntegrated,0.1).r;
  
  
  vec3 cam_pos = vec3(cos(fft_time),1.5*sin(fft_time),0.45+0.05*sin(texture(texFFTIntegrated,0.3).r));
  
  float time = fGlobalTime;
  
  cam_pos *= vec3(1.0+step(mod(time+0.25*CAMPERIOD, 4.0*CAMPERIOD), 0.25*CAMPERIOD),1.0,3.0- step(mod(time, CAMPERIOD), 0.5*CAMPERIOD)-1.0*step(mod(time,CAMPERIOD),0.75*CAMPERIOD));
  
  vec3 cam_dir = normalize(-cam_pos);
  cam_pos += vec3(0.0,fft_time,0.0);
  vec3 cam_x = normalize(cross(vec3(0,0,1),cam_dir));
  vec3 cam_y = normalize(cross(cam_x,cam_dir));
  
  vec3 ray_dir = normalize(cam_dir + uv.x * cam_x - uv.y * cam_y);
  
  float dist = 1.0/0.0;
  vec3 ray_pos = cam_pos;
  bool hit_sphere = false;
  float size=2.0;
  
  out_color = vec4(vec3(0.02, 0.02, 0.04),1.0);
  
  for (int i = 0; i < 400; i++) {
    vec3 h = quadtree_hash(ray_pos.xy, size);
    float adjusted_size = size*2.0*PERIOD;
    vec3 cell_centre = vec3(adjusted_size*(floor(ray_pos.xy/adjusted_size)),0.0)+vec3(vec2(0.5*size),0.5*size);
    vec3 relative = ray_pos - cell_centre;
    dist = (length(relative)-0.5*size);
    if (dist < 0.001) {
      if (flower_test(ray_pos, cell_centre, size, ray_dir, out_color)) {
        out_color.xyz += 0.2*h-0.1;
        //out_color = vec4(h*vec3(clamp(dot(vec3(1.0,0.0,0.0),relative/size),0.0,1.0)+0.1),1.0);
        break;
      }
    } else if (ray_pos.z < -1) {
      //out_color.xyz = 0.1*h;
      break;
    } else {
      ray_pos += 0.25*(dist * ray_dir);
      //ray_pos.xy = mod((ray_pos.xy+PERIOD),2.0*PERIOD)-PERIOD;
    }
  }
  
  
  vec2 frame_uv = gl_FragCoord.xy/v2Resolution;
  for (int i = -1; i<2; i++) {
    for (int j = -1; j<2; j++) {
      out_color += texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution-vec2(i,j)*0.002)/9.0 * 0.5;
    }
  }
  
  //out_color = vec4(quadtree_hash(10.0*uv,size),1.0);
  
  out_color = tanh(1.5*out_color);
}