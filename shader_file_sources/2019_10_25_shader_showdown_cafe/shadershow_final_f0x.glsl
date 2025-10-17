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

/*  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1 / length(uv) * .2;
  float d = m.y;

  float f = texture( texFFT, d ).r * 100;
  m.x += sin( fGlobalTime ) * 0.1;
  m.y += fGlobalTime * 0.25;

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  t = clamp( t, 0.0, 1.0 );*/

void main(void)
{
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  
  uv+=vec2(sin(fGlobalTime),sin(fGlobalTime*1.3))*.3;
  
  uv*= 1+texture( texFFT, abs(uv.y) ).r * 11.100;
  
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 uv2=uv;
float c =  length(uv)-fGlobalTime*.1;  
float b = atan(uv.x / uv.y) / 3.14+fGlobalTime*.1+c;

 
uv=vec2(b,c);
  
float a=texture( texNoise, uv/4 ).r*2;
float a2=texture( texNoise, uv/8 ).r*2;
  a2+=fGlobalTime*.1;
 a=texture( texNoise, vec2(a,a2) ).r*2;
  a=1./(a+1);
  a=pow(a,13)*13;
  
  a*=1-sin(21*length(uv));
 
  float g=max(sin(uv2.x*22+fGlobalTime*11.1),sin(uv.y*22+uv2.y*22+fGlobalTime*.1));
  
  g*=texture( texNoise, vec2(a,a2) ).r*4;
 
  
  g-=.95;
  g*=333;
  a=max(a,g);
  
  
  vec3 col=vec3(a*3,a*2,a);
  
  out_color = vec4(col,1);
}

// LEFT