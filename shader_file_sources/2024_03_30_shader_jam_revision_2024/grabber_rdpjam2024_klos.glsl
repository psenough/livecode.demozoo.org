#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define f float 
#define v2 vec2
#define v3 vec3

#define F gl_FragCoord
#define R v2Resolution
#define T fGlobalTime
// #define R iResolution
// #define T iTime
#define N normalize

#define B (0.01*abs(sin(10.* T)) +0.01*sin(T) +0.005*sin(0.1*T))
#define BI (0.01*T)
#define BS B
// #define B (50.*texture(texFFTSmoothed, 0.).x);

// V A = V(0.2, 0.5, 1.4);

f gB = 10e8;

v3 colA = v3(0.2, 0.5, 1.4);

mat2 rot(f a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

f box(v3 p, v3 b) {
  v3 q = abs(p) -b;
  return length( max(q, v3(0.))) + min( max(max(q.x, q.y), q.z), 0.);
}

f plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  vec4 p = vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
	return dot(p.xyz, p.xyz);
}

f map(v3 p) {
  
  f s = 10e8;
  
  v3 p0 = p; 
  p0.z -= 10.0*T +10*abs(sin(0.1*T)) +20*B;
  s = min( p0.y +1.5 + plas(0.1*p0.xz - 0.1*T, 0.1*BI), -p0.y + 6.);
  
  p0.x  = abs(p0.x);  
  p0.xy *= rot( -0.7);  
  p0.x -= 8.;  
  p0.z = mod(p0.z + 2.0, 4.0) - 2.0;
  s = min(s, box(p0, v3(1.0, 100.0, 1.0)));
  
  
  p -= v3(0, 2., 12. -100.0*BS);
  
  for (f i = 0.; i < 4.; ++i) {
    p -= v3(0.2, 0.6 + 0.5*abs(sin(BI)), 0.6);
    p.xy *= rot(  0.01*T -5*B );
    p.yz *= rot( -0.05*T +10*B);
    p = abs(p);
    
    if (i > 2) {
      p.yz *= rot( 5.*T);
      p.xz *= rot( 1.*T);
    }
    
    f sl = box(p, v3(0.01, 100.0, 0.01));
    s = min(s, sl);
    gB = min(gB, sl);
  }
  
  s = min(s , 
    mix(
      length(p) -0.15 -200.0*B,
      box(p, v3(0.2)),
      0.5 + 0.5*abs(sin(T))
)  );
  
  return s;
}


void main(void)
{
 v3 c = v3(0);
  
  vec2 q = (2.0*F.xy - R.xy) / R.y;
  out_color = vec4(0.);
  if (abs(q.y) > 0.75) return;
  
  v3 ro = v3( 2.0*sin(10.0*BI) + sin(.1*T), 2. + 20.0*B +1.*sin(T), 0);
  v3 rd = N(v3(q, 2.));
  rd.xy *= rot( 0.4*sin(20.0*B) );
  
  // c = v3(q, 0.);
  c = v3(0.);
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
          f str0 = smoothstep(.5, .51, fract(2.33*p.x));
          f str1 = smoothstep(.5, .51, fract(0.1*p.x));
          
          v2 e = 0.001 * v2(-1., 1);
          v3 n = N(
              e.xxx * map(p + e.xxx)
            + e.yxx * map(p + e.yxx)
            + e.xyx * map(p + e.xyx)
            + e.xxy * map(p + e.xxy)
          );
          // c = n;
          f fre = pow(dot(rd, n) + 1., 6.);
          c += colA.zyx * (0.5+0.5*fre) * (str0+str1);
        
          rd = N(reflect(rd, n) + 0.01 * fract(sin(100.0*p) * 43758.5453));
          ro = p;
      }  
  } 
  // c = v3(1.0 - (t / 32.));
  // c = mix(c, N(mix(colA, colA.zyx, sin(20.0*(t / 32.)))), sin(T));
  
  c = mix(c, 0.01*colA, 1.0 - exp(-0.01 *tt*tt));
  
  f sb = 2. + 80.0*BS + 20.0*B + 0.1*pow((1.-fract(7.5*T)), 4.) * smoothstep(0., 1., fract(T));;
  c += sb * colA * exp(gB * -20.0);
  c += sb * colA * exp(gB * -10.0);
  c += sb * colA * exp(gB * -2.0);
  c += sb * colA * exp(gB * -1.0);
  c += 20.0*B;
  c += 0.3 * pow((1.-fract(7.5*T)), 4.) * smoothstep(0., 1., fract(T));
  
  
  c = c / (1. + c);
  c = pow(c, v3(0.4545));
  c = pow(c, v3(2.));
  out_color = c.xyzz;
}