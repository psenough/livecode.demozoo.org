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

vec2 rotate(vec2 orig, float theta)
{
  float x = orig.x * cos(theta) - orig.y * sin(theta);
  float y = orig.x * sin(theta) + orig.y * cos(theta);
  
  return vec2(x,y);
}
void main(void)
{
  
  float low = 100 * texture(texFFTSmoothed, 0.15).r;
  float mid = 100 * texture(texFFTSmoothed, 0.25).r;
  float hi = 100 * texture(texFFTSmoothed, 0.5).r;
	vec2 uv2 = rotate(vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y), fGlobalTime + gl_FragCoord.y / 4000);
	uv2 -= 0.5;
	uv2 /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 xy2 = vec2(uv2.x * (low + cos(3.141 * uv2.y)), uv2.y * hi + cos(3.141 * uv2.x));
  xy2 = rotate(xy2, 3.1415 * 2 * fGlobalTime * 0.125);
  xy2 = rotate(xy2, 3.141 * 0.5 * sin(2 * 3.141 * sqrt(xy2.x * xy2.x + xy2.y * xy2.y)));
  xy2 = xy2 * 0.1 * (2 + 0.5 * sin(fGlobalTime * 3.141));
  float x = xy2.x/2;
  float y = xy2.y/2;

  float col2 = sin(10 * x + fGlobalTime) * sin(10 * x * sin(200 * sqrt(0.5 + uv2.x * x + uv2.y * y))) - cos(10 * y + fGlobalTime * 2);
  
  vec2 uv = low * 4.5 * vec2(gl_FragCoord.x - v2Resolution.x * 0.5, gl_FragCoord.y - v2Resolution.y * 0.5) / v2Resolution.y;
  vec4 lastCol = texture(texPreviousFrame, vec2(gl_FragCoord.xy) / v2Resolution.xy) * 0.98 - 0.002;

  ivec2 pos = ivec2(0,0);
  float v = imageLoad(computeTexBack[1], pos).r / float(0xFFFFFF);
  float v2 = 0;
  if (ivec2(gl_FragCoord.xy) == ivec2(0,0)) {
    for (float f = 0.f; f < 1.0f; f += 1.0f/1024)
    {
      v2 += pow((1 - pow(f, 0.5)) * abs(texture(texFFT, f).r), 2.5);
    }
    v = mod(v + v2 * 0.03, 200.531);
    v *= float(0xFFFFFF);
    imageStore(computeTex[1], pos, uvec4(v,0,0,0));
    imageStore(computeTexBack[1], pos, uvec4(v,0,0,0));
  }
  v = imageLoad(computeTexBack[1], pos).r / float(0xFFFFFF);
  vec2 col = vec2(sin(0.643 * fGlobalTime + v * 3)/2, sin(fGlobalTime + v * 4)/2);
  vec2 dif = vec2(uv.x - 0.8f * col.x, uv.y - 0.5f * col.y);
  float dist = (1.f + mid) * sqrt(dif.x * dif.x + dif.y * dif.y);
  
  out_color = xy2.x * 2 + mod(0.1 * max(0.95f * (0.955f + 1.1f * mid) * lastCol, vec4(2.f * hi, 2.f * hi, 2.f * hi, 1.f) + 1.5 * vec4(clamp(1 - dist * dist * 200, 0.00, 0.1f), clamp(1 - dist * dist * 500, 0.00, 2.f), clamp(1 - dist * dist * 1000, 0.00, 0.1f), 1)) + (vec4(0.15f, 0.15f, 0.15f, low * 0.5) * vec4(low * sin((1.f - abs(col2 * col2)) * 3 + 3.141 / 4), hi * (1.f - abs(col2 * col2)), low * col2 * 2, 1)), 1.f);
  
  if (mod(fGlobalTime * -100 + gl_FragCoord.x, 1 / 1000 * v2Resolution.x) < 4) out_color = vec4(1.f, 1.f, 1.f, 0.f) - out_color;
  if (mod(fGlobalTime * -100 - gl_FragCoord.y, 1 / 1000 * v2Resolution.y) < 4) out_color = vec4(1.f, 1.f, 1.f, 0.f) - out_color;
  
  out_color +=  vec4(clamp(1 - dist * dist * 200, 0.00, 0.5f), clamp(1 - dist * dist * 500, 0.00, 2.f), clamp(1 - dist * dist * 1000, 0.00, 0.5f), 1);
}
