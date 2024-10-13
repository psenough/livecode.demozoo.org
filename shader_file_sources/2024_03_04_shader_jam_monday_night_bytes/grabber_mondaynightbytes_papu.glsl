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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 rot(vec3 p, vec3 r)
{
  mat3 rotm_x = mat3(
    1, 0, 0,
    0, cos(r.x), -sin(r.x),
    0, sin(r.x), cos(r.x)
  );
  mat3 rotm_y = mat3(
    cos(r.y), 0, sin(r.y),
    0, 1, 0,
    -sin(r.y), 0, cos(r.y)
  );
  mat3 rotm_z = mat3(
    cos(r.z), -sin(r.z), 0,
    sin(r.z), cos(r.z), 0,
    0, 0, 1
  );
  
  return rotm_z*rotm_y*rotm_x*p;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float distfun(in vec3 p, out int id)
{
  vec3 boxdim = vec3(.5) + 10.*texture(texFFTSmoothed, 0.9).r;
  vec3 boxloc = vec3(0.,0.,6.);
  vec3 rotation = vec3(
    texture(texFFTIntegrated,0.001).r - fGlobalTime*2,
    texture(texFFTIntegrated,0.001).r - fGlobalTime*2,
    0
  );
  vec3 q = abs(rot(p - boxloc, rotation)) - boxdim;
  id = 1;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

vec3 getcolor(int id, int nsteps)
{
  if (id == 1)
  {
    return vec3(1) * clamp(nsteps/10. ,0.1, 1.) 
      * vec3(
          mod(texture(texFFTIntegrated, 0.01).r*.5, 4) / 4,
          mod(texture(texFFTIntegrated, 0.01).r*.5, 6) / 6,
          mod(texture(texFFTIntegrated, 0.01).r*.5, 2) / 2
    );
  }
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
	
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;

	//vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = clamp( t, 0.0, 1.0 );
	//out_color = f + t;
  
  float f = texture( texFFT, 0.1 ).r * 10;
  out_color = vec4(1.);
  out_color.xyz = vec3(f);
  
  vec3 eye = vec3(0.,0.,-1.);
  vec3 p = vec3(uv, 0.);
  vec3 dir = normalize(p - eye);
  for (int i = 0; i < 50; ++i)
  {
    int id = 0;
    float d = distfun(p, id);
    if (d < 0.1)
    {
      out_color.xyz = getcolor(id, i);
      break;
    }
    else
    {
      p += d * dir;
    }
  }
  
}