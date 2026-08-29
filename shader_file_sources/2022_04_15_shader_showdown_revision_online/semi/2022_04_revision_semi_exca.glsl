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

float time = fGlobalTime;

float ffti =0.0;
float ffts  = 0.0;
float beat =0.0;
float beatstep = 0.0;
float bar = 0.0;

float glow = 0.0;

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target -cam);
  vec3 right = normalize( cross(vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  return normalize( forward*fov + right*uv.x + up*uv.y);
}

float smin( float a, float b, float k)
{
  float h = clamp(0.5 +0.5*(b-a)/k, 0.0, 1.0);
  return mix(b,a,h) + k*h*(h-1.0);
}

vec2 shift( vec3 p)
{
  return vec2( 
    sin(p.z*0.33 + time),
    cos(p.z*0.43 + time)
  );
}

float sphere( vec3 p, float r)
{
  return length( p) -r;
}
vec3 map( vec3 p)
{
  float s1 = sphere( p + vec3( sin(time*0.9), cos(time*0.35), sin(time*.12))*0.25, 0.25);
  float s2 = sphere( p + vec3( sin(time*0.59), cos(time*0.335), sin(time*.512))*0.25, 0.25);
  float s3 = sphere( p + vec3( sin(time*0.19), cos(time*0.635), sin(time*.212))*0.25, 0.25);
  
  float s = smin( s1, smin(s2, s3, 0.15),0.15);
  float w = (1.5+4.0 * smoothstep(50.0, 5.0, p.z)) - length(p.xy + shift(p));
  
  float mat = s < w ? 2.0 : 1.0;
  
  w = min(s,w);
  
  return vec3(w, mat, 1.0);
}
vec3 march( vec3 cam, vec3 rd, out vec3 p, out float t)
{
  for(int i = 0; i < 100; i++)
  {
    p = cam+rd*t;
    vec3 r = map(p);
    t+=r.x;
    if(r.x < 2.0) glow += r.x;
    if(r.x < 0.001)
    {
      return r;
    }
    if(t > 50.0)
    {
      t = 50.0;
      return vec3(-1.0);
    }
  }
  return vec3(-1.0);
}

vec3 normal( vec3 p)
{
  vec3 c = map(p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map(p +e.xyy).x,
    map(p +e.yxy).x,
    map(p +e.yyx).x
  )-c.x);
}

float light( vec3 p, vec3 l, vec3 n)
{
  return max(0.0, dot( n, normalize( l-p)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 vuv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  ffts = texture(texFFTSmoothed,0.1).r;
  ffti = texture(texFFTIntegrated,0.1).r*2.0;
  
  beat = floor( fGlobalTime * 165.0/60.0);
  beatstep=  fract( fGlobalTime * 165.0/60.0);
    bar = floor( beat / 4.0);
 
  time = fGlobalTime*0.1 + ffti*10.0;
  
	vec3 col = vec3(0.0);
  vec3 light1 = vec3( sin(time)*10.0, 10.0, 0.0);
  
  vec3 cam = vec3(0,0,-3);
  vec3 target = vec3(0,0,0);
  float fov = 2.0 + sin(bar)*1.9;
  
  vec3 col1 = vec3(0.5, 0.3, 0.6);
  vec3 col2 = vec3(0.1, 0.5, 0.9);
  vec3 col3 = vec3(0.9, 0.0, 0.0);
  
  
  vec3 rd = getcam( cam, target, uv, fov);
  vec3 p = cam; float t = 0.0;
  vec3 res = march( cam, rd, p, t);
  
  if(res.y > 1.5){
    vec3 n = normal(p);
    col = col1*light(p,light1,n)+0.2*col3;
    
    vec3 refrd = reflect( rd, n);
    vec3 refp = p;
    vec3 refc = vec3(0.0);
    float reft = 0.0;
    vec3 refres = march( refp+ refrd*0.01, refrd, refp, reft);
    if(refres.y > 1.5){
    }
    else if(refres.y>-0.5){
      vec3 rn = normal(refp);
      refc = col2*light(refp,light1,rn)+0.2*col3;
      
      float td = smoothstep(1.0, 0.9, sin(reft*2.0));
      refc +=vec3(1.0, 0.1,0.0)* 0.1/td;
    }
    col = mix(col, refc, 0.5);
    
  }
  else if(res.y > -0.5){
    vec3 n = normal(p);
    col = col2*light(p,light1,n)+0.2*col3;
    
    float td = smoothstep(1.0, 0.9, sin(t*2.0+time*5.0));
    col += vec3(1.0, 0.1,0.0)* 0.1/td;
  }
  
  vuv -= 0.5;
  vuv *= 0.99;
  vuv += 0.5;
  vec3 previous = texture( texPreviousFrame, vuv).rgb;
  
  col += previous * 0.9 * smoothstep( 0.0, 0.1, ffts*10.0);
  
  col += glow * vec3(1.0, 0.5, 0.0) *0.1;
  
  if(mod(bar, 4.0) < 0.5) col.rgb = col.bgr;
  else if(mod(bar, 4.0) < 1.5) col.rgb = col.gbr;
  else if(mod(bar, 4.0) < 2.5) col.rgb = col.grb;
  
  out_color = vec4( col, 1.0);;
}









