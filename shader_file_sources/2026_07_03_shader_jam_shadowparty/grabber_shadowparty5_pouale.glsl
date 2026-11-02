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

float sdStar( in vec2 p, in float r, in int n, in float m)
{
    // next 4 lines can be precomputed for a given shape
    float an = 3.141593/float(n);
    float en = 3.141593/m;  // m is between 2 and n
    vec2  acs = vec2(cos(an),sin(an));
    vec2  ecs = vec2(cos(en),sin(en)); // ecs=vec2(0,1) for regular polygon

    float bn = mod(atan(p.x,p.y),2.0*an) - an;
    p = length(p)*vec2(cos(bn),abs(sin(bn)));
    p -= r*acs;
    p += ecs*clamp( -dot(p,ecs), 0.0, r*acs.y/ecs.y);
    return length(p)*sign(p.x);
}

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

mat2 rot(float angle)
{
  vec2 cossin = vec2(cos(angle), sin(angle));
  return mat2 (cossin.x, cossin.y, -cossin.y, cossin.x);
}

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
  
  /*

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );*/
  vec3 color = vec3(0., 1., 1.);
  vec2 uv0 = uv;
  
  uv = rot(fGlobalTime)*uv;
  
  float scale = mix(0.1, 0.5, sin(fGlobalTime)*0.5 + 0.5);
  float shape = mix(2, 5, sin(fGlobalTime*2)*0.5 + 0.5) ;
  float star = sdStar(uv, scale, 7, shape);
  
   uv=uv0;
   uv = rot(-fGlobalTime)*uv;
   scale = mix(0.1, 0.5, sin(fGlobalTime*2)*0.5 + 0.5);
  float star2 = sdStar(uv, scale *2, 14, shape);
  
  uv=uv0;
     scale = mix(0.1, 0.5, sin(fGlobalTime)*0.5 + 0.5);
  float circle = sdStar(uv, scale * 0.5, 21, 10);
  float scene = max(min(circle, -star),star2);
  color = (1-step(0., scene)) * vec3(0.7,abs(uv.y*2),1.) + step(0.,scene) * vec3(abs(uv.x), 1., 1.);
  color *= mix(0.8,1.2,sin(fGlobalTime*5)*.5+.5);

  
	out_color = vec4(color, 1);
}