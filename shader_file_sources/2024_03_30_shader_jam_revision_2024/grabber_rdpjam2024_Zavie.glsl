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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// --------------------------------------------------------------------
// The low level building blocks:

float pi = acos(-1.);
float tau = 2. * pi;
float ratio = v2Resolution.x / v2Resolution.y;
float invratio = v2Resolution.y / v2Resolution.x;

// A quick smoothstep helper to have antialiased cuts:
float smootherstep(float a, float b, float x) { float dx = min(abs(dFdx(x)),abs(dFdy(x))); return smoothstep(a-dx, b+dx, x); }
float smoothcut(float a, float x) { return smootherstep(a, a, x); }

float hash(vec2 x) { return fract(sin(dot(x, vec2(12.9898, 78.233))) * 43758.5453); }
float hash(vec3 x) { return hash(vec2(hash(x.xy), x.z)); }

float valueNoise(vec2 p)
{
  vec2 ip = floor(p);
  vec2 dp = p - ip;
  float x0 = smoothstep(0., 1., mix(hash(ip+vec2(0.,0.)), hash(ip+vec2(0.,1.)), dp.y));
  float x1 = smoothstep(0., 1., mix(hash(ip+vec2(1.,0.)), hash(ip+vec2(1.,1.)), dp.y));
  return smoothstep(0., 1., mix(x0, x1, dp.x));
}

float valueNoise(vec3 p)
{
  vec3 ip = floor(p);
  vec3 dp = p - ip;
  float y00 = smoothstep(0., 1., mix(hash(ip+vec3(0.,0.,0.)), hash(ip+vec3(0.,0.,1.)), dp.z));
  float y01 = smoothstep(0., 1., mix(hash(ip+vec3(0.,1.,0.)), hash(ip+vec3(0.,1.,1.)), dp.z));
  float y10 = smoothstep(0., 1., mix(hash(ip+vec3(1.,0.,0.)), hash(ip+vec3(1.,0.,1.)), dp.z));
  float y11 = smoothstep(0., 1., mix(hash(ip+vec3(1.,1.,0.)), hash(ip+vec3(1.,1.,1.)), dp.z));

  float x0 = smoothstep(0., 1., mix(y00, y01, dp.y));
  float x1 = smoothstep(0., 1., mix(y10, y11, dp.y));
  return smoothstep(0., 1., mix(x0, x1, dp.x));
}

float fBm(vec2 uv, float t)
{
  float w = 0.5;
  float x = w*valueNoise(vec3(uv, t)); uv = uv*2.+10.; w /= 2.;
  x += w*valueNoise(vec3(uv, t)); uv = uv*2.+10.; w /= 2.;
  x += w*valueNoise(vec3(uv, t)); uv = uv*2.+10.; w /= 2.;
  x += w*valueNoise(vec3(uv, t)); uv = uv*2.+10.; w /= 2.;
  x += w*valueNoise(vec3(uv, t)); uv = uv*2.+10.; w /= 2.;
  return x;
}

float norm(vec2 p, float normType)
{
  float l1 = max(abs(p.x), abs(p.y));
  float l2 = length(p);
  float l3 = abs(p.x) + abs(p.y);
  return (normType > 0. ? mix(l2, l1, normType) : mix(l2, l3, -normType));
}

vec4 grid(vec2 uv, vec2 size) { uv *= size; return vec4(fract(uv), floor(uv)); }
vec4 modgrid(vec2 uv, vec2 size) { vec4 uvzw = grid(uv, size); uvzw.zw = mod(uvzw.zw,size); return uvzw; }
vec2 polar(vec2 uv) { return vec2(atan(uv.y, uv.x)/tau+0.5, length(uv)); }
vec2 tunnel(vec2 uv) { uv = polar(uv); return vec2(uv.x, 1./uv.y/tau); }

float segment(vec2 p, vec2 a, vec2 b)
{
	vec2 ab = b - a;
	vec2 ap = p - a;
	float h = clamp(dot(ap, ab) / dot(ab, ab), 0., 1.);
	return length(ap - h * ab);
}

vec2 pinch(vec2 uv, float strength)
{
  return sign(uv) * pow(abs(uv), (1. + 2. * pow(vec2(dot(uv, uv)), vec2(0.8, 5.))));
}

vec2 truchet(vec2 uv, float seed, float dir, float normType)
{
  if (seed > 0.5) uv.y = 1. - uv.y;
  vec2 uv1 = uv;
  vec2 uv2 = uv - vec2(1.);
  float x = uv.x+uv.y-1.;

  float r1 = norm(uv1, normType);
  float r2 = norm(uv2, normType);
  float a1 = dir * (atan(uv1.y, uv1.x) / tau + 0.5);
  float a2 = dir * (atan(uv2.y, uv2.x) / tau + 0.5);

  float arc1 = clamp(2.*r1, 0., 1.) * clamp(2. - 2.*r1, 0., 1.);
  float arc2 = clamp(2.*r2, 0., 1.) * clamp(2. - 2.*r2, 0., 1.);
  arc1 = clamp(arc1 - 0.4, 0., 1.) / 0.6;
  arc2 = clamp(arc2 - 0.4, 0., 1.) / 0.6;

  float a = (x < 0. ? a1 : a2);
  return vec2(1.-max(arc1,arc2), 2.*a);
}

vec2 zoom(vec2 uv, float scale)
{
  return (uv - 0.5) * scale + 0.5;
}

vec4 blurredPrev(float blurScale, float zoomScale)
{
  vec2 duv = blurScale/v2Resolution;
  return 1./8. * (
    4.*texture(texPreviousFrame, zoom(out_texcoord, zoomScale))
  + texture(texPreviousFrame, zoom(out_texcoord + duv * vec2( 1.,  0.), zoomScale))
  + texture(texPreviousFrame, zoom(out_texcoord + duv * vec2(-1.,  0.), zoomScale))
  + texture(texPreviousFrame, zoom(out_texcoord + duv * vec2( 0.,  1.), zoomScale))
  + texture(texPreviousFrame, zoom(out_texcoord + duv * vec2( 0., -1.), zoomScale)));
}

// --------------------------------------------------------------------
// The high level effects:

float bars(vec2 uv, float ratio, float n, float height, float width, float soft)
{
    ratio *= n;
    vec4 grid = grid(clamp(uv, 0., 1.), vec2(n, 1.));
    grid.x -= 0.5;
    grid.x /= ratio;
    height *= texture(texFFT, abs((grid.z+0.5)/n * 2. - 1.)).x;
    float s = segment(grid.xy, vec2(0., 0.5-height), vec2(0., 0.5+height));
    float cut = 0.5*width;
    return 1.-smootherstep(cut-soft, cut+soft, s*ratio);
}

vec2 barsWithShadow(vec2 uv, float ratio, float n, float height, float width, vec2 shadowOffset, float shadowWidth, float shadowSoft)
{
  float bar = bars(uv, ratio, n, height, width, 0.);
  float shadow = 1.-bars(uv + shadowOffset, ratio, n, height, shadowWidth, shadowSoft);
  shadow = max(bar, shadow);
  return vec2(bar, shadow);
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

float wireframe(vec2 uv, vec2 width)
{
  float x = smoothcut(width.x, uv.x) * smoothcut(width.x, 1.-uv.x);
  float y = smoothcut(width.y, uv.y) * smoothcut(width.y, 1.-uv.y);
  return max(1.-x, 1.-y);
}

vec3 spinpill(vec2 uv, float id)
{
  float angle = pi/5. + 20.*pi*pow(texture(texFFTSmoothed, id).r,1.);
  vec2 pillDir = vec2(sin(angle), cos(angle));
  float pill = segment(uv, vec2(0.5)+0.25*pillDir, vec2(0.5)-0.25*pillDir);
  pill = 1.-4.*pill;

  float pillStripes1 = fract(4.*clamp(pill, 0., 1.)-0.5);
  pillStripes1 = abs(pillStripes1 * 2. - 1.);
  pillStripes1 = smoothcut(0.5, pillStripes1);

  float pillStripes2 = fract(2.*clamp(pill, 0., 1.)-0.25);
  pillStripes2 = abs(pillStripes2 * 2. - 1.);
  pillStripes2 = smoothcut(0.5, pillStripes2);
  pill = smoothcut(0.2, pill);

  return vec3(pill, pillStripes1, pillStripes2);
}

vec3 rotapill(vec2 uv, float id, float rows)
{
  vec2 polarUV = polar(uv*2.-1.);
  float inside = 1.-smoothcut(1.-0.1/rows, polarUV.y);
  float row = floor(rows * polarUV.y);
  float oddRow = mod(row, 2.);
  polarUV.x += hash(vec2(row, id));
  polarUV.x += fGlobalTime*0.2 * (oddRow*2.-1.);
  polarUV = fract(vec2(row+2., rows) * polarUV);
  float rotapill = segment(polarUV*vec2(rows,1.5), vec2(1., 0.5), vec2(rows-1., 0.5));
  rotapill = 1.-smoothcut(0.5, rotapill);
  rotapill *= inside;
  float tail = mix(polarUV.x, 1.-polarUV.x, oddRow);

  return vec3(rotapill, tail, oddRow);
}

vec3 truchetlanes(vec4 tiles, float id, float lanes, float speed)
{
  float dir = mod(tiles.z + tiles.w,2.);
  vec2 pattern = truchet(tiles.xy, id, dir*2.-1., 0.);
  pattern.x /= 0.7;

  vec4 curve = grid(pattern.xy, vec2(lanes, 1.));
  float lane = hash(vec2(curve.z));
  float odd = smoothcut(0.5, pattern.x);
  speed *= odd * 2. - 1.;
  float forward = texture(texFFTIntegrated, lane).x;
  curve.y = fract(pattern.y + mix(fGlobalTime, forward, 0.7) * speed);

  float worm = segment(curve.xy * vec2(1., 10.), vec2(0.5, 0.5), vec2(0.5, 9.));
  worm = 1. - smoothcut(0.25, worm);
  worm *= 1.-smoothcut(1.0, pattern.x);
  return vec3(worm, curve.y, odd);
}

// --------------------------------------------------------------------
// A few predefined colours:

vec3 palette_linear[] = vec3[](vec3(0.037, 0.173, 0.177), vec3(0.235, 0.013, 0.145), vec3(0.752, 1.0, 0.076), vec3(1.0, 0.133, 0.125), vec3(0.0003));
vec3 palette(float x)
{
  x = 4. * fract(x);
  int i = int(floor(x));
  int j = (x >= 3. ? 0 : i + 1);
  float t = smoothstep(0., 1., fract(x));
  return mix(palette_linear[i], palette_linear[j], t);
}

vec3 recolorise(vec3 color, float saturation, float contrast)
{
  color = contrast * color + ( 1.0 - contrast ) / 2.0;
  float luma = dot(color, vec3(0.299, 0.587, 0.114));
  return mix(vec3(luma), color, saturation);
}

// ====================================================================

void main(void)
{
  vec2 uv = (out_texcoord - 0.5) * vec2(v2Resolution.x / v2Resolution.y, 1.);
  vec3 bgColor = palette_linear[4];

  if (true) // FEEDBACK ZOOM IN
  {
    float remanance = 0.85;
     
    bgColor = remanance * pow(blurredPrev(2., 0.99).rgb, vec3(2.2));
  }

  vec3 color = bgColor;
  float tone = 0.2*length(uv) - 0.05*fGlobalTime;
  float t = fGlobalTime*0.05;
  float variation1 = sin(t*tau);
  float variation2 = smoothstep(0.45, 0.55, abs(fract(t) * 2. - 1.));
  float variation3 = smoothstep(0.45, 0.55, abs(fract(t+0.25) * 2. - 1.));
  vec2 set1 = vec2(1.);//vec2(variation2, mix(0.5, 1.5, variation1*variation1*variation1*variation1*variation1*variation1*variation1*0.5+0.5));
  vec2 set2 = vec2(variation3, 1.);
  vec2 set3 = vec2(variation3, 1.);

  float forward = mix(texture(texFFTIntegrated, 0.).x, fGlobalTime, 0.4);
  vec2 tunnel = tunnel(uv);
  float tunnelFade = exp(-pow(tunnel.y, 1.2));

  vec2 fftUV = uv;
  if (false) // PINCH
  {
    fftUV = pinch(uv, 0.);
  }

  if (true) // CIRCULAR FFT
  {
    fftUV = vec2(fract(atan(fftUV.y, fftUV.x) / pi + t), length(fftUV) * 2. - 0.7);
  }

  if (true) // A TUNNEL OF PILLS
  {
    vec2 t2 = tunnel;
    t2.x += -0.01 * fGlobalTime;
    t2.y += 0.04 * forward;
    vec4 tiles = modgrid(t2, vec2(40.));
    float id = hash(tiles.zw);

    vec3 pill = spinpill(tiles.xy, id );

    float pillSwitchSpeed = 0.02;
    float pillSwitch = smoothstep(0.3, 0.4, abs(fract(pillSwitchSpeed*fGlobalTime) * 2. - 1.));
    float pillSwitch2 = smoothstep(0.6, 0.7, abs(fract(pillSwitchSpeed*fGlobalTime) * 2. - 1.));
    vec3 c = palette(tone + 0.2*(id*2.-1.) + 0.5*pill.z*pillSwitch*pillSwitch2);
    c = recolorise(c, set1.x, set1.y);
    color = mix(color, c, mix(pill.x, pill.y, pillSwitch));
  }

  if (false) // A WIREFRAME TUNNEL
  {
    vec2 t2 = tunnel;
    t2.x += sin(fGlobalTime*0.2)*0.2;
    t2.y += 0.1 * forward;
    vec4 tiles = modgrid(t2, vec2(12.));

    float mesh = wireframe(tiles.xy, vec2(0.01, 2.*fwidth(tiles.y)));

    vec3 c = palette(tone + 0.3);
    c = recolorise(c, set2.x, set2.y);
    color = mix(color, c, mesh);
  }

  if (false) // A TUNNEL OF DISKS
  {
    vec2 t2 = tunnel;
    t2.x += sin(fGlobalTime*0.2)*0.2;
    t2.y += 0.1 * forward;
    float rotate = 0.05 * fGlobalTime * (hash(vec2(floor(t2.y*12.))) * 2. - 1.);
    t2.x += rotate;
    vec4 tiles = modgrid(t2, vec2(12.));

    vec3 rotapills = rotapill(tiles.xy, hash(tiles.zw), 3.+floor(20. * pow(texture(texFFTSmoothed, 0.).x, 0.25)));

    vec3 c = palette(tone + 0.3 + 0.1*rotapills.z);
    c = recolorise(c, set2.x, set2.y);
    color = mix(color, c, rotapills.x * smoothstep(0.1, 0.15, rotapills.y));
  }
  
  if (false) // A TUNNEL OF TRUCHET
  {
    vec2 t2 = tunnel;
    t2.x += sin(fGlobalTime*0.1)*0.5;
    t2.y += 0.15 * forward;
    vec4 tiles = modgrid(t2, vec2(11.));
    float id = hash(tiles.zw);

    vec3 pattern = truchetlanes(tiles, id, 2., 1.);

    vec3 c = palette(tone + 0.2*pattern.z + 0.2*pattern.y);
    c = recolorise(c, set3.x, set3.y);
    color = mix(color, c, pattern.x);
  }
  color = mix(bgColor, color, tunnelFade);
  
  if (true) // ROUND BARS FFT
  {
    vec2 s = barsWithShadow(fftUV, v2Resolution.y / v2Resolution.x, 80., 1., 0.6, vec2(-0.004, 0.006), 0.8, 0.2);
    vec3 c = palette(tone + 0.4);
    c = recolorise(c, set3.x, set3.y);
    color = mix(color * s.y, c, s.x);
  }
  
  if (false) // DIGITAL FFT
  {
    vec3 c = palette(tone + 0.6);
    c = recolorise(c, set3.x, set3.y);
    vec2 resolution = vec2(25., 80.);
    vec2 dropShadowOffset = vec2(-0.2, 0.3) * 1./max(resolution.x, resolution.y);
    color = mix(color, vec3(0.), digitalFFTview(fftUV + dropShadowOffset, resolution, 4.));
    color = mix(color, c, digitalFFTview(fftUV, resolution, 4.));
  }

  if (false) // ANALOG FFT
  {
    vec3 c = palette(tone + 0.8);
    c = recolorise(c, set3.x, set3.y);
    color = mix(color, c, analogFFT(fftUV));
  }

  if (true) // SMOKEY NOISE
  {
    float signalNoise = 0.97;
    color *= mix(signalNoise, 1./signalNoise, fBm(out_texcoord*20., fGlobalTime));
  }
  out_color = vec4(pow(color, vec3(1./2.2)), 1.);
}
