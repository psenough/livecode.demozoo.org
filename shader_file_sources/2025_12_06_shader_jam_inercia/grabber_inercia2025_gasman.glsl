#version 420 core

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
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	vec4 res = vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
  if (mod(floor(v.x),2) == mod(floor(v.y),2)) {
    res = vec4(1,1,1,0)-res;
  }
  return res;
}

vec4 getTexture(sampler2D sampler, vec2 uv) {
  vec2 size=textureSize(sampler,0);
  float ratio = size.x/size.y;
  return texture(sampler, uv*vec2(1., -1.*ratio)-.5);
}

const float PI = 3.14159265;
const float SSEP = 1.5;
const vec3 SPHERES[5] = {
  vec3(0,1,0), vec3(SSEP*cos(0),3,SSEP*sin(0)), vec3(SSEP*cos(2*PI/3),3,SSEP*sin(2*PI/3)), vec3(SSEP*cos(4*PI/3),3,SSEP*sin(4*PI/3)),
  vec3(0,5,0)
};

vec4 dist(vec3 cam, float t) {
  vec4 result = vec4(999999,1,1,0);
  float floor_d = abs(cam.y);
  if (floor_d < result.x) {
    result = vec4(floor_d,cam.x/4,cam.z/4,1);
  }
  vec3 camx=vec3(mod(cam.x+5,10)-5,cam.y,mod(cam.z+10,20)-10);
  for (int i=0; i<5; i++) {
    vec3 sph=SPHERES[i];
    sph.y = sph.y * (0.5+abs(sin(t*2)));
    float sph_dc = length(camx-sph);
    float sph_d = abs(sph_dc-1);
    if (sph_d < result.x) {
      float ang = atan((camx.y-sph.y)/(camx.x-sph.x));
      result = vec4(sph_d,ang,(camx.z-sph.z)/2,0);
    }
  }
  return result;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float cam_r = fGlobalTime/3;
  float cam_dist = 10 + 4*sin(fGlobalTime);
  vec3 cam = vec3(cam_dist*sin(cam_r),1,-cos(cam_r)*cam_dist);
  vec3 ray = vec3(uv.x, uv.y, 1);
  float x_rot = .2+.3*sin(fGlobalTime);
  ray = vec3(ray.x,ray.y*cos(x_rot)+ray.z*sin(x_rot),ray.z*cos(x_rot)-ray.y*sin(x_rot));
  ray = vec3(ray.x*cos(-cam_r)+ray.z*sin(-cam_r), ray.y, ray.z*cos(-cam_r)-ray.x*sin(-cam_r));
  vec3 cam0=cam;
  
  // pos = cam + t*ray
  //float floor_d = -cam.y/ray.y;
  
  vec4 result = dist(cam, fGlobalTime);
  int steps=0;
  while (result.x>0.001 && steps<100) {
    cam += result.x*ray;
    steps++;
    result=dist(cam, fGlobalTime);
  }
  vec4 t;
  if (result.w == 0) {
    t = getTexture(texInerciaID, result.yz + vec2(fGlobalTime*3,0));
  } else {
    t = plas(result.yz + vec2(fGlobalTime*3,fGlobalTime), fGlobalTime);
  }
  t /= max(1,length(cam-cam0)/8);
	t = clamp( t, 0.0, 1.0 );
	out_color = t;
}