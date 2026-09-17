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

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize(target - cam);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize(cross(forward, right));
  
  return normalize( uv.x * right + uv.y * up + fov*forward);
}

vec3 repeat( vec3 p, vec3 q)
{
  vec3 b = mod(p + 0.5*q,q) - 0.5*q;
  return b;
}

float smin( float a, float b, float k)
{
  float h = clamp(0.5 + 0.5 *(b-a)/k, 0.0, 1.0);
  return mix( b,a,h) - k*h*(1.-h);
}

float box( vec3 p, vec3 b)
{
  vec3 q = abs(p)-b;
  return length (max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sphere( vec3 p, float r )
{
  return length(p) - r;
}

float ground( vec3 p, float y)
{
  return p.y - y;
}

vec2 U(vec2 a, vec2 b)
{
  return vec2( min(a.x, b.x), mix(a.y, b.y, step(b.x, a.x)));
}

vec3 map( vec3 p, float fft, float fftS)
{
  
  float spoff = sin(p.x) + cos(p.z*5.+fGlobalTime+p.y*3.);
  float sp1 = sphere( p-vec3(
    sin(fGlobalTime*0.75+fftS*2.5),
    1.5+cos(fGlobalTime*0.25),
    cos(fGlobalTime*0.5)
  ), 0.5+spoff*0.05);
  float sp2 = sphere( p-vec3(
    sin(fGlobalTime*0.5),
    1.5,
    cos(fGlobalTime*0.55+fftS*2.5)
  ), 0.5+spoff*0.05);
  sp1 = smin(sp1,sp2,0.5);
  
  float sp3 = sphere( p-vec3(
    sin(fGlobalTime*0.25),
    1.5+cos(fGlobalTime*0.25+fftS*2.5)*0.5,
    cos(fGlobalTime*0.35)
  ), 0.5+spoff*0.05);
  
  sp1 = smin(sp3,sp1,0.5);
  
  float h = texture(texNoise, p.xz*.1+vec2(fftS*0.06+fGlobalTime*0.01,-fftS*0.16+fGlobalTime*0.012 )).r*1.0;
  h += texture(texNoise, p.xz*.1+vec2(fGlobalTime*0.017,+fGlobalTime*0.02 )).r*0.5;
  
  float g1 = ground(p, h);
  
  float b1 = box( p - vec3(3,0,0), vec3(1,10,1)); 
  sp1 = min(b1,sp1);
  
  vec2 obu = vec2( sp1, 0.0);
  vec2 grn = vec2( g1, 1.0);
  
  return vec3(U(obu,grn),h);
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, float fft, float fftS)
{
  float t = 0.0;
  for(int i = 0; i < 200; i++)
  {
    p = cam + rd*t;
    vec2 r = map(p,fft,fftS).xy;
    t+=r.x;
    if(r.x < 0.001)
    {
      return vec3(r,t);
    }
    if(t > 20.)
    {
      return vec3(0, -1,t);
    }
  }
}

vec3 normal(vec3 p, float fft, float fftS)
{
  vec2 c = map(p,fft,fftS).xy;
  vec2 e = vec2( 0.01, 0);
  return normalize( vec3(
    map(p+e.xyy,fft,fftS).x,
    map(p+e.yxy,fft,fftS).x,
    map(p+e.yyx,fft,fftS).x
  ) - c.x );
}

float light( vec3 n, vec3 p, vec3 l)
{
  return max(0.0, dot( n, normalize( l - p)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float fft = texture(texFFT, 0.2).r;
  float fftS = texture(texFFTIntegrated, 0.2).r;
  
  vec3 cam = vec3( 
    sin(fftS*4)*2.,
    1.25+cos( fftS* (0.25+sin(fGlobalTime*0.01)*0.25 ))*0.5,
    8);
  vec3 target = vec3(0,0.5+cam.y,0);
  vec3 p = vec3(0);
  vec3 rd = getcam(cam,target,uv,2.0+sin(fftS*3.)*1.85);
  vec3 res = march(cam, rd, p, fft, fftS);
  
  float ambient = 0.5;
  
  vec3 light1 = vec3(
    sin(fGlobalTime)*10,
    10.,
    cos(fGlobalTime*0.4)*10
  );
  
  vec3 col = vec3(0.);
  if(res.y < -0.5)
  {
    col = vec3(0.25);
  }
  else if(res.y < 0.5)
  {
    vec3 n = normal(p, fft, fftS);
    vec3 ref = reflect(rd,n);
    vec3 pp = vec3( 0);
    vec3 rr = march( p+n, ref,pp,fft, fftS);
    
    if( rr.y < -0.5)
    {
      col += mix(vec3( 0.2, 0.2, 0.7), vec3(0.), sin( 55*p.x+5*p.z +fftS*5. )*cos( 35*p.x+65*p.z +fftS+fGlobalTime ));
    }
    else if(rr.y < 0.5)
    {
      vec3 nn = normal(pp,fft, fftS);
      vec3 ref2 = reflect(ref,nn);
      vec3 ppp = vec3( 0);
      vec3 rrr = march( pp+nn, ref2,ppp,fft, fftS);
      
      if( rrr.y < -0.5)
      {
        col = vec3(0.25);
      }
      else if(rrr.y < 0.5)
      {
        col = vec3(0.5);
      }
      else if(rrr.y < 1.5)
      {
        col = mix(vec3(1.0,0.6,0.),vec3(0.0,0.0,0.0),ppp.y*3.-fft*150.) * (ambient+light( normal(ppp,fft, fftS), ppp, light1));
      }
      col = mix( col, vec3(0.4) * (ambient+light( nn, pp, light1)), 0.5);
    }
    else if(rr.y < 1.5)
    {
      col = mix(vec3(1.0,0.6,0.),vec3(0.0,0.0,0.0),pp.y*3.-fft*150.) * (ambient+light( normal(pp,fft, fftS), pp, light1));
    }
    col = mix( col, vec3(0.0) * (ambient+light( n, p, light1)), 0.5);
    //col *= vec3(1.0,1.05,1.) * (ambient+light( n, p, light1));
    //col = vec3(0.4)*n * (ambient+light( n, p, light1));
    
  }
  else if(res.y < 1.5)
  {
    col = mix(vec3(1.0,0.76,0.),vec3(0.0,0.0,0.0),p.y*5.-fft*150.) * (ambient+light( normal(p,fft, fftS), p, light1));
  }
  
  col = mix( col, vec3(0.0,0.05,0.15), smoothstep( 0., 15., res.z));
  
	out_color = vec4(col, 1.0);
}