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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 COLOR_0 = vec3(0x1a/255., 0x1c/255., 0x2c/255.);
vec3 COLOR_1 = vec3(0x5d/255., 0x27/255., 0x5d/255.);
vec3 COLOR_2 = vec3(0xb1/255., 0x3e/255., 0x53/255.);
vec3 COLOR_3 = vec3(0xef/255., 0x7d/255., 0x57/255.);
vec3 COLOR_4 = vec3(0xff/255., 0xcd/255., 0x75/255.);
vec3 COLOR_5 = vec3(0xa7/255., 0xf0/255., 0x70/255.);
vec3 COLOR_6 = vec3(0x38/255., 0xb7/255., 0x64/255.);
vec3 COLOR_7 = vec3(0x25/255., 0x71/255., 0x79/255.);
vec3 COLOR_8 = vec3(0x29/255., 0x36/255., 0x6f/255.);
vec3 COLOR_9 = vec3(0x3b/255., 0x5d/255., 0xc9/255.);
vec3 COLOR_10 = vec3(0x41/255., 0xa6/255., 0xf6/255.);
vec3 COLOR_11 = vec3(0x73/255., 0xef/255., 0xf7/255.);
vec3 COLOR_12 = vec3(0xf4/255., 0xf4/255., 0xf4/255.);
vec3 COLOR_13 = vec3(0x94/255., 0xb0/255., 0xc2/255.);
vec3 COLOR_14 = vec3(0x56/255., 0x6c/255., 0x86/255.);
vec3 COLOR_15 = vec3(0x33/255., 0x3c/255., 0x57/255.);

vec3 palette[16];
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 fantasyScreen(vec2 uv) {
  palette[0] = COLOR_0;
palette[1] = COLOR_1;
palette[2] = COLOR_2;
palette[3] = COLOR_3;
palette[4] = COLOR_4;
palette[5] = COLOR_5;
palette[6] = COLOR_6;
palette[7] = COLOR_7;
palette[8] = COLOR_8;
palette[9] = COLOR_9;
palette[10] = COLOR_10;
palette[11] = COLOR_11;
palette[12] = COLOR_12;
palette[13] = COLOR_13;
palette[14] = COLOR_14;
palette[15] = COLOR_15;
  vec2 availRes=vec2(240,136);
  vec2 screenRes = availRes + 20;
  
  uv = floor(uv*screenRes);
  uv -= 20;
  if (uv.x < 0 || uv.x > availRes.x-20 || uv.y < 0 || uv.y > availRes.y-20) {
    return COLOR_0;
  }
  uv -= vec2(120-10,68-10);
  uv /= 240;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec3 t = plas( m * 3.14, fGlobalTime ).rgb / d;
	t = clamp( t, 0.0, 1.0 );
  
  int i = int((length(t))*16);
  if (f > 0.6) i = 12;
  
  t = palette[i];
  return t;
}

void main(void)
{
  
palette[0] = COLOR_0;
palette[1] = COLOR_1;
palette[2] = COLOR_2;
palette[3] = COLOR_3;
palette[4] = COLOR_4;
palette[5] = COLOR_5;
palette[6] = COLOR_6;
palette[7] = COLOR_7;
palette[8] = COLOR_8;
palette[9] = COLOR_9;
palette[10] = COLOR_10;
palette[11] = COLOR_11;
palette[12] = COLOR_12;
palette[13] = COLOR_13;
palette[14] = COLOR_14;
palette[15] = COLOR_15;

	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	//uv -= 0.5;
	//uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec2 availRes=vec2(240,136);
  vec2 screenRes = availRes + 20;
  
  uv = floor(uv*screenRes);
  uv -= 20;
  if (uv.x < 0 || uv.x > availRes.x-20 || uv.y < 0 || uv.y > availRes.y-20) {
    out_color = vec4(COLOR_0,1);
    return;
  }
  uv -= vec2(120-10,68-10);
  uv /= 240;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec3 t = plas( m * 3.14, fGlobalTime ).rgb / d;
	t = clamp( t, 0.0, 1.0 );
  
  int i = int((length(t))*16);
  if (f > 0.6) i = 12;
  
  t = palette[i];
  
	out_color = vec4(t,1);
}