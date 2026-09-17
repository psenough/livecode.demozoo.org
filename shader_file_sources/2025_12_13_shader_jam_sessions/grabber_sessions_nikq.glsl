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
uniform sampler2D texShort;
uniform sampler2D texSessions;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


float beat(float b, float offset)
{
  // return  clamp(tan(-fGlobalTime * b * 148 / 60),0,1) + offset;
  return  mod(fGlobalTime * 148 / b / 60 + offset,1);
}


vec3 xyz(float lambda)
{
    // 可視域外はゼロ
    if (lambda < 380.0 || lambda > 780.0)
        return vec3(0.0);

    float x, y, z;

    // X
    x  = exp(-0.5 * pow((lambda - 595.8) / 33.33, 2.0));
    x += 0.26 * exp(-0.5 * pow((lambda - 446.8) / 19.44, 2.0));

    // Y（輝度）
    y  = exp(-0.5 * pow((lambda - 556.3) / 46.14, 2.0));

    // Z
    z  = 1.8 * exp(-0.5 * pow((lambda - 449.8) / 26.0, 2.0));

    return vec3(x, y, z);
}


vec4 mark(vec2 uv)
{
  vec2 center = vec2(0.6,-0.33);
  float size = 0.1;
  
  vec2 uv2 = (uv - center) / size;
  uv2.y *= -1;
  if(uv2.x<0||uv2.x>1||uv2.y<0||uv2.y>1)return vec4(0);
  vec3 col = xyz(200+ (uv2.x / 3 + 0.5)*500);
  vec4 t= texture(texShort, uv2);
  return vec4(t.rgb * col,t.a);
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 texuv = vec2(uv.x,uv.y*-1);
  vec2 center = vec2(0.5,-0.5);
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float b = 0.4-beat(1,0);
  vec4 stamp = mark(uv);
  out_color = vec4(mix(vec3(b),stamp.rgb,stamp.a),1);
}