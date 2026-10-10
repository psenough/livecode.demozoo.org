#version 460 core

//hello aldroid!

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

struct Ray {
  vec3 origin;
  vec3 dir;
};

bool hit_sphere(Ray ray, vec3 centre, float radius, out float t) {
  t = 1.0/0.0; //send t to infinity by default
  vec3 oc = ray.origin - centre;
  float b = dot(2.0 * ray.dir, oc);
  float c = dot(oc, oc) - radius * radius;
  float discriminant = b*b - 4.0*c;
  if (discriminant < 0.0) {
    return false;
  } else {
    float tmin = 0.5 * (-b - sqrt(discriminant));
    float tmax = 0.5 * (-b + sqrt(discriminant));
    if (tmin > 0.0) {
      t = tmin;
      return true;
    } else if (tmax > 0.0) {
      t = tmax;
      return true;
    } else {
      return false;
    }
  }
}

bool hit_xy_plane(Ray ray, float plane_height, out float t) {
  t = (plane_height - ray.origin.z)/ray.dir.z;
  return t > 0;
}

const vec3 SKY_COLOR = vec3(0.01, 0.08, 0.2);
const vec3 SPHERE_COLOUR = 10.0*vec3(0.8, 0.4, 0.1);

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

const float QUANT = 0xFFFFFFF;
const float ACCUMULATION_RATE = 0.3;

vec3 accumulate_old(ivec2 UV, vec3 samp) {
  float r_old = imageLoad(computeTexBack[0], UV).r / QUANT;
  float g_old = imageLoad(computeTexBack[1], UV).r / QUANT;
  float b_old = imageLoad(computeTexBack[2], UV).r / QUANT;
  samp = vec3(r_old, g_old, b_old) * (1.0 - ACCUMULATION_RATE) + ACCUMULATION_RATE * samp;
  imageStore(computeTex[0], UV, uvec4(QUANT * samp.x));
  imageStore(computeTex[1], UV, uvec4(QUANT * samp.y));
  imageStore(computeTex[2], UV, uvec4(QUANT * samp.z));
  return samp;
}

vec3 accumulate(ivec2 UV, vec3 samp) {
  vec4 prev;
  for (int i = -1; i < 2; i++) {
    for (int j = -1; j < 2; j++) {
      prev += texelFetch(texPreviousFrame, UV+ivec2(i,j), 0);
    }
  }
  return prev.rgb * 0.11111111 * (1.0 - ACCUMULATION_RATE) + ACCUMULATION_RATE * samp;
}

vec3 cosine_direction(uvec3 seed, vec3 hit_normal) {
  vec2 u = vec2(seed.xy) * (1.0/float(0xffffffffu));
  
  vec3 t = normalize(cross(vec3(0.0,1.0,0.0),hit_normal));
  vec3 b = normalize(cross(t,hit_normal));
  
  
  float r = sqrt(u.x);
  float theta = 2*3.14159265359 * u.y;
  float x = r * cos(theta);
  float y = r * sin(theta);
  return x * b + y * t + sqrt(max(0.0, 1-u.x)) * hit_normal;
}

vec3 pathtrace_sample(Ray ray, uvec3 seed, vec3 sun_dir, vec3 sphere_heights) {
  float t, t_1, t_2, t_3;
  vec3 sphere1_origin = vec3(-2.5,0.0,sphere_heights.x);
  vec3 sphere2_origin = vec3(0.0,0.0,sphere_heights.y);
  vec3 sphere3_origin = vec3(2.5,0.0, sphere_heights.z);
  float radius = 1.0;
  vec3 attenuation = vec3(1.0);
  vec3 col = vec3(0.0);
  vec3 hit_normal;
  vec3 hit_position;
  vec3 sphere1_colour = vec3(1.0, 0.2, 0.2);
  vec3 sphere2_colour = vec3(0.2, 1.0, 0.2);
  vec3 sphere3_colour = vec3(0.2, 0.2, 1.0);
  for (int i = 0; i < 20; ++i) {
    bool hit_sphere1 = hit_sphere(ray, sphere1_origin, radius * (1.0 + 0.5*sphere_heights.x), t_1);
    bool hit_sphere2 = hit_sphere(ray, sphere2_origin, radius * (1.0 + 0.5*sphere_heights.y), t_2);
    bool hit_sphere3 = hit_sphere(ray, sphere3_origin, radius * (1.0 + 0.5*sphere_heights.z), t_3);
    
    if (hit_sphere1 && t_1 < t_2 && t_1 < t_3) {
      hit_position = ray.origin + t_1 * ray.dir;
      hit_normal = normalize(hit_position - sphere1_origin);
      attenuation *= sphere1_colour;
      t = t_1;
    } else if (hit_sphere2 && t_2 < t_1 && t_2 < t_3) {
      hit_position = ray.origin + t_2 * ray.dir;
      hit_normal = normalize(hit_position - sphere2_origin);
      attenuation *= sphere2_colour;
      t = t_2;
    } else if (hit_sphere3 && t_3 < t_1 && t_3 < t_2) {
      hit_position = ray.origin + t_3 * ray.dir;
      hit_normal = normalize(hit_position - sphere3_origin);
      attenuation *= sphere3_colour;
      t = t_3;
    } else if (hit_xy_plane(ray, -1.0, t)) {
      hit_position = ray.origin + t * ray.dir;
      hit_normal = vec3(0.0, 0.0,1.0);
    } else {
      break;
    }
    ray.origin = hit_position + 0.0001 * hit_normal;
    ray.dir = cosine_direction(seed, hit_normal);
    //attenuation *= max(dot(ray.dir, hit_normal), 0.0);
    seed = hash(seed);
  }
  bool hit_sun = hit_sphere(ray, 5.0*sun_dir, 0.4+0.5*sphere_heights.x,t);
  vec3 sky_colour = 1.5*mix(3.0*SKY_COLOR, SKY_COLOR, ray.dir.z);
  if (hit_sun) {
    sky_colour += 3.0*vec3(14.0,14.0,10.0);
  }
  return 1.0*attenuation * sky_colour;

}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uvec3 seed = uvec3(gl_FragCoord.x, uint(fGlobalTime * 1000.0), gl_FragCoord.y);
  
  float rolling_shutter = texture(texFFT,0.1).r;
  
  float camera_t = fGlobalTime / 2.0 + rolling_shutter * uv.y;
  
  vec3 ray_origin = (7.0 + 2.0*cos(1.5 * camera_t)) * vec3(cos(3.0 * camera_t), sin(3.0*camera_t), 0.0);
  float fov_scale = 1.0;
  vec3 camera_dir = -normalize(ray_origin);
  vec3 camera_x = normalize(cross(camera_dir,vec3(0.0,0.0,1.0)));
  vec3 ray_dir = normalize(fov_scale * uv.x * camera_x + camera_dir + vec3(0.0,0.0,fov_scale * uv.y));
  
  Ray ray = Ray(ray_origin, ray_dir);
  
  vec3 sphere_heights = 10.0*vec3(texture(texFFTSmoothed, 0.01).r, 4.0*texture(texFFTSmoothed, 0.31).r,8.0*texture(texFFTSmoothed, 0.61).r);
  
  float t = texture(texFFTIntegrated, 0.1).r;

  
  
  //vec3 sun_dir = normalize(vec3(cos(t), 1.0, sin(t)));
  vec3 sun_dir = normalize(vec3(cos(t),sin(t),0.5));
  
  vec3 col;
  
  const uint RAYS = 128;
  
  for (int i = 0; i < RAYS; ++i) {
    seed = hash(seed);
    col += pathtrace_sample(ray, seed, sun_dir, sphere_heights);
  }
  
  col = accumulate(ivec2(gl_FragCoord.xy), tanh(col/float(RAYS)));
 

	out_color = vec4(col, 1.0);
}