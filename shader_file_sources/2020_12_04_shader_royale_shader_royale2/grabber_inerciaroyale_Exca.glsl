#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D a_logo;
uniform sampler2D asm_inverse;
uniform sampler2D asm_text;
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float fft()
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv.x = length(uv.x-0.5);
  float fft = texture(texFFTSmoothed, floor(uv.x*50.)/50.).r*25.;
  fft *= step(uv.y, fft);
  
  return fft;
  
}

vec3 repeat( vec3 p , vec3 q)
{
  return mod(p + 0.5*q, q)-0.5*q;
}

float ground(vec3 p, float off)
{
  return p.y - off;
}

float sphere( vec3 p, float r)
{
  return length(p)-r;
}

float box( vec3 p, vec3 b)
{
  vec3 q = abs(p)-b;
  return length(max(q,0))+
  min(max(q.x,max(q.y, q.z)),0);
}

vec2 U( vec2 a, vec2 b)
{
  return vec2(
    min(a.x, b.x),
    step(a.x, b.x)*a.y + step(b.x, a.x)*b.y
  );
}

vec2 map( vec3 p, float ffts, float ffta)
{
  float h = texture(texNoise, p.xz*0.1).r*1.;
  h+=abs( 
    sin(p.x+fGlobalTime )*0.05+
    sin(p.x*2.+p.z+fGlobalTime*2. )*0.03  
  );
  h*=1.+ffts;
  vec2 gr1 = vec2(ground(p , h), h);
  
  vec2 s1 = vec2(
    sphere( p+vec3(0,-1,0), 0.5),
    3.
  );
  
  vec2 b1 = vec2(
    box( repeat(p,vec3(8,0,8)) + vec3(0, -1, 0), vec3(0.4)),
    3.
  );
  
  b1 = mix(s1, b1, ffts*10.);
  
  vec2 union = U(b1,gr1);
  
  return union;//gr1;
}



vec3 getcam( vec2 uv, vec3 cam, vec3 target, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross(vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  
  return normalize( vec3( fov*forward + right*uv.x + up * uv.y ));
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float fftS = texture(texFFTSmoothed, 0.15).r*25.;
  float fftA = texture(texFFT, 0.15).r*25.;

  vec3 col = vec3(0.);
  
  float time = fGlobalTime*3.;
  
  vec3 cam = vec3(
    sin(time*0.1)*3.,
    sin(time*0.1)*0.5+3.7,
    cos(time*0.1)*3
  );
  vec3 target = vec3(
    0,
    sin(time*0.1)*0.5+1.0,
    0-time*0.
  );
  vec3 rd = getcam(uv, cam, target, 0.8);
  
  
  
  float t = 0;
  for(int i = 0; i < 100; i++)
  {
    vec3 p = cam + rd*t;
    vec2 r = map(p, fftS, fftA);
    if(r.x < 0.01)
    {
      if(r.y < 0.5)
        col = mix( vec3(0.05, 0.01,0.)+smoothstep(0.05,0.5,fftS), vec3(0.4,0.5,1.0),r.y*2.);
      else if(r.y > 2.5)
        col = vec3(1.,0,0);
      break;
    }
    t += r.x;
    if(t> 30.) break;
  }
  
  col = mix( col, vec3(0.2,0.3,0.6), smoothstep(5., 30., t));
  
  
  float ffbar = fft();
  col=mix(col, col+fft()*vec3(1,1,1), step(0.1,ffbar));
  out_color = vec4(col, 1.);
}