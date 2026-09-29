#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
  float t = fGlobalTime;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv = uv - 0.5;
  vec4 pp = texture(texPreviousFrame,uv)*tan(t*1.+uv.x+cos(uv.y)*10.);
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv.x*=cos(t*0.1)*0.1;

  if (uv.x < 0.0) uv.x = 0.0-uv.x;
  if (uv.y > 0.0) uv.y = 0.0-uv.y;
  vec3 c = vec3(0.0);
  
  for (float z = 0.0; z<20.0; z=z+1.0) 
  {
    vec2 p = 0.1*vec2(uv.x*z,uv.y*z)*(cos(t*2.)*z*cos(t+uv.y)-sqrt(z+t*0.2))*2./cos(pp.g); 
    c += p.x*cos(cos(z+p.x*0.1*cos(t*3.+z))+tan(p.x*0.1+t)*z*0.1+p.x*p.y+t)*sin(t*1.2+z+pp.b)*1.;
    c *= smoothstep(p.x,uv.y,cos(z*0.10+t+pp.r))*100.;
  }
	
  c = c / 20.0;
  c = clamp(c, 0.0, 1.0);
  float cc = fract(c.r*t+c.g+tan(uv.y*10.)+uv.x*100.+10.*cos(t*0.1+sin(uv.y*1.+t)))*c.b;
  cc = cc / pp.r*1.2;
  cc = cc - pp.g*1.4;
  cc = cc / pp.b*1.6;
	out_color = vec4(cc/cos(pp.r))/vec4(1.6/c.r,cos(t*0.1)*1.5/c.g,sin(t*0.1)*4.2/c.b,1.0);
}