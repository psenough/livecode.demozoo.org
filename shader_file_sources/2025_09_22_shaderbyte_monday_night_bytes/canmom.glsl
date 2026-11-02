#version 420 core

//hello sceners!! let's have a good jam :3

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

//step 1: get a nice little velocity field
//step 2: move some particles

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const uint N_PARTICLES = 100;

//memory layout:
//particles along V=0, V=1
//V=0, U=0..N is position + age
//V=1, U=0..N is velocity + colour ramp
//rest of the buffer can be used for blitting

vec2 noise(vec2 uv) {
  float offset_r = texture(texFFTIntegrated, 0.1).r;
  float offset_g = texture(texFFTIntegrated, 0.3).r;
  
  float scale_r = 2.0;
  float scale_g = 0.3;
  
  float noise_r = 2.0*texture(texNoise,uv*scale_r+vec2(0.3,0.1)*offset_r).r-0.4;
  float noise_g = 2.0*texture(texNoise,uv*scale_g+vec2(-0.4,0.9)*offset_g).r-0.4;
  return vec2(noise_r, noise_g);
}


vec3 update_particles(ivec2 UV, float dt) {
  
  if (UV.y > 1) {
    vec3 old = vec3(imageLoad(computeTexBack[0], UV).r, imageLoad(computeTexBack[1], UV).r,imageLoad(computeTexBack[2], UV).r);
    old = old * 0.8 * vec3(0.9, 0.8,0.7)/255;
    imageAtomicAdd(computeTex[0], UV, int(old.r*255));
    imageAtomicAdd(computeTex[1], UV, int(old.g*255));
    imageAtomicAdd(computeTex[2], UV, int(old.b*255));
    return old + vec3(imageLoad(computeTexBack[0], UV).r, imageLoad(computeTexBack[1], UV).r, imageLoad(computeTexBack[2], UV).r)/5.0;
  } else if (UV.y == 1) {
    return vec3(0.0);
  } else {
    ivec2 UV2 = UV+ivec2(0,1);
    
    float lifetime = imageLoad(computeTexBack[2], UV).r;
    lifetime = lifetime - 1;
    vec2 position, velocity;
    
    position = vec2(imageLoad(computeTexBack[0], UV).r/255.0,imageLoad(computeTexBack[1], UV).r/255.0);
    velocity = vec2(imageLoad(computeTexBack[0], UV2).r/255.0,imageLoad(computeTexBack[1], UV2).r/255.0);   
    
    if (lifetime <= 0) {
      velocity = vec2(0.0);
      position = vec2(2.0*UV.x/v2Resolution.x, 0.5);
      lifetime = 100.0;
    }

    
    vec2 acceleration = 5.0*noise(position);
    //euler is simple
    velocity += acceleration * dt;
    position += velocity * dt;
    imageStore(computeTex[0], UV, uvec4(position.x * 255));
    imageStore(computeTex[1], UV, uvec4(position.y * 255));
    imageStore(computeTex[2], UV, uvec4(lifetime));
    imageStore(computeTex[0], UV2, uvec4(velocity.x * 255));
    imageStore(computeTex[1], UV2, uvec4(velocity.y * 255));
    
    ivec2 particle_UV = ivec2((position) * v2Resolution.xy);
    
    for (int i=0; i<=5; i++) {
    for (int j=0; j<=5; j++) {
      imageAtomicAdd(computeTex[0], particle_UV+ivec2(i,j), 255);
      imageAtomicAdd(computeTex[1], particle_UV+ivec2(i,j), 255);
      imageAtomicAdd(computeTex[2], particle_UV+ivec2(i,j), 255);
    }}
    
    
    return vec3(position,lifetime);
  }
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float circle = step(dot(uv,uv), texture(texFFT,0.05).r);
  
  vec2 n = noise(uv);
  
  vec3 particle = update_particles(ivec2(gl_FragCoord.xy), fFrameTime);

	//out_color = vec4(mix(vec3(0.1,0.05,0.1),vec3(0.2,0.1,0.1),vec3(circle)),1.0);
  out_color = vec4(particle, 1.0);
}