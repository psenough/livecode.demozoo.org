#version 420 core

//hello havoc, archy, totetmatt, weatherman, boris!
//excited to jam

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

uint life(ivec2 UV, uint forcing) {
  int left = (UV.x - 1) % int(v2Resolution.x);
  int right = (UV.x + 1) % int(v2Resolution.x);
  int up = (UV.y + 1) % int(v2Resolution.y);
  int down = (UV.y - 1) % int(v2Resolution.y);
  uint current = + imageLoad(computeTexBack[0],UV).x;
  uint living_neighbours = imageLoad(computeTexBack[0],ivec2(left, up)).x
  + imageLoad(computeTexBack[0],ivec2(UV.x, up)).x
  + imageLoad(computeTexBack[0],ivec2(right, up)).x
  + imageLoad(computeTexBack[0],ivec2(left, UV.y)).x
  + imageLoad(computeTexBack[0],ivec2(right,UV.y)).x
  + imageLoad(computeTexBack[0],ivec2(left,down)).x
  + imageLoad(computeTexBack[0],ivec2(UV.x,down)).x
  + imageLoad(computeTexBack[0],ivec2(right,down)).x
  + current;
  
  if (forcing > 0) {
    imageStore(computeTex[0],UV,uvec4(1));
    return current;
  } else if (living_neighbours == 3) {
    imageStore(computeTex[0],UV,uvec4(1));
    return 1;
  } else if (living_neighbours > 4) {
    imageStore(computeTex[0],UV,uvec4(0));
    return 0;
  } else {
    return current;
  }
}

const uint MAX_STEPS = 20;

float sample_ground_plane(vec3 camera_pos, vec3 camera_dir, vec2 uv, float fov_factor, float tex_scale) {
  vec3 camera_x = normalize(cross(camera_dir,vec3(0,0,1)));
  vec3 camera_y = normalize(cross(camera_x, camera_dir));
  vec3 ray = normalize((uv.x * camera_x + uv.y * camera_y) * fov_factor + camera_dir);
  if (ray.z >= 0) {
    return 0.0;
  } else {
    

    vec2 ground_position = tex_scale*camera_pos.z*ray.xy/ray.z + camera_pos.xy;
    ivec2 ground_uv = ivec2(mod(ground_position,v2Resolution));
    uint life_cell = imageLoad(computeTexBack[0],ground_uv).r;
    
    if (life_cell == 1) {
      return life_cell;
    } else {
      vec2 step_v = -0.5*ray.xy*tex_scale;
      
      //now we raymarch into the Game of Life plane
      for(int i = 0; i < MAX_STEPS; i++) {
        ground_position += step_v;
        ivec2 ground_uv = ivec2(mod(ground_position,v2Resolution));
        uint life_cell = imageLoad(computeTexBack[0],ground_uv).r;
        if (life_cell == 1) {
          return 0.2;
        }
      }
    }
  }
}

void main(void)
{
  float fft = texture(texFFTSmoothed, 0.05).x;
  vec2 offset = vec2(texture(texFFTIntegrated,0.3).x,texture(texFFTIntegrated,0.15).x);
  float noise = step(0.15,9.0*texture(texNoise, 0.5*gl_FragCoord.xy / v2Resolution + offset).x*fft + 0.3*texture(texNoise, 5.0*gl_FragCoord.xy / v2Resolution).x);
  
  vec2 uv = 2.0*gl_FragCoord.xy/v2Resolution.y - vec2(v2Resolution.x/v2Resolution.y,1.0);
  
  float do_life = texture(texFFT, 0.0).x;
  uint l;
  if (do_life >= 0.02) {
    l = life(ivec2(gl_FragCoord.xy), uint(noise));
  } else {
    l = imageLoad(computeTexBack[0],ivec2(gl_FragCoord.xy)).x;
    imageStore(computeTex[0],ivec2(gl_FragCoord.xy),ivec4(l));
  }

  
  float camera_rotation_time = 0.05*fGlobalTime;
  vec2 camera_rotation = vec2(cos(camera_rotation_time),sin(camera_rotation_time));
  
  float ground_sample = sample_ground_plane(vec3(25.0 * camera_rotation, 40.0), normalize(vec3(-camera_rotation, -0.08)), uv, 0.1, 0.5);
  
	out_color = vec4(vec3(0.1,0.1,0.1)+ground_sample*vec3(0.6,0.2,0.6),1.0);
}