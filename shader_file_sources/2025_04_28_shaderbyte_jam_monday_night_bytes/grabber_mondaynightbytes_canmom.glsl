#version 420 core

//hi hi! excited to be jamming with ya~
//I did not read up on raymarching before this so this is sorta figured out from memory

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

#define fft(x) texture(texFFTSmoothed, x)
#define MAX_ITER 10
#define THRESHOLD 0.1
#define t fGlobalTime

//sdf
float f(in vec3 p)
{
  return length(p) - 10*fft(0).r-2;
}

vec3 calcNormal( in vec3 p ) // for function f(p)
{
    const float eps = 0.0001; // or some other value
    const vec2 h = vec2(eps,0);
    return normalize( vec3(f(p+h.xyy) - f(p-h.xyy),
                           f(p+h.yxy) - f(p-h.yxy),
                           f(p+h.yyx) - f(p-h.yyx) ) );
}

struct RaymarchOutput
{
  vec3 position;
  vec3 normal;
  bool isHit;
};

RaymarchOutput raymarch(vec3 ray_origin, vec3 ray_direction)
{
  vec3 p = ray_origin;
  float increment, total = 1.;
  bool found_hit = false;
  for(int x = 0; x < MAX_ITER; x+=1)
  {
    increment = f(ray_origin + ray_direction * total);
    total += increment;
    if (f(p) <= THRESHOLD)
    {
      break;
    }
  }
  if (increment <= THRESHOLD)
  {
    vec3 p = ray_origin + ray_direction * total;
    vec3 normal = calcNormal(p);
    return RaymarchOutput(p, normal, true);
  }
  else {
    return RaymarchOutput(vec3(0),vec3(0),false);
  }
}

void main(void)
{
  vec2 UV = gl_FragCoord.xy/v2Resolution;
  UV -=vec2(0.5);
  UV/=vec2(v2Resolution.y / v2Resolution.x, 1);
  float fftx = fft(UV.x).x;
  
  vec3 cameraTarget=vec3(0,0,0);                                //Camera target
  float fftTime = texture(texFFTIntegrated,0).x;
  vec3 cameraPosition=5*vec3(cos(fftTime),3,sin(fftTime));
  vec3 cameraForward=normalize(cameraTarget-cameraPosition);        //Camera forward
  vec3 cameraLeft=normalize(cross(cameraForward,vec3(0,1,0)));       //Camera left
  vec3 cameraTop=normalize(cross(cameraLeft,cameraForward));         //Camera top
  mat3 cameraDirection=mat3(cameraLeft,cameraTop,cameraForward);//Camera direction matrix
  
  vec3 rayDir = 3 * cameraForward + UV.x * cameraLeft + UV.y * cameraTop;
  rayDir = normalize(rayDir);
  
  RaymarchOutput ray = raymarch(cameraPosition,rayDir);
  
  vec3 light_direction = normalize (vec3(0.2, 0.5,-0.3));
  
  float shading = ray.isHit ? max(dot(ray.normal, light_direction),0) + 0.2 : 0.0;
  
	out_color.rgb += shading * vec3(1.0,0.3,0.4);
}