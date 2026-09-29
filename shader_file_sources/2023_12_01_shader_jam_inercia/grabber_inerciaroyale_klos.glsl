#version 420 core

// cheers from klos / k2

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

#define f float
#define v3 vec3
#define v2 vec2
#define T fGlobalTime
#define N normalize
#define B_0 8.4
#define B (texture(texFFT, .0).x)
#define BI (texture(texFFTIntegrated, 0.).x)
// #define BS (texture(texFFTSmoothed, 0.).x)
#define BS ( smoothstep(0.5, 1., fract(T/(.5))) )

f gB = 10e8;

v3 colA = v3(0.2, 0.5, 1.4);

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

f noise(v3 p) {
  return plas(p.xy, p.z).x;
}

mat2 rot(f a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

f box(v3 p, v3 b) {
  v3 q = abs(p) -b;
  return length( max(q, v3(0.))) + min( max(max(q.x, q.y), q.z), 0.);
}

float map(vec3 p) {
  p.z -= 8.;
  float s = p.y +0.2*plas(0.05*p.xz, T).x +0.1*plas(0.2*p.xz, 2.*T).x;

    
  v3 p4 = p; 
  p4.z -= 8.;
  f s2 = box(p4, vec3(0.05, 100, .05));
  s = min( s, s2 );
  gB = min(gB, s2 );
  
  p.y -= .5;
  
  v3 p1 = p;
  p1.z += 20.*T; 
  
  v3 p3 = p1;
  if (p.z < 1.) {    
    p3.x -= 0.5*T;
    v3 p3f = fract(p3);
    v3 p3i = p3 - p3f;
    p3 = mod(p3 + .5, 1.0) -.5;    
    p3 += 0.5*noise(p3i);
    s = min(s, length(p3) - .01);  
  }
  
  p1.x = abs(p1.x);
  p1.x -= 1.5;
  p1.z = mod(p1.z + 2.0, 4.0) -2.0;
  p1.xy *= rot(0.8);
  s = min(s, box(p1, vec3(0.2, 10, .1)) );  
  
  p.z -= 5 + 5.*sin(5.*T);
  
  v3 p2 = p;
  p2.y -= 1.;
  p2.y -= BS * 1.;
  for (float i = 0; i < 4; i += 1) {
    p2 -= vec3(0.2, 0.33, 1.);
    
    p2.xy *= rot(.1 * BS + 1.*T);
    p2.zy *= rot(-0.1 * B + 5. * T);
    p2 = abs(p2);
  
    s = min(s, length(p2) - .1);  
    if (i > 2.) {
      f s1 = box(p2, vec3(0.01, 100, .01));
      s = min( s, s1 );
      gB = min(gB, s1 );
    }
  }  
   
  return s;
}

vec3 render(v2 p, f T) {
  v3 c = v3(0.);
  
  v3 ro = v3(1.2*sin(T), 1.0, 0.);
  ro.y += 1.*BS;
  v3 rd = N(v3(p, 2.));
  rd.xy *= rot( 0.2*sin(2.0*T) );
  f t = 0.2;

  f tt = 10e8;
  for (f bi = 0.; bi < 4.; ++bi) {
    for (f i = 0.; i < 64.; ++i) {
      f d = map(ro + rd * t);    
      if (d < 0.0001 || t > 40.) break;
      t += d;
    }  
     tt = bi == 0. ? t : tt;
      if (t > 0.1 && t < 40.0) {
          v3 p = ro + rd * t;
          f str0 = smoothstep(.5, .51, fract(.33*p.x));
          f str1 = smoothstep(.5, .51, fract(1.*p.x));
          
          v2 e = 0.002 * v2(1., -1);
          v3 n = N(e.xyy * map(p + e.xyy) +
                   e.yyx * map(p + e.yyx) +
                   e.yxy * map(p + e.yxy) +
                   e.xxx * map(p + e.xxx));
       
          // c = n;
          f fre = pow(dot(rd, n) + 1., 6.);
          c += colA.zyx * (0.5+0.5*fre) * (str0+str1);
        
          rd = N(reflect(rd, n) + 0.01 * fract(sin(100.0*p) * 43758.5453));
          ro = p;
      }  
  } 

  
  // c = v3(1.0 - (t / 32.));
  // c *= colA;
  
  c = mix(c, 0.01*colA, 1.0 - exp(-0.005 *tt*tt));
  
  // v3 g = colA.yxz * 10. * B;
  v3 g = v3( smoothstep(0.9, 1.0, BS) );
  g += colA.yxz * exp(gB * -20.0);
  g += colA.yxz * exp(gB * -10.0);
  g += colA.yxz * exp(gB * -5.0);
  g += colA.yxz * exp(gB * -1.0);
  c += g;
  
  return c;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec2 p = uv; 
  
  // out_color.xyz = vec3(uv, 0.);
  // out_color.xyz = vec3(p, 0.);
  // out_color.xyz = rd;
    
  v3 c = v3(0.);
  out_color.xyz = c;
  if (abs(p.y) > 0.45) {
    // c = v3(1) * plas(uv, T).x;
    out_color.xyz = c;
    return;
  };
  
  
  f shift = BS;
  v3 cr = render(p *v2(mix(1.,-0.995, shift), 1.), T) * v3(1,0.2,0);
  v3 cb = render(p *v2(mix(1., 0.995, shift), 1.), T) * v3(0,0.2,1);
  
  c = cr + cb;
  
  c = c / (1. + c);
  c = pow(c, v3(0.4545));
  
  out_color.xyz = c;
}
