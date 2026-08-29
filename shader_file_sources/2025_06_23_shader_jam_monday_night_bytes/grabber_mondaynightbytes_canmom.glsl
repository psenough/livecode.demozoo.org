#version 420 core

//last time we wrote a basic raymarcher
//this time let's do something more interesting

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

#define fft(x) texture(texFFTSmoothed, x+3.5/1024)
#define ffti(x) texture(texFFTIntegrated, x+3.5/1024)
#define MAX_DIST 10.0
#define STEPS 300
#define THRESHOLD 0.00001
#define MAX_LAYER 10.0
#define t fGlobalTime
#define PI 3.14159265358979323846264

struct double_uv
{
  vec2 uv_lower;
  vec2 uv_upper;
  float inter;
};

double_uv get_uvs(vec3 polar)
{
  //polar should be cylindrical r, theta, z
  float r = polar.x;
  float theta = polar.y;
  float z = polar.z;
  float layer_lower = floor(r);
  float layer_upper = layer_lower + 1.0;
  float offset_lower = ffti(layer_lower/MAX_LAYER).r;
  float offset_upper = ffti(layer_upper/MAX_LAYER).r;
  float inter = r - layer_lower;
  vec2 uv_lower = vec2((theta)*layer_lower + offset_lower, z+5.0*theta/PI);
  vec2 uv_upper = vec2((theta)*layer_upper + offset_upper, z+5.0*theta/PI);
  return double_uv(uv_lower, uv_upper, inter);
}

vec4 density(vec3 p)
{
  float r = length(p.xz);
  float theta = atan(p.z, p.x);
  float z = p.y+2.0;
  vec3 polar = vec3(r*sqrt(z*z+3.0), theta, z);
  float radius = sqrt(z*z+3.0);
  //float density = smoothstep(radius,0.0,r);
  double_uv uvs = get_uvs(polar);
  float lower_noise = texture(texNoise,uvs.uv_lower).r;
  float upper_noise = texture(texNoise,uvs.uv_upper).r;
  //float density = lower_noise*smoothstep(radius,0.0,r);
  float density = mix(lower_noise, upper_noise,uvs.inter)*smoothstep(radius,0.0,r);
  return vec4(vec3(max(density, 0.0)*1.0),0.0);
}

vec4 accumulate_ray(vec3 p, vec3 ray_dir)
{
  float ray_step = MAX_DIST/STEPS;
  vec4 val = vec4(0.0);
  for (int i = 0; i < STEPS; ++i)
  {
    p += ray_step * ray_dir;
    val += density(p) * ray_step;
  }
  return val;
}

void main(void)
{
  vec2 UV = gl_FragCoord.xy/v2Resolution;
  UV -=vec2(0.5);
  UV/=vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 cameraPosition = 10.0*vec3(cos(t),0.0,sin(t));
  vec3 cameraTarget = vec3(0.0);
  vec3 cameraForward=normalize(cameraTarget-cameraPosition);        //Camera forward
  vec3 cameraLeft=normalize(cross(cameraForward,vec3(0,1,0)));       //Camera left
  vec3 cameraTop=normalize(cross(cameraLeft,cameraForward));         //Camera top
  mat3 cameraDirection=mat3(cameraLeft,cameraTop,cameraForward);//Camera direction matrix
  
  vec3 rayDir = 3 * cameraForward + UV.x * cameraLeft + UV.y * cameraTop;
  rayDir = normalize(rayDir);
  
  vec4 accumulated = tanh(accumulate_ray(cameraPosition, rayDir));
  out_color = vec4(vec3(accumulated),1.0);
}