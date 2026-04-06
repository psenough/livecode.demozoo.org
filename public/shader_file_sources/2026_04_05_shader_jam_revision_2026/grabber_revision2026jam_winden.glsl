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


int do_snake(vec2 uv, int j, int k) {
    int colour = 0;

    float music = texture( texFFT, 0.1 ).r;

  
  vec2 uuv = uv;
    uuv *= 4;
    uuv.x -= j * 1.750;
    uuv.y -= k * 0.950;

    for (int i = 0 ; i < 50 ; i++) {


    float ii = i;
    ii += 3.5 * fGlobalTime;

    float fx = 0.23 + 0.012 * sin(j * 0.051 * fGlobalTime);
    float fy = 0.22 + 0.013 * sin(k * 0.063 * fGlobalTime);

    float bx = 0.5 + 0.5 * sin(fx * ii);
    float by = 0.5 + 0.5 * sin(fy * ii);


    float dist = length(uuv - vec2(bx, by));
    if (dist < 0.045 + music) {
      colour += 1;
    }
  }
  return colour;
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	// uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

//	vec2 m;
//	m.x = atan(uv.x / uv.y) / 3.14;
//	m.y = 1 / length(uv) * .2;
//	float d = m.y;

//	float f = texture( texFFT, d ).r * 100;
//	m.x += sin( fGlobalTime ) * 0.1;
//	m.y += fGlobalTime * 0.25;

  int colour_red = 0;
  for (int k = 0 ; k < 4 ; k++) {
  for (int j = 0 ; j < 4 ; j++) {
    colour_red += do_snake(uv, j, k);
  }
  }

  
  vec4 result;
  result.x = uv.x;
  result.y = uv.y;
  result.z = 0.5;
  if (colour_red >= 1) {
    result = vec4(0.2 * colour_red, 0.3 * colour_red, 0.5 * colour_red, 1.0);
  }

  out_color = result;
}