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

vec2 proj(vec2 v, float a, float z)
{
    float zF=1-z/100;
    return vec2((v.x+cos(a)-v.y*sin(a))/zF, (v.x*sin(a)+v.y*cos(a))/zF);
}

void main(void)
{
    float pi=3.141593;
    float tau=pi*2;
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    float zoom=sin(fGlobalTime)*3;
    vec2 icon_uv = proj(uv, fGlobalTime*.4, zoom);
    vec2 bg_uv = proj(uv, fGlobalTime*.6, -zoom);

    float d=sqrt(uv.x*uv.x+uv.y*uv.y);
    float a=atan(uv.y,uv.x)/tau+.5;
    float icon_d=sqrt(icon_uv.x*icon_uv.x+icon_uv.y*icon_uv.y);
    float icon_a=atan(icon_uv.y,icon_uv.x)/tau+.5;

    float fft = texture( texFFT, 0.1 ).r * 5;

    float rFactor = sin(bg_uv.x+icon_a*tau) * 20 + sin(bg_uv.y) * 10 + fGlobalTime * 2;
    float gFactor = sin(bg_uv.y+pow(d,.1)) * 20 - sin(bg_uv.x *.6) * 10 + fGlobalTime * 3;
    float bFactor = -sin(d) * 20 + fGlobalTime * 5;
    float r = 0.5+sin(rFactor)*.5;
    float g = 0.5+sin(gFactor)*.5;
    float b = 0.5+sin(bFactor)*.5;

    out_color = vec4(0,0,0,0);  
    if ((icon_d<.1) || ((icon_d>.15 && icon_d<.5) && ((icon_a>.167 && icon_a<=.33) || (icon_a>.5 && icon_a<=.66) || (icon_a>.8333 && icon_a<=1)))) {
        out_color = vec4(g*b,fft,g*b,0);    
    } else { 
        out_color = vec4(max(r,g),g*b,0,0);
    }

    float zoombg=1+sin(fGlobalTime*.5)*2;
    d=d*zoombg;
    if ((d<.1) || ((d>.15 && d<.5) && ((a>.167 && a<=.33) || (a>.5 && a<=.66) || (a>.8333 && a<=1)))) {
        out_color.g -= out_color.r * sin(fGlobalTime*.5)*2;
    } 
}