#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

//HELP IM TRAPPED IN A SHADER FACTORY

#define off(a) fract(fGlobalTime*a/2)*2.5-1.25
#define offpi(a) fract(fGlobalTime*a)*3.14159
#define pal(a) a
//normalize(pow(a,vec3(1.1))+vec3(1.1))

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float circle(vec2 p, float r)
{
  return length(p) -r;
}

float square(vec2 p, vec2 r)
{
  return length(max(abs(p)-r,0.));
}

vec2 rotate(vec2 p, float a)
{
  return mat2(sin(a),cos(a),-cos(a),sin(a))*p;
}

vec3 scene(vec2 p, float dist)
{
  if (circle(p+vec2(dist*0.1+off(0.1),0.1),0.2) <=0)
    return pal(vec3(1,0.2,0.4));
  if (circle(p+vec2(dist*0.15+off(0.2),-0.1),0.14) <=0)
    return pal(vec3(0.2,1,0.4));
  if (square(rotate(p+vec2(dist*0.2+off(0.3),0.3),offpi(0.3)),vec2(0.17)) <=0.1)
    return pal(vec3(0.4,0.2,1));
  if (square(rotate(p+vec2(dist*0.25+off(0.3),-0.3),offpi(0.4)),vec2(0.17)) <=0.1)
    return pal(vec3(1,0.6,0.2));
  if (circle(p+vec2(dist*0.3+off(0.5),0.5),0.2) <=0)
    return pal(vec3(0.6,1,0.2));
  if (circle(p+vec2(dist*0.35+off(0.6),-0.5),0.2) <=0)
    return pal(vec3(0.2,0.6,1));

  if (circle(p+vec2(dist*0.4+off(0.7),0.2),0.18) <=0)
    return pal(vec3(1,0.8,0.3));
  if (circle(p+vec2(dist*0.45+off(0.8),-0.2),0.21) <=0)
    return pal(vec3(0.2,1,0.8));
  if (square(rotate(p+vec2(dist*0.5+off(0.9),0.3),offpi(0.6)),vec2(0.12)) <=0.1)
    return pal(vec3(0.8,0.2,1));
  if (square(rotate(p+vec2(dist*0.55+off(1.0),-0.3),offpi(0.5)),vec2(0.2)) <=0.1)
    return pal(vec3(1,0.6,0.8));
  if (circle(p+vec2(dist*0.6+off(1.1),0.4),0.11) <=0)
    return pal(vec3(0.6,1,0.8));
  if (circle(p+vec2(dist*0.65+off(1.2),-0.4),0.3) <=0)
    return pal(vec3(0.8,0.6,1));
  
  if (sin(p.x+(p.y*8)+(dist*0.8)+offpi(0.5)*2) <= 0)
    return vec3(0.4);

  if (sin(-p.x+(p.y*8)+(dist*0.9)+offpi(0.9)*2) <= 0)
    return vec3(0.3);
  
  return vec3(0.2);
}

//I DIDNT THINK THIS FAR
//HELP

#define stereo 0.05

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 pxl = 1/v2Resolution;
  //ANTIALIASING
  //nice
  vec3 l = (scene(uv+pxl,stereo) + scene(uv-pxl,stereo) + scene(uv,stereo)) / 3;
  vec3 r = (scene(uv+pxl,-stereo) + scene(uv-pxl,-stereo) + scene(uv,-stereo)) / 3;
  vec3 m = vec3((length(l)*0.3+l*0.2).r,(length(r)*0.3+r*0.2).gb);

	out_color = vec4(m,1);
}