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

// hi!
// I have some ideas for tonight's jam but nothing concrete
// so let's throw some math at the wall and see what sticks!

// thank you blackle
vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}

float gKick;
float gKickSum;

float gScale()
{
  return 7.0 - 10.0 * gKick;
}

float gFoldingLimit() { return 1.0f; }

float gMinRadius2() { return 1.0f; }
float gFixedRadius2() { return 2.0f; }

void boxFold(inout vec3 z, inout float dz)
{
  float f = gFoldingLimit();
  for(float x = -1.0; x <= 1.0; x+= 2.0)
  {
    for(float y = -1.0; y <= 1.0; y += 2.0)
    {
      vec3 n = f * vec3(x, y, x*y);
      // ar not actually
      float parallel = dot(n, z) / dot(n, n);
      vec3 perp = z - n * parallel;
      parallel = clamp(parallel, -1.0, 1.0) * 2.0 - parallel;
      z = perp + n * parallel;
    }
  }
  //z = clamp(z, -gFoldingLimit(), gFoldingLimit()) * 2.0 - z;
}

void sphereFold(inout vec3 z, inout float dz)
{
  float r2 = dot(z, z);
  float s = 1.0;
  if(r2 < gMinRadius2()) {
    s = gFixedRadius2() / gMinRadius2();
  }
  else if(r2 < gFixedRadius2())
  {
    s = gFixedRadius2() / r2;
  }
  z *= s;
  dz *= s;
}

float de(vec3 z)
{
  z = erot(z, vec3(0,1,0), 0.01 * sin(gKickSum) * z.y);
  vec3 c = z;
  float dr = 1.0;
  for(int n = 0; n < 4; n++)
  {
    boxFold(z, dr);
    sphereFold(z, dr);
    sphereFold(z, dr);
    z = gScale() * z + c;
    dr = dr * abs(gScale()) + 1.0;
  }
  return length(z)/abs(dr);
}

vec4 plas( vec2 v, float time )
{
  
  vec2 m;
	m.x = atan(v.x / v.y) / 3.14;
	m.y = 1 / length(v) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  float c = 0.5 + sin( m.x * 10.0 ) + cos( sin( time + m.y ) * 20.0 );
	vec4 t = vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
  
	t = clamp( t / d, 0.0, 1.0 );
  return f + t;
}

uint rngState;

// Steps the RNG and returns a floating-point value between 0 and 1 inclusive.
float rng()
{
  // Condensed version of pcg_output_rxs_m_xs_32_32, with simple conversion to floating-point [0,1].
  rngState = rngState * 747796405 + 1;
  uint word = ((rngState >> ((rngState >> 28) + 4)) ^ rngState) * 277803737;
  word      = (word >> 22) ^ word;
  return float(word) / 4294967295.0f;
}

vec3 camNode(uint i)
{
  rngState = i;
  return 5.0 * vec3(rng(), rng(), rng());
}

void main(void)
{
  gKick = texture(texFFTSmoothed, 4.5/1024.f).r;
  gKickSum = texture(texFFTIntegrated, 4.5/1024.f).r;
  
	vec2 uv = ((gl_FragCoord.xy / v2Resolution) - .5) * vec2(v2Resolution.x / v2Resolution.y, 1.0);
  
  float pathT = 0.1 * gKickSum;
  rngState = uint(pathT);
  vec3 cFrom = camNode(uint(pathT));
  vec3 cTo = camNode(uint(pathT) + 1);
  
  vec3 cam = vec3(0, 0, -20.0);
  vec3 dir = vec3(uv.x, uv.y, 1.0);
  float t = 0.1 * fGlobalTime + 0.05 * gKickSum;
  cam = mix(cFrom, cTo, smoothstep(0.0, 1.0, fract(pathT)));
  dir = erot(dir, vec3(0, 1, 0), t);
  dir = normalize(dir);
  
  float d = 0.0;
  const float TMAX = 60.0;
  for(int i = 0; i < 64; i++)
  {
    float dd = de(cam + dir * d);
    d += dd;
    if(dd < 0.001 || d >= TMAX) break;
  }
  
  out_color = vec4(0.0);
  if(d < TMAX)
  {
    vec3 p = cam + dir * d;
    vec3 grid = clamp(fract(p), 0.0, 1.0);
    vec2 eps = vec2(0.01 / gKick, 0.0);
    vec3 n = normalize(vec3(de(p + eps.xyy), de(p + eps.yxy), de(p + eps.yyx)) - de(p));
    out_color = vec4(grid * pow(max(0.0, dot(n, vec3(0, 1, 0))), 2.0), 1.0);
    // out_color = vec4(n, 1.0);
  }
  
  vec4 fog = 0.00 * vec4(0.0, 0.5, 1.0, 0.0);
  
  out_color = mix(fog, out_color, exp2(-d * .1));
  out_color = tanh(sqrt(out_color) * 1.5);
  
  out_color += 0.03 * plas(uv.xy, fGlobalTime);
  
  if(uv.y + .5 < texture(texFFT, uv.x).r)
  {
    out_color = vec4(1.0, 0.0, 0.5, 1.0);
  }
}