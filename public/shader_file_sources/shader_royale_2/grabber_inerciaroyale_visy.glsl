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

void main(void)
{
  float t = (fGlobalTime*1000.)*0.1;
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1)*(2.5+cos(t*uv.x)*0.001);

  float e = 0.0;
  
  float m = t*4.;
  
  float vv = 0.5*cos(t*0.1*uv.y*0.02);
  vec4 c = vec4(-2.0);
  
  int ii = 0;
  for(float i=0.0;i<10.0;i+=0.5+vv) {
    e += distance(uv,vec2(0.0,0.0))*fract(i*(0.1*m)*cos(uv.x*uv.y)*0.5);
    c += vec4(e+fract(i*t*2.1+uv.y*10.),e-distance(uv.y,uv.y*cos(fract(uv.y*t)))*1.1,e*0.7,1.0)*4.0;
    ii++;
  }
  
  c/=ii;
  
  c/=distance(uv,vec2(c.r,c.g))*abs(cos(c.g)*3.0);
  
  out_color = 0.8-c;
}