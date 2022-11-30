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

#define FFT(a) (texture(texFFT, a).x)
#define FFTS(a) (texture(texFFTSmoothed, a).x)

#define sat(a) clamp(a, 0., 1.)

float hash11(float p)
{
  return fract(sin(p*123.456)*123.456);
}
float _seed;
float rand()
{
  return hash11(_seed++);
}
mat2 r2d(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
float _cucube(vec3 p, vec3 s, vec3 th)
{
    vec3 l = abs(p)-s;
    float cube = max(max(l.x, l.y), l.z);
    l = abs(l)-th;
    float x = max(l.y, l.z);
    float y = max(l.x, l.z);
    float z = max(l.x, l.y);
    
    return max(min(min(x, y), z), cube);
}

vec3 getCam(vec3 rd, vec2 uv)
{
  float fov = 2.;
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+(r*uv.x+u*uv.y)*fov);
}

vec2 _min(vec2 a, vec2 b)
{
  if (a.x < b.x)
    return a;
  return b;
}

float ztunnel;
vec2 map(vec3 p)
{
  p.xz *= r2d((p.y)*.1);
  vec2 acc = vec2(100000., -1.);
    vec3 pcubes = p;
  //acc = _min(acc, vec2(length(p)-1., 0.));
  p.x += sin(p.z+fGlobalTime*5.)*.5;
  acc = _min(acc, vec2(-p.y, 1.));

  // ceiling
  //acc = _min(acc, vec2(p.y+3., 2.));
  
  float repcut = 10.;
  vec3 pcut = p+vec3(0.,0.,ztunnel);
  pcut = mod(pcut+repcut*.5,repcut)-repcut*.5;
  float cut = abs(pcut.z)-2.;
  
  vec2 repwall = vec2(.5);
  vec2 idwall = floor((p.zy+vec2(ztunnel, 0.)+repwall*.5)/repwall);
  float off = sign(p.x)*texture(texNoise, idwall*.05).x*2.
  -FFT(idwall.x*.1+idwall.y*.05)*5.;
  float walls = abs(p.x)-4.-off;
  acc = _min(acc, vec2(max(max(-walls, cut), (abs(p.x)-4.5)), 3.));
  

  vec3 repcubes = vec3(5.);
  vec3 idcubes = floor((pcubes+repcubes*.5)/repcubes);
  pcubes = mod(pcubes+repcubes*.5,repcubes)-repcubes*.5;
  pcubes.xy *= r2d(idcubes.x+fGlobalTime*sin(idcubes.y));
  pcubes.xz *= r2d(idcubes.y+fGlobalTime*sin(idcubes.z));
  float cubes = _cucube(pcubes, vec3(.3)+8.*FFTS(idcubes.z*.1), vec3(.05));
  cubes = max(cubes, abs(p.z)-10.);
  acc = _min(acc, vec2(cubes, 4.));
  
  return acc;
}
vec3 getMat(vec3 p, vec3 n, vec3 rd, vec3 res)
{
  if (res.z == 2.)
    return vec3(0.);
  if (res.z == 1.)
    return vec3(.1);
  if (res.z == 3. && abs(dot(n, vec3(0.,1.,0.))) < 0.5 && abs(dot(n, vec3(0.,0.,1.))) < 0.5) // walls
  {
    vec2 repwall = vec2(.7);
    float stpwall = 0.05;
    vec2 uvwall = floor((p.zy*vec2(.5,1.)+vec2(ztunnel, 0.))/stpwall)*stpwall;
    vec3 colA = vec3(.1,.3,.7);
    vec3 colB = vec3(.9,.3,.8);
    float thstrip = 0.1;
    uvwall = mod(uvwall+repwall*.5,repwall)-repwall*.5;
    float strips = min(abs(uvwall.x)-thstrip, abs(uvwall.y)-thstrip);
    return pow(texture(texNoise, uvwall).x, 3.)*25.*mix(colA, colB, texture(texChecker, uvwall).x)*sat(strips*100.);
  }
  else
    return vec3(.1,.4,.9);
  return n*.5+.5;
}

vec3 accCol;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  accCol = vec3(0.);
  vec3 p = ro;
  for (int i = 0; i < steps && distance(p, ro) < 80.; ++i)
  {
    vec2 res = map(p);
    if(res.x < 0.01)
      return vec3(res.x, distance(p, ro), res.y);
    accCol += getMat(p, normalize(vec3(1.)), rd, vec3(0.,distance(p, ro), res.y))
    *(1.-sat(res.x/.5))*.1;
    p+=rd*res.x;
  }
  return vec3(-1.);
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}



vec3 getEnv(vec3 rd)
{
  return vec3(.2,.7,.7)*4.*(sin(rd.x*25.+fGlobalTime)*.2+.8)*sat(pow(abs(dot(rd, vec3(0.,0.,1.))), 55.));
}

vec3 rdr(vec2 uv)
{
  vec3 col = vec3(0.);
  uv *= r2d(fGlobalTime*.1);
  vec3 ro = vec3(sin(fGlobalTime*.25)*7.5,-2.,-5.);
  vec3 ta = vec3(0.,-1.5-(sin(fGlobalTime*.3)*.5+.5)*2.,0.);
  vec3 rd = normalize(ta-ro);
  
  rd = getCam(rd, uv);
  
  vec3 res = trace(ro, rd, 256);
  vec3 accLightA = accCol;
  if (res.y > 0.)
  {
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(p, res.x);
    col = getMat(p, n, rd, res);
    float rough = 0.005;
    vec3 refl = normalize(reflect(rd, n)+rough * normalize(vec3(rand(), rand(), rand())-.5));
    
    vec3 rorefl = p+n*0.01;
    vec3 resrefl = trace(rorefl, refl, 256);
    if (resrefl.y > 0.)
    {
      vec3 prefl = rorefl+refl*resrefl.y;
      vec3 nrefl = getNorm(prefl, resrefl.x);
      
      col += getMat(prefl, nrefl, refl, resrefl);
    }
    else if (abs(dot(n, vec3(0.,1.,0.))) > 0.5)
      col += getEnv(rd);
  }
  else
    col += getEnv(rd);
  
  col += accLightA;
  
  col = mix(col.zyx, col, sat(abs(uv.y*2.)));
  
  col *= .5;
  col = mix(col.xxx, col.xxx*vec3(1.,.2,.1), 1.-sat((abs(uv.x)-.25)*100.));
  
  return col;
}
float lenny(vec2 v)
{
  return abs(v.x)+abs(v.y);
}
float _sqr(vec2 uv, vec2 s)
{
  vec2 l = abs(uv)-s;
  return max(l.x, l.y);
}

void main(void)
{
  ztunnel = fGlobalTime*2.;
	vec2 uv = (gl_FragCoord.xy-0.5*v2Resolution.xy)/v2Resolution.xx;
  vec2 ouv = uv;
  uv *= 1.+length(uv);

  _seed = texture(texNoise, uv*100.).x+fGlobalTime;
  
  vec3 col = rdr(uv);
  
  vec2 glowuv = uv+(vec2(rand(), rand())-.5)*.02;
  col += pow(sat(rdr(glowuv)), vec3(1.5))*(1.+FFTS(0.05));
  
  col = sat(col);
  
  vec2 grid = sin(uv*100.)+.999;
  col += vec3(.1)*(1.-sat(min(grid.x, grid.y)*20.));
  
  col += vec3(.4,.5,.7)*pow(1.-sat(lenny(uv*2.-vec2(0.,.15))),2.)*2.;
  col *= (1.-sat(lenny(uv)))*(1.+5.*FFTS(.1));
  col = pow(col, vec3(2.));
  
  float sharp = 400.;
  col = mix(col, (vec3(240, 95, 34)/255.), (1.-sat(_sqr(ouv-vec2(.4,0.), vec2(.2,.07))*sharp)));
  
  float th = 0.007;
  float z = _sqr(ouv-vec2(.25,0.05), vec2(.03,th));
  z = min(z, _sqr(ouv-vec2(.25,-0.05), vec2(.03,th)));
  z = min(z, _sqr((ouv-vec2(.25,0.))*r2d(2.), vec2(.049,th)));
  col = mix(col, vec3(0.), (1.-sat(z*sharp)));

  ouv -= vec2(.07,0.);
  float o = _sqr(ouv-vec2(.25,0.05), vec2(.03,th));
  o = min(o, _sqr(ouv-vec2(.25,-0.05), vec2(.03,th)));
  o = min(o, _sqr(ouv-vec2(.225,-0.0), vec2(.03,th).yx));
    o = min(o, _sqr(ouv-vec2(.275,-0.0), vec2(.03,th).yx));
col = mix(col, vec3(0.), (1.-sat(o*sharp)));

ouv -= vec2(.07,0.);
  float r = _sqr(ouv-vec2(.25,0.05), vec2(.03,th));
  r = min(r, _sqr(ouv-vec2(.25,0.0), vec2(.01,th)));
  r = min(r, _sqr(ouv-vec2(.225,-0.01), vec2(.045,th).yx));
  
    r = min(r, _sqr(ouv-vec2(.275,0.02), vec2(.015,th).yx));
  r = min(r, _sqr((ouv-vec2(.26,-0.035))*r2d(-.7), vec2(.025,th).yx));
col = mix(col, vec3(0.), (1.-sat(r*sharp)));

ouv -= vec2(.07,0.);
  float g = _sqr(ouv-vec2(.25,0.05), vec2(.03,th));
  g = min(g, _sqr(ouv-vec2(.25,0.0), vec2(.01,th)));
  g = min(g, _sqr(ouv-vec2(.25,-0.05), vec2(.03,th)));
  g = min(g, _sqr(ouv-vec2(.225,0.02), vec2(.015,th).yx));
    g = min(g, _sqr(ouv-vec2(.275,-0.0), vec2(.03,th).yx));
col = mix(col, vec3(0.), (1.-sat(g*sharp)));


  col = mix(col, texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy).xyz, .95);
	out_color = vec4(col, 1.);
}