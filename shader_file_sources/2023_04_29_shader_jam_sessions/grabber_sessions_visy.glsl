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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t = 0.0;


vec2 clog (vec2 z) {
	return vec2(log(length(z)), atan(z.y, z.x));
}

// thx roywig
vec2 drosteUV (vec2 p) 
{
    float speed = 0.5;
    float animate = mod(t*speed,2.07);
    float rate = sin(t*0.9);
    p = clog(p)*mat2(1,.11,rate*0.5,1);
    p = exp(p.x-animate) * vec2( cos(p.y), sin(p.y));
    vec2 c = abs(p);
    vec2 duv = cos(t)*0.1+0.5+p*exp2(ceil(-log2(max(c.y,c.x))-2.));
    return duv;
}


#define C(c) U.x-=1.0; O+= charri(U,64+c)

vec4 charri(vec2 p, int c)
{
  if (p.x<.0 || p.x>1. || p.y<0. || p.y>1.) return vec4(0,0,0,1e5);
  p.y = -p.y;
  p.x = p.x+t;
  p.y = p.y-t;
  return textureGrad(texChecker, p/8. + fract( vec2(c, 8-c/8) / 8.), dFdx(p/8.),dFdy(p/8.));
 
}

vec4 logo(vec2 uv)
{
  return texture(texSessions,vec2(uv.x/1.88,-uv.y+cos(t*0.4+uv.x*2)*0.2))*abs(cos(t*2+cos(uv.x*1.+uv.y*10.)*1)*4);
}

float FFT_POWER=50;

void main(void)
{
  vec4 O = vec4(0.0);
  vec2 uv = gl_FragCoord.xy;
  uv /= v2Resolution.y;
  vec2 uv2 = uv;
  vec4 prev = texture(texPreviousFrame,uv2);
  vec4 text = texture(texFFTIntegrated,0);
  t = fGlobalTime*0.1+prev.x*0.1+text.x;
  uv = drosteUV(uv-vec2(1.0+cos(t*0.1),0.5+prev.x*0.001)+prev.xy*0.1*cos(t*1.1)*(0.2+text.x*0.0001));

  vec2 position = vec2(0.);
  float size = 4.0+cos(t)*0.1;
  for(int y = -4; y < 16; y++) {
    vec2 U = (uv - position)*64.0/size;
    U.x+=1;
    U.y-=15;
    U.y+=y;

    
    for(int x = 0; x < 32; x++) {
        C(((int(t*8)+x^y+int(t*4))*int(t*1)));
    }
  }
  
  O = O.zyxy*0.5;

  O+= O.xyzy*0.0;
  
  O*=logo(uv)+O;
  O+=-logo(uv2)*.5+O;
  
  
  out_color = O+prev.xyzw*0.5;
}