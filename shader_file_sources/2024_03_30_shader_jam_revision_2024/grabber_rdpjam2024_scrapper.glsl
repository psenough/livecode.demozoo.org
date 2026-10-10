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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

const float sample1 = 0.004f;
const float sample2 = 0.04f;

const float sampleC = 120.5f / 10000.0f;
const float sampleD = 140.0f / 10000.0f;
const float sampleE = 150.5f / 10000.0f;
const float sampleF = 160.5f / 10000.0f;
const float sampleG = 180.0f / 10000.0f;
const float sampleA = 200.0f / 10000.0f;
const float sampleB = 228.0f / 10000.0f;
const float sampleC2 = 241.0f / 10000.0f;

const float sampleBass = 42.0f / 10000.0f;
const float sampleKick = 66.0f / 10000.0f;

const float octaveOffset = sampleC2 - sampleC;

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}


float noise(vec2 n) {
	const vec2 d = vec2(0.0, 1.0);
  vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
	return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}


vec3 hsv_to_rgb(vec3 color) {
    // Translates HSV color to RGB color
    // H: 0.0 - 360.0, S: 0.0 - 100.0, V: 0.0 - 100.0
    // R, G, B: 0.0 - 1.0

    float hue = color.x;
    float saturation = color.y;
    float value = color.z;

    float c = (value/100) * (saturation/100);
    float x = c * (1 - abs(mod(hue/60, 2) - 1));
    float m = (value/100) - c;

    float r = 0;
    float g = 0;
    float b = 0;
    
    if (hue >= 0 && hue < 60) {
        r = c;
        g = x;
        b = 0;
    } else if (hue >= 60 && hue < 120) {
        r = x;
        g = c;
        b = 0;
    } else if (hue >= 120 && hue < 180) {
        r = 0;
        g = c;
        b = x;
    } else if (hue >= 180 && hue < 240) {
        r = 0;
        g = x;
        b = c;
    } else if (hue >= 240 && hue < 300) {
        r = x;
        g = 0;
        b = c;
    } else if (hue >= 300 && hue < 360) {
        r = c;
        g = 0;
        b = x;
    }

    r += m;
    g += m;
    b += m;

    return vec3(r, g, b);
}


float circle(vec2 p, float r){
  
  
  float lerper = 0.5f + 0.5f * sin(fGlobalTime * 0.1f);
  
  float circle = length(p) - r;
  float square = abs(p.x) + abs(p.y) - r;
  
  return step(mix(circle, square, lerper), 0.0f);
}

float box(vec2 p, float r)
{
  float lerper = 1f;
  
  float circle = length(p) - r;
  float square = abs(p.x) + abs(p.y) - r;
  
  return step(mix(circle, square, lerper), 0.0f);
}


void main(void)
{
  //float bpm = 155.0f;
  //float bps = bpm / 60.0f;
  
  //float 
  
  //float v = 0.5f + 0.5f * sin(fGlobalTime * 3.14159f * bps);
  
  
  
  float t = fGlobalTime;
  
  float integrated = texture(texFFTIntegrated, 0.01f).r;
  
	vec2 uvRaw = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = uvRaw - 0.5;                          // centered
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1); // aspect ratio
  
  
  
  float uvAngle = atan(uv.y, uv.x);
  
  uvAngle += sin(t * .1f) * 0.5f;
  
  // ---
  
  uv = uv * (1.0f + 0.4f * sin(integrated * 0.05f) * 0.8f);
  

  vec3 led = hsv_to_rgb(vec3(360f * mod(t, 1.0f), 100.0f, 50.0f));
  
  //uv = abs(uv);
  
  
  // ========
  
  float valueC = max(texture(texFFT, sampleC).r, texture(texFFT, sampleC * 2.0f).r);
  float valueD = max(texture(texFFT, sampleD).r, texture(texFFT, sampleD * 2.0f).r);
  float valueE = max(texture(texFFT, sampleE).r, texture(texFFT, sampleE * 2.0f).r);
  float valueF = max(texture(texFFT, sampleF).r, texture(texFFT, sampleF * 2.0f).r);
  float valueG = max(texture(texFFT, sampleG).r, texture(texFFT, sampleG * 2.0f).r);
  float valueA = max(texture(texFFT, sampleA).r, texture(texFFT, sampleA * 2.0f).r);
  float valueB = max(texture(texFFT, sampleB).r, texture(texFFT, sampleB * 2.0f).r);
  
  float valueKick = texture(texFFT, sampleKick).r;
  float valueBass = texture(texFFT, sampleBass).r;
  
  
  
    // ----
  
  
    float noiseX = (0.5f - noise(uv * 1000f)) * 0.5f;
  float noiseY = (0.5f - noise(uv * 987f)) * 0.5f;
  
  uv += vec2(noiseX, noiseY) * pow(valueBass, 4.0) * 0.5f;
  
  // ----
  
  

  const float tau = 3.14159f * 2.0f;
  float angle = tau * 0.2f * t;
  
  angle -= integrated * 0.2f;
  
  float toneDist = 0.3f;

  vec2 circlePosC = vec2(cos(angle + 0.0f/7.0f * tau) * toneDist, sin(angle + 0.0f/7.0f * tau) * toneDist);
  vec2 circlePosD = vec2(cos(angle + 1.0f/7.0f * tau) * toneDist, sin(angle + 1.0f/7.0f * tau) * toneDist);
  vec2 circlePosE = vec2(cos(angle + 2.0f/7.0f * tau) * toneDist, sin(angle + 2.0f/7.0f * tau) * toneDist);
  vec2 circlePosF = vec2(cos(angle + 3.0f/7.0f * tau) * toneDist, sin(angle + 3.0f/7.0f * tau) * toneDist);
  vec2 circlePosG = vec2(cos(angle + 4.0f/7.0f * tau) * toneDist, sin(angle + 4.0f/7.0f * tau) * toneDist);
  vec2 circlePosA = vec2(cos(angle + 5.0f/7.0f * tau) * toneDist, sin(angle + 5.0f/7.0f * tau) * toneDist);
  vec2 circlePosB = vec2(cos(angle + 6.0f/7.0f * tau) * toneDist, sin(angle + 6.0f/7.0f * tau) * toneDist);

  float circleBase = 0.05f;
  float circleRange = 0.4f;

  float circleC = circle(uv - circlePosC, circleBase + circleRange * valueC);
  float circleD = circle(uv - circlePosD, circleBase + circleRange * valueD);
  float circleE = circle(uv - circlePosE, circleBase + circleRange * valueE);
  float circleF = circle(uv - circlePosF, circleBase + circleRange * valueF);
  float circleG = circle(uv - circlePosG, circleBase + circleRange * valueG);
  float circleA = circle(uv - circlePosA, circleBase + circleRange * valueA);
  float circleB = circle(uv - circlePosB, circleBase + circleRange * valueB);
  
  float circleKick = circle(uv, circleBase * 1.5f + circleRange * 2.0f * valueKick);
  float circleBass = circle(uv, circleBase * 0.3f + circleRange * 3.0f * valueBass);
  
  float squareKick = box(uv * vec2(0.5f, 1.0f), circleBase * 1.5f + circleRange * 2.0f * valueKick);
  
  // ---
  



  
  

  
  vec4 fft1 = texture(texFFT, uvRaw.x / 5f, uvRaw.y) * (1.0f + 5.0f * uvRaw.x);
  vec4 fft2 = texture(texFFTSmoothed, uvRaw.x / 5f, uvRaw.y) * (1.0f + 5.0f * uvRaw.x);
  
  float bass = texture(texFFT, sample1).r;
  float snare = texture(texFFT, sample2).r;
  
  //vec2 p1 = translate(uv, vec2(0f, 0f));
  
  //float c1 = step(circle(p1, 0.1f + bass * 0.3f), 0);
  //float c2 = step(circle(p1, 0.1f + snare * 0.3f), 0);
  
  
  //out_color = vec4(bass);
  
  //out_color = vec4(c1, 0f, c2, 0f);
  
  
  vec4 gradient = vec4(0.1, 0.2f, 1.1f, 1.0f);
  vec4 gradient2 = vec4(0.4, 0.34f, 0.3f, 1.0f);
  
  // ===
  
  float allCircles = max(circleC, max(circleD, max(circleE, max(circleF, max(circleG, max(circleA, circleB))))));
  
  allCircles = max(allCircles, circleBass);
  allCircles = allCircles - circleKick;
  
  
  gradient = vec4(led.r, led.g, led.b, 1.0f) * 100.0f;
  vec4 allCirclesColor = allCircles * gradient;
  
  
  //vec3 rgb = hsv2rgb(vec3(mod(uvAngle + 1.5f, 1.0f), 0.2f, 0.5f));
  //vec3 rgb = hsv_to_rgb(vec3(0.0f, 1.0f, 0.5f));
  //allCirclesColor = allCircles * vec4(rgb.r, rgb.b, rgb.b, 1.0f);
  
  vec4 allSquaresColor = squareKick * gradient2;
  
  allCircles = allCircles + circleBass;
  
  //out_color = vec4(allCircles, 0.0f, 0.0f, 0.0);
  
  

  out_color = allCirclesColor;
  //out_color = allCirclesColor + allSquaresColor;
  
  out_color = clamp(out_color, 0.0f, 1.0f);
  
  //out_color = vec4(1.0f) - out_color;
  
  //float c = circle(uv - vec2(0.0f, 0.0f), 0.1f);
  //out_color = vec4(c);
  
  
  // ghost
  
  float c = 0.005f;
  
  vec4 prev_but_smaller = texture(texPreviousFrame, uvRaw * (1.0f + 2.0f * c) - vec2(c));
  
  out_color += 0.9f * prev_but_smaller;
  //out_color += vec4(fft1.r, fft2.r, 0.0f, 1.0f)*0.2;
  
  
  //out_color = max(out_color, 0.4f * gradient2 * step(sin(uvAngle * 20.0f), 0.0f));
  
  //out_color = vec4(v, v, v, 1.0f);
}