#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texErr;

#define iTime fGlobalTime

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


mat2 rot(float a) {return mat2( cos(a), -sin(a), sin(a), cos(a) ) ;}

// Hash function from - https://suricrasia.online/blog/shader-functions/
#define FK(k) floatBitsToInt(cos(k))^floatBitsToInt(k)
float hash(vec2 p) {
  int x = FK(p.x); int y = FK(p.y);
  return float((x-y*y)*(x*x+y)-x)/2.14e9;
}

float beat(float a) {
  float bpm = 128.;
  float one_bpm = 60. / bpm;
  return fract(fGlobalTime/(one_bpm*a));
}

// Box function from https://iquilezles.org/articles/distfunctions2d/
float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float cir(vec2 uv, float a) {
  return length(uv) - a;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uuv = uv;
  vec2 uv2 = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec4 prev = texture(texPreviousFrame, uv);
  
  if(true || beat(32)<0.5 ) {
    for(int i = 0; i < 2; i++) {
      uv = fract(uv * 2 * prev.x);
    uv -= 0.5;
    }
    
  }
  

  if(beat(16) < 0.25) {
    uv.x = abs(uv.x);  
  }
  else if(beat(16) < 0.5) {
    
   uv.y = abs(uv.y);  
  }
  else if(beat(16) < 0.75) {
    
   uv.xy *= rot(beat(4));
   uv.y *= uv.y;  
  }
  else if(beat(16) < 1.0) {
    
   uv.xy *= rot(beat(8));
  }
  
  uv.x = abs(uv.x);
  
  uv.x -= 0.75;
  float a = cir(uv, 0.01);
  
  for(int i = 0; i < 10; i++) {
    float t = (0.75 * iTime) * i;
    
    
    uv.x += 0.1;
    
    uv.x -= 0.055 * sin(t);
    uv.y -= 0.055 * cos(t);
    
    if(beat(16) < 0.5) {
      
    if(beat(4) > 0.5 && uuv.x < 0.5) {
      a = 0;
    }
    if(beat(4) < 0.5 && uuv.x > 0.5) {
      a = 0;
    }
  }
   
    a = min(cir(uv, 0.01), a);
  }
    
  
	uv += iTime * 0.2;
  vec3 ca = vec3(0.2, 0.2, 0.451);
  vec3 cb = vec3(0.7, 0.1, 0.3);
  a = step(a, beat(4) * 0.1);
  
  
  
  
  
  
  
  vec3 color = vec3(mix(ca, cb, a ));
  
  
  if(beat(16) < 0.5) {
    if(beat(4) < 0.5) {
      if(uuv.x < 0.5) {
        color = color.xxx;
      }
      else {
        color = color.xzx;
      }
    }
  
  }
  
  color = step(color.xxx, vec3(0.5));  
 
  
  color = mix(texture(texPreviousFrame, uv).xyx, color, 0.5);
  
       
	out_color = vec4(color , 0);
}