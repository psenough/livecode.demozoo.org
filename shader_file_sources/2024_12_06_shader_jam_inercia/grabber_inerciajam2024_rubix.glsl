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

float gsin(float x) { return sin(x + .1 * floor(x/20.)); }
float gcos(float x) { return sin(x + .1 * floor(x*10.)); }
mat2 r2d(float a) { float c=gcos(a),s=gsin(a); return mat2(c,s,-s,c); }
void main(void)
{
	float t = fGlobalTime;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv *= (1.25+0.25*sin(t*9.8)*sin(t*9.8)*sin(t*9.8))/1.;
  float a = atan(uv.x / uv.y) / 3.14;
  
  uv *= r2d(length(uv - vec2(sin(t),cos(t)) ));
  uv *= r2d(length(uv + vec2(sin(t),cos(t)) )+t*.2);
  uv *= r2d(length(uv + .5*vec2(cos(t),sin(t)) )+t*.9);
  
  float oo = cos(uv.x * 9.) + sin(uv.y * (11.+8*cos(t*.4))) - length(uv);
  float o = .4 + abs(
    (35.*uv.x * sin(uv.y * 55.)+
    25.*uv.y * sin(uv.x * 145.)) * sin(t) +
    sin(t)*sin(t)*sin(t)
  );
  vec3 col = vec3(
    .5+.5*sin(1.+t+oo),
    .5+.5*sin(2.+t+oo+.2*sin(t*9.)+.1*t),
    .5+.5*sin(4+t+oo)
  );
  col /= abs(o);
  float e = 1.5+.5*clamp(2*sin(t*1.6), -1, 1);
  col.x = pow(col.x, e);
  col.y = pow(col.y, e);
  col.z = pow(col.z, e);
	out_color = sqrt(clamp(vec4(col,1), 0, 1));
}
