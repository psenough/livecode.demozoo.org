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

// --------------------------------------------------
// Color palette

const vec3 palette[] = vec3[](
  vec3(0.0252, 0.3813, 0.3712),
	vec3(0.9647, 0.4287, 0.0),
	vec3(0.7305, 0.0369, 0.3372),
	vec3(0.0012, 0.7991, 0.1221)
  );
const vec3 bgColor =vec3(0.0065, 0.0056, 0.006);

vec3 getColor(float x) {
  x = mod(x, palette.length());
  float x0 = floor(x);
  float x1 = mod(x0 + 1., palette.length());
  float w = clamp(x - x0, 0., 1.);
  w = w * w * (3. - 2. * w);
  w = w * w * (3. - 2. * w);
  return mix(palette[int(x0)], palette[int(x1)], w);
}

// --------------------------------------------------
float hash(vec2 co){ return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); }

// --------------------------------------------------
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

// --------------------------------------------------
// 2D functions

float Plane(vec2 p, vec2 n, float t0) { return dot(p, normalize(n)) - t0; }
float Box(vec2 p, vec2 size) { vec2 u = abs(p) - size; return length(max(u, 0.0)) + min(max(u.x, u.y), 0.0); }
float Segment(vec2 p, vec2 a, vec2 b) { vec2 ba = b - a, pa = p - a; float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0); return length(pa - h * ba); }

float Box(vec2 p, vec2 size, vec4 r) {
  r.xy = p.x > 0. ? r.xy : r.zw;
  r.x = p.y > 0. ? r.x : r.y;
  vec2 q = abs(p) - size/2. + r.x;
  return min(max(q.x, q.y), 0.) + length(max(q, 0.)) - r.x;
}
mat2 rot(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, -s, s, c);
}

// --------------------------------------------------
// Demogroup logos

float catLogo(vec2 uv) {
  float sizeBig = 0.8/4.;
  vec4 holes[] = vec4[](
    vec4(0., 2., 1., 0.),
    vec4(1., 2., 1., -1.),
    vec4(1., 2., -1., -1.),
    vec4(2., 2., 1., -1.),
    vec4(3., 2., 1., 1.),

    vec4(0., 1., 0., -1.),
    vec4(1., 1., 1., 1.),
    vec4(2., 1., 1., -1.),
    vec4(2., 1., -1., -1.),

    vec4(0., 0., 1., -1.),
    vec4(0., 0., -1., -1.),

    vec4(1., 0., 1., 0.45),
    vec4(1., 0., 1., -0.45),

    vec4(2., 0., 1., 0.45),
    vec4(2., 0., -1., -0.45),

    vec4(3., 0., 1., -1.),
    vec4(3., 0., -1., -1.)
  );

  float d = 1.;
  for (int j = 0; j < 3; ++j)
    for (int i = 0; i < 4; ++i)
      if (i != 3 || j != 1) {
        vec2 localUV = (uv * 4. - vec2(i - 1.5, j - 1.))/4.;
        float d1 = Box(localUV, vec2(sizeBig), vec4(0.01));
        
        for (int k = 0; k < holes.length(); ++k)
          if (vec2(i, j) == holes[k].xy) {
            vec2 offset = holes[k].zw * (sizeBig / 2.);
            vec2 size = vec2(sizeBig /3.);
            if (abs(holes[k].z) == 1.) size.x *= 2.;
            if (abs(holes[k].w) == 1.) size.y *= 2.;
            d1 = max(d1, -Box(localUV - offset, size, vec4(0.005)));
          }
        d = min(d, d1);
      }
  return d;
}

float _0b5vrLogo(vec2 p) {
  float d = min(Box(p, vec2(0.18, 0.3)), Box(p, vec2(0.3, 0.18)));
  d = max(d, -Box(p, vec2(0.18)));
  d = min(d, Box(p, vec2(0.06)));
  return d;
}

float AlcatrazLogo(vec2 p) {
    vec2 a = abs(p);
    return min(max(max(
        min(abs(mod(p.x+.067,.134)-.067),max(a.x, a.y)-.1),
        -min(length(p-vec2(0,.03))-.06,max(a.x,abs(p.y+.02)-.03)-.04)
    ),a.x+a.y-.4),abs(a.x+a.y-.41)+.01)-0.02;
}

float Spike(vec2 p) { return max(max(Plane(p, vec2(1., 0.), 0.), Plane(p, vec2(-1., -1.), -0.06)), Plane(p, vec2(-5., 1.), 0.09)); }
float ConspiracyLogo(vec2 c) {
    float halfSqrt2 = sqrt(2.)/2.;
    vec2 c2 = vec2(c.y, -c.x);
    vec2 c3 = halfSqrt2 * vec2(c.x + c.y, -c.x + c.y);
    vec2 c4 = vec2(-c3.y, c3.x);

    float d = length(c) - 0.05;
    d = min(d, min(Spike(c), Spike(-c)));
    d = min(d, min(Spike(c2), Spike(-c2)));
    d = min(d, min(Spike(c3), Spike(-c3)));
    d = min(d, min(Spike(c4), Spike(-c4)));
    return d;
}

float LogicomaLogo(vec2 c) {
    float d = length(c) - 0.4;
    d = max(d, 0.39 - length(c));
    float r = 0.275;
    vec2 c2 = c + r * vec2(0., 1.0);
    d = min(d, max(length(c2) - 0.03, 0.02 - length(c2)));
    c2 = c + r * normalize(vec2(1.5, -1.));
    d = min(d, max(length(c2) - 0.03, 0.02 - length(c2)));
    c2 = c + r * normalize(vec2(-1.5, -1.));
    d = min(d, max(length(c2) - 0.03, 0.02 - length(c2)));
    return d;
}

float MercuryLogo(vec2 p) {
  float d = Box(p - vec2(0., 0.148), vec2(0.28, 0.2));
  d = max(d, -Box(p - vec2(0., .1), vec2(0.16, 0.04)));
  d = max(d, -Box(p - vec2(0., .36), vec2(0.16, 0.1)));
  d = min(d, Box(p + vec2(0., .2), vec2(0.28, 0.06)));
  d = min(d, Box(p + vec2(0., .2), vec2(0.068, 0.2)));
  return d;
}

float StillLogo(vec2 p) {
    float h = 0.15;
    vec2 pIII = p;
    pIII.x = (fract(pIII.x * 5. + 0.5)-0.5) / 5.;
    float d = Box(pIII, vec2(0.33/5., h));
    d = max(d, -Box(p + vec2(3./5., 0.), vec2(0.1, h*1.2)));
    d = max(d, -Box(p + vec2(2./5., h*-0.7), vec2(0.1, h*0.5)));
    d = max(d, -Box(p + vec2(0., h*-0.4), vec2(0.1, h*0.2)));
    d = min(d, Box(p + vec2(1./5., 0.), vec2(1./5., h*0.2)));
    d = min(d, Box(p + vec2(2.5/5., h*0.8), vec2(0.5/5., h*0.2)));

    d = max(d, Box(p + vec2(1./10., 0.), vec2(0.6, 0.2)));
    return d;
}

vec2 selectLogo(vec2 p, float x) {
  x = fract(x / 8.) * 8.;
  if (x < 1.) return vec2(_0b5vrLogo(p), 1.);
  if (x < 2.) return vec2(AlcatrazLogo(p), 1.);
  if (x < 3.) return vec2(ConspiracyLogo(p), .05);
  if (x < 4.) return vec2(LogicomaLogo(p), 1.);
  if (x < 5.) return vec2(MercuryLogo(p), 1.);
  if (x < 5.) vec2(StillLogo(p), 1.);
  return vec2(catLogo(p), 1.);
}

// --------------------------------------------------

float inside(float d) {
    float dd = fwidth(d);
    return 1. - smoothstep(-dd / 2., dd / 2., d);
}

float outline(float d, float h) {
    float dd = fwidth(d);
    return 1. - smoothstep(-dd / 2., dd / 2., abs(d) - h);
}

float glow(vec2 d) {
    float s = max(0., d.x);
    return d.y/(1.+10. * s * s * s * s);
}

float radiate(float d, float x) {
  float dd = fwidth(d*40.);
  float h = abs(fract(d * 10. - x) * 2. - 1.);
  return (1. - smoothstep(-dd, dd, h)) / (1. + 20.*d*d);
}

float draw(vec2 logo, float x)
{
  float d = 0.;
  d += inside(logo.x) * 1.;
  d += glow(logo) * 0.;
  d += radiate(logo.x, x) * 1.;
  d += outline(logo.x, 0.004) * 1.;
  return d;
}

// --------------------------------------------------

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 color = vec3(0.);
  int i, j = 0;
  //for (int j = -1; j <= 1; ++j)
    //for (int i = -1; i <= 1; ++i)
    {
      uv += vec2(i, j);
      
      float id = 0.;//hash(vec2(i, j));
      if (true) uv *= mix(0.4, 4., sin(0.2 * fGlobalTime) * .5 + .5);;
      if (true) uv = rot(2. * sin(0.1*fGlobalTime)) * uv;
      if (true) uv += abs(fract(vec2(0.2) * fGlobalTime) * 2. - 1.) * 1.5 - .75;
      if (true) {
        vec2 uvi = floor(uv);
        id = uvi.x + 3215431 * uvi.y;
        uv = fract(2. * uv) * 2. - 1.;
      }
      float progress = getFFT(0.1);
      vec2 logo = selectLogo(uv*2., id + fGlobalTime);
      float d = draw(logo, 3. * fGlobalTime + progress);
      color += d * getColor(fGlobalTime);
    }
    color /= 9.;

	out_color = vec4(pow(color, vec3(1./2.2)), 1.);
}
