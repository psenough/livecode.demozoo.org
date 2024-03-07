#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uva = uv / vec2(v2Resolution.y / v2Resolution.x, 1);
  
  // FFTSamples
  float fftBass = texture(texFFTSmoothed, 0.001+uva.x*0.005).x;
  float fftBassInt = texture(texFFTIntegrated, 0.001).x;
  
  // Prev sample
  vec4 prevPure = texture(texPreviousFrame, uv);
  vec3 prevHSV = rgb2hsv(prevPure.rgb);
  float offsetAngle = prevHSV.r*3.14159 * 2. * 10;
  vec2 prevOffset = vec2(cos(offsetAngle),sin(offsetAngle));
  vec4 prev = texture(texPreviousFrame, uv + prevOffset*(0.001 + fftBass*0.005));
  //out_color = prev*0.4;
  
  // Inercia logo
  vec2 iuv = (uv*2-fGlobalTime*0.2+sin(uva.x+fGlobalTime)*0.15)*vec2(1,-1);
  iuv += + vec2(0, fftBass);
  iuv.y = mod(iuv.y, 0.4)+0.25;
	vec4 inerciaLogo = texture(texInercia, iuv);
  float inerciaLogoMask = smoothstep(0.0, 0.3, texture(texInerciaBW, iuv).x);
  
  // Hue shift inercia logo
  vec3 logoHSV = rgb2hsv(inerciaLogo.rgb);
  vec3 logoShifted = hsv2rgb(logoHSV + vec3(fftBassInt*0.05 - fGlobalTime*0.1 + uv.x, 0,0));
  
  // Out
  //out_color = mix(vec4(logoShifted*10, 0.), prev*0.999, inerciaLogoMask);
  out_color = mix(vec4(logoShifted*2, 0.), prev*0.9, 1-inerciaLogoMask);
  //out_color = vec4(inerciaLogoMask);
}