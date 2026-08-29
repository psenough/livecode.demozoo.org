#version 410 core

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(float a)
{
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float dist(vec3 pos)
{
  float d = 10e+10;
  pos.x += sin(pos.z  + time * 4.0) * 0.5;
  pos.y += sin(pos.z  + time * 4.0 + 2.) * 0.5;
  pos = mod(pos, 8.0) - 4.0;
  float scale = 1.0;
  for (int i = 0; i< 6; ++i) 
  {
    pos -= sin(time + vec3(1, 2, 3)) * .05 + 0.5;
    if (pos.x < pos.y) pos.xy = pos.yx;
    if (pos.y < pos.z) pos.yz = pos.zy;
    if (pos.x < pos.z) pos.xz = pos.zx;
    
    pos = abs(pos);
  }
  d = min(d, (length(pos) - 0.3));
  d = min(d, length(pos.xy) - 0.1);
  d = min(d, length(pos.yz) - 0.05);
  d = min(d, length(pos.xz) - 0.05);
  return d;
}

vec3 calcColor(vec2 uv)
{
  vec3 pos = vec3(0, 0, time * 10.);

  vec3 dir = normalize(vec3(uv, 1.0));
  dir.xy = dir.xy * rot(time * 0.5);
  dir.xz = dir.xz * rot(sin(time * 0.5) * 0.3);
  dir.yz = dir.yz * rot(sin(time * 0.5 + 0.5) * 0.3);
  
  for (int i = 0; i < 128; ++i)
  {
    float d = dist(pos) * 0.9;
    if (d < 0.001) return vec3(1, 1, 1) * float(i) / 128.;
    pos += dir * d;
  }
  return vec3(1, 1, 1);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  out_color = vec4(calcColor(uv) + vec3(sin(uv.x), sin(uv.y * 5.0 + 4. + time), sin(uv.y * 2. + 3. + time)) * 0.3, 1.0
);
}