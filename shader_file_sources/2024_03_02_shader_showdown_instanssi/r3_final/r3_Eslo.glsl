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

float time = fGlobalTime;

float p(vec2 v, float p){
    return length(v)-p;
  }
  
float pp(vec2 v, float r){
    return step(p(v, r), 0.1 +( mod(time, 0.1))) - step(p(v, r- 0.05), 0.1);
  }
  
vec2 rot(vec2 v, float f){
  mat2 m = mat2(cos(f), sin(f), -sin(f), cos(f));
  return m * v;
  }

  
float ren(vec2 v, float time){
  float g = 0;
  g += p(v, 0.1);
  for(float i =0; i<5; i++){
    g += pp( vec2(mod(v.x * 4, 1*i * mod(time,1)) - 0.5, mod(v.y * 4*i, 1*i * mod(time,1)) - 0.5 ), 0.1);
    }
    return g;
  }  
  
  float ren2(vec2 v, float time){
  float g = 0;
  g += p(v, 0.1);
  for(float i =0; i<4; i++){
    g += p( vec2(mod(v.x * 4, 1*i * abs(sin(time))) - 0.5, mod(v.y * 4*i, 1*i * mod(time,1)) - 0.5 ), 0.2);
    }
    return g;
  }  

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

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp(t, 0.0, 1.0 );
  
  //float g = 0; //pp(uv,0.1);
  float g = ren2(uv*2, f+0.5)* 10;
  float r = ren(uv, time)* 0.4;
  float b = ren(rot(uv/5, time)/2, f*2)* 0.6;
  b += ren(uv/2, time/2)* 0.4;
  b += ren(uv/3, time/1.5)* 0.4;
  b += ren(uv/3, time/1.5)* 0.4;
	out_color = vec4(r,g,b,0);
}