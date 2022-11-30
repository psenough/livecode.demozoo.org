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

vec2 rot(vec2 p, float a)
{
    float c = cos(a); float s = sin(a);
    return p * mat2(c, -s, s, c);
}

float vmax(vec3 p)
{
  return max(p.x, max(p.y, p.z));
}


float scene(vec3 p)
{
  //p.zx = rot(p.zx, fGlobalTime * 0.1);
  p.xy = rot(p.xy, fGlobalTime);
  float c = 2.;
  p = mod(p + c *0.5, c ) - c *0.5;
  p.zx = rot(p.zx, p.y * 1.8 + fGlobalTime);
  p.xy = rot(p.xy, p.x * 1.8 + fGlobalTime);
    float b1 = vmax( abs(p) - vec3(0.5));
  float f = texture(texFFT, 0.3).r;
  float s1 = length(p) - ((1. * sin(fGlobalTime * 4 ) * 0.05 ) + 0.7);
  return max(b1, -s1);
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y) * 2 - 1;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 o = vec3(0,0, fGlobalTime * 5);
  

  vec3 r = normalize(vec3(uv, 3) );

 r.zx = rot(r.zx, sin (fGlobalTime * 2 ) * 0.4 );
  r.xy = rot(r.xy, sin (fGlobalTime * 4 ) * 0.4 );

  
  float sh;

  float t = 0;
int i;  
  for (i = 0; i < 100; ++ i)
  {
    vec3 p = o + r * t;
    float d = scene(p);
    if (d < 0.01) {
      break;
    }
    
    t += d;
    
  }
    sh = 1 - i / 100.;

  float f = texture(texFFT, uv.y).r;
  
  //vec3 c = vec3(sh,sh, 0);
  
  float fog = 1 / (1 + sh * sh + 0.0);
  
  vec3 c = vec3(0.5) + vec3(0.7) * cos(  2*3.14 * (vec3(0.8 + f) * sh + vec3(0.3,0.5,0.7) ) );
  
  c = mix(c, vec3(0), fog);
  
  out_color = vec4(c, 1);
}