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

 float fft = 0.0;
 float ffts = 0.0;
 float ffti = 0.0;
 float beat = 0.0;
 float beatstep = 0.0;
 float bar = 0.0;


layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 texmap( vec3 p, vec3 n)
{
  return mat3( texture(texNoise, p.yz).rgb, texture(texNoise, p.xz).rgb, texture(texNoise, p.xy).rgb) * n;
}

vec3 getcam(vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  return normalize( forward*fov + right * uv.x + up*uv.y);
}

float sphere( vec3 p, float r)
{
    return length(p)-r;
}

vec3 repeat( vec3 p, vec3 c)
{
  return mod(p+0.5*c,c) - c*0.5;
}

vec3 map( vec3 p )
{
  if( mod(bar, 8.0) < 4.5)
    p = repeat(p, vec3( 2.0, 0.0, 3.0));
  
  float h = texmap( p, p).r * (
    0.1 +
    smoothstep( 0.0, 0.1, ffts)*0.75+
    smoothstep( 0.1, 0.3, ffts)*1.5
  );
  float s = sphere(p, 0.25 + h);
  return vec3(s, 1.0, 1.0);
}



vec3 march( vec3 cam, vec3 rd, out vec3 p, out float t)
{
  for(int i =0 ;i < 100; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p);
    t+=r.x*0.5;
    if(r.x < 0.001)
    {
      return r;
    }
    if(t > 50.0)
    {
     t= 50.0;
       return vec3(-1);
    }
  }
  return vec3(-1.0);
}
float marchV( vec3 cam, vec3 rd)
{
  float t = 0.0;
  float v = 0.0;
  for(int i =0 ;i < 100; i++)
  {
    vec3 p = cam + rd*t;
    vec3 r = map(p);
    t+=r.x*0.5;
    if(r.x < 10.001)
    {
      v +=1.0/50.0;
    }
    if(t > 50.0)
    {
       return v;
    }
  }
  return 0.0;
}


vec3 normal( vec3 p )
{
  vec3 c = map(p);
  vec2 e = vec2( 0.001, 0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x );
}

float light( vec3 p, vec3 l, vec3 n)
{
  return max( 0.0, dot( n, normalize(l-p) ) );
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 vuv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  float time = fGlobalTime;
  
  fft = texture( texFFT, 0.1).r;
  ffts = texture( texFFTSmoothed, 0.1).r + texture( texFFTSmoothed, 0.05).r*4.;
  ffti = texture( texFFTIntegrated, 0.1).r;
  
  beat = floor( time * 127.0/60.0);
  beatstep = fract( time * 127.0/60.0);
  bar = floor( beat / 4.0 );
  vec3 col1 = vec3(1.0, 0.5, 0.0);
  vec3 col2 = vec3(0.0, 0.5, 1.0);
  
  
  vec3 col = vec3(0.0);
  vec3 cam = vec3( 
    sin(time*0.7+ffti)*2.0, 
    cos(time*0.5+ffti*0.1)*2.0, 
    sin(time*0.25)*2.0
  );
  vec3 target = vec3(0,0,0);
  vec3 light1 = vec3(
    sin(time)*10.0,
    sin(time*0.5)*10.0,
    sin(time*0.25)*10.0
  );
  vec3 light2 = vec3(
    sin(time*0.5)*10.0,
    sin(time*0.25)*10.0,
    sin(time*0.55)*10.0
  );
  float fov = 3.2 + 1.5*sin(bar*4.2);
  vec3 rd = getcam( cam, target, uv, fov);
  
  float travel = 0.0;
  vec3 p = cam;
  vec3 res = march(cam, rd, p, travel);
  if(res.y > -0.5)
  {
    vec3 n = normal(p);
    col = col1*light(p, light1, n) + 
          col2*light(p, light2, n);
  }
  
  float v = marchV( cam, rd);
  col += mix( col1, col2, uv.x+uv.y)*v*0.15 * (0.25 + smoothstep( 0.0, 0.05, ffts) +0.5* smoothstep( 0.5,  1.0, beatstep));
  
  vuv -= 0.5;
  vuv*=0.98;
  vuv+=0.5;
  
  vec3 previous = texture( texPreviousFrame, vuv).rgb;
  
  if(mod(bar, 4.0) < 0.5) col = col.gbr;
  else if(mod(bar, 4.0) < 1.5) col = col.bgr;
  else if(mod(bar, 4.0) < 2.5) col = col.rbg;
  
	out_color = vec4( col + 0.85*previous*(0.15+0.85*smoothstep(0.0, 0.1, ffts)) , 1.0);
}
















