#version 420 core

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

float distscale(float angle) {
  int nsides = 6;//int(fGlobalTime/3.14159)%3*2+4;
  float r = cos(2/float(nsides)*asin(sin(float(nsides)/2*angle)));
  return r;
}

void rotate(inout vec2 v, float a) {v = vec2(v.x*cos(a)+v.y*sin(a), v.y*cos(a)-v.x*sin(a));}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  rotate(uv, cos(fGlobalTime) + sin(fGlobalTime/3) + 2*sin(fGlobalTime/4));
  //uv.x += 
  
  //uv.x /= sin(fGlobalTime);
  //uv.y /= sin(fGlobalTime+3.14/2);

  float scale = 12;
  
	vec2 m;
  
  int steps = 0;
  
  for(;; steps++) {
    m.x = atan(uv.x, uv.y);
    m.y = length(uv) * scale;
    m.y *= distscale(m.x);
    if(m.y < 1) break;
    if(steps > 15) break; // CAREFUL DON'T REMOVE
    
    float anglestep = 3.14159/3;
    //float anglestep = sin(fGlobalTime)+2;
    float angle = m.x - mod(m.x, anglestep) - anglestep/(2 + sin(fGlobalTime));
    
    rotate(uv, -angle);
    
    uv.x = 2/scale-uv.x;
    rotate(uv, angle);
    
    scale *= 1.25;
  }
  

	float d = m.y;
  float f = texture( texFFTSmoothed, 1/d ).r * 40;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( vec2(m.x/3.14, 1/m.y) * 3.14, fGlobalTime + float(steps) ) * d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
}

