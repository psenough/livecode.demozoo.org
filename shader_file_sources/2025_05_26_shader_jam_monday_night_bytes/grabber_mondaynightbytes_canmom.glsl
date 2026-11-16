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
#define MAX_ITER 100
#define THRESHOLD 0.01
#define t fGlobalTime
#define OCTREE_DEPTH 4

//sdf
float sphere(in vec3 p, in float r)
{
  return length(p) - r;
}

float cube(in vec3 p)
{
  vec3 q = abs(p) - 0.9;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float trig(vec2 p)
{
  return fract(43757.5453*sin(dot(p, vec2(12.9898,78.233))));
}


// http://www.jcgt.org/published/0009/03/02/
vec3 pcg3d(uvec3 v) {

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

vec3 iqhash( vec3 p ) // inigo quilez to the rescue
{
  p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
  dot(p,vec3(269.5,183.3,246.1)),
  dot(p,vec3(113.5,271.9,124.6)));

  return -1.0 + 2.0*fract(sin(p)*43758.5453123);
} 

float rand2d(vec2 p)
{
  //this hash works
  //let's see if we can get pcg3d to work instead
  //return trig(p);
  //p*=0xffffffffu;
  vec3 p3 = vec3(p, uint(p.x) ^ uint(p.y));
  return iqhash(p3).x;
}

float rand3d(vec3 p )
{
  return iqhash(p).x;
}


vec4 octree( in vec3 p)
{
  vec3 id, idSum = vec3(0.);
  float rnd = 0.;
  float i;

  for (i = 0; i < OCTREE_DEPTH; i+= 1)
  {
    p *= 2.;
    id = floor(p);
    idSum += id;
    rnd = rand3d(p);
    p = fract(p)-.5;
    if (rnd < .5) break;
  }
  
  return vec4(p.x,p.y,p.z,i);
}

float f(in vec3 p, in float level)
{
  vec4 po = octree(p);
  level = po.w;
  float sphereRadius = 0.05+0.5*fft(level/OCTREE_DEPTH).x;
  //float sphereRadius = 0.1;
  return sphere(po.xyz,sphereRadius);
}

vec3 calcNormal( in vec3 p, in float l ) // for function f(p)
{
    const float eps = 0.0001; // or some other value
    const vec2 h = vec2(eps,0);
    return normalize( vec3(f(p+h.xyy,l) - f(p-h.xyy,l),
                           f(p+h.yxy,l) - f(p-h.yxy,l),
                           f(p+h.yyx,l) - f(p-h.yyx,l) ) );
}

struct RaymarchOutput
{
  vec3 position;
  vec3 normal;
  bool isHit;
};

vec3 noise3d(vec3 p)
{
  float noiseA = texture(texNoise,p.xy).r;
  float noiseB = texture(texNoise,p.yz).r;
  float noiseC = texture(texNoise,p.xz).r;
  
  return vec3(noiseB, noiseC, noiseA);
}

RaymarchOutput raymarch(vec3 ray_origin, vec3 ray_direction, float octree_depth)
{
  vec3 p = ray_origin;
  float increment, total = 1.;
  for(int x = 0; x < MAX_ITER; x+=1)
  {
    increment = f(p, octree_depth);
    increment = min(increment, 0.1/OCTREE_DEPTH);
    total += increment;
    p += (ray_direction) * increment;
    //float spacing = 10;
    //p.x = mod(p.x+spacing/2,spacing)-spacing/2;
    if (increment <= THRESHOLD)
    {
      vec3 normal = calcNormal(p, octree_depth);
      return RaymarchOutput(p, normal, true);
    }
    if (total > 5.0) break;
  }
  return RaymarchOutput(vec3(0),vec3(0),false);
}

vec3 hue_shift(vec3 color, float dhue) {
  float s = sin(dhue);
  float c = cos(dhue);
  return (color * c) + (color * s) * mat3(
    vec3(0.167444, 0.329213, -0.496657),
    vec3(-0.327948, 0.035669, 0.292279),
    vec3(1.250268, -1.047561, -0.202707)
  ) + dot(vec3(0.299, 0.587, 0.114), color) * (1.0 - c);
}

void main(void)
{
  vec2 UV = gl_FragCoord.xy/v2Resolution;
  UV -=vec2(0.5);
  UV/=vec2(v2Resolution.y / v2Resolution.x, 1);
  float fftx = fft(UV.x).x;
  
  
  
  vec3 cameraTarget=vec3(0,0,0);                                //Camera target
  float fftTime = 0.01*texture(texFFTIntegrated,0).x;
  vec4 oc = octree(vec3(UV,0.00000001*fftTime));
  vec2 quadtree_uv = oc.xy;
  float rnd = oc.z;
  float level = oc.w;
  //camera will trace a lissajous figure in time with the music
  vec3 cameraPosition=30*vec3(cos(fftTime+0.8),0.3*cos(1.5*fftTime+0.3),sin(2*fftTime));
  //vec3 cameraPosition = vec3(1.0,0.2,0.0);
  vec3 cameraForward=normalize(cameraTarget-cameraPosition);        //Camera forward
  vec3 cameraLeft=normalize(cross(cameraForward,vec3(0,1,0)));       //Camera left
  vec3 cameraTop=normalize(cross(cameraLeft,cameraForward));         //Camera top
  mat3 cameraDirection=mat3(cameraLeft,cameraTop,cameraForward);//Camera direction matrix
  
  vec3 rayDir = 3 * cameraForward + UV.x * cameraLeft + UV.y * cameraTop;
  rayDir = normalize(rayDir);
  
  RaymarchOutput ray = raymarch(cameraPosition,rayDir, 0.0);
  
  vec3 light_direction = normalize (vec3(0.2, 0.5,-0.3));
  
  vec3 triplanar = 2*noise3d(ray.position*0.1)+0.5;
  
  vec3 half = normalize(-cameraForward + light_direction);
  float NdotH = max(dot(ray.normal,half),0.0);
  float blinnPhong = pow(NdotH,120.0);
  
  vec3 diffuse = hue_shift(vec3(1.0,0.5,0.0), 0.0);
  
  vec3 ambient = vec3(0.08,0.04,0.1);
  
  vec3 shading = ray.isHit ? diffuse * (vec3(max(dot(ray.normal, light_direction),0))+ambient) + vec3(blinnPhong) : vec3(0.0);
  
  out_color.rgb += tanh(shading);
  //out_color = vec4(mix(vec3(0.1,0.0,0.0), vec3(0.0,0.0,0.1), rnd.x),1.0);
}