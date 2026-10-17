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

float sdBox( in vec2 p, in vec2 b)
{
  vec2 q = abs(p) - b;
  return min(max(q.x,q.y),0.0) + length(max(q,0.0));
}

float shape(vec2 p, in vec2 id)
{
  float a = 10.* fGlobalTime;
  return sdBox(mat2x2(cos(a),-sin(a),sin(a),cos(a))*p, vec2(0.4,0.4) ) - sin(fGlobalTime*20.)/10.;
}

float map(in vec2 p)
{
  const float s = 1.5;
  const vec2 rep = vec2(2,1);
  
  vec2 id = round(p/s);
  vec2 r = p - s*id;
  return shape( r*2., id );
  
}

mat2 rotated2d(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}

void main()
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 rotatedUV=uv*rotated2d(fGlobalTime/2.);
  
  vec2 rotatedUV2=uv*rotated2d(-fGlobalTime/1.);
  
  vec2 p = 4.25*(sin(fGlobalTime)*20./fGlobalTime*v2Resolution.xy)/v2Resolution.xy;

  float d = map(p/rotatedUV*20);
  
  float d2 = map(p+rotatedUV2*1.5);
  
  float pattern = ceil(sin(fGlobalTime+uv.x*uv.y*10));
  
  vec3 col = (d*d2>.0) ? vec3(0,0,0) : vec3(.5+.5*cos(fGlobalTime+uv.xyx+vec3(0,3,3)));
  
	out_color =vec4(col,0);
}