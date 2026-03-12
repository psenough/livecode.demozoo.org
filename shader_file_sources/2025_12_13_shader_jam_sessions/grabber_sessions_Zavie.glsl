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

vec3 palette[] = vec3[](vec3(12,18,12)/255, vec3(194,1,20)/255, vec3(236,235,243)/255, vec3(96,67,95)/255, vec3(113,103,124)/255);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const int MAX_DEPTH = 10;
vec4 stack[MAX_DEPTH];

vec3 pickColor(vec4 p)
{
  vec3 c0 = palette[0];
  vec3 c1 = palette[1];
  vec3 c2 = palette[2];
  vec3 c3 = palette[3];
  vec3 c4 = palette[4];
  return mix(c0, mix(mix(c0, c1, p.y), mix(c2, c3, p.z), p.w), p.x);
}

// ---8<---------------------------------------------------------------
// Greetings to IQ <3
float box(vec2 p, vec2 size, vec4 r)
{
  r.xy = p.x > 0. ? r.xy : r.zw;
  r.x = p.y > 0. ? r.x : r.y;
  vec2 q = abs(p) - size/2. + r.x;
  return min(max(q.x, q.y), 0.) + length(max(q, 0.)) - r.x;
}
// -------------------------------------------------------------->8----

mat2 rot(float angle)
{
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, s, -s, c);
}

float hash(vec2 p)
{ 
	return fract(sin(dot(p, vec2(12.9898, 4.1414))) * 43758.5453);
}

float cat(vec2 uv)
{
  float sizeBig = 0.9;
  float sizeSmall = sizeBig / 3.;
  vec2 pos[] = vec2[](
    vec2(-1. - sizeSmall/2., 1.),
    vec2(-0.5 +sizeBig/4.+ sizeSmall/2., 0.5 + sizeSmall/2.),
    vec2(-0.5 -sizeBig/4.- sizeSmall/2., 0.5 + sizeSmall/2.),
    vec2(0.5 +sizeBig/4.+ sizeSmall/2., 0.5 + sizeSmall/2.),
    vec2(1.5 +sizeBig/4.+ sizeSmall/2., 1.5 - sizeSmall/2.),
  
    vec2(-1.5, -0.5 + sizeSmall/2.),
    vec2(-0.5 +sizeBig/4.+ sizeSmall/2., 0.5 - sizeSmall/2.),
    vec2(0.5 +sizeBig/4.+ sizeSmall/2., -0.5 + sizeSmall/2.),
    vec2(0.5 -sizeBig/4.- sizeSmall/2., -0.5 + sizeSmall/2.),
  
    vec2(-1.5 +sizeBig/4.+ sizeSmall/2., -1.5 + sizeSmall/2.),
    vec2(-1.5 -sizeBig/4.- sizeSmall/2., -1.5 + sizeSmall/2.),

    vec2(-0.5 +sizeBig/4.+ sizeSmall/2., -1.0 + sizeBig * 4./18.),
    vec2(-0.5 +sizeBig/4.+ sizeSmall/2., -1.0 - sizeBig * 4./18.),
    vec2(0.5 +sizeBig/4.+ sizeSmall/2., -1.0 + sizeSmall/2.),
    vec2(0.5 -sizeBig/4.- sizeSmall/2., -1.0 - sizeSmall/2.),

    vec2(1.5 +sizeBig/4.+ sizeSmall/2., -1.5 + sizeSmall/2.),
    vec2(1.5 -sizeBig/4.- sizeSmall/2., -1.5 + sizeSmall/2.)
  );

  float d = 1.;
  for (int j = 0; j < 3; ++j)
    for (int i = 0; i < 4; ++i)
      if (i != 3 || j != 1)
      {
        vec2 size = vec2(sizeBig);
        vec4 r = vec4(0.1);
        d = min(d, box(uv * 4. - vec2(i - 1.5, j - 1.), size, r));
      }
  for (int i = 0; i < pos.length(); ++i)
  {
    vec2 size = vec2(sizeSmall);
    vec4 r = vec4(0.03);
    d = max(d, -box(uv * 4. - pos[i], size, r));
  }


  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);


  float quant = 1./mix(1e-6, 0.1, pow(sin(fGlobalTime * 0.11)*0.5+0.5, 2.5));
  uv = floor(uv * quant) / quant;

  
  vec2 offset = vec2(sin(fGlobalTime * 0.2), cos(fGlobalTime));
  uv += offset;  
  float angle = 20. * sin(fGlobalTime * 0.05);
  uv = rot(angle) * uv;
  float zoom = mix(0.5, 2., sin(fGlobalTime * 0.2)*0.5+0.5);
  uv *= zoom;

  vec3 color = vec3(0);
  float sum = 0.0;
  for (int i = 0; i < MAX_DEPTH; ++i)
  {
    float h = hash(floor(uv));
    vec2 p = mix(vec2(0.25), vec2(0.75), vec2(h, fract(h + 0.5)));
    float d = length(fract(uv)-p);
    float bright = 10. * pow(1. - d, 100.);
    vec4 c = vec4(h*h*h, fract(h + fGlobalTime), fract(h + 1.2 * fGlobalTime), fract(h + 1.3 * fGlobalTime));
    vec3 localColor = bright*pickColor(c);
    if (i == 1)
    {
      //if (h < 0.05)
        //color *= cat(4.*uv);
    }
    color += localColor;
    ++sum;
    uv *= 2.0;
  }
    
	out_color = vec4(color, 1);
}
