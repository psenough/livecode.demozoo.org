#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// Hello!!

float bpm = 60.0/124.0;
#define iTime fGlobalTime
#define beat(a) fract(iTime/(bpm*a))
mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}


float map(vec3 p) {
  
  if(beat(8) < 0.2) {
    p.yz *= rot(3.145*0.5);
  }
  else  if(beat(8) < 0.4) { 
    p.yz *= rot(3.145*0.1);
  }
  else  if(beat(8) < 0.6) { 
    p.yz *= rot(3.145*0.8);
  }
  else  if(beat(8) < 0.8) { 
    p.yz *= rot(beat(2));
  }
  else  if(beat(8) < 1.0) { 
    p.xz *= rot(3.145*0.8);
  }
  
  p.xz *= rot(0.1*iTime);
  
  float a = 1e3;
  int steps = beat(16) < 0.5 ? 32 : 64;
  for(int i = 0; i < steps; i++) {
    p.xz *= rot(iTime*0.1);
    float t = length(p - vec3(i)*0.2) - beat(4);
    a = min(a, t);
  }
  
  return a;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 tuv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0,0, -20);
  vec3 rd = normalize(vec3(uv, 1));

  
  
  float a = 0.01;
  float hit = 0;
  for(int i = 0; i < 32; i++) {
    vec3 p = ro + rd * a;
    float t = map(p);
    a += t;
    if (t > 100) {
      hit = 0;
      break;
    }
    if(t<0.001) {
      hit = 1.0;
      break;
    }
  }
  
  
  //Sphere yes!
  
  
  vec3 color = vec3(tuv.x < 0.5 ? 0.0 : 1.0);
  
  if(tuv.x < 0.5) {
    color += hit;
  }
  else {
    color -= hit;
  }
  
  color *= a;
    
  vec3 tex = texture(texPreviousFrame, tuv).xyz;

  color = mix(color, tex, 0.8) * vec3(0.9, 0.2, 0.1);
	out_color = vec4(color, 1) ;
}