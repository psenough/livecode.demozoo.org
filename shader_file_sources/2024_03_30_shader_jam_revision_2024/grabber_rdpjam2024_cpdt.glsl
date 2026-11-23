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

float noise2d(vec2 co){
  return fract(sin(dot(co.xy ,vec2(1.0,73))) * 43758.5453);
}

float tile(vec2 p, float s) {  
  for (int i = 0; i < 5; i++) {
    
    // boundary condition
    if (noise2d(vec2(s)) < float(i) / 4) return 1.;
    
    // quadrant?
    s += 1.;
    float q = noise2d(vec2(s));
    p *= 2.;
    if (q < 0.25) {
    } else if (q < 0.5) {
      p.x -= 1.;
    } else if (q < 0.75) {
      p.y -= 1.;
    } else {
      p.x -= 1.;
      p.y -= 1.;
    }
    
    if (p.x < 0. || p.y < 0. || p.x > 1. || p.y > 1.) return 0.;
    
    s += 1.;
  }
  
  return 0.;
}

float tile1(vec2 p, float s, float aspect, float size) {
    float v = tile(p, s);
    
  float vx0 = tile(p - vec2(size, size * aspect), fFrameTime);
  float vx1 = tile(p + vec2(size, size * aspect), fFrameTime);

  return v - sign(vx0 * vx1);
}

float BPM = 120.;

float find(vec2 p) {
  
  
  float destX = noise2d(vec2(floor(fGlobalTime * BPM) + 100.));
  float destY = noise2d(vec2(floor(fGlobalTime * BPM) + 200.));
  
  vec2 minX = vec2(floor(destX * 10.) / 10., floor(destY * 10.) / 10.);
  vec2 maxX = minX + vec2(1. / 10.);
  
  if (p.x > minX.x && p.x < maxX.x && p.y > minX.y && p.y < maxX.y) return 1.;
  return 0.;
}

void main(void)
{
	vec3 c = vec3(0.);
  
  float aspect = v2Resolution.x / v2Resolution.y;
  vec2 uv = gl_FragCoord.xy / v2Resolution;
  
  uv.y += fGlobalTime * 1.;
  uv.y = mod(uv.y, 1.);
  
  float v = 0.;
  for (int i =0; i < 10; i++) {
    v += tile1(uv / float(i), fFrameTime, aspect, float(i) * 0.01);
  }
  
  float m = find( gl_FragCoord.xy / v2Resolution);
  v = v != m ? 1. : 0.;
  
  
	out_color = vec4(v, v, v, 1);
}