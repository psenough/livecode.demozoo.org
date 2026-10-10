#version 460 core

//hello reality!!

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
const float ACCUMULATION_RATE = 0.1;

vec3 accumulate(ivec2 UV, vec3 samp) {
  float r_old = imageLoad(computeTexBack[0], UV).r / QUANT;
  float g_old = imageLoad(computeTexBack[1], UV).r / QUANT;
  float b_old = imageLoad(computeTexBack[2], UV).r / QUANT;
  samp = vec3(r_old, g_old, b_old) * (1.0 - ACCUMULATION_RATE) + ACCUMULATION_RATE * samp;
  imageStore(computeTex[0], UV, uvec4(QUANT * samp.x));
  imageStore(computeTex[1], UV, uvec4(QUANT * samp.y));
  imageStore(computeTex[2], UV, uvec4(QUANT * samp.z));
  return samp;
}

vec3 pathtrace_sample(Ray ray, uvec3 seed, vec3 sun_dir) {
  float t;
  vec3 sphere_origin = vec3(0.0,0.0,0.0);
  float radius = 1.0;
  vec3 attenuation = vec3(1.0);
  vec3 col = vec3(0.0);
  vec3 hit_normal;
  vec3 hit_position;
  for (int i = 0; i < 20; ++i) {
    if (hit_sphere(ray, sphere_origin, radius, t)) {
      //hit a surface, bounce the ray
      //for now just confirm the hit
      hit_position = ray.origin + t * ray.dir;
      hit_normal = normalize(hit_position - sphere_origin);
      //return attenuation * SPHERE_COLOUR / (t * t);
    } else if (hit_xy_plane(ray, -1.0, t)) {
      hit_position = ray.origin + t * ray.dir;
      hit_normal = vec3(0.0, 0.0,1.0);
    } else {
      break;
    }
    ray.origin = hit_position + 0.0001 * hit_normal;
    ray.dir = normalize(2.0*(vec3(seed) * (1.0/float(0xffffffffu)))-1.0); //this is not a proper distribution at all
    attenuation *= max(dot(ray.dir, hit_normal), 0.0);
    seed = hash(seed);
  }
  bool hit_sun = hit_sphere(ray, 10.0*sun_dir, 1.0,t);
  vec3 sky_colour = mix(3.0*SKY_COLOR, SKY_COLOR, ray.dir.z);
  if (hit_sun) {
    sky_colour += vec3(50.0);
  }
  return 2.0*attenuation * sky_colour;

}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uvec3 seed = uvec3(gl_FragCoord.x, uint(fGlobalTime * 1000.0), gl_FragCoord.y);
  
  vec3 ray_origin = vec3(0.0, -4.0, 0.0);
  float fov_scale = 2.0;
  vec3 ray_dir = normalize(vec3(fov_scale * uv.x, 1.0, fov_scale * uv.y));
  
  Ray ray = Ray(ray_origin, ray_dir);
  
  float t = texture(texFFTIntegrated, 0.1).r;
  
  //vec3 sun_dir = normalize(vec3(cos(t), 1.0, sin(t)));
  vec3 sun_dir = normalize(vec3(cos(t),sin(t),0.5));
  
  vec3 col;
  
  const uint RAYS = 256;
  
  for (int i = 0; i < RAYS; ++i) {
    seed = hash(seed);
    col += pathtrace_sample(ray, seed, sun_dir);
  }
  
  col = accumulate(ivec2(gl_FragCoord.xy), col/float(RAYS));
 

	out_color = vec4(col, 1.0);
}