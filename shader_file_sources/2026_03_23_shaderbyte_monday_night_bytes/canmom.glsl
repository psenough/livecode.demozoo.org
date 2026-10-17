#version 430 core

//hello fieldfx crew! thanks for listening to the talk today!

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

//we have 3D divergence free noise so
//let's see if we can do something 3D with it

//bitpack the particle positions, quantised to 16 bits per axis, in the first two compute buffers
//then I can perspective project each particle, and write it with atomic adds to the third buffer.
//and then finally I read the third compute buffer and render it the following frame.

const float GRID_SCALE = 65536.0;
const float GRID_SCALE_INV = 1.0/GRID_SCALE;

vec3 read_position(ivec2 UV) {
  //upper 16 bits are x, lower 16 bits are y
  uint xy = imageLoad(computeTexBack[0], UV).r;
  uint x = (xy & 0xFFFF0000) >> 16;
  uint y = xy & 0xFFFF;
  uint z = imageLoad(computeTexBack[1], UV).r;
  
  return vec3(
    x, y, z
  ) * GRID_SCALE_INV;
}

void write_position(ivec2 UV, vec3 value) {
  uvec3 uvalue = uvec3(value * GRID_SCALE);
  uint x = ((uvalue.x & 0xFFFF) << 16);
  uint y = uvalue.y & 0x0000FFFF;
  uint xy = x | y;
  uint z = uvalue.z & 0x0000FFFF;
  imageStore(computeTex[0],UV,uvec4(xy));
  imageStore(computeTex[1],UV,uvec4(z));
}

const float SPEED = 0.005;

//integrate the position of the particle owned by this pixel
vec3 integrate(ivec2 UV, vec3 offset, vec3 noise) {
  vec3 pos = read_position(UV);
  vec3 noise_up = noised(pos+ offset).yzw;
  vec3 noise_down = noised(pos-offset).yzw;
  vec3 curl = cross(noise_up, noise_down);
  vec3 new_pos = pos + curl * SPEED + noise;
  //if a particle goes out of bounds, place it at a random position
  //alternatively can use fract() but this increases planar artefacts
  if (any(greaterThan(new_pos, vec3(1.0))) || any(lessThan(new_pos,vec3(0.0)))) {
    new_pos = hash(uvec3(UV.x, UV.y, 100*fGlobalTime));
  }
  //vec3 new_pos = pos;
  write_position(UV, new_pos);
  return new_pos;
}

//perspective project particles and draw them to computeTex[2]
void project_particle(vec3 pos, vec3 camera_dir) {
  vec3 camera_x = normalize(cross(camera_dir, vec3(0,1,0)));
  vec3 camera_y = normalize(cross(camera_x, camera_dir));
  float projected_x = dot(camera_x, pos);
  float projected_y = dot(camera_y, pos);
  float projected_z = dot(camera_dir, pos);
  if (projected_z <= 0) {
    return;
  }
  float fov = 1.0;
  vec2 projected_uv = vec2(projected_x, projected_y)/(projected_z * fov);
  ivec2 projected_pixel = ivec2((projected_uv + vec2(0.5*v2Resolution.x/v2Resolution.y, 0.5)) * v2Resolution.y);
  imageAtomicAdd(computeTex[2],projected_pixel,1);
}

float saturate(float t) {
  return clamp(t,0.0, 1.0);
}

const float PI = 4.0*asin(1.0);
  
void main(void) {
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  float acc_mask = 1.0;
  vec3 acc = vec3(0.0);
  vec3 backface_acc = vec3(0.0);
  
  for (float i = 1.0; i > 0.0; i -= 0.1) {
    uv += vec2(0.0,-0.03);
    float dist2 = dot(uv,uv);
    float r = 0.5*i;
    float z2 = 10.0*(r*r-dot(uv,uv));
    float z = sqrt(z2);
    vec2 xydir = normalize(uv);
    float mask = step(dist2,r*r);
    vec3 n = vec3(xydir * sqrt(dist2) * mask/r,z);
    vec3 lambert = vec3(0.0,0.1,0.1)*mask+vec3(1.0,1.0,0.8)*saturate(dot(n, normalize(vec3(1.0,0.4,0.4))));
    vec3 lambert_backface = vec3(0.0,0.1,0.1)*mask+vec3(1.0,1.0,0.8)*saturate(dot(n*vec3(1.0,1.0,-1.0), normalize(vec3(1.0,0.4,0.4))));
    float longi = atan(n.z,n.x)/PI;
    float latitude = atan(n.y, sqrt(dot(n.xz, n.xz)));
    float longitude = 1.0-fract(longi + 0.2*texture(texFFTIntegrated, i).r);
    float zigzag = step(abs(fract(longitude*4.0)-0.5),latitude-0.8+1.5*i);
    longi = atan(-n.z,n.x)/PI;
    longitude = 1.0-fract(longi + 0.2*texture(texFFTIntegrated, i).r);
    float zigzag_backface = step(abs(fract(longitude*4.0)-0.5),latitude-0.8+1.5*i);
    vec3 colour = mix(vec3(1.0,0.2,0.1),vec3(0.1,0.2,1.0),i);
    
    acc += 2.0*(1.0-zigzag)*lambert * acc_mask*colour+zigzag*(1.0-zigzag_backface)*lambert * acc_mask*colour;
    
    acc_mask *= min(zigzag,zigzag_backface);
  }
  
  
  
  //it's a sphere, jim, but not raymarched! or raytraced! or rasterised!
  //it's an orthographic sphere!!
  
  out_color = vec4(vec3(tanh(acc)),1.0);
}
