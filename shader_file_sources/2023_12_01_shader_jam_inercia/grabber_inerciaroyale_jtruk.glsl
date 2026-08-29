#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= vec2(0.5+sin(fGlobalTime*1.2)*.2,0.5+sin(fGlobalTime*1.5)*.2);
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float f=sin(fGlobalTime);
  float d=length(uv);
  float a=atan(uv.x,uv.y);
  float r=sin(d*20+a-fGlobalTime*3);
  float g=sin(d*12+a+fGlobalTime*7);
  float b=sin(d*15+a-fGlobalTime*8);
  r=(g+b)/d;
  g=(b+r)/(d+sin(fGlobalTime));
  b=(r+g)/f;
  out_color=vec4(r,g,b,0);
}