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

const float M_PI = 3.14159;

float smin( float a, float b, float k )
{
    k *= log(2.0);
    float x = b-a;
    return a + x/(1.0-exp2(x/k));
}

float pMod1(inout float p, float size) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	return c;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rotate(float phi) {
  return mat2(cos(phi), sin(phi), -sin(phi), cos(phi));
}

float beat() {
  return fGlobalTime * 126. / 60.;
}

float wobble(float s) {
  return 0.5 + 0.5 * sin(beat() * M_PI / 2. * s);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p) {
  
  p.y += 1.;
  //p.x += beat() * 0.5;
  p.yz = rotate(0.2) * p.yz;
  //p.yz = rotate(beat() * M_PI / 2.) * p.yz;
  pMod1(p.z, 0.2 + 2. * wobble(2.));
  pMod1(p.x, 0.4 + 2. * wobble(1.));
  
  
  p.xy = rotate(beat() * M_PI / 8.) * p.xy;
  p.y += 0.2 * sin(p.z + beat() * M_PI / 2.);
  
  float bol = length(p) - 0.25;
  
  float box = sdBox(p, vec3(1., 0.1, 0.1));
  
  return mix(box, bol, wobble(0.25));
}

vec3 normal(vec3 p) {
  return normalize(vec3(
    map(p - vec3(0.001, 0., 0.)) - map(p + vec3(0.001, 0., 0.)),
    map(p - vec3(0., 0.001, 0.)) - map(p + vec3(0., 0.001, 0.)),
    map(p - vec3(0., 0., 0.001)) - map(p + vec3(0., 0., 0.001))
  ));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv0 = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  vec3 ro = vec3(0., 0., -5.);
  vec3 rd = normalize(vec3(uv, 1.));
  vec3 ld = normalize(vec3(1., 1., 1.));
  vec3 col = vec3(0., 0., 0.);
  
  
  
  float t = 0., d, l = 1.;
  vec3 p, n;
  bool hit = true;
  for (int i = 0; i < 50; i++) {
    p = ro + t * rd;
    d = map(p);
    if (d < 0.001) {
      col = vec3(1.);
      n = normal(p);
      l = dot(n, ld);
      break;
    }
    t += d;
  }
  
  vec3 rb = mix(vec3(0.3, 0.2, 1.), vec3(1., 0.5, 0.), uv.x * 2);
  
  out_color = vec4(col * l * rb, 1.);
  
  out_color += 0.9 * texture(texPreviousFrame, uv0 + vec2(-0.005, -0.002) * texture(texFFTIntegrated, 0.2).x);

}