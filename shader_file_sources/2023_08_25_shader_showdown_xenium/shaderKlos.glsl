#version 410 core

// cheers to k2! 

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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


#define f float
#define v3 vec3
#define T fGlobalTime

v3 A = v3(0.2, 0.6, 1.2);

f g = 10e8;

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(f a) { return mat2(cos(a), sin(a), -sin(a), cos(a)); }

f box(v3 p, v3 b) {
  v3 q = abs(p) - b;
  return length(max(q, 0.)) + min(max(max(q.x, q.y), q.z), 0.);
}

f map(v3 p) {
  
  // p.z += 0.1*T;
 
  f s = p.y +1. -dot(plas(0.2*p.xz, T).x, plas(0.5*p.xz, T).y) ;
  
  p.z -= 8.; 
  p.z -= 8. + 3.*sin(20.*T);
  p.y -= abs(sin(7.5*T));
  
  // p.
  
  for (f i = 0.; i < 4. ; ++i)  {
    p = abs(p);
    p -= v3(0.2, 0.4, 1.);
    p.xy *= rot(4.*T);
    p.zy *= rot(2.33*T);
  }
  f s2 = box(p, v3(10., 0.1, 0.1));
  
  f s1 = length(p) -0.2 + 0.1*sin(T);
  g = min(g, s1);
  s = min(s, s1);
  s = min(s, s2);
  
  return s;
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1); 
  
  if (abs(uv.y) > 0.4) { return; }

  v3 c = v3(0);
  
  v3 ro = v3(0);
  ro.x += 1.5*sin(.8*T);
  v3 rd = normalize(v3(uv, 2));
  rd.xy *= rot(0.2*sin(T));
  
  
  f t = 0;
  f d = 0;
  
  for ( f i = 0.; i < 64.; ++i) {
      d = map( ro + rd * t);
      t += d;
      if (d < 0.001 || t > 20.) {
        break;
      }
  c = vec3(mix(A + abs(0.5*sin(2.*T)), A.yxz, t/32.) );
  }

  
  c += exp(g - 10);
  
  
  out_color = vec4(c, 1.);
  
/*
	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
*/  
}