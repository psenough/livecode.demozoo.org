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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define FFT(a) (texture( texFFT, a).r * 100)

float _cube(vec3 p, vec3 s)
{
  vec3 l = abs(p)-s;
  return max(l.x, max(l.y, l.z));
}

#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))

float lenny(vec2 v)
{
  return abs(v.x)+abs(v.y);
}

float map(vec3 p)
{
  float vx =.5;
  p = floor(p/vx)*vx;
  p.z += fGlobalTime*50.+FFT(.1)*2.;
  p.x = abs(p.x);
  vec2 repz = vec2(5.);
  p.xy *= rot(p.z*.05+.2*fGlobalTime*sin(fGlobalTime*.001));
  p += vec3(5.*sin(fGlobalTime+p.z*.01), sin(p.z*.01-fGlobalTime)*10., 0.);
  p.zy = mod(p.zy+repz*.5,repz)-repz*.5;
  float shape = length(p)-1.;
  p.xy *= rot(fGlobalTime);
  p.yz *= rot(fGlobalTime*.8);
  shape = mix(shape, _cube(p, vec3(.5)), -1.);
  
  return shape;
}
#define sat(a) clamp(a, 0., 1.)

vec3 getCol(vec3 p)
{
  vec3 cola = vec3(1., 0., 0.);
  cola.xz *= rot(fGlobalTime);
  return mix(cola, vec3(.2,.32, .6)*.3, (1.-sat((length(p.xy)-20.1)*10.))+sin(p.z));
}

vec3 rdr(vec2 uv)
{
  uv *= asin(sin(fGlobalTime*.05));
  uv *= rot(fGlobalTime*sign(sin(fGlobalTime*.5)));
  uv = abs(uv);
  vec3 col = vec3(0.);
   vec3 ro = vec3(15.*sin(fGlobalTime), 0., -5.);
  vec3 rd = normalize(vec3(uv, 1.));
  
  vec3 p = ro;
  vec3 accCol = vec3(0.);
  for (float i = 0.; i < 128; ++i)
  {
    float d = map(p);
    if (d < 0.01)
    {
      //col += vec3(.5);
      break;
    }
    col += getCol(p)*(1.-sat(d/5.5))*.2;
    p+=d*rd;
  }
  col += accCol;

  return col;
}

vec3 rdr2(vec2 uv)
{
  vec3 col = vec3(0.);
  vec2 off = vec2(0.01, 0.);
  col.x = rdr(uv+off).x;
  col.y = rdr(uv).y;
  col.z = rdr(uv-off).z;
  return col;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col = vec3(0.);
  uv *= .2+length(uv)*5.;
  float px = .01;
  uv = floor(uv/px)*px;
  col = rdr2(uv);
  col = sat(col);
  col += vec3(.2,.4,.6)*pow(1.-sat(lenny(uv)-.4), 5.)*FFT(.1);
	out_color = vec4(col, 1.);
}