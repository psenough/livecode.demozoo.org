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

/*
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
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
  t = clamp( t, 0.0, 1.0 );
  out_color = f + t;
*/

vec3 chess(vec2 uv)
{
  float a=max(sin(uv.x*2.7),sin(uv.y*555));
  float b=max(sin(uv.x*3.8),sin(uv.y*12));
  float c=max(sin(uv.x*5.9),sin(uv.y*3));
  vec3 r;
  r.x=a;
  r.y=b;
  r.z=c;
  return r;
 }

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float f = texture( texFFT, sin(length(uv)/12) ).r * 12;
 uv.x+=f;
  vec3 a;
  vec2 c=vec2(sin(fGlobalTime/2),sin(fGlobalTime/2))*.3;
  float x= atan(uv.x+c.x,uv.y+c.y);
  float y=length(uv)-fGlobalTime/10;
  
  c=vec2(sin(fGlobalTime/2.3),sin(fGlobalTime/2.5))*.3;
  x+= atan(uv.x+c.x,uv.y+c.y);
  y+=length(uv)-fGlobalTime/10;
  
  c=vec2(sin(fGlobalTime/2.9),sin(fGlobalTime/3.5))*.3;
  x+= atan(uv.x+c.x,uv.y+c.y);
  y+=length(uv)-fGlobalTime/10;
  
  
  a=chess(vec2(x,y));
  
  
  vec3 v=vec3(0,0,1);
  vec3  v2=a;
  a*=dot(v,v2);
  a*=1+pow(-reflect(v,a),a);
 // a*=3-3*length(uv);
  out_color = vec4(a,1.0);
}

// LEFT COMPUTER