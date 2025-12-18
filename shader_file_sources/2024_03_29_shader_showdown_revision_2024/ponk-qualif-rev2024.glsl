#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define time fGlobalTime
float fft;

mat2 rot(float a)
{
  float c=cos(a),s=sin(a);
  return mat2(c,-s,s,c);
}

float gyroid (vec3 p)
{ return dot(cos(p),sin(p.yzx));
}

float fbm (vec3 p)
{
  float result = 0.;
  float a = .5;
  for (float i = 0.; i < 3.; ++i)
  {
    p += result;
    p += time*.1;
    result += gyroid(p/a)*a;
    a /= 2.;
  }
  return result;
}

float map(vec3 p)
{
  float dist = 100.;
  
  float a = 1.;
  float t = time*1.;
  t = pow(fract(t),.4)+floor(t);
  t *= 3.;
  //t +=p.z*.9;
  
  p.xz *= rot(time);
  p.yx *= rot(time);
  
  vec3 e = vec3(.1,.1*abs(sin(time*1.)),0);
  
  float r = .5+abs(sin(time*10.))*.5;
  //r += fft*1.;
  
  for (float i = 0.; i < 12.; ++i)
  {
    
    p.x = abs(p.x)-r*a;
    p.xz *= rot(t*a);
    p.yz *= rot(t*a);
    p = p - clamp(p, -e, e);
    float b = length(p)-.01*a;
    dist = min(dist, b);
    a/=1.8;
  }
  
  
  return dist;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  fft = texture(texFFT, abs(uv.x)).a;
  
  vec3 pos = vec3(0,0,10);
  vec3 ray = normalize(vec3(uv, -1.));
  float shade = 0.;
  float dist = 100.;
  float total = 0.;
  const float count = 100.;
  
  for (float i = count; i > 0.; --i)
  {
     dist = map(pos);
    if (dist < .001)
    {
      shade = i/count;
      break;
    }
    pos += ray * dist;
    total += dist;
  }
  vec3 back = vec3(smoothstep(1., -.5, length(uv)));
  vec3 seed = vec3(uv*10.,0.);
  seed.xy = vec2(atan(seed.y, seed.x), log(length(seed.xy))*.2-time);
    vec3 tint2 = 0.5 + 0.5 * cos(vec3(1,2,3)+length(uv)*4.);
  back = tint2*smoothstep(.01,.0,abs(abs(fbm(seed))-.5)-.2);
  vec3 color =back;
  if (total < 10.)
  {
    
    vec2 e = vec2(.001,0);
    vec3 normal = normalize(dist-vec3(map(pos+e.xyy),map(pos+e.yxy),map(pos+e.yyx)));
   

    vec3 tint = 0.5 + 0.5 * cos(vec3(1,2,3)+length(pos)*3.);
    float light = dot(reflect(ray, normal), normalize(vec3(0,1,-1)));
    color = vec3(tint*shade);
    color += pow(light, 3.);
  }
	out_color = vec4(color, 1);
}