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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float getSessions(vec2 uv)
{
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions,uv*vec2(1,1*ratio)-.5).r;
}

float hash(vec2 co)
{
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

const float gamma = 2.2;
const vec3 palette[5] = vec3[](
    pow(vec3(0.102, 0.078, 0.137), vec3(gamma)), // Black-ish
    pow(vec3(0.910, 0.914, 0.922), vec3(gamma)), // White-ish
    pow(vec3(0.878, 1.000, 0.310), vec3(gamma)), // Yellow-ish
    pow(vec3(1.000, 0.125, 0.431), vec3(gamma)), // Red-ish
    pow(vec3(0.180, 0.769, 0.714), vec3(gamma)) // Cyan-ish
);

vec3 getColor(vec3 ci, vec3 cj, float x)
{
    float dx = fwidth(x) * 4.;
    x = smoothstep(-dx, dx, x - 0.5);
    return mix(ci, cj, x);
}

vec3 getColor(ivec2 ij, float x)
{
    vec3 ci = palette[ij.x];
    vec3 cj = palette[ij.y];
    return getColor(ci, cj, x);
}

ivec2 pickColors(float x)
{
    float i = mod(floor(x), 4.);
    //float j = mod(i + 1., 4.);
    return ivec2(i);//, j);
}

vec2 fracfloor(float x, float count)
{
    return vec2(fract(x * count), floor(x * count));
}

mat2 rotate(float a)
{
    return mat2(cos(a), sin(a), -sin(a), cos(a));
}

float analogFFT(vec2 uv)
{
  float fft = texture(texFFT, abs(uv.x * 2. - 1.)).r;
  float dist = pow(fft, 0.7) - abs(uv.y * 2. - 1.);
  float dDist = 2. * abs(dFdy(dist));
  return smoothstep(-dDist, dDist, dist);
}

float digitalFFTview(vec2 uv, vec2 res, float amp)
{
  vec2 fftUV = floor(vec2(abs(uv)) * res) / res;
  vec2 pixelUV = fract(vec2(uv) * res + 0.5);

  float fft = fract(texture(texFFT, fftUV.x).x) * amp;
  fft = smoothstep(0., 0.01, fft - fftUV.y);

  float fade = 0.5;
  float pixelShape = smoothstep(0.1, 0.1+fade*res.x/res.y, abs(pixelUV.x * 2. - 1.)) * smoothstep(0.1, 0.1+fade, abs(pixelUV.y * 2. - 1.));
  return pixelShape * mix(0.01, 1., fft);
}

void main(void)
{
  float t = fGlobalTime;
	vec2 uv0 = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv0 -= 0.5;
	uv0 /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv = uv0;

  float ht = hash(vec2(floor(0.2*t/0.14)*0.14));

  vec2 uv1 = uv * rotate(-(ht *2. - 1.) * t);
  float h = hash(vec2(floor(t/0.14)*0.14, hash(floor(uv1 * 4.) / 4.)));
  float h2 = hash(vec2(floor(t/0.14)*0.14, hash(floor(uv1 * 8.) / 4.)));
  float sessions = getSessions(h+uv * 2. + vec2(0., -0.1 * t));
  vec3 color = palette[0];
  if (false)
  {
    color = vec3(getColor(ivec2(mod(ivec2(3,1) + h * 3, vec2(4))), sessions));
  }
  
  if (true)
  {
    uv += h;
  }

  if (true)
  {
    int colorOffset = 1 + int(mod(floor(2*t/0.14)*0.14, 4.));
    color = mix(color, palette[0], getSessions(uv + 0.01 + vec2(0.1 * t, 0.)));
    color = mix(color, palette[colorOffset], getSessions(uv + vec2(0.1 * t, 0.)));
  }

  
  if (true)
  {
    uv += h2;
  }
  
  if (true)
  {
    vec2 uvFFT = (uv * rotate(-0.2 * (h2 *2. - 1.)*t)*vec2(0.2, 0.7) + 0.5);
    vec2 duv = vec2(0.05);
    for (int i = 0; i < 5; ++i)
    {
      color = mix(color, palette[i], analogFFT(uvFFT-(i-2) * duv));
    }
  }
  
  if (true)
  {
    int colorOffset = int(2 + mod(floor(2*t/0.14)*0.14, 4.));
    vec2 res = vec2(10., 100.);
    color = mix(color, palette[0], digitalFFTview(uv + 0.01, res, 100.));
    color = mix(color, palette[colorOffset], digitalFFTview(uv, res, 100.));
  }

  if (true)
  {
    if (h > 0.8)
    {
      int colorOffset = int(2 + mod(floor(2*t/0.14)*0.14, 4.));
      color = palette[colorOffset];
    }
  }
  
  if (false)
  {
    if (h2 > 0.4)
    {
      float circles = abs(fract(4. * length(uv0) - 2. * t) * 2. - 1.);
      float dc = fwidth(circles);
      circles = smoothstep(-dc, dc, circles - 0.98);
      color += mix(color, palette[1], circles);
    }
  }

	out_color = vec4(pow(color, vec3(1. / gamma)), 1.);
}
