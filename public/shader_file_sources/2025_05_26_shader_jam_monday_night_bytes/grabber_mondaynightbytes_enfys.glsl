#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//float dt = 0;

// ello you lot
// haven't attempted shaders since a jam last year
// so i'm not sure quite what i'm doing currently lol
// we'll figure it out innit
// :3


void main(void)
{
  float dt = fGlobalTime;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  // i did a thing and it actually worked????
  // behold! pixels!!!!
  
  uv.x -= mod(uv.x, 1.0/ 64+sin(dt)/16.0);
  uv.y -= mod(uv.y, 1.0/ 64+sin(dt)/16.0);


  float rb = floor(sin(uv.x*7.0+dt*8.0)*sin(uv.x*16.0+dt*7)-uv.y*16.0);
  
  //vec4 t = vec4(0.1,0.1,rb+uv.y,1.0);
  
  float ca = uv.x/2+rb/16+abs(sin(dt*2+uv.x)/2);

  vec4 t = vec4(ca/3,ca/2,ca,1.0);
  
  // okay i think its safe to say i have absolutely no clue what im doing
  
	//vec4 t = vec4(0.1,0.1,rc+uv.y*5.0,1.0);
	out_color = t;
}