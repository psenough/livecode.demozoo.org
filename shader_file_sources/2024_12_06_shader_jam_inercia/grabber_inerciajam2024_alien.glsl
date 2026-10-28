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
uniform sampler2D texInerciaLogo2024;
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
  float bpm = 140.;
  float one_bpm = 60. / bpm;
  return fract(fGlobalTime/(one_bpm*a));
}

// Box function from https://iquilezles.org/articles/distfunctions2d/
float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void main(void)
{

  vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
  if(beat(8) < 0.5) {
    uv -= 0.5;
    uv += atan(uv.x, 1-uv.y) + iTime*0.5;
  }
    
  vec2 tuv = uv;
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 fuv = uv;
  vec2 uv2 = uv;
  vec2 muv = uv;
  vec2 uv1 = uv;
  uv.x += 0.4*sin(iTime*0.4);
  uv.y += 0.5*cos(iTime*0.3);

  
  vec2 uuv = uv;
  
  
  
  
  if(beat(2) < 0.5) {
    uv *= rot(0.4);
  }
  
  float off = 0;
  if(beat(8) < 0.5) {
    off = hash(uuv)*0.1;
  }
  uv = fract(uv * 3 + off);
  uv.x -= 0.5;
  uv.y -= 0.5;
  vec2 id = floor(uv);
  
  float bump = 0;
  
  if(beat(2) < 0.5) {
    bump = hash(id)*0.4;
  }
  
  
  float a = length(uv) + 0.1 + 0.4*beat(1) + bump;  
  float b = length(uv) + 0.8 + 0.4*beat(1) + bump;  
  
  a = smoothstep(0.99, 0.97, a);
  b = smoothstep(0.9, 0.99, b);
 
  uuv *= 4.0;
  uuv *= rot(0.4 + beat(1));
  if(beat(16) < 0.5) {
    uuv += 0.5;
  }
  float d = sdBox(uuv, vec2(0.1 + beat(4)));
  uuv /=4.0;
  d = smoothstep(0.99, 0.98, d);
  

  
  
  a = min(a, b);
  
  if(beat(8) < 0.5) {
    a = mix(a, min(a,d), 0.7);
  }
  if(beat(2) < 0.5) {
    uv1 *= rot(0.8 + hash(uv1)*0.05); 
  }
  uv1 +=  iTime*0.4;
  a *= fract(uv1 * 5).x;
  
  muv += hash(uv)*0.01;
  
  if(beat(16) < 0.5) {
    if(muv.y < -0.25 + beat(8)) {
      a = 1;
      if(beat(1) < 0.5) {
        a = 1-b;
      }
      else {
        a = b;
      }
      
    }
  }
  
  float z = 0;
  if(beat(16) < 0.5) {
    float z = 0.0;
    vec2 zuv = muv;
    zuv.x += iTime*0.4;
    
    vec2 id = floor(zuv);
    
    
    zuv = fract(zuv * 4);
    zuv -= 0.5;
    zuv *= rot(hash(id) + beat(2));
    z = sdBox(zuv, vec2(0.2 + beat(1)*0.1) + beat(1)*0.1) ;
    a = 0.015  / z;
    a = 1-a;
  }
  
  if(beat(4) < 0.5) {
    tuv = muv;
    tuv -= 0.5;
  }
  
  vec4 color = texture(texInerciaLogo2024, tuv * vec2(1, -1) +hash(uv)*0.005  );
  float az = a+z;
  
  
  
  vec4 f = vec4(color * ( az * 2.1)  );
  
  f = pow(f, vec4(0.42));
  
  if(beat(4) < 0.25) {
    f = f.xyzw;
  }
  else if(beat(4) < 0.5) {
    f = f.yzxw;
  }
  else if(beat(4) < 0.75) {
    f = f.zxyw;
  }
  else {
    f = f.yzxw;
  }
  
  
  
  if(beat(8) < 0.25) {
    if(fuv.x < -0.75) {
    f *= 0;
  }
  }
  else if(beat(4) < 0.5) {
    if(fuv.x < -0.5) {
    f *= 0;
  }
  }
  else if(beat(4) < 0.75) {
    if(fuv.x < 0.) {
    f *= 0;
  }
  }
  else {
    f *= 0;
  }
  
  
  
  
  out_color = f;
  
  
  
}