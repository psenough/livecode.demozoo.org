#version 460 core

//hello reality and all eight other jammers!!

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


//intersect a cone pointing vertically upwards
bool hit_cone(Ray ray, vec3 tip, float cosa, out float t, out vec3 n) {
  //based on solution by 'light is beautiful'
  // https://lousodrome.net/blog/light/2017/01/03/intersection-of-a-ray-and-a-cone/
    vec3 co = ray.origin - tip;
    vec3 v = vec3(0.0, 0.0, -1.0);
  
    float dotrdsv = -ray.dir.z;
  
    float cosa2 = cosa * cosa-0.02 * (tip.z);

    float a = ray.dir.z * ray.dir.z - cosa2;
    float b = 2. * (ray.dir.z*co.z - dot(ray.dir,co)*cosa2);
    float c = co.z*co.z - dot(co,co)*cosa2;

    float det = b*b - 4.*a*c;
    if (det < 0.) return false;

    det = sqrt(det);
    float t1 = (-b - det) / (2. * a);
    float t2 = (-b + det) / (2. * a);

    // Determine which of the t, if any, is a solution:
    bool hitFound = false;
    vec3 cp;
    float cone_height = tip.z + 0.5;
    if (t1 >= 0.0)
    {
        vec3 cp1 = ray.origin + t1 * ray.dir - tip;
        float h = -cp1.z;
        if (h >= 0.0 && h < cone_height)
        {
            hitFound = true;
            t = t1;
            cp = cp1;
        }
    }
    if (t2 >= 0.0 && (!hitFound || t2 < t))
    {
        vec3 cp2 = ray.origin + t2 * ray.dir - tip;
        float h = -cp2.z;
        if (h >= 0.0 && h < cone_height)
        {
            hitFound = true;
            t = t2;
            cp = cp2;
        }
    }
    
    n = normalize(-cp * cp.z / dot(cp, cp) - v);

    return hitFound;
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
  float t, t_1, t_sun;
  float radius = 1.0;
  vec3 attenuation = vec3(1.0);
  vec3 col = vec3(0.0);
  vec3 hit_normal;
  vec3 hit_position;
  vec3 cone_colour = vec3(1.0, 0.1, 0.3);
  bool hit_sun = false;
  for (int i = 0; i < 10; ++i) {
    bool found_hit = false;
    float this_t, prev_t = 1.0/0.0;
    vec3 this_normal, prev_normal = vec3(0.0,0.0,1.0);
    for (int cone_index = 0; cone_index < 10; ++cone_index) {
      float cone_position = float(cone_index)*2.0;
      bool this_hit = hit_cone(ray, vec3(cone_position, 0.0, 1.0+7.5*pow(texture(texFFTSmoothed, float(cone_index)*0.1).r,0.3)), 0.98, this_t, this_normal);
      if (this_hit && this_t < prev_t) {
        found_hit = true;
        prev_t = this_t;
        prev_normal = this_normal;
        cone_colour = vec3(1.0, 0.1, float(cone_index)*0.1);
      }
    }
    
    hit_normal = prev_normal;
    
    hit_sun = hit_sphere(ray, 5.0*sun_dir, 0.4+0.5*sphere_heights.x,t_sun);
    
    if (found_hit && (!hit_sun || this_t < t_sun)) {
      hit_position = ray.origin + prev_t * ray.dir;
      attenuation *= cone_colour;
      t = prev_t;
    } else if ( hit_sun) {
      hit_sun = true;
      break;
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

  vec3 sky_colour = 1.5*mix(3.0*SKY_COLOR, SKY_COLOR, ray.dir.z);
  if (hit_sun) {
    sky_colour += 3.0*vec3(14.0,14.0,10.0);
  }
  return 1.0*attenuation * sky_colour;

}

void main_old(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uvec3 seed = uvec3(gl_FragCoord.x, uint(fGlobalTime * 1000.0), gl_FragCoord.y);
  
  float rolling_shutter = 0.0;
  
  float camera_t = fGlobalTime / 2.0 + rolling_shutter * uv.y;
  
  vec3 ray_origin = (7.0 + 2.0*cos(1.5 * camera_t)) * vec3(cos(3.0 * camera_t), sin(3.0*camera_t), 0.0);
  float fov_scale = 2.0;
  vec3 camera_dir = -normalize(ray_origin);
  vec3 camera_x = normalize(cross(camera_dir,vec3(0.0,0.0,1.0)));
  vec3 ray_dir = normalize(fov_scale * uv.x * camera_x + camera_dir + vec3(0.0,0.0,fov_scale * uv.y));
  
  vec3 camera_position = 2.0 + 6.0*(1.0 + sin(camera_t)) * vec3(1.0,0.0,0.1)-vec3(0.0,0.0,2.0);
  
  Ray ray = Ray(ray_origin+camera_position, ray_dir);
  
  vec3 sphere_heights = 10.0*vec3(texture(texFFTSmoothed, 0.01).r, 4.0*texture(texFFTSmoothed, 0.31).r,8.0*texture(texFFTSmoothed, 0.61).r);
  
  float t = texture(texFFTIntegrated, 0.1).r;

  //we'll put these guys back while I work on the next thing!
  
  //vec3 sun_dir = normalize(vec3(cos(t), 1.0, sin(t)));
  vec3 sun_dir = 2.0*normalize(5.0*vec3(cos(t) + 5.0,3.0*sin(t),0.5));
  
  vec3 col;
  
  const uint RAYS = 32;
  
  for (int i = 0; i < RAYS; ++i) {
    seed = hash(seed);
    col += pathtrace_sample(ray, seed, sun_dir, sphere_heights);
  }
  
  col = accumulate(ivec2(gl_FragCoord.xy), tanh(col/float(RAYS)));
 

	out_color = vec4(col, 1.0);
}

void main(void)
{
  main_old();
}