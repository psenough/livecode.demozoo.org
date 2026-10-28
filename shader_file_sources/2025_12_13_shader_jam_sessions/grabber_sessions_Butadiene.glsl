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

vec3 getTexture(vec2 uv){
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions,uv*vec2(1,-1*ratio)-.5).rgb;
}

mat2 rot(float r){
  return mat2(cos(r),sin(r),-sin(r),cos(r));}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    vec4 fi = 0.04*texture(texFFTIntegrated,0.);
  float as = 0.4;
  float ax = fract(fi.r*as);
  ax = pow(ax,2.0);
  fi.r = (ax+floor(fi.r*as))/as;

  uv -= 0.5;
  uv *= rot(fi.r*4.);
  uv += 0.5;
  vec2 uv_tex = uv;
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
  vec3 col = vec3(0.);
  if((uv_tex.y>1./3.&&uv_tex.y<2./3.)||(uv_tex.y>1.||uv_tex.y<0.)){
     col = getTexture(vec2(uv.x+fi.r,uv.y)*(1.0+0.002*f));
    col.gb *= 0.5;
  }else{
       col = getTexture(vec2(uv.x-fi.r,uv.y));

      col.r *= 0.5;
    }
  out_color = vec4(col,1.0);
	//out_color = f + t;
}