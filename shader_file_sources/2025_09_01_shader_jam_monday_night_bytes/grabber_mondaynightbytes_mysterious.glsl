#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCatnip;
uniform sampler2D texChecker;
uniform sampler2D texChvch;
uniform sampler2D texNoise;
uniform sampler2D texPerci;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define time fGlobalTime
#define rotation(p,a) p=cos(a)*p+sin(a)*vec2(-p.y, p.x)

float box(vec3 p, vec3 s, float r) {
  p = abs(p) - s + r;
  return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.) - r;
}

float df(vec3 p) {
  float dp = dot(p, p);
  float scale = sin(time / 4.) * 30. + 50.;
  //scale = 20.;
  p = p / dp * scale;
  //p.z += 5.;
  p = fract(p) * 2 - 1.;
  float d = box(p, vec3(2, .1, .1), .1);
  d = min(d, box(p, vec3(.1, 2, .1), .1));
  d = min(d, box(p, vec3(.1, .1, 2), .1));
  
  const float s = 20.;
  //d += (sin(p.x * s) * sin(p.y * s) + sin(p.z * s)) / 8.;
  return d * dp / scale;
}

vec3 norm(vec3 p) {
  vec2 e = vec2(1e-3, 0.);
  return normalize(vec3(
    df(p + e.xyy) - df(p - e.xyy),
    df(p + e.yxy) - df(p - e.yxy),
    df(p + e.yyx) - df(p - e.yyx)
  ));
}

vec3 rm(vec3 p, vec3 dir) {
  vec3 light = vec3(0.);
  const float e = 1e-2;
  
  for (int i=0; i<100; i++) {
    float d = df(p);
    light += (sin(p + time + cos(p.yzx * 1.37 - time)) * .5 + .5) * pow((.1 / max(0.001, d*2.)), .2);
    p += dir * .1;
  }
  float pwr = .3;
  //light = pow(1./(light+1.), vec3(pwr));
  //light = (light/20.+1.);
  light = pow(light*.08, vec3(2.5)) * .02;
  return vec3(light);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.xy * 2. - v2Resolution.xy) / v2Resolution.y;
	
  float r1 = texture(texFFTIntegrated, 0.05).x / 3.;
  float r2 = texture(texFFTIntegrated, 0.06).x / 3.;
  float r3 = texture(texFFTIntegrated, 0.04).x;
  
  vec3 pos = vec3(sin(r2 * 2.) * .5,sin(r1 * 2.) * .5, 5.5 + sin(r3) * 0.);
  vec3 dir = normalize(vec3(uv, 1.));
 
  rotation(pos.xz, r1);
  rotation(dir.xz, r1);
  rotation(pos.xy, r2);
  rotation(dir.xy, r2);
   
  vec3 p = rm(pos, dir);
  
  out_color = vec4(p * (1. + texture(texFFTSmoothed, 0.05).x * 4.), 1.);
}


// Greetz to ffx crew!




































