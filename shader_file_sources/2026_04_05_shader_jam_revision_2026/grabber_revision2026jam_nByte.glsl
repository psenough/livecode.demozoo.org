#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[4] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


vec4 plas(vec2 v, float time, float fft)
{
    float r = length(v);
    float a = atan(v.y, v.x);

    float spiral = a + r * 10.0 - time * 2.0;
    float bands = sin(spiral * 3.0);
    float pulse = cos(r * 18.0 - time * 2.0);
    float c = 0.7 + 0.7 * (bands + pulse);

    vec3 col;
  
 col.r = 0.6 + 0.6 * sin(spiral + time * 0.5);
    col.g = 0.5 + 0.5 * sin(spiral + 2.094 + time * 0.9);
    col.b = 0.5 + 0.5 * sin(spiral + 4.188 + time * 1.1);

    col *= 0.6 + 0.4 * c;
    col /= (1.0 + r * 3.0);

    return vec4(col, 1.0);
}

void main(void)
{
    vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
    uv -= 0.5;
  
      uv.x *= v2Resolution.x / v2Resolution.y;

    float fft = texture(texFFTSmoothed, 0.05).r;
    vec4 t = plas(uv * 2.0, fGlobalTime, fft);

    out_color = clamp(t, 0.0, 0.7);
}
