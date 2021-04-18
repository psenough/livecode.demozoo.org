#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

const float pi = acos(-1.);
const vec3 c = vec3(1.,0.,-1.);

void rand(in vec2 x, out float r)
{
   x.x -= 1.e3;
  r = fract(sin(dot(vec2(1333.1232e6*x.x,32211231.212354),x)));
}

float dbox(in vec3 x, in vec3 a)
{
  vec3 b = abs(x)-a;
  return length(max(b,0.));
}

float dline(in vec3 x, in vec3  p1, in vec3 p2)
{
  float t = clamp(dot(x-p1,p2-p1),0.,1.);
  return t;
}

float scene(in vec3 x)
{
  x.z = abs(x.z);
  
  x.y += .3*fGlobalTime;
  const float ms = .2;
  vec2 y = mod(x.xy, ms)-.5*ms;
  
  vec2 pt = vec2(atan(y.y,y.x),acos(y.y/length(vec3(y,x.z)))); 
  
  float s = min(x.z,length(vec3(y,x.z)-.1*c.yyx)-.1);
  //s = min(s, dline(
  return s;
  
}

vec3 normal(in vec3 x)
{
  const float dx = 1.e-4;
  float s = scene(x);
  return normalize(vec3(scene(x+dx*c.xyy), scene(x+dx*c.yxy), scene(x+dx*c.yyx))-s);
}

void main(void)
{
  vec2 uv = (gl_FragCoord.xy-.5*v2Resolution.xy)/v2Resolution.y;
  vec3 o = c.yzx,
    t = .9*c.yyx,
    r = c.xyy,
    u = cross(normalize(t-o),-r),
    dir = normalize(t-o),
    col,
    l = c.xzx,
    n,
    x;
  t += uv.x*r + uv.y*u;
  dir = normalize(t-o);
  
  float d = 0.,
    s;
  int i=0,
    N = 250;
  
  for(i=0; i<N; ++i)
  {
    x = o + d * dir;
    s = scene(x);
    if(s<1.e-4) break;
    d += s;
  }
  
  if(i<N)  
  {
    n = normal(x);
    
    if(x.z < 1.e-1)
    {
      col = .2*c.yyx
      + .3*c.yxy*dot(normalize(l-x), n)
      + .5*c.yyx*pow(dot(reflect(-normalize(l-x),n),dir),2.);
    }
    else
    {
      const float ms = .2;
      vec2 y = mod(x.xy, ms)-.5*ms,
        yi = x.xy-y;
      /*
      rand(yi, col.x);
      rand(yi+1337., col.y);
      rand(yi+2337., col.z);
      */
      col = c.xyy
      + .3*c.yxy*dot(normalize(l-x), n)
      + .5*c.yyx*pow(dot(reflect(-normalize(l-x),n),dir),2.);
      col *= 2.;
    }
  }
  
  col = mix(col, mix(c.xxx, vec3(1.,.6,.2),.4), smoothstep(-5., 20., x.y));
    
  out_color = vec4(clamp(col, 0., 1.), 1.);
}