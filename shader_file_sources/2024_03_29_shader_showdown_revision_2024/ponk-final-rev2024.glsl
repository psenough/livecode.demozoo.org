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

mat2 rot (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }

float gyroid (vec3 p) { return dot(cos(p),sin(p.yzx)); }

float fbm(vec3 p)
{
  float result = 0.;
  float a = .5;
  for (float i = 0.; i < 3.; ++i)
  {
    p += result;
    p.z += time*.2;
    result += abs(gyroid(p/a)*a);
    a/=2.;
  }
  return result;
}
float fbm2(vec3 p)
{
  float result = 0.;
  float a = .5;
  for (float i = 0.; i < 9.; ++i)
  {
    p += result*.1;
    p.z += time*.1;
    result += abs(gyroid(p/a)*a);
    a/=2.;
  }
  return result;
}


vec2 momo (vec2 p, float count)
{
  float a= 6.283/count;
  float an = mod(atan(p.y,p.x)+a/2.,a)-a/2.;
  return vec2(cos(an),sin(an))*length(p);
}

float map(vec3 p)
{
  float dist = 100.;
  
  float t = time*6.28*2.;
  t += sin(t);
  t *= .2;
  float b = abs(sin(t*2.));
  t += p.z*.5;
  p.xz *= rot(t);
  p.xy *= rot(t);
  p.xy = momo(p.xy, 5.);
  p.x -= 1.*b;
  p.y = abs(p.y);
  //p.x = abs(p.x)-b;
  //p.xz *= rot(t);
  //p.yz *= rot(sin(t)*2.);
  //p.xz *= rot(3.14/4.);
  //p.xy *= rot(3.14/4.);
  p = abs(p)-vec3(.8);
  
  dist = max(p.x, max(p.y, p.z));
  dist += fbm(p*1.)*.5*b;
  dist += fbm(p*20.)*.001;
  
  dist = abs(dist)-.1;
  
  
  return dist;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 pos = vec3(0,0,7);
  vec3 ray = normalize(vec3(uv, -1.5));
  float total = 0.;
  float dither = fbm2(vec3(uv,0.)*12345678.);
  float shade = 0.;
  const float count = 200.;
  for (float i = count; i > 0.; --i)
  {
     float dist = map(pos);
    if (dist < .0001)
    {
      shade += 0.001;
      dist = 0.002;
    }
    if (total > 10.) break;
    dist *= .9+.1*dither;
    total += dist;
    pos += ray * dist;
  }
  vec3 color = vec3(0.);
  
  vec3 e = vec3(1000./v2Resolution, 0.);
  
#define T(u) fbm2(ray*3.+u)
  vec3 normal = normalize(T(0.)-vec3(T(e.xzz),T(e.zyz),.7));
  color = 0.5 + 0.5 * cos(vec3(1,2,3)*5.9 + (normal.z*3.));
  color *= smoothstep(.1,.0,T(0.)-.8);//+abs(sin(time*6.*2.))*.1);
  color *= smoothstep(.0, .9, length(uv));
  
  if (total < 10.)
  {
    color = 0.5 + 0.5 * cos(vec3(1,2,3)*5.5+shade*300.);
  }
	out_color = vec4(color, 1);
}











