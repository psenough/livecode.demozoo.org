#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything





#define TAU 6.2831853071795864769
#define PI  3.1415926535897932384
float t = fGlobalTime;
#define sat(a) clamp(a, 0., 1.)
float hash11(float seed) { return fract(sin(seed*123.456789)*123.456); }
float sin3(float x) { return sin(x)*sin(x)*sin(x); }
float tsin(float x) { return tan(sin(x))/tan(1.); }
float ststs(float x) { return sin(tan(sin(tan(sin(x))))); }
float s3c3(float x) { return sin(x)*sin(x)*sin(x)+cos(x)*cos(x)*cos(x); }
float ass(float x) { return asin(sin(x))/(PI/2.); }
float cir(float x) { return -sign(mod(.5*x,2.)-1.)*sin(acos(mod(x, 2.) - 1.)); }
float stshc(float x) { return sin(tan(sinh(cos(x)))); }
float wtf(float x) { return -1.+2.*fract(atan(atanh(fract(x*.5))/tan(x*.5))); }
vec4 polar(vec2 v) { return vec4(length(v), 0., 0., atan(v.y, v.x)); } // r=radius, a=angle
mat2 rot(float a) { float c=cos(a), s=sin(a); return mat2(c, s, -s, c); }
vec4 textu(sampler2D s, vec2 uv, bool wrap) {
    vec2 size = textureSize(s,0);
    float ratio = size.x/size.y;
    vec2 uv2 = uv * vec2(1,-1*ratio);
    if (!wrap) uv2 = clamp(uv2, -.5, .5);
    return texture(s, uv2 - .5);
}
vec4 textu2(sampler2D s, vec2 uv, bool wrap) {
    vec2 size = textureSize(s,0);
    float ratio = size.x/size.y;
    vec2 uv2 = uv * vec2(1,-1*ratio);
    if (!wrap) uv2 = clamp(uv2, -.5, .5);
    return texture(s, uv2 - .5);
}




float map(vec3 p) {
  return length(p);
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
  vec4 pol = polar(uv);
  vec3 col = vec3(0);

vec3 co=vec3(1,2,4);
  vec2 ttuv = uv;
  ttuv *= rot(t*1.7);
  ttuv /= 1.5;
  //ttuv /= .5+.5*s3c3(t*3.1);
  vec4 ttex = textu(texRevisionBW, ttuv, false);
  t += ttex.r;
  co.x -= ttex.r*1.7;
  
  vec2 tuv = uv;
  tuv /= .5+.5*s3c3(t*3);
  vec4 tex = textu(texEwerk, tuv, false);
  //col = mix(col,tex.rgb,tex.a);
  vec2 tttuv = uv;
  //tttuv /= .5+.5*s3c3(t*3);
  tttuv /= 6 + 2.*abs(sin3(fGlobalTime*8));
  tttuv.y -= -.185;
  vec4 texx = textu2(texEvilbotTunnel, tttuv, false);
  //col = mix(col,tex.rgb,tex.a);
  tex=texx;

  col += tex.xyz;

  uv *=rot(t*.2 + length(uv) + sin(t*.3)*.2);
  float ff = sin(uv.x * 50) + sin(uv.y) * 70;
  ff = 1 / cos(ff);
  col = (.7*sin(co+ff+fGlobalTime+pol.a*90));

  col = mix(col, tex.xyz, tex.a);

  vec3 ro = vec3(0,0,-5);
  vec3 rd = vec3(uv, 1);
  vec3 p = ro;
  for(float i=0;i<100;i++) {
    float d = map(p);
    if (d < .001){
      col = vec3(0);
      break;
    }
    p += d * rd;
  }

	out_color = vec4(col,1);
}