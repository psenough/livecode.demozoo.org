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

/*
vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
*/
void main(void)
{
  float f1=length(sin(0.01*gl_FragCoord.x+sin(fGlobalTime*2))+cos(0.01*gl_FragCoord.y+cos(fGlobalTime*3)));
  float f2=0.1*sin(0.05*gl_FragCoord.x+texture(texFFT,0.7).x*4);//+cos(0.01*gl_FragCoord.y);
  //float f3=sqrt(sin(gl_FragCoord.x*gl_FragCoord.x*0.005*(fGlobalTime*0.001)+gl_FragCoord.y*gl_FragCoord.y*0.005*(fGlobalTime*0.001)));
  vec4 dance=texture(texFFT,0.7);
  float f3=sqrt(sin(gl_FragCoord.x*gl_FragCoord.x*0.005*(fGlobalTime*0.0005+(dance.x*0.7))+gl_FragCoord.y*gl_FragCoord.y*0.005*(fGlobalTime*0.0005+(dance.x*0.7))+sin(fGlobalTime*0.5)));
  //float f3=sq
  
  float f=f1+f3*0.3+f2;
  float dancc=dance.x*0.3;
  vec4 t=vec4(sin(f*0.5+fGlobalTime+dancc),cos(0.5*f+0.5*fGlobalTime+dancc),sin(0.22*f+fGlobalTime*0.5+dancc)+cos(0.5*f+fGlobalTime*0.4+dancc),1.0);
  out_color=t;
  
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
}