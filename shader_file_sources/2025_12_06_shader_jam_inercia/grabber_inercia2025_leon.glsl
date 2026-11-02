#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds
#define time fGlobalTime

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hash(vec2 p) { return fract(sin(dot(p, vec2(123.321,321.123)))*321.654); }
vec3 hash31(float i) { return vec3(hash(vec2(i,17.)), hash(vec2(i,357.)), hash(vec2(i,-95.))); }
vec3 hash32(vec2 p) { return vec3(hash(p+17.), hash(p+657.), hash(p+95.)); }
mat2 rot(float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }
float rng;

float map(vec3 p)
{
  float d = 100.;
  
  float t = time * 8. + p.z * 0.5 + rng * 0.25;
  t = pow(fract(t), 4.5) + floor(t);
  vec2 anim = vec2(fract(t), floor(t));
  vec3 offset = mix(hash31(anim.y), hash31(anim.y+1.), anim.x);
  //p.yx *= rot(t);
  p.x = abs(p.x)-.5*abs(sin(t*3.))-.5;
  p.xz *= rot(t);
  p.xy *= rot(t*1.);
  p += (offset-0.5)*2.;//*vec3(2,1,.1);
  
  
  //float e = .24-sin(t*10.)*.25;
  //p = p - clamp(p, -e, e);
  p = abs(p) - abs(sin(time*2.))*.5;
  p.xz *= rot(t*2.);
  d = length(p)-(.2-0.1*sin(t*4.))*.5;
  
  p = abs(p)-.0-.5*sin(t*4.);
  //p = abs(p)-.1-.125*sin(t*1.);
  d = min(d, length(p)-.05+.2*step(.99, fract(t*2.)));
  
  return d;
}

void main(void)
{
  rng = hash(gl_FragCoord.xy);
	vec2 uv = gl_FragCoord.xy/v2Resolution.xy;
	vec2 p = (2.*gl_FragCoord.xy-v2Resolution.xy)/v2Resolution.r;
  vec3 pos = vec3(0,0,-4.+1.*sin(time/2.));
  float t = time/4.;
  //pos.xz *= rot(t);
  //pos.xy *= rot(t);
  vec3 z = normalize(pos);
  vec3 x = normalize(cross(z, vec3(0,1,0)));
  vec3 y = normalize(cross(x, z));
  vec3 ray = mat3(x,y,z) * normalize(vec3(p,-1.));
  
  float total = 0.0;
  float shade = 0.0;
  float far = 20.;
  float dist = 100.;
  const float count = 100.;
  for (float i = 1.; i > 0.; i -= 1./count) {
    dist = map(pos);
    if (dist < .001 || total > far) break;
    dist *= 0.5 + 0.1 * rng;
    pos += ray * dist;
    total += dist;
    shade = i;
  }
  vec3 color = vec3(shade);
  vec2 e = vec2(.001,0);
  vec3 normal = normalize(dist - vec3(map(pos-e.xyy), map(pos-e.yxy), map(pos-e.yyx)));
  color = 0.5+0.5*cos(vec3(1,2,3)*4.5 + pos.z + time + normal*1.);
  color += 2.*pow(0.5+0.5*dot(normal, -ray), 10.);
  color *= shade;
  //color *= 4.0;
  vec3 back = (.5+.5*cos(vec3(1,2,3)*4.5+p.y*3.+time*4.)) * smoothstep(-.0, 2.0,length(p));
  back = vec3(smoothstep(-.0, 2.0,length(p)));
  if (total > far) color = vec3(back);
  color = 1.-color;
  
  //color = vec3(hash(gl_FragCoord.xy));
  vec3 offset = hash32(floor(p*mix(4.,8.,hash31(floor(time*40.)).x))+floor(time*4.));
  uv -= step(.5, offset.z) * 4.*normalize(offset.xy-.5)*abs(sin(time*10.))/v2Resolution;
  vec3 frame = texture(texPreviousFrame, uv).rgb;
  uv += 4.*(frame.xy-0.5)/v2Resolution;
  frame = texture(texPreviousFrame, uv).rgb;
	out_color = vec4(min(color, frame+.01), 1.);
}