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
	//return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
  return vec4(vec3(c*0.1), 1.0);
}

int hash(int i) {
  i = (i >> 16) ^ (i * 0x45d9f3b);
  i = (i >> 16) ^ (i * 0x45d9f3b);
  i *= 0x45d9f3b;
  return i;
}

int bitmangle_int(int i, int seed, float offset, int maxval) {
  int hashval = hash(int(fGlobalTime*2+offset+seed));
  
  i -= maxval/2;
  bool negative = (i < 0);
  i = abs(i);
  
  //i &= (hashval | (hashval >> 1) | (hashval >> 2) | (hashval >> 3));
  i ^= hashval%maxval;

  if(negative) i=-i;
  i += maxval/2;
  return i;
}

vec4 tunnel(ivec2 ifrag) {
  vec2 uv = vec2(ifrag.x / v2Resolution.x, ifrag.y / v2Resolution.y);
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  //return vec4(uv,0,1);
	vec2 m = vec2(atan(uv.x / uv.y) / 3.14, 1 / length(uv) * .2);
  float d = m.y;
	float f = texture( texFFT, mod(d+fGlobalTime,1) ).r * 20;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	return f + t;
}

void main(void)
{
  vec2 ffrag = gl_FragCoord.xy/v2Resolution;
  //if(ffrag.y < texture(texFFT, ffrag.x).x) {out_color=vec4(1,0,0,0); return;}
  
  ivec2 ifrag = ivec2(gl_FragCoord.xy);
  
  out_color = vec4(0);
  const int steps = 2;
  for(int i = 0; i < steps; i++) {
    ifrag.x = bitmangle_int(ifrag.x, 26724+i, 0, int(v2Resolution.x));
    ifrag.y = bitmangle_int(ifrag.y, 92324+i, 0.5, int(v2Resolution.y));
    //ifrag.y &= ifrag.x;
    //ifrag.x ^= ifrag.y;
    out_color += tunnel(ifrag) / steps;
  }
  
  out_color += 0.75*(texture(texPreviousFrame, ivec2(ifrag.x/*^ifrag.y*/, ifrag.y)/v2Resolution, 0) - out_color);
}
