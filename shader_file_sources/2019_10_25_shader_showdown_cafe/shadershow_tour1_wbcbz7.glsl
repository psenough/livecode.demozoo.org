#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


float t = fGlobalTime;

void main(void)
{
  
  vec2 uv_raw = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
   
  uv.x += 1.1*texture(texFFT, 0.00).r *mod(int(uv.y * 23.5), 6);
  uv.y += 1.1*texture(texFFT, 0.00).r *mod(int(uv.x * 23.5), 6);
  
  
  
  // row stuff
  
  vec3 buf = vec3(0.0);
  
  for (int i = 0; i < 9; i++) {
        vec2 ab = abs(uv*(0.9+0.01*i));
    
        float color = 0.0;
        if (mod (t, 2.5) < 1.3) {
          color = mod((ab.x + ab.y + t) * 4.4, 1.0) < 0.5 ? 1.0 : 0.0;
        } else
        if (mod (t, 4.5) < 1.3) {
          color = mod((dot(ab.x, ab.y) + t) * 2.4, 1.0) < 0.5 ? 1.0 : 0.0;
        } else {
          color = mod((dot(ab.x, mod(7.5*ab.y+t, 2) + mod(t, 0.3)) + t) * 8.4, 1.0) < 0.5 ? 1.0 : 0.0;
        }        
        buf += clamp(color * vec3(
        mod(0.4 + 0.6*int((uv.x + t) * 12.3)/18.3, 1.0),
        mod(0.4 + 0.6*int((uv.y + t) * 18.3)/3.3, 1.0),
        mod(0.4 + 0.6*int((uv.y + t) * 18.3)/15.3, 1.0)), 0.0, 1.0);
  }
  
  vec4 o  = vec4(buf / 9, 1.0);
  
  
  // vingette
  out_color = o * (1.0 - (0.7*dot(uv, uv)));
  
  
  
}