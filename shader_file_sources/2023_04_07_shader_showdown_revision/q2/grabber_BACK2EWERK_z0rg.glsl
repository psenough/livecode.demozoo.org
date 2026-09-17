#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define FFT(a) (texture(texFFT, a).x*100.)
#define sat(a) clamp(a, 0., 1.)

vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+(uv.x*r+uv.y*u)*1.5);
}

vec2 _min(vec2 a, vec2 b)
{
  if (a.x < b.x)
    return a;
  return b;
}

float sqr(vec2 v, vec2 s)
{
  vec2 l = abs(v)-s;
  return max(l.x, l.y);
}
mat2 r2d(float a) { float c = cos(a), s  = sin(a); return mat2(c, -s, s, c); }
vec2 map(vec3 p)
{
  vec2 acc = vec2(10000., -1.);
  p.z += texture(texFFTIntegrated, 0.1).x*10.;
  float room = -sqr(p.xy, vec2(3.,1.));
  
  acc = _min(acc, vec2(room, 0.));
  //acc = _min(acc, vec2(length(p)-1., 0.));

  vec2 repCol = vec2(3.);
  vec3 pcol = p;
  float pix = .1+.05*sin(fGlobalTime);
  pcol = floor(pcol/pix)*pix;
  vec2 id = floor((pcol.xz+repCol*.5)/repCol);
  pcol.xz = mod(pcol.xz+repCol*.5,repCol)-repCol*.5;
  pcol.xy *= r2d(id.x+id.y);
  float col = sqr(pcol.xz, vec2(.1));
  acc = _min(acc, vec2(col, abs(id.x+id.y+floor(fGlobalTime))+1.));
  
  
  return acc;
}

vec3 trace(vec3 ro, vec3 rd, int steps)
{
  vec3 p = ro;
  for (int i = 0;i < steps; ++i)
  {
    vec2 res = map(p);
    if (res.x < 0.01)
      return vec3(res.x, distance(p, ro), res.y);
    p+=rd*res.x;
  }
  return vec3(-1.);
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01, 0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}

vec3 getMat(vec3 p, vec3 n, vec3 rd, vec3 res)
{
  vec3 col = vec3(0.);
    vec3 ldir = normalize(vec3(1.));
    col = vec3(1.)*sat(dot(ldir,n))*.2;;
  if (res.z > 1.)
  {
        col = mix(vec3(1.), vec3(1.,0.,0.), mod(res.z, 2.));

  }
  if (res.z == 0.)
    col = vec3(1.)*sat(FFT(abs(p.x)+abs(p.z)))*vec3(.1,.2,.8)*.5;
  return col;
}

float _seed;
float hash(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}

float rand()
{
  return hash(_seed++);
}

vec3 rdr(vec2 uv)
{
  uv *= r2d(fGlobalTime*.3);
  vec3 col = vec3(0.);
  
  col = vec3(1.)*sat(FFT(abs(uv.x)+abs(uv.y)))*.5;
  vec3 ro = vec3(1., 0., -5.);
  vec3 ta = vec3(0.,0.,0.);
  vec3 rd = normalize(ta-ro);
  
  rd = getCam(rd, uv);
  vec3 res = trace(ro, rd, 128);
  if (res.y > 0.)
  {
    vec3 p = rd+res.y*rd;
    vec3 n = normalize(cross(dFdx(p), dFdy(p)));
    col += (n*.5+.5)*.5;
    vec3 ldir = normalize(vec3(1.));
    col = getMat(p, n, rd, res);
    vec3 refl = normalize(reflect(rd, n)+(vec3(rand(), rand(), rand())-.5)*.1);
    vec3 resrefl = trace(p+n*0.01, refl, 128);
    if (resrefl.y > 0.)
    {
      vec3 prefl = p+n*0.01+resrefl.y*refl;
      col += getMat(prefl, vec3(1.), refl, resrefl)*.2;
    }
  }
  return col;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  _seed = fGlobalTime+length(uv);
  vec3 col = rdr(uv);
  col = pow(col, vec3(1.7));
  col += rdr(uv+(vec2(rand(), rand())-.5)*.1)*.5;
	out_color = vec4(col, 1.);
}