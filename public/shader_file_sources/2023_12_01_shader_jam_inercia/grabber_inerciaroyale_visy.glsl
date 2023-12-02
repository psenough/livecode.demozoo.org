#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = 0.0;

float rect(vec2 uv, vec2 scale)
{
  vec2 s = vec2(0.5) - scale * 0.5;
  vec2 shape = vec2(step(scale.x, uv.x), step(scale.y, uv.y));
  shape *= vec2(step(scale.x, 0.5 - uv.x), step(scale.y, 1.0 - uv.y));
  return shape.x * shape.y;
}

void main(void)
{
  time = fGlobalTime;
  vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
  vec4 c = vec4(0.0);
  if (uv.x < 0.5) {
    uv.x = 1.0-uv.x;
  }
  if (uv.y < 0.5) {
    uv.y = 1.0-uv.y;
  }
  vec4 p = texture(texPreviousFrame,uv);
  for(float i = 0.0; i < 5.0; i++) 
  {
   float of = 0.3*cos(time*0.1+i)+0.3*cos(i*0.6+time*0.2);
   float r = rect(uv*(0.8+cos(time*1.1-of*0.01)*0.01),vec2(of+p.r*0.1,-of+p.g*0.4));
   vec3 clogo = texture(texInercia,vec2(1.0+sin(i*0.1+time*0.1)*0.1,cos(time*0.1)*cos(i*0.4*r))+uv*0.8).rgb;
   c += r*3.1-cos(uv.y+time*0.0002*cos(time*0.001)+of)-vec4(vec3(r*clogo.r,r*0.5+clogo.g,r*0.7*clogo.b),1.0)*0.4+cos(uv.y*r+of)*cos(of+time*0.5+of*1)*1.;
  }
  out_color = c;
}