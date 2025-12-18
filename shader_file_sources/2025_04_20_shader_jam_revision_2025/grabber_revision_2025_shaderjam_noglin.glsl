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

  //uv = sin(uv + 0.1*vec2(sin(fGlobalTime), cos(fGlobalTime)));
  uv /= abs(sin(vec2(fGlobalTime)));
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime*0.5 ) / d;
	t = clamp( t, 0.0, 1.0 );

  vec4 c = vec4(0);
  
  float q = fGlobalTime;
  for (int i = 0; i < abs(sin(fGlobalTime))*15; ++i) {
      c += plas(c.b + m*3.14, q)/d;
      q += c.r*0.1 + c.g*0.2;
 
  }
  
  float l = c.r + c.g + c.b;
  
  vec4 c2 = texture(texPreviousFrame, uv);
  l.r += sin(c2.r);
  l *= 1/normalize(l);
  l.r -= c2.g;
  l = 1-l;

  float k = 0.05;
  vec3 col1 = texture(texTex4, k*vec2(abs(sin(fGlobalTime)))).xyz;
  vec3 col2 = texture(texTex4, k*vec2(abs(sin(fGlobalTime - 1.0/60.0)))).xyz;
  
  vec3 col3 = texture(texPreviousFrame, uv).xyz;
  
  vec3 c3;
  if (l < 0.05) {
    //c3 = vec3(0,0,mix(col1,col2,smoothstep(0,0.9,l)));
    c3 = mix(col3, mix(col1, col2, l), 0.4) + 0.1*col3;
  } else {
    c3 = vec3(l);
  }
  
 	out_color = vec4(c3,1);
}
