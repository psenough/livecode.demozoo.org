#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//let's go!!

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float fftTime = 3.0*texture(texFFTIntegrated, 0.4).r;
  
  //first we need a camera
  vec3 camera_pos = 1.3*vec3(cos(fftTime),1.5*sin(fftTime), 0.3+0.2*sin(2.0*texture(texFFTIntegrated,0.3)));
  
  vec3 camera_dir = normalize(-camera_pos);
  vec3 camera_y = normalize(cross(camera_dir,vec3(0,0,1)));
  vec3 camera_x = normalize(cross(camera_y,camera_dir));
  
  //idk why it's wrong but whatever lmao
  vec3 ray_dir = normalize(camera_dir + uv.y * camera_x + uv.x * camera_y);
  
  vec3 ray_pos = camera_pos;
  float dist;
  
  bool hit_sphere = false;
  float flower = 0.0;
  
  for (int i = 0; i < 20; i++) {
    dist = length(ray_pos)-0.5;
    if (dist < 0.001) {
      hit_sphere = true;
      break;
    } else {
      ray_pos += dist * ray_dir;
    }
  }
  
  const float PI = radians(180.0);
  
  if (hit_sphere) {
    for(int i = 0; i < 300; i++) {
      float layer = floor(length(ray_pos)*(10.0+texture(texFFT,0.1).r));
      float longitude = atan(ray_pos.y, ray_pos.x)/PI + 0.5;
      float latitude = atan(ray_pos.z,length(ray_pos.xy));
      if (latitude < abs(fract((5.0+layer)*(longitude-0.2*texture(texFFTIntegrated,layer/10.0).r ))-0.5)-layer/2.6+0.6) {
        flower = layer/10.0;
        
        break;
      }
      if (length(ray_pos) > 1.0) {
        break;
      }
      ray_pos += 0.003 * ray_dir;
    }
  }
  if (flower > 0.0) {
    out_color = vec4(vec3(mix(vec3(1.0,0.2,0.6),vec3(0.3,0.4,0.6),1.5*flower-0.3*ray_pos.z)), 1.0);
    
  } else {
    out_color = vec4(vec3(0.02,0.02,0.04),1.0);
  }
  
  vec2 uv2 = gl_FragCoord.xy/v2Resolution;
  
  for(int i = -1; i < 1; i++) {
    out_color += 0.6*texture(texPreviousFrame, uv2-0.005*vec2(i))/9.0;
  }
  
  //out_color = tanh(1.2*out_color);
}