#version 410 core

//hello!! shaders are very scary
//ah well first try for everything!! :)

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq

float rt=fGlobalTime;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void main(void)
{
  float f=texture(texFFT, 0.05).x *20;
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float cv=sin(uv.x*32+rt*8+cos(uv.y*16+rt*5)*sin(uv.x*2)+sin(rt*4)/4*uv.x);
  
  float cy=sin(uv.x*16+cos(rt))*sin(uv.y*16+sin(uv.x*2+rt*4)+sin(rt)*4)+sin(rt+uv.y);
  
  vec4 t2 = vec4(cy+0.9,cy+1,cv,0);
  
  vec4 t = vec4(cv+1.9,cv,cv/2,0)*2+(sin(rt*8)/4);
	t = clamp( t, 0.0, 1.0 );
	out_color = t / (t2*8);
}