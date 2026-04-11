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


#define PI 3.14159265358979323846264338327950
#define EPS .001

float time, ray = 0, vol = texture(texFFTSmoothed, .005).x;
int idx;

float noise(vec2 p)
{
  return texture(texNoise, p).x;
}

mat2 rot(float a)
{
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float sdf(vec3 p)
{
  float s[4];
  vec3 q = fract(p + .5) - .5;
  float r = 0.65 + noise(q.zy)*.1;
  s[0] = r - length(q);  // walls
  float snd = pow(texture(texFFTSmoothed, length(q.xz)).x, .025) * vol * 10;
  s[1] = p.y + .5 - (noise(q.zx) * (.5+snd) + sin(time))*.2;  // floor
  vec3 qq = mod(p + vec3(noise(q.yz), noise(q.xz)*5+time*10, noise(q.xy))*.1 + .1, .2) - .1;
  s[2] = length(qq) - .001;  // snow
  s[3] = length(q.yx) - .01; // ray
  idx = 0;
  for (int i = 1; i < 4; ++i)
    if (s[i] < s[idx])
      if (i == 3)
        if (s[i] < EPS) ray = 1;
        else return s[i];
      else idx = i;
  return s[idx];
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  time = fGlobalTime;
  time /= 2;
  
  vec3 rp = vec3(sin(time*PI/5)*2.7,-.05,time), rd=normalize(vec3(uv,1));
  rd.xz *= rot(sin(time/2));
  rd.xy *= rot(sin(time*1.7)/4);
  int i;
  while (++i<100) {
    float d = sdf(rp);
    if (d < EPS) break;
    rp += d*rd;
  }
  
  float br = clamp(pow(6/float(i), 1.5), 0, 1);
  float v = sin(time*.7)*vol*5;
  vec3 c[3] = vec3[](vec3(0,ray+(1-ray)*.2,1-ray), vec3(1,v,-v), vec3(.5));
  
  vec3 col = br * c[idx];
	out_color = vec4(col,1);
}

// GOOD LUCK, IVAN! ;))))