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


mat2 rot( float a )
{
  float c= cos(a);
  float s = sin(a);
  return mat2( c, -s, s, c ); 
  }

  float sea(vec3 p)
  {
    return abs(p.y +1. + texture( texNoise,p.xz*.08 +.1*fGlobalTime).x);
    }
  
float map( vec3 g)
{
  vec3 p =g;
  
  
  vec3 z = p;
 p.xy *= rot( p.z);
  float d =  cos( p.x ) + cos (p.y ) + cos( p.z);
  
  
  d = min ( d, sea( p*.1) ); 
  
  return d;
}

float prout(float x) {
 const float c1 = 1.70158;
const float c2 = c1 * 1.525;

return x < 0.5
  ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
  : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;

}

vec3 grad( vec3 p, float d ){
  vec2 e = vec2( .001, 0.0);
  
  return normalize( vec3( map( p +e.xyy)-d, map( p + e.yxy )-d, map( p +e.yyx)-d ));
  
  }

vec3 rm( vec3 ro, vec3 rd, out float st )
{
  vec3 p = ro;
  st = 0.;
  
  for ( float i = 0.0 ; i < 128.0; ++i )
  {
    float d = map( p );
    if ( d < .01 )
    {
      return p;
    }      
    p+= d * rd;
    st += 1. / 128.;
   }
  return p;
  
 }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3( 0.,0.,fGlobalTime +fract(prout( fGlobalTime )));
  vec3 rd = normalize( vec3 ( uv, 1.0) ); 
  float st = 0.;
  vec3 p = rm( ro, rd, st );
  float d = map( p );
  vec3 n = grad( p, d );
  vec3 rd2 = reflect( n, rd) ;
  vec3 ro2 = p + rd2*.02; 
  vec3 c = clamp( n, 0., 1. ) * st;
  
  float st2 ;
  vec3 p2 = rm( ro2, rd2, st2 );
  vec3 n2 = grad( p2, map( p2 ) );
  c = max( c, clamp( n2, 0., 1. ) * st2 );
	out_color = vec4( c, 1.0);
}