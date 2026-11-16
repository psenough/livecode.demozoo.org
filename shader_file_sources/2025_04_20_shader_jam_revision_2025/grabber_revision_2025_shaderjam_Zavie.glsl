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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float sdf(vec2 p);

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

// ---8<---------------------------------------------------------------
// FFT stuff
float fftExponentX = 2.;

float getFFT(float x)
{
  float y = texture(texFFT, pow(x, fftExponentX)).r;
  float fftExponentY = 1. / mix(4., 8., x);
  y = smoothstep(0., 1., pow(y, fftExponentY));
  return y;
}

float getSmoothFFT(float x)
{
  float y = texture(texFFTSmoothed, pow(x, fftExponentX)).r;
  float fftExponentY = 1. / mix(4., 8., x);
  y = smoothstep(0., 1., pow(y, fftExponentY));
  return y;
}

float getFFTIntegrated(float x)
{
  float y = texture(texFFTIntegrated, pow(x, fftExponentX)).r;
  y *= mix(1. / 50., 1., smoothstep(0., 1., x));
  return y;
}

vec3 fftCalibration(vec2 uv, float aspectRatio)
{
  float balls = 32.;
  float r = 0.9 / balls;
  vec2 p = vec2((fract(uv.x * balls) - 0.5) / balls, uv.y / aspectRatio) * 2.;
  float h = mix(r, 2. / aspectRatio - r, fract(getFFT(floor(uv.x * balls) / balls)));
  //float h = mix(r, 2. / aspectRatio - r, fract(getFFTIntegrated(floor(uv.x * balls) / balls)));
  return vec3(length(p - vec2(0., h)) - r, uv);
}
// -------------------------------------------------------------->8----

float slide(vec2 uv, float freq, float n, float speed)
{
  float d = uv.x;
  d *= n / 4.;
  return fract(d - getFFTIntegrated(freq) * speed) * 2. - 1.;
}

float diamond(vec2 uv, float freq, float n, float speed)
{
  float d = abs(uv.x) + abs(uv.y);
  d *= n / 4.;
  return fract(d - getFFTIntegrated(freq) * speed) * 2. - 1.;
}

float ring(vec2 uv, float freq, float n, float speed)
{
  float d = length(uv);
  d *= n / 4.;
  return fract(d - getFFTIntegrated(freq) * speed) * 2. - 1.;
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
	vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
  float aspectRatio = v2Resolution.x / v2Resolution.y;
  uv = uv * 2. - 1.;
  uv.x *= aspectRatio;

  float d = 1.;
  float mode = floor(fract(fGlobalTime / 64.) * 8.) / 8.;
  
  bool doDiamond = fract(fGlobalTime / 100.) < 0.35;
  bool doRing = fract(fGlobalTime / 99.) < 0.4;
  bool doSlide1 = fract(fGlobalTime / 98.) < 0.35;
  bool doSlide2 = fract(fGlobalTime / 97.) < 0.35;
  bool doLogo = fract(fGlobalTime / 60.) < 0.25;
  
  float total = (doDiamond ? 0.7 : 0.) + (doRing ? 1. : 0.) + (doSlide1 ? 0.4 : 0.) + (doSlide2 ? 0.4 : 0.) +  + (doLogo ? 0.25 : 0.);
  
  if (doDiamond || total < 0.8)
  {
    float n = mix(1., 32., mode);
    d *= diamond(uv, 0.1, n, 1.5);
    d *= diamond(uv, 0.1, n, -1.);
  }
  if (doRing)
  {
    float n = mix(1., 64., mode);
    d *= ring(uv, 0.1, n, -1.);
    d *= ring(uv, 0.1, n, 1.);
  }
  if (doSlide1)
  {
    float n = mix(1., 128., mode);
    d *= slide(uv, 0.3, n / aspectRatio, 2.);
    d *= slide(uv, 0.3, n / aspectRatio, -2.);
  }
  if (doSlide2)
  {
    float n = mix(1., 64., mode);
    d *= slide(uv.yx, 0.4, n, 1.5);
    d *= slide(uv.yx, 0.4, n, -1.5);
  }

  float dd = fwidth(d) * 2.;
  
  vec3 color = vec3(1.) - smoothstep(-dd * vec3(1., 1.5, 2.), dd * vec3(1.,1.5,2.), vec3(d));
  if (uv. x > 0. /* */&& false/* */)
    color = vec3(max(0., -d), max(0., d), 0.);


  float logo = cat(uv * mix(1., 1./1.5, getFFT(0.2)));
  if (doLogo)
  {
    if (fract(fGlobalTime / 120.) < 0.5)
    {
      d = logo;
      dd = fwidth(d);
      color *= 1. - 0.5*pow(smoothstep(0.5, 0., d), 4.);
      color = mix(color, vec3(1.), 1. - smoothstep(-dd, dd, d));
    }
    else
    {
      d *= logo;
      dd = fwidth(d);
      color = vec3(1. - smoothstep(-dd, dd, d));
    }
  }
  out_color = vec4(color, 1.);
  

  if (false)
  {
    vec3 fftTest = fftCalibration(gl_FragCoord.xy / v2Resolution.xy, aspectRatio);
    d = fftTest.x;
    dd = fwidth(d);
    d = 1. - smoothstep(-dd, dd, d);
    out_color = vec4(vec3(d), 1.);
  }
}
