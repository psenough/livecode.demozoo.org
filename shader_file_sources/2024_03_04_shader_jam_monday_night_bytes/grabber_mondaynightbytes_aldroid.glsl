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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

float hash(vec2 uv) {
  vec3 p=mod(uv.xyx + vec3(345.23,237.32,565.2),vec3(7,3,5));
  p += dot(p,p.yxz +34.32);
  return fract((p.x+p.y)+p.z);
}

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 2.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

vec2 min2(vec2 a, vec2 b) {
  return a.x<b.x ? a:b;
}

float ran=0;
vec2 map(vec3 p) {
  float circ = length(p)-5;
  float toob = 1e7;
  float loob = 1e7;
  for (int i=0; i < 5; ++i) {
      
    p.xz *= rot(0.5 +sin(fGlobalTime*3)*.2);
    p.yz *= rot(4.4+sin(fGlobalTime*3.21)*.14);
    toob = min(length(p.xy) -1.+texture(texFFT,0.04).x*10,toob);
    loob = min(length(p.xy) -0.1,loob);
    
  }
  ran = min(ran,loob);
  return min2(min2(
  vec2(max(circ,-toob),0),
  vec2(length(p)-4,1))   ,
  vec2(loob,2))
   ;
}

vec3 sky(vec3 p) {
  
	vec2 m = -p.xz;
  m +=vec2(sin(p.y),cos(p.y));
	float d = m.y;

	float f = max(0,1-texture( texFFTSmoothed, d ).r * 100);
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec3 t = plas( m * 3.14, fGlobalTime ) / d;
  t = floor(t*10)/10;
	t = clamp( t, 0.0, 1.0 );
  t = t.xyx;
  return f+t;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float bfft = texture(texFFT,0.1).x;
  vec3 ro=vec3(sin(fGlobalTime),cos(fGlobalTime*0.9),-10+bfft*20),rd=normalize(vec3(uv,1));
  float t=0;
  vec2 d;
  
  
  
  for (int i=0;i<100; ++i) {
    d=map(ro+rd*t);
    if (d.x<0.01 && d.y==0) {
      rd=reflect(rd,gn(ro+rd*t));
      t+=0.1;
    }
    t+=d.x;
  }
  
  vec3 col = sky(rd);
  
  if (d.x<0.01) {
    vec3 bcol = vec3(0,0.3,0.5)*texture(texFFT,0.1).x;

    col=vec3(bcol*10);
  } 
  col *= hash(uv)*1.-length(uv);
  col = pow(col,vec3(.45));
  col += exp(1-ran*ran*0.01);
	out_color = vec4(col,1.0);
}