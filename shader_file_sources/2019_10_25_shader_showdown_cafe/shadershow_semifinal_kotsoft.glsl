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
  vec4 dance=texture(texFFT,0.7);
  float f1 = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  float f2 = cos(v.y*20)+sin(v.x*15);
  float f3 = length(v.y-0.7);
  //float f3=0.5;
  float dancc=dance.x*0.44;
  float c=f1+f2+f3*0.003;
 
  return vec4(sin(c * dancc *0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, dance.x*0.9 );
}
void main(void)
{
  float time=fGlobalTime;
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.2*sin(time*0.9)+0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x*2*sin(time*0.6), 1);

  
  vec2 m;
  vec4 dance=texture(texFFT,0.7);
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1 / length(uv*fGlobalTime*60*dance.x) * .3;
  float d = m.y;

  //float f = texture( texFFT, d ).r * 100;
  float f=0.0;
  m.x += fGlobalTime;
  m.y += fGlobalTime * 0.25;

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  t = clamp( t, 0.0, 1.0 );
    
  out_color = f + t;
}