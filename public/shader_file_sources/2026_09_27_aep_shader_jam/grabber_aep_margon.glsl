#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

uniform sampler2D texLogo; // screenshot of the previous frame
uniform sampler2D texNoise;
uniform sampler2D texTex2;


layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
  float r = 0.1;
  r += texture(texFFTSmoothed, 0.8).x * 100;
  
  vec2 uv2 = uv;

  //float ss = 0.05;
  //int id = int(floor(length(uv2)*ss));
  //r -= ss * id;
  //r = floor(r / 10) * 10;
  r += floor(pow(length(uv2), 2) * 10) / 8;
  
    float tt = fGlobalTime + texture(texFFTIntegrated, 0.1).r * 5;

  r += texture(texNoise, uv + vec2(tt * 0.1, (tt + 100) * 0.1)).x * 0.2;
  
  
  
  vec2 q = uv2;
  q += texture(texNoise, uv2 * 5).xy * 0.1 * fract(tt);
  float c, s;
  c = cos(tt * 0.1); s = sin(tt * 0.1);
  q *= mat2(c, s, -s, c);
  float c2, s2;
  float ql = 0.5 * length(q) * sin(tt);
  c2 = cos(tt + ql); s2 = sin(tt + ql);
  //q *= mat2(c, s, -s, c) * mat2(c2, s2, -s2, c2);
  q *= mat2(c2, s2, -s2, c2);
  
  float p = atan(q.y, q.x) / 6.283185307179586;
  
  p = int(p * 51) % 10;
  //r = p < 5 ? r : 3;
  
  //uv2 += 
  
  vec4 cb = vec4(0);
  //cb = 1 - texture(texLogo, vec2(uv.x, -uv.y)  + vec2(0.5)),

  //cb = texture(texTex2, 
  //out_color = length(uv2) < r ? vec4(0) : vec4(1.0);
  out_color = mix(
    cb,
    //texture(texLogo, -uv + vec2(0.5)),
    vec4(1.0),
    smoothstep(r - 0.0, r + 0.0, length(uv2))
   );
   
   //out_color += texture(texPreviousFrame, gl_FragCoord.xy + vec2(0, 2)) * 0.99;
   //out_color = mix(out_color, texture(texPreviousFrame, gl_FragCoord.xy * 1.01 + vec2(0, 5)), 0.1);

   //out_color = mix(out_color, texture(texPreviousFrame, gl_FragCoord.xy + vec2(0.05)), 0.99);

}