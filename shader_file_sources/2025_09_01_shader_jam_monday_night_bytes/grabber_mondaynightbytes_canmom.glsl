#version 420 core

//let's march some rays, march some cubes, march everything

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

//borrow one from inigo
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdf(vec3 p,float r) {
  return sdBox(p, vec3(0.1))-r;
}

//thanks inigo
//i'll memorise this at some point
vec3 calcNormal( in vec3 p , float r) // for function f(p)
{
    const float h = 0.0001; // replace by an appropriate value
    const vec2 k = vec2(1,-1);
    return normalize( k.xyy*sdf( p + k.xyy*h,r ) + 
                      k.yyx*sdf( p + k.yyx*h,r ) + 
                      k.yxy*sdf( p + k.yxy*h,r ) + 
                      k.xxx*sdf( p + k.xxx*h,r ) );
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 UV = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 cam_pos = vec3(-1,-0.25,-1.);
  
  vec3 cam_x = normalize(cross(cam_pos, vec3(0.0,1.0,0.0)));
  vec3 cam_y = normalize(cross(cam_x,cam_pos));
  
  vec3 dir = -normalize(uv.x * cam_x + uv.y * cam_y+cam_pos);
  
  const float THRESHOLD = 0.001;
  
  vec3 hit = vec3(0.0);
  vec3 normal_r = vec3(0.0);
  vec3 normal_g = vec3(0.0);
  vec3 normal_b = vec3(0.0);
  
  float r = 5.0*texture(texFFTSmoothed,0.1).r;
  
  vec3 theta = -texture(texFFTIntegrated, 0.1).rgb + vec3(0.2, 0.1, 0.0) * r;
  
  vec3 c = cos(theta);
  vec3 s = sin(theta);
  
  vec3 p_g = cam_pos;
  vec3 p_b = p_g;
  vec3 p_r = p_g;
  
  for (int i = 0; i < 40; i++) {
    vec3 rotated_p = vec3(c.r*p_r.x+s.r*p_r.y,-s.r*p_r.x+c.r*p_r.y,p_r.z);
    float sd = sdf(rotated_p,r);
    p_r+=sd * dir;
    if (sd < THRESHOLD) {
      hit.r = 1.0;
      normal_r = calcNormal(rotated_p,r);
      normal_r = vec3(normal_r.x * c.r - normal_r.y * s.r, normal_r.x * s.r + normal_r.y*c.r, normal_r.z);
      break;
    }
  }
  
  for (int i = 0; i < 40; i++) {
    vec3 rotated_p = vec3(c.g*p_g.x+s.g*p_g.y,-s.g*p_g.x+c.g*p_g.y,p_g.z);
    float sd = sdf(rotated_p,r);
    p_g+=sd * dir;
    if (sd < THRESHOLD) {
      hit.g = 1.0;
      normal_g = calcNormal(rotated_p,r);
      normal_g = vec3(normal_g.x * c.g - normal_g.y * s.g, normal_g.x * s.g + normal_g.y*c.g, normal_g.z);
      break;
    }
  }
  
  for (int i = 0; i < 40; i++) {
    vec3 rotated_p = vec3(c.b*p_b.x+s.b*p_b.y,-s.b*p_b.x+c.b*p_b.y,p_b.z);
    float sd = sdf(rotated_p,r);
    p_b+=sd * dir;
    if (sd < THRESHOLD) {
      hit.b = 1.0;
      normal_b = vec3(normal_b.x * c.b - normal_b.y * s.b, normal_b.x * s.b + normal_b.y*c.b, normal_b.z);
      normal_b = calcNormal(rotated_p,r);
      break;
    }
  }
  
  float f = sqrt(texture(texFFT,abs(uv.y)).r);
  
  vec3 light = normalize(vec3(-0.6,-0.25,-0.25));
  
  vec3 l = vec3(dot(normal_r, light), dot(normal_g, light), dot(normal_b, light));
  
  float fft_vis = 1.0-step(f,abs(uv.x));
  
  out_color = vec4(mix( vec3(fft_vis*f),l, hit),1.0);
  
}