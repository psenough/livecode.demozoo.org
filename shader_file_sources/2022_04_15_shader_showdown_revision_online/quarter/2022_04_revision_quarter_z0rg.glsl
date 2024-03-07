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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define sat(a) clamp(a, 0., 1.)

vec2 _min(vec2 a, vec2 b)
{
  if (a.x < b.x)
    return a;
  return b;
}

vec2 map(vec3 p)
{
  vec2 acc = vec2(10000.,-1.);
  acc = _min(acc, vec2(length(p)-1.,0.));
  return acc;
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}

vec3 getCam(vec3 rd, vec2 uv)
{
  float fov = 1.;
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+fov*(r+uv.x+u*uv.y));
}

vec3 trace(vec3 ro, vec3 rd, int steps)
{
  vec3 p = ro;
  for (int i = 0; i < steps; ++i)
  {
    vec2 res = map(p);
    if (res.x < 0.01)
      return vec3(res.x, distance(p, ro), res.y);
    p+=rd*res.x;
  }
  return vec3(-1.);
}

float _sqr(vec2 uv, vec2 s)
{
  vec2 l = abs(uv)-s;
  return max(l.x, l.y);
}
mat2 r2d(float a)
{
  float c = cos(a);
  float s = sin(a);
  return mat2(c, -s, c, c);
}

float hash11(float seed)
{
  return fract(sin(seed*123.456)*12.456);
}
float _seed;
float rand()
{
  return hash11(_seed++);
}
vec3 rdr(vec2 uv)
{
  vec2 ouv = uv;
  vec3 col = vec3(0.);
  
  vec3 ro = vec3(0.,0.,-5.);
  vec3 ta = vec3(0.,0.,0.);
  vec3 rd = normalize(ta-ro);
  
  rd = getCam(rd, uv);
  vec3 res = trace(ro, rd, 256);
  
  if (res.y > 0.)
  {
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(p, res.x);
    col = n*.5+.5;
  }
  
  vec2 rep = vec2(.1);
  vec2 id = floor((uv+rep*.5)/rep);
    uv += (rand()-.5)*.05*sin(length(id+fGlobalTime));

  uv = mod(uv+rep*.5,rep);
  
  uv *= r2d(sin(id.x+id.y+fGlobalTime));
  uv *= r2d(fGlobalTime+uv.x);
  float shape = abs(_sqr(uv, vec2(.1)))-.01;
  //col = vec3(sin(length(ouv.x*10.5)*fGlobalTime)*.5+.5, .5,.7)*(1.-sat(shape*400.));
  return col;
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy-.5*v2Resolution.xy)/v2Resolution.xx;
  _seed = fGlobalTime+texture(texNoise, uv).x; 

  vec3 col = rdr(uv);
  //col = vec3(1.)*sat((length(uv)-.5)*400.);
  col = pow(col, vec3(5.)*sat(length(uv)));
	out_color = vec4(col, 1.);
}