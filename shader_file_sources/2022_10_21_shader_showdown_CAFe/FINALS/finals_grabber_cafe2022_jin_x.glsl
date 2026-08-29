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

#define EPS .0001

int idx = 0;
float time, glow = 1;

float sdf(vec3 p)
{
  float s[3];
  s[0] = p.y + texture(texNoise, p.xz * .05).x * 5;
  s[1] = 10 - p.y + texture(texNoise, p.xz * .01).x * 5;
  s[2] = length(p - vec3(16, 4, time+50));
  idx = 0;
  for (int i = 1; i < 3; ++i)
    if (s[i] < s[idx])
      idx = i;
  if (idx == 2) glow += .02/(.1*s[2]*s[2]);
  return s[idx];
}

mat2 rot(float a)
{
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  time = fGlobalTime;
  
  int i;
  vec3 rp = vec3(sin(time/10)*3.3,sin(time)*.5+1,time), rd = normalize(vec3(uv, 1));
  rd.xz *= rot(sin(time/10)/2);
  rd.xy *= rot(sin(time/7)/5);
  float td = 0;
  while (++i < 1000) {
    float d = sdf(rp)*.1;
    if (d < EPS) break;
    td += d;
    if (td > 100) { idx = 2; break; }
    rp += d*rd;
  }
  
  float br = pow(50/float(i), 1.5);
  
  float l = 5;
  float s1 = texture(texFFTSmoothed, .005).x;
  float s2 = texture(texNoise, vec2(time*.5,0)).x;
//  if (s1 > .25) l = 25;
  if (s2 < 0.1) l = 25;
  float sky = pow(texture(texNoise, rp.xz * .001).x, 5) * 3000 * l;
  vec3 c[3] = vec3[](vec3(1,.4,0)*sqrt(l)/1.5, vec3(.2,.5,1)*sky, vec3(glow));
	vec3 col = br * glow * c[idx];
	out_color = vec4(col,1);
}