#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

float tst = 0;

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler2D texNoise;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


//hello twitch, i have no idea what i'm doing :3


void main(void)
{
  float ft=fGlobalTime;
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 0.1);
  float out_t = 1.0 /sin(uv.y/2+sin(uv.y+sin(uv.x*8+sin(uv.x*2+uv.y)+ft/3)+ft)+ft);
  vec4 t = texture(texNoise, vec2(atan(uv.x,uv.y)*8/3.141*4,uv.y-8/((uv.x*uv.x)+(uv.y*uv.y))/16)-ft);
  vec4 t2 = vec4(sin(ft-uv.x+uv.y)+1,sin(ft+1+uv.y/2)+1,1,1);
  
  vec4 t3 = texture(texNoise, vec2(atan(uv.x,uv.y)/3.141,uv.y)*4+ft/32);
  
  out_color = t*t2+(t3/2)+out_t/24;
  
  //i have remembered why i dont usually participate in shader jams now
}