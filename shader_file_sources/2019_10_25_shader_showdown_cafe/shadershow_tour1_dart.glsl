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
  float s = sin(a), c =cos(a);
  return p * mat2(c, -s, s, c);
}

float vmax( vec3 p) {

  return max(p.x, max(p.y, p.z) );
  }

float scene(vec3 p)
{
// p = mod( p , 2) + 1;
  
  float s1 = length(p ) + 4.2;

  
 
 p.xy = rot(p.xy, p.y * 0.3 + fGlobalTime );
  p.zx = rot(p.zx, p.y * 0.3 + fGlobalTime );
  float b1 = vmax( abs(p - 0.2) - vec3(0.7, 0.8, 0.8) );
  

  return mix(s1, b1, fract(fGlobalTime * 0.01 ));
}

vec4 trace(vec3 o, vec3 r)
{
    float t;
  vec3 p;
  for(int i=0; i < 100; ++ i )
  {
    p = o + r * t;
      float d = scene(p);
    if (d < 0.01) {
      p.x = i / 100.;
      return vec4(p, t);
    }
      t += d * 0.2;
    if (t > 100 )
      break;
  }

  p.x = 1.0;
  return vec4(p, t);
}



void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y) * 2. - 1.;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 o = vec3(0,0,-10.);
  vec3 r = normalize( vec3(uv, 2) );
  
  vec4 p = trace(o, r);
  
  float x = p.w * 0.1;
  vec3 c = vec3(0.5) + vec3(0.5)*cos(2. * 3.14 * ( vec3(0.3) * x + vec3(0.0, 0.2, 0.5) ) );
  //c = vec3(p.w);
  
  out_color = vec4(c, 1.);
}