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

float lenny(vec2 v)
{
  return abs(v.x)+abs(v.y);
}

vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+r*uv.x+u*uv.y);
}

float _cube(vec3 p, vec3 s)
{
  vec3 l= abs(p)-s;
  return max(l.x, max(l.y, l.z));
}
mat2 r2d(float a) {
float c = cos(a);
  float s= sin(a);
  return mat2(c, -s, s, c);
  }
float map(vec3 p)
{
  float pix = .05;
  p = floor(p/pix)*pix;
  vec3 op = p;
  float rep = 2.;
  
  p.xy *= r2d(p.z*.1*sin(fGlobalTime));
  p.z += texture(texFFTIntegrated, 0.).x*3.;
  p.z = mod(p.z+rep*.5,rep)-rep*.5;
  p.xy *= mix(.5,1.,sin(p.z*2.)*.5+.5);
  float shape = _cube(p, vec3(1.,1.,.1));
  shape = max(shape, -_cube(p, vec3(.99,.99,1.)));
  
  float ground = -op.y+5.
  -texture(texNoise, op.xz*.01+vec2(0.,fGlobalTime*.03)).x*10.;
  
  shape = min(shape, ground);
  
  return shape;
}
#define sat(a) clamp(a, 0., 1.)
float hash11(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}
vec3 rdr(vec2 uv)
{
  vec3 col = vec3(0.);
  
  vec3 ro = vec3((hash11(floor(fGlobalTime))-.5)*5.,(hash11(floor(-fGlobalTime))-.5)*3.,-5.);
  vec3 ta = vec3(0.,0.,0.);
  vec3 rd = normalize(ta-ro);
  rd = getCam(rd, uv);
  col = (1.-sat(lenny(uv)))*vec3(1.,0.,0.2);
  vec3 p = ro;
  vec3 accCol = vec3(0.);
  for (int i = 0;i <128;++i)
  {
    float res = map(p);
    if (res < 0.01)
    {
      col = vec3(.1);
    if (p.y >1.)
    {
      vec3 rgb = mix(vec3(1.,0.,0.2), vec3(.8,0.5,.7)*0., sin(p.y*5.+fGlobalTime));
      col = rgb*sat(sin(p.y*50.)-.5)*2.;
    }
    }
    if (p.y <1.)
      accCol += vec3(sin(p.z)*.2+.8, .5,1.)*(1.-sat(res/.5))*.1;
    p+=rd*res;
  }

    
  col += accCol;
    col = pow(col, vec3(2.2));

  return col;
}

vec3 rdr2(vec2 uv)
{
  vec2 off = vec2(0.01,0.)*texture(texFFTSmoothed, 0.2).x*40.;
  vec3 col = vec3(0.);
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

  uv *= 2.-length(uv)*2.;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / mix(lenny(uv), length(uv),-1.) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 20*.1;


  vec3 col = vec3(1.)*f;
  
  col += rdr2(uv);
	out_color = vec4(col,1.);
}