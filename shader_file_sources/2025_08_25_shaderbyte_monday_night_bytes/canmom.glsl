#version 420 core

//hello fieldfx crew! hype to jam again post-Evoke~

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

const vec3 SPHERE = vec3(0.0,0.0,5.0);
const vec3 LIGHT = normalize(vec3(0.4,0.2,-1.0));

const float TAU = 2.0*3.141592643589793232846264;

vec4 sdf(vec3 pos) {
  float u = atan(pos.y, pos.x)/TAU+1.0;
  float nearest_sphere_u = (u - mod(u, 0.1)+0.05);
  float nearest_sphere_theta = TAU*nearest_sphere_u;
  float r = length(pos.xy);
  float nearest_sphere_r = r-mod(r,1.0)+0.5;
  float revolution = 0.1*texture(texFFTIntegrated,0.1).r;
  //float revolution = 0.0;
  
  vec3 nearest_sphere = vec3(nearest_sphere_r*cos(nearest_sphere_theta),nearest_sphere_r*sin(nearest_sphere_theta),SPHERE.z);
  
  float sphere_radius = sqrt(texture(texFFT,nearest_sphere_u+0.1*(nearest_sphere_r-0.5)).r)*2.0+0.1;
  
  vec3 disp = pos - nearest_sphere;
  
  return vec4(length(disp) - sphere_radius,nearest_sphere);
}

vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  const int ITER = 20;
  const float THRESHOLD = 0.01;
  
  vec3 pos = vec3(uv.x, uv.y, 0.0);
  
  vec3 dir = pos - vec3(0.0,0.0,-1.0);
  
  float hit = 0.0;
  
  vec4 s = vec4(0.0);
  
  for (int i = 0; i<=ITER; ++i) {
    s = sdf(pos);
    if (s.r < THRESHOLD) {
      hit = 1.0;
      break;
    }
    pos += s.r * dir;
  }
  
  vec3 normal = normalize(pos-s.yzw);
  
  float lambertian = dot(normal, LIGHT);
  
  float u = atan(uv.y, uv.x)/TAU+0.5;
  float nearest_sphere_u = (u - mod(u, 0.1));
  vec3 sphere_col = hsb2rgb(vec3(nearest_sphere_u,1.0,1.0));
  
  out_color = vec4(hit*lambertian*sphere_col,1.0);
}