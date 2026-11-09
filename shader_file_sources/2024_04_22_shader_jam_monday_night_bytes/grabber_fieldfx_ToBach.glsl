#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( v.y ) * 20.0 );
	return vec4( sin(c * 0.2), c * 0.15, cos( c * 0.1) * .25, 1.0 );
}
void main(void)
{
  float t = fGlobalTime;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float xv=32+sin(uv.y*(sin(t)*8)+t*3)*8;
  float sv = (sin(uv.x*xv+sin(uv.y*3)+t*2*2)*sin(uv.y*xv))+1;
  float sv2 = (sin(uv.x*xv+sin(uv.y*3)+t*2*2+sin(t*8)/2)*sin(uv.y*xv))+1;

  //i have no clue what i am doing, its not going well sadly :(
  //think that's me for tonight
  
  out_color = vec4(int(sv*sv2),int(sv),int(sv),1);
}