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
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x - 0.5, gl_FragCoord.y / v2Resolution.y - 0.5) * 2.;

	vec3 m;
	m.x = sin(uv.x * 12.9 + fGlobalTime * 8.0);
  m.y = cos((uv.x + fGlobalTime / 34.) * 114.) * uv.y * sin(3.1 * fGlobalTime);
//  m.z = sin(uv.x * 24.4 + uv.y) + cos(fGlobalTime);

  m.x /= 2.;
  m.x *= pow(uv.x * uv.y + sin(fGlobalTime), 2.);
  m.y += tan(0.2 * (uv.y + 0.3 * sin(fGlobalTime)));
  m.z += cos(uv.y * 131. + uv.x * 113.1 * sin(fGlobalTime));

  float angle = fGlobalTime;
  vec2 nuv;
  nuv.x = uv.x * cos(angle) - uv.y * sin(angle);
  nuv.y = uv.x * sin(angle) + uv.y * cos(angle);

  m.y = m.y * 0.3;
  m.y += 0.4 * (sin((fGlobalTime * (nuv.y - 0.3) * 0.3 * (nuv.x - 0.6))));

//  m.x = 0.; m.y = 0.; m.z = 0.;

  angle = sin(fGlobalTime);
  nuv.x = uv.x * cos(angle) - uv.y * sin(angle);
  nuv.y = uv.x * sin(angle) + uv.y * cos(angle);

  vec2 c = vec2(cos(fGlobalTime) * 0.5, sin(fGlobalTime) * 0.5);

  nuv.xy += c;
  vec3 n;
  n.x = sin(pow(fGlobalTime, nuv.x * nuv.y * 1.4));
  n.y = texture(texShort, uv).y;

  angle = fGlobalTime * 2.4;
  mat3 cr = mat3(
    sin(angle), cos(angle * 1.7), uv.x,
    cos(angle), uv.y, sin(angle),
    sin(angle * 0.9), uv.x * uv.y, cos(angle)
  );
  n *= cr;

  c = vec2(cos(fGlobalTime * 3.) * 0.5, sin(fGlobalTime) * 0.5);

  nuv = uv * mat2(sin(cos(fGlobalTime * uv.x)), cos(fGlobalTime), sin(fGlobalTime), cos(-fGlobalTime * 2.0));
  vec3 q = vec3(nuv, 1.0);


  vec3 p;
  p.x = length(uv * 0.3 - c); p.y = p.x; p.z = p.x;

  vec3 o1 = (m * (1.0 - p) + n * p) * 0.8 + 0.2 * q;
  vec3 o2 = (m * p + n * (1.0 - p)) * 0.8 + 0.2 * q;

out_color = vec4(mix(o1, o2, sin(fGlobalTime)), 1.);
}
