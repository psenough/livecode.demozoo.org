#version 430 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texInercia2025_t;
uniform sampler2D texInerciaBW_t;
uniform sampler2D texInerciaID_t;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

// http://www.jcgt.org/published/0009/03/02/
vec3 hash(uvec3 v) {

    v = v * 1664525u + 1013904223u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    v ^= v >> 16u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    return vec3(v) * (1.0/float(0xffffffffu));
}

uvec3 uhash(uvec3 v) {
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

//borrowing noise with derivatives from Inigo Quilez
//https://www.shadertoy.com/view/4dffRH
//thanks Inigo we would be nowhere without you <3
vec4 noised( in vec3 x )
{
  // grid
  uvec3 i = uvec3(floor(x));

  vec3 f = fract(x);
  
  // quintic interpolant
  vec3 u = f*f*f*(f*(f*6.0-15.0)+10.0);
  vec3 du = 30.0*f*f*(f*(f-2.0)+1.0);  
  
  // gradients
  vec3 ga = hash( i+ivec3(0,0,0) );
  vec3 gb = hash( i+ivec3(1,0,0) );
  vec3 gc = hash( i+ivec3(0,1,0) );
  vec3 gd = hash( i+ivec3(1,1,0) );
  vec3 ge = hash( i+ivec3(0,0,1) );
  vec3 gf = hash( i+ivec3(1,0,1) );
  vec3 gg = hash( i+ivec3(0,1,1) );
  vec3 gh = hash( i+ivec3(1,1,1) );
  
  // projections
  float va = dot( ga, f-vec3(0.0,0.0,0.0) );
  float vb = dot( gb, f-vec3(1.0,0.0,0.0) );
  float vc = dot( gc, f-vec3(0.0,1.0,0.0) );
  float vd = dot( gd, f-vec3(1.0,1.0,0.0) );
  float ve = dot( ge, f-vec3(0.0,0.0,1.0) );
  float vf = dot( gf, f-vec3(1.0,0.0,1.0) );
  float vg = dot( gg, f-vec3(0.0,1.0,1.0) );
  float vh = dot( gh, f-vec3(1.0,1.0,1.0) );

  // interpolations
  float k0 = va-vb-vc+vd;
  vec3  g0 = ga-gb-gc+gd;
  float k1 = va-vc-ve+vg;
  vec3  g1 = ga-gc-ge+gg;
  float k2 = va-vb-ve+vf;
  vec3  g2 = ga-gb-ge+gf;
  float k3 = -va+vb+vc-vd+ve-vf-vg+vh;
  vec3  g3 = -ga+gb+gc-gd+ge-gf-gg+gh;
  float k4 = vb-va;
  vec3  g4 = gb-ga;
  float k5 = vc-va;
  vec3  g5 = gc-ga;
  float k6 = ve-va;
  vec3  g6 = ge-ga;
  
  return vec4( va + k4*u.x + k5*u.y + k6*u.z + k0*u.x*u.y + k1*u.y*u.z + k2*u.z*u.x + k3*u.x*u.y*u.z,    // value
               ga + g4*u.x + g5*u.y + g6*u.z + g0*u.x*u.y + g1*u.y*u.z + g2*u.z*u.x + g3*u.x*u.y*u.z +   // derivatives
               du * (vec3(k4,k5,k6) + 
                     vec3(k0,k1,k2)*u.yzx +
                     vec3(k2,k0,k1)*u.zxy +
                     k3*u.yzx*u.zxy ));
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 sample_ground_plane(vec3 camera_pos, vec3 camera_dir, vec2 uv, float offset, float noise_pulse, float fov_factor, float tex_scale) {
  vec3 camera_x = normalize(cross(camera_dir,vec3(0,0,1)));
  vec3 camera_y = normalize(cross(camera_x, camera_dir));
  vec3 ray = normalize((uv.x * camera_x + uv.y * camera_y) * fov_factor + camera_dir);
  vec3 mist_colour = vec3(0.0,0.05,0.1);
  if (ray.z >= 0) {
    return mist_colour;
  } else {
    vec2 ground_uv = tex_scale*camera_pos.z*ray.xy/ray.z + camera_pos.xy+vec2(1000.0);
    float scale = 1.0;
    for (int i=0; i < 40; i++) {
      
      vec4 noise_up = noised(vec3(ground_uv, offset));
      vec4 noise_down = noised(vec3(ground_uv, -offset));
      vec3 curl = cross(noise_up.yzw, noise_down.yzw);
      float aspect_id = 454.0/131.0;
      vec2 tex_uv = 0.1*ground_uv*vec2(1.0,-aspect_id)+noise_pulse*(1.0-scale)*curl.xy;
      vec4 tex_id = texture(texInerciaID_t, tex_uv);
      if (tex_id.a > 0.5) {
        uvec2 cell = uvec2(tex_uv);
        vec3 cell_colour = mix(hash(uvec3(cell, offset)), hash(uvec3(cell, offset+1)), fract(offset));
        float mist = exp(-0.008*length(ground_uv-vec2(1000.0)));
        return mix(mist_colour,(tex_id.xyz  + 0.5*cell_colour) ,1.5*mist* scale);
      }
      float vstep = 0.03;
      ground_uv += vstep*ray.xy/ray.z;
      offset += vstep;
      scale *= 0.9;
    }
    return mist_colour;
  }
}

void main(void)
{
  float camera_rotation_time = 0.1*fGlobalTime;
  float camera_height = abs(sin(0.2*fGlobalTime));
  float camera_distance = 1.0;
  vec2 camera_rotation = vec2(cos(camera_rotation_time),sin(camera_rotation_time));
  float noise_pulse = 5.0*texture(texFFTSmoothed,0.1).r;
  float fft_time = texture(texFFTIntegrated, 0.2).r;
  
  vec2 uv = 2.0*gl_FragCoord.xy/v2Resolution.y - vec2(v2Resolution.x/v2Resolution.y,1.0);
  
  vec3 camera_position = camera_distance * vec3(25.0 * camera_rotation, 40.0*camera_height);
  vec3 camera_direction = normalize(vec3(-camera_rotation, -0.8*camera_height));
  
  vec3 ground = sample_ground_plane(camera_position, camera_direction, uv, fft_time, noise_pulse, 0.2, 0.5);
  
	out_color = vec4(tanh(1.5*ground), 1.0);
  //out_color = vec4(ground_uv, 0.0,1.0);
  //out_color = vec4(curl, 1.0);
}