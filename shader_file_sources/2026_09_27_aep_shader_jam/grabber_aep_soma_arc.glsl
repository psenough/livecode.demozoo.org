#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAep;
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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec2 circleInv(vec2 p, vec3 c) {
  p = p - c.xy;
  float r2 = c.z * c.z;
  float R2 = dot(p, p);
  return p * r2 / R2 + c.xy;
  }

  
 vec2 polarCoord(vec2 p){
   return vec2(log(length(p)), atan(p.y, p.x));
 }

 float PI = acos(-1.);
 
 float lineA = 5.;
 
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y) * 2.0 - 1.0;
	//uv -= 0.5;
  uv.x *= v2Resolution.x / v2Resolution.y;
	//uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

float tt =  1. * sin(fGlobalTime);
  
  lineA = lineA * tt * 2.0 * 1.2 + 1.;
  
  float vx = sin(fGlobalTime);
  vec2 vpos = vec2(vx, vx * lineA);
  vec2 tangent = normalize(vec2(cos(vpos.y) - lineA * sin(vpos.y), sin(vpos.y) + lineA * cos(vpos.y)));
  vec2 normal = vec2(-tangent.y, tangent.x);
  mat2 basis = mat2(tangent, normal);
  
  vec3 c = vec3(0.1, 0.2, 0.5);
  vec2 coord = exp(vpos.x) * vec2(cos(vpos.y), sin(vpos.y));
  coord = circleInv(coord, c + vec3(sin(fGlobalTime), cos(fGlobalTime), .2));
  //coord = circleInv(coord, c + vec3(0.2, 0.2, 0.));
  uv= 1. * sin(fGlobalTime) * basis * uv + c.xy;
  
  
  //uv *= 0.8 + tt;
  uv = circleInv(uv, c);
  //uv = circleInv(uv, vec3(tt, 0.4, 0.5));
  uv = polarCoord(uv);
 
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  vec3 col;
  float err = uv.y - lineA * uv.x;
  err = mod(err + PI, 2.0 * PI) - PI;
  float ld = abs(err) / sqrt(lineA * lineA + 1.0);
  if(ld < 0.1) {
      col = (t + f).xyz ;
  }
  
	out_color = vec4(col, 0.1);
}